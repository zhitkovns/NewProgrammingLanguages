import Foundation
import Network

let host = NWEndpoint.Host("127.0.0.1")
let port = NWEndpoint.Port(rawValue: 8080)!
let connection = NWConnection(host: host, port: port, using: .tcp)

let semaphore = DispatchSemaphore(value: 0)
let lock = NSLock()
var completed = false

func finish(_ message: String) {
    lock.lock()
    if completed {
        lock.unlock()
        return
    }
    completed = true
    lock.unlock()
    print(message)
    semaphore.signal()
}

connection.stateUpdateHandler = { state in
    switch state {
    case .ready:
        print("connected")
        let message = "Hello from Swift client".data(using: .utf8)!
        connection.send(content: message, completion: .contentProcessed { error in
            if let error = error {
                finish("send error: \(error)")
            }
        })
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, _, error in
            if let error = error {
                finish("receive error: \(error)")
            } else if let data = data, let response = String(data: data, encoding: .utf8) {
                finish("received: \(response)")
            } else {
                finish("received empty data")
            }
        }
    case .failed(let error):
        finish("connection failed: \(error)")
    case .waiting(let error):
        print("waiting: \(error)")
    default:
        break
    }
}

DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
    finish("timeout")
}

connection.start(queue: .global())

if semaphore.wait(timeout: .now() + 10) == .timedOut {
    print("main timeout")
}

connection.cancel()