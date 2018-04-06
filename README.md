# SilverCord-iOS-client
iOS client databinding used as part of SilverCord arhitecture

## Binder protocol

```swift
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
```

## SocketProvider

```swift 
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
```
