import PostgreSQL
import WebSocket
import Vapor

func chatterHandler(_ ws: WebSocket, req: Request) throws {
    let channelName: String = try req.parameter()
    let logger = try req.make(Logger.self)
    let database = try req.make(PostgreSQLDatabase.self)
    var subscriptionClient: PostgreSQLConnection? = nil

    // Subscribe to channel
    guard let loop = MultiThreadedEventLoopGroup.currentEventLoop else { return }
    _ = database
        .makeConnection(on: loop)
        .map(to: Void.self, { conn in
            _ = try conn.listen(channelName, handler: { text in
                ws.send(text)
            })
            subscriptionClient = conn
        }).catch({ err in
            logger.error("Error connecting \(err)")
        })

    ws.onText({ text in
        _ = req.connect(to: .psql).map(to: Void.self, { conn in
            _ = try conn.notify(channelName, message: text)
        })
    })

    ws.onClose {
        subscriptionClient?.close()
        logger.info("Socket disconnected \(channelName)")
    }
}
