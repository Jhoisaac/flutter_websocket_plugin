//
//  StreamManager.swift
//  websocket_manager
//
//  Created by Luan Almeida on 15/11/19.
//

import Starscream

@available(iOS 9.0, *)
class StreamWebSocketManager: NSObject, WebSocketDelegate {
    var ws: WebSocket?
    var updatesEnabled = false

    var messageCallback: ((_ data: String) -> Void)?
    var closeCallback: ((_ data: String) -> Void)?
    var conectedCallback: ((_ data: Bool) -> Void)?

    var enableRetries: Bool = true

    override init() {
        super.init()

        // print(">>> Stream Manager Instantiated")
    }

    required init(coder _: NSCoder) {
        fatalError(">>> init(coder:) has not been implemented")
    }

    func areUpdateEnabled() -> Bool { return updatesEnabled }

    func create(url: String, header: [String: String]?, enableCompression _: Bool?, disableSSL _: Bool?, enableRetries: Bool) {
        print("34 StreamWebSocketManager: create() executed!")
        var request = URLRequest(url: URL(string: url)!)
        if header != nil {
            for key in header!.keys {
                request.setValue(header![key], forHTTPHeaderField: key)
            }
        }
        self.enableRetries = enableRetries
        print("42 request.allHTTPHeaderFields es: \(request.allHTTPHeaderFields as Any)")
        ws = WebSocket(request: request)
        ws?.delegate = self
//        if(enableCompression != nil) {
//            ws?.enableCompression = enableCompression!
//        } else {
//            ws?.enableCompression = true
//        }
//        if(disableSSL != nil) {
//            ws?.disableSSLCertValidation = disableSSL!
//        } else {
//            ws?.disableSSLCertValidation = false
//        }
        onConnect()
        onClose()
    }

    func onConnect() {
        print("60 StreamWebSocketManager: onConnect() executed!")
        ws?.onConnect = {
             print("62 StreamWebSocketManager:ws?.onConnect opened")
            if self.conectedCallback != nil {
                (self.conectedCallback!)(true)
            }
        }
    }

    func connect() {
        print("70 StreamWebSocketManager: connect() executed!")
        onText()
        ws?.connect()
    }

    func disconnect() {
        print("76 StreamWebSocketManager: disconnect() executed!")
        enableRetries = false
        ws?.disconnect()
    }

    func send(string: String) {
        print("76 StreamWebSocketManager: disconnect() executed!")
        ws?.write(string: string)
    }

    func onText() {
        print("76 StreamWebSocketManager: disconnect() executed!")
        ws?.onText = { (text: String) in
            // print("recv: \(text)")
            if self.messageCallback != nil {
                (self.messageCallback!)(text)
            }
        }
    }

    func onClose() {
        print("97 StreamWebSocketManager: onClose() executed! attached listener :)")
        ws?.onDisconnect = { (error: Error?) in
             print("99 close \(String(describing: error).debugDescription)")
             print("100 ws?.onDisconnect self.enableRetries es: \(self.enableRetries)");
            if self.enableRetries {
                print("102 StreamWebSocketManager: enableRetries() enter!")
                self.connect()
            } else {
                print("105 StreamWebSocketManager: self.conectedCallback != nil es: \(self.conectedCallback != nil)")
                if self.conectedCallback != nil {
                    print("107 StreamWebSocketManager: (self.conectedCallback!)(false) executed!")
                    (self.conectedCallback!)(false)
                }
                print("110 StreamWebSocketManager: self.closeCallback != nil es: \(self.closeCallback != nil)")
                if self.closeCallback != nil {
                    if error != nil {
                        if error is WSError {
                             print("Error message: \((error as! WSError).message)")
                        }
                        (self.closeCallback!)("false")
                        print("117 close callback calling false")
                    } else {
                        (self.closeCallback!)("true")
                        print("120 close callback calling true")
                    }
                } else {
                    print("124 close callback is nil")
                }
            }
        }
    }

    func isConnected() -> Bool {
        if ws == nil {
            return false
        } else {
            return ws!.isConnected
        }
    }

    func echoTest() {
        print("105 StreamWebSocketManager: echoTest() executed!")
        var messageNum = 0
        ws = WebSocket(url: URL(string: "wss://echo.websocket.org")!)
        ws?.delegate = self
        let send: () -> Void = {
            messageNum += 1
            let msg = "\(messageNum): \(NSDate().description)"
            // print("send: \(msg)")
            self.ws?.write(string: msg)
        }
        ws?.onConnect = {
            // print("opened")
            send()
        }
        ws?.onDisconnect = { (_: Error?) in
            // print("close")
        }
        ws?.onText = { (_: String) in
            // print("recv: \(text)")
            if messageNum == 10 {
                self.ws?.disconnect()
            } else {
                send()
            }
        }
        ws?.connect()
    }

    func websocketDidConnect(socket _: WebSocketClient) {
        //
    }

    func websocketDidDisconnect(socket _: WebSocketClient, error _: Error?) {
        //
    }

    func websocketDidReceiveMessage(socket _: WebSocketClient, text _: String) {
        //
    }

    func websocketDidReceiveData(socket _: WebSocketClient, data _: Data) {
        //
    }
}
