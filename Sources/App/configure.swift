import Vapor
import PostgreSQL

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(PostgreSQLProvider())


    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    configureWebsockets(&services)
    try configureDatabase(&services)
}

func configureWebsockets(_ services: inout Services) {
    let websockets = EngineWebSocketServer.default()
    websockets.get("socket", String.parameter, use: chatterHandler)
    services.register(websockets, as: WebSocketServer.self)
}


private func configureDatabase(_ services: inout Services) throws {
    let defaultConfig = PostgreSQLDatabaseConfig.default()
    let databaseHostname = ProcessInfo.processInfo.environment["DATABASE_HOSTNAME"] ?? defaultConfig.hostname
    let databasePort = ProcessInfo.processInfo.environment["DATABASE_PORT"]?.intValue ?? defaultConfig.port
    let databaseUsername = ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ??  defaultConfig.username

    let databasePassword = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"]
    let databaseName = ProcessInfo.processInfo.environment["DATABASE_NAME"] ??  defaultConfig.database

    let databaseConfig = PostgreSQLDatabaseConfig(hostname: databaseHostname,
                                                  port: databasePort,
                                                  username: databaseUsername,
                                                  database: databaseName,
                                                  password: databasePassword)

    let database = PostgreSQLDatabase(config: databaseConfig)

    var databases = DatabaseConfig()
    databases.add(database: database,
                  as: .psql)
    services.register(databases)
    services.register(database)
}
