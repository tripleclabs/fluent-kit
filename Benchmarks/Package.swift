// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "FluentKitBenchmarks",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(path: ".."),
        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            from: "2.12.0"
        ),
        .package(
            url: "https://github.com/ordo-one/benchmark.git",
            from: "1.35.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "FluentPostgresBenchmarks",
            dependencies: [
                .product(name: "Benchmark", package: "benchmark"),
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "FluentSQL", package: "fluent-kit"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            ],
            path: "Benchmarks/FluentPostgresBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "benchmark"),
            ]
        ),
    ]
)
