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
                        dataObserver?(Self.map(frame))
                    case .connectionClose:
                        errorObserver?(.disconnected)
                        return // return to close channel
                    case .ping, .pong:
                        break
                    default:
                        try await sendClose(code: .unacceptableData)
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
