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

typealias AsyncChannel = NIOAsyncChannel<WebSocketFrame, WebSocketFrame>

actor DefaultWebSocket: WebSocket {
    private var channel: Channel {
        asyncChannel.channel
    }
    
    private var dataObserver: DataObserver?
    private var errorObserver: ErrorObserver?
    private let asyncChannel: AsyncChannel
    
    init(asyncChannel: AsyncChannel) {
        self.asyncChannel = asyncChannel
    }
    
    func setObservers(dataObserver: DataObserver?, errorObserver: ErrorObserver?) async {
        self.dataObserver = dataObserver
        self.errorObserver = errorObserver
        await handleChannel()
    }
    
    func close() async throws {
        try await sendClose(code: .goingAway)
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
    
    func send(data: Data) async throws {
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

// Reference: https://github.com/apple/swift-nio/blob/main/Sources/NIOWebSocketClient/Client.swift
final class NIOWebSocketClient: WebSocketClient {
    func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
        guard let url = request.url,
              let host = url.host(),
              let port = url.port,
              let token = request.value(forHTTPHeaderField: .authorizationField) else {
            throw .invalidURL
        }
        
        do {
            let group = MultiThreadedEventLoopGroup.singleton
            let bootstrap = ClientBootstrap(group: group)
            let connect = try await bootstrap.connect(host: host, port: port) { channel in
                channel.eventLoop.makeCompletedFuture {
                    let promise = channel.eventLoop.makePromise(of: AsyncChannel.self)
                    
                    let upgrader = NIOTypedWebSocketClientUpgrader<Void>(
                        upgradePipelineHandler: { (channel, _) in
                            channel.eventLoop.makeCompletedFuture {
                                promise.succeed(try AsyncChannel(wrappingChannelSynchronously: channel))
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
                    
                    negotiationResultFuture.cascadeFailure(to: promise)
                    return negotiationResultFuture.flatMap {
                        promise.futureResult
                    }
                }
            }
            
            let asyncChannel = try await connect.get()
            return DefaultWebSocket(asyncChannel: asyncChannel)
        } catch let error as WebSocketClientError {
            throw error
        } catch {
            throw .other(error)
        }
    }
}

private extension String {
    static var authorizationField: String { "Authorization" }
}
