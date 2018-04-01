// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "smoke-signals-postgresql",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/pedantix/postgresql.git", .branch("notify-listen"))
    ],
    targets: [
        .target(name: "App", dependencies: ["PostgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

