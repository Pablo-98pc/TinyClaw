// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TinyClaw",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TinyClawCore", targets: ["TinyClawCore"]),
    ],
    targets: [
        .target(
            name: "TinyClawCore",
            path: "TinyClaw/Core"
        ),
        .target(
            name: "TinyClawStore",
            dependencies: ["TinyClawCore"],
            path: "TinyClaw/Store"
        ),
        .target(
            name: "TinyClawSpecialists",
            dependencies: ["TinyClawCore"],
            path: "TinyClaw/Specialists"
        ),
        .target(
            name: "TinyClawDispatcher",
            dependencies: ["TinyClawCore"],
            path: "TinyClaw/Dispatcher"
        ),
        .target(
            name: "TinyClawTranscriber",
            dependencies: ["TinyClawCore"],
            path: "TinyClaw/Transcriber"
        ),
        .testTarget(
            name: "TinyClawTests",
            dependencies: ["TinyClawCore", "TinyClawStore", "TinyClawSpecialists", "TinyClawDispatcher"],
            path: "TinyClawTests"
        ),
    ]
)
