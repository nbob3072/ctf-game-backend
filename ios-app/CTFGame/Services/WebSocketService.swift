import Foundation

class WebSocketService: NSObject {
    static let shared = WebSocketService()
    
    // MARK: - Configuration
    // WebSocket disabled in production (no Redis on Railway free tier)
    // When Redis is added, use: wss://ctf-game-backend-production.up.railway.app
    private let wsURL = "wss://ctf-game-backend-production.up.railway.app"
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var isConnected = false
    private var reconnectTimer: Timer?
    private var pingTimer: Timer?
    
    // Callbacks
    var onFlagUpdate: (([String: Any]) -> Void)?
    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    
    private override init() {
        super.init()
        setupSession()
    }
    
    // MARK: - Setup
    
    private func setupSession() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }
    
    // MARK: - Connection
    
    func connect() {
        guard !isConnected else {
            Logger.debug("WebSocket already connected")
            return
        }
        
        // Get auth token
        guard let token = KeychainService.shared.load(for: .authToken) else {
            Logger.error("No auth token available for WebSocket connection")
            return
        }
        
        // Build WebSocket URL with token
        var urlComponents = URLComponents(string: wsURL)!
        urlComponents.queryItems = [URLQueryItem(name: "token", value: token)]
        
        guard let url = urlComponents.url else {
            Logger.error("Invalid WebSocket URL")
            return
        }
        
        Logger.debug("Connecting to WebSocket: \(wsURL)")
        
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
        startPingTimer()
    }
    
    func disconnect() {
        Logger.debug("Disconnecting WebSocket")
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        stopPingTimer()
        stopReconnectTimer()
        onDisconnected?()
    }
    
    // MARK: - Messaging
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage() // Continue listening
                
            case .failure(let error):
                Logger.error("WebSocket receive error: \(error)")
                self?.handleDisconnection()
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            Logger.debug("WebSocket received: \(text)")
            
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else {
                return
            }
            
            switch type {
            case "connected":
                handleConnected()
                
            case "pong":
                // Heartbeat response
                break
                
            case "flag_update":
                if let flagData = json["data"] as? [String: Any] {
                    onFlagUpdate?(flagData)
                }
                
            case "global_event":
                // Handle global events (future feature)
                break
                
            default:
                Logger.debug("Unknown WebSocket message type: \(type)")
            }
            
        case .data(let data):
            Logger.debug("WebSocket received binary data: \(data.count) bytes")
            
        @unknown default:
            Logger.error("Unknown WebSocket message format")
        }
    }
    
    private func sendMessage(_ message: [String: Any]) {
        guard isConnected else {
            Logger.debug("Cannot send message: WebSocket not connected")
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let text = String(data: data, encoding: .utf8) else {
            Logger.error("Failed to encode WebSocket message")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                Logger.error("WebSocket send error: \(error)")
            }
        }
    }
    
    // MARK: - Actions
    
    func subscribeToFlag(flagId: String) {
        sendMessage([
            "type": "subscribe_flag",
            "flagId": flagId
        ])
    }
    
    func unsubscribeFromFlag(flagId: String) {
        sendMessage([
            "type": "unsubscribe_flag",
            "flagId": flagId
        ])
    }
    
    private func sendPing() {
        sendMessage(["type": "ping"])
    }
    
    // MARK: - Connection Handling
    
    private func handleConnected() {
        Logger.debug("WebSocket connected")
        isConnected = true
        stopReconnectTimer()
        onConnected?()
    }
    
    private func handleDisconnection() {
        Logger.debug("WebSocket disconnected")
        isConnected = false
        webSocketTask = nil
        stopPingTimer()
        onDisconnected?()
        scheduleReconnect()
    }
    
    private func scheduleReconnect() {
        stopReconnectTimer()
        Logger.debug("Scheduling WebSocket reconnect in 5 seconds")
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
    
    // MARK: - Ping/Pong
    
    private func startPingTimer() {
        stopPingTimer()
        
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    // MARK: - Cleanup
    
    deinit {
        disconnect()
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Logger.debug("WebSocket did open")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Logger.debug("WebSocket did close with code: \(closeCode)")
        handleDisconnection()
    }
}
