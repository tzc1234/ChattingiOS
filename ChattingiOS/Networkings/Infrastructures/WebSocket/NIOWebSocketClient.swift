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

typealias AsyncChannel = NIOAsyncChannel<WebSocketFrame, Never>

// Reference: https://github.com/apple/swift-nio/blob/main/Sources/NIOWebSocketClient/Client.swift
actor NIOWebSocketClient: WebSocketClient {
    func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
        guard let url = request.url,
              let host = url.host(),
              let port = url.port,
              let token = request.value(forHTTPHeaderField: .authorizationHTTPHeaderField) else {
            throw .invalidURL
        }
        
        do {
            let eventLoopGroup = MultiThreadedEventLoopGroup.singleton
            let bootstrap = ClientBootstrap(group: eventLoopGroup)
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
                        headers: HTTPHeaders([(.authorizationHTTPHeaderField, token)])
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
