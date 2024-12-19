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

enum WebSocketClientError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case forbidden
    case unknown
    case other(Error)
}

// Reference: https://github.com/apple/swift-nio/blob/main/Sources/NIOWebSocketClient/Client.swift
final class NIOWebSocketClient {
    private enum UpgradeResult {
        case webSocket(NIOAsyncChannel<WebSocketFrame, WebSocketFrame>)
        case notUpgraded(statusCode: EventLoopFuture<HTTPResponseStatus>)
    }
    
    func connect(_ request: URLRequest) async throws(WebSocketClientError) {
        guard let url = request.url,
              let host = url.host(),
              let port = url.port,
              let token = request.value(forHTTPHeaderField: .authorizationField) else {
            throw .invalidURL
        }
        
        let upgradeResult: EventLoopFuture<UpgradeResult>
        do {
            let bootstrap = ClientBootstrap(group: MultiThreadedEventLoopGroup.singleton)
            upgradeResult = try await bootstrap.connect(host: host, port: port) { channel in
                channel.eventLoop.makeCompletedFuture {
                    let upgrader = NIOTypedWebSocketClientUpgrader<UpgradeResult>(
                        upgradePipelineHandler: { (channel, _) in
                            channel.eventLoop.makeCompletedFuture {
                                let asyncChannel = try NIOAsyncChannel<WebSocketFrame, WebSocketFrame>(
                                    wrappingChannelSynchronously: channel
                                )
                                return UpgradeResult.webSocket(asyncChannel)
                            }
                        }
                    )
                    
                    let requestHead = HTTPRequestHead(
                        version: .http1_1,
                        method: .GET,
                        uri: url.path,
                        headers: HTTPHeaders([(.authorizationField, token)])
                    )
                    
                    let clientUpgradeConfiguration = NIOTypedHTTPClientUpgradeConfiguration(
                        upgradeRequestHead: requestHead,
                        upgraders: [upgrader],
                        notUpgradingCompletionHandler: { channel in
                            let promise = channel.eventLoop.makePromise(of: HTTPResponseStatus.self)
                            let hander = HTTPClientResponsePartHandler { promise.succeed($0) }
                            _ = channel.pipeline.addHandler(hander)
                            
                            return channel.eventLoop.makeCompletedFuture {
                                UpgradeResult.notUpgraded(statusCode: promise.futureResult)
                            }
                        }
                    )
                    
                    let negotiationResultFuture = try channel.pipeline.syncOperations
                        .configureUpgradableHTTPClientPipeline(
                            configuration: .init(upgradeConfiguration: clientUpgradeConfiguration)
                        )
                    
                    return negotiationResultFuture
                }
            }
        } catch {
            throw .other(error)
        }
        
        try await handleUpgradeResult(upgradeResult)
    }
    
    private func handleUpgradeResult(_ futureUpgradeResult: EventLoopFuture<UpgradeResult>) async throws(WebSocketClientError) {
        switch try await getUpgradeResult(futureUpgradeResult) {
        case .webSocket(let channel):
            print("Handling websocket connection")
        case .notUpgraded(let futureStatus):
            let status = try await getStatue(futureStatus)
            throw mapError(from: status)
        }
    }
    
    private func getUpgradeResult(_ futureUpgradeResult: EventLoopFuture<UpgradeResult>) async throws(WebSocketClientError) -> UpgradeResult {
        do {
            return try await futureUpgradeResult.get()
        } catch {
            throw .other(error)
        }
    }
    
    private func getStatue(_ futureStatus: EventLoopFuture<HTTPResponseStatus>) async throws(WebSocketClientError) -> HTTPResponseStatus {
        do {
            return try await futureStatus.get()
        } catch {
            throw .other(error)
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
    
    private let status: (HTTPResponseStatus) -> Void
    
    init(_ status: @escaping (HTTPResponseStatus) -> Void) {
        self.status = status
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let response = unwrapInboundIn(data)
        switch response {
        case .head(let responseHead):
            status(responseHead.status)
        case .body, .end:
            break
        }
        context.fireChannelRead(data)
    }
}
