//
//  BinderProtocol.swift
//  SilverCordDemo
//
//  Created by Blaž Jurišić on 28/01/2018.
//  Copyright © 2018 Blaž Jurišić. All rights reserved.
//
import SocketIO

protocol BinderProtocol {
    associatedtype T
    func bindDataToView(data: T)
}

extension BinderProtocol {
    func bind<T: Decodable>(id: String, bindCallback: @escaping (T) -> Void) {
        let action: (SocketIOClient) -> Void = { socket in
            socket.emit("REQ_" + id)
            socket.on("RES_" + id) { data, _ in
                let decoder = JSONDecoder()
                guard let dict = try? JSONSerialization.data(withJSONObject: data[0] as! [String: Any]),
                    let props = try? decoder.decode(T.self, from: dict) else { return }
                bindCallback(props)
                //ack.with("tenks brate")
            }
        }
        guard SocketProvider.isConnected else {
            SocketProvider.onConnect(callback: action)
            return
        }
        action(SocketProvider.defaultSocket)
        
    }
}
