//
//  NIOWebSocketClient.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 19/12/2024.
//

import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket
import NIOFoundationCompat

enum WebSocketClientError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case forbidden
    case unknown
    case disconnected
    case other(Error)
}

actor DefaultWebSocket {
    typealias DataObserver = (Data?) throws -> Void
    typealias ErrorObserver = (WebSocketClientError) -> Void
    
    var channel: Channel {
        asyncChannel.channel
    }
    
    private var dataObserver: DataObserver?
    private var errorObserver: ErrorObserver?
    private let asyncChannel: NIOAsyncChannel<WebSocketFrame, WebSocketFrame>
    
    init(asyncChannel: NIOAsyncChannel<WebSocketFrame, WebSocketFrame>) {
        self.asyncChannel = asyncChannel
    }
    
    func setObservers(dataObserver: @escaping DataObserver, errorObserver: @escaping ErrorObserver) async {
        self.dataObserver = dataObserver
        self.errorObserver = errorObserver
        await handleChannel()
    }
    
    func close(code: WebSocketErrorCode) async throws {
        try await sendClose(code: code)
    }
    
    private func sendClose(code: WebSocketErrorCode) async throws {
        let intCode = UInt16(webSocketErrorCode: code)
        // Code 1005 and 1006 are used to report errors to the application, never send them out.
        let codeToBeSent = if [1005, 1006].contains(intCode) {
            WebSocketErrorCode.normalClosure
        } else {
            code
        }
        
        var buffer = channel.allocator.buffer(capacity: 2)
        buffer.write(webSocketErrorCode: codeToBeSent)
        try await send(buffer: buffer, opcode: .connectionClose)
    }
    
    func send(_ data: Data) async throws {
        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        try await send(buffer: buffer, opcode: .binary)
    }
    
    private func send(buffer: ByteBuffer, opcode: WebSocketOpcode, fin: Bool = true) async throws {
        let frame = WebSocketFrame(fin: fin, opcode: opcode, data: buffer)
        try await channel.writeAndFlush(frame)
    }
    
    private func handleChannel() async {
        do {
            try await asyncChannel.executeThenClose { inbound, _ in
                for try await frame in inbound {
                    switch frame.opcode {
                    case .binary:
                        let data = Self.map(frame)
                        try dataObserver?(data)
                    case .connectionClose:
                        errorObserver?(.disconnected)
                        print("Received Close instruction from server.")
                        return
                    default:
                        errorObserver?(.disconnected)
                        return
                    }
                }
            }
        } catch {
            errorObserver?(.other(error))
        }
    }
    
    private static func map(_ frame: WebSocketFrame) -> Data? {
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        var unmaskedData = frame.unmaskedData
        buffer.writeBuffer(&unmaskedData)
        return buffer.readData(length: buffer.readableBytes)
    }
}

enum UpgradeResult {
    case webSocket(NIOAsyncChannel<WebSocketFrame, WebSocketFrame>)
    case notUpgraded(status: HTTPResponseStatus)
}

// Reference: https://github.com/apple/swift-nio/blob/main/Sources/NIOWebSocketClient/Client.swift
final class NIOWebSocketClient {
    func connect(_ request: URLRequest) async throws(WebSocketClientError) -> DefaultWebSocket {
        guard let url = request.url,
              let host = url.host(),
              let port = url.port,
              let token = request.value(forHTTPHeaderField: .authorizationField) else {
            throw .invalidURL
        }
        
        let group = MultiThreadedEventLoopGroup.singleton
        let promise = group.next().makePromise(of: UpgradeResult.self)
        
        do {
            let bootstrap = ClientBootstrap(group: group)
            let connect = try await bootstrap.connect(host: host, port: port) { channel in
                channel.eventLoop.makeCompletedFuture {
                    let upgrader = NIOTypedWebSocketClientUpgrader<Void>(
                        upgradePipelineHandler: { (channel, _) in
                            channel.eventLoop.makeCompletedFuture {
                                let asyncChannel = try NIOAsyncChannel<WebSocketFrame, WebSocketFrame>(
                                    wrappingChannelSynchronously: channel
                                )
                                promise.succeed(.webSocket(asyncChannel))
                            }
                        }
                    )
                    
                    let requestHead = HTTPRequestHead(
                        version: .http1_1,
                        method: .GET,
                        uri: url.path,
                        headers: HTTPHeaders([(.authorizationField, token)])
                    )
                    
                    let clientUpgradeConfiguration = NIOTypedHTTPClientUpgradeConfiguration<Void>(
                        upgradeRequestHead: requestHead,
                        upgraders: [upgrader],
                        notUpgradingCompletionHandler: { channel in
                            channel.pipeline.addHandler(HTTPClientResponsePartHandler(promise: promise))
                        }
                    )
                    
                    let negotiationResultFuture = try channel.pipeline.syncOperations
                        .configureUpgradableHTTPClientPipeline(
                            configuration: .init(upgradeConfiguration: clientUpgradeConfiguration)
                        )
                    
                    return negotiationResultFuture
                }
            }
            
            let upgradeResult = try await connect.flatMap { promise.futureResult }.get()
            return try await handleUpgradeResult(upgradeResult)
        } catch {
            throw .other(error)
        }
    }
    
    private func handleUpgradeResult(_ upgradeResult: UpgradeResult) async throws(WebSocketClientError) -> DefaultWebSocket {
        switch upgradeResult {
        case .webSocket(let channel):
            return DefaultWebSocket(asyncChannel: channel)
        case .notUpgraded(let status):
            throw mapError(from: status)
        }
    }
    
    private func mapError(from status: HTTPResponseStatus) -> WebSocketClientError {
        switch status {
        case .unauthorized: .unauthorized
        case .notFound: .notFound
        case .forbidden: .forbidden
        default: .unknown
        }
    }
}

private extension String {
    static var authorizationField: String { "Authorization" }
}

private final class HTTPClientResponsePartHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPClientResponsePart
    
    private let promise: EventLoopPromise<UpgradeResult>
    
    init(promise: EventLoopPromise<UpgradeResult>) {
        self.promise = promise
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let response = unwrapInboundIn(data)
        switch response {
        case .head(let responseHead):
            promise.succeed(.notUpgraded(status: responseHead.status))
        case .body, .end:
            break
        }
        
        context.fireChannelRead(data)
    }
}
