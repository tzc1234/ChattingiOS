//
//  DefaultWebSocket.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/12/2024.
//

import Foundation
import NIO
import NIOWebSocket
import NIOFoundationCompat

actor DefaultWebSocket: WebSocket {
    private var channel: Channel { asyncChannel.channel }
    
    private let asyncChannel: AsyncChannel
    let outputStream: AsyncThrowingStream<Data, Error>
    private let continuation: AsyncThrowingStream<Data, Error>.Continuation
    
    init(asyncChannel: AsyncChannel) {
        self.asyncChannel = asyncChannel
        (self.outputStream, self.continuation) = AsyncThrowingStream.makeStream()
    }
    
    func close() async throws {
        try await sendClose(code: .normalClosure)
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
    
    func start() async {
        do {
            try await asyncChannel.executeThenClose { [weak self] inbound in
                for try await frame in inbound {
                    try await self?.handleFrame(frame)
                    
                    if frame.opcode == .connectionClose {
                        return // close the channel
                    }
                }
            }
        } catch {
            continuation.finish(throwing: WebSocketError.other(error))
        }
    }
    
    private func handleFrame(_ frame: WebSocketFrame) async throws {
        switch frame.opcode {
        case .binary:
            continuation.yield(frame.toData)
        case .connectionClose:
            continuation.finish(throwing: WebSocketError.disconnected)
        case .ping, .pong:
            break
        case .continuation, .text:
            fallthrough
        default:
            continuation.finish(throwing: WebSocketError.unsupportedData)
            try await sendClose(code: .unacceptableData)
        }
    }
}

private extension WebSocketFrame {
    var toData: Data {
        Data(buffer: data)
    }
}
