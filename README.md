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
                //ack.with("thanks!")
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
    
    static let manager = SocketManager(socketURL: URL(string: "<ENTER_YOUR_URL_HERE>")!, config: [.log(false), .compress])
    
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

## Example of binding to ViewController

```swift
import UIKit

class ViewController: UIViewController, BinderProtocol {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        bind(id: "TIME", bindCallback: self.bindDataToView)
    }
    
    //ovo je potrebno
    typealias T = TimeVCProps
    
    func bindDataToView(data: TimeVCProps) {
        dateLabel.text = data.time
        nameLabel.text = data.name
        timestampLabel.text = "\(data.timestamp)"
    }
}

struct TimeVCProps: Decodable {
    let name: String
    let time: String
    let timestamp: String
}
```
