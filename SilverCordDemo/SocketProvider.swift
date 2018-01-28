//
//  SocketProvider.swift
//  SilverCordDemo
//
//  Created by Blaž Jurišić on 28/01/2018.
//  Copyright © 2018 COBE. All rights reserved.
//
import SocketIO

class SocketProvider {
    
    static let manager = SocketManager(socketURL: URL(string: "wss://silvercord.herokuapp.com")!, config: [.log(false), .compress])
    
    static let defaultSocket = SocketProvider.manager.defaultSocket
    
    static var isConnected = false
   
    static func onConnect(callback: @escaping (SocketIOClient)-> Void) {
        let socket = SocketProvider.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            SocketProvider.isConnected = true
            callback(socket)
        }
    }
    
    static func onDisconnect(callback: @escaping ()-> Void) {
        SocketProvider.defaultSocket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
            SocketProvider.isConnected = false
            callback()
        }
    }
    
    private init() {}
}
