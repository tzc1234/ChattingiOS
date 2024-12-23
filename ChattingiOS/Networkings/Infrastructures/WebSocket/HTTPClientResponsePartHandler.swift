//
//  HTTPClientResponsePartHandler.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/12/2024.
//

import NIO
import NIOHTTP1

final class HTTPClientResponsePartHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPClientResponsePart
    
    private let promise: EventLoopPromise<AsyncChannel>
    
    init(promise: EventLoopPromise<AsyncChannel>) {
        self.promise = promise
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let response = unwrapInboundIn(data)
        switch response {
        case .head(let responseHead):
            promise.fail(mapError(responseHead.status))
        case .body, .end:
            break
        }
        
        context.fireChannelRead(data)
    }
    
    private func mapError(_ status: HTTPResponseStatus) -> WebSocketClientError {
        switch status {
        case .unauthorized: .unauthorized
        case .notFound: .notFound
        case .forbidden: .forbidden
        default: .unknown
        }
    }
}
