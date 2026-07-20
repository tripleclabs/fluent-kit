@preconcurrency import Benchmark
import FluentPostgresDriver
import FluentSQL
import Foundation
import Logging

final class PostgresBenchmarkContext: @unchecked Sendable {
    let databases: Databases
    let database: any Database
    let sql: any SQLDatabase

    private init(databases: Databases, database: any Database) {
        self.databases = databases
        self.database = database
        self.sql = database as! any SQLDatabase
    }

    static func start() async throws -> PostgresBenchmarkContext {
        guard let url = ProcessInfo.processInfo.environment["FLUENT_BENCHMARK_DATABASE_URL"],
              !url.isEmpty
        else {
            throw BenchmarkSetupError.missingDatabaseURL
        }

        let databases = Databases(
            threadPool: .singleton,
            on: MultiThreadedEventLoopGroup.singleton
        )
        databases.use(
            try .postgres(
                url: url,
                maxConnectionsPerEventLoop: 1,
                // The benchmark logger's default level is `.info`, so trace-level SQL
                // logging is disabled without paying to format each query.
                sqlLogLevel: .trace
            ),
            as: .psql
        )

        let logger = Logger(label: "codes.vapor.fluent.performance-benchmark")
        guard let database = databases.database(
            .psql,
            logger: logger,
            on: databases.eventLoopGroup.any()
        ) else {
            await databases.shutdownAsync()
            throw BenchmarkSetupError.databaseUnavailable
        }

        let context = PostgresBenchmarkContext(databases: databases, database: database)
        do {
            try await context.createFixtures()
            try await context.warmConnectionPool()
            return context
        } catch {
            await databases.shutdownAsync()
            throw error
        }
    }

    func shutdown() async {
        try? await self.sql.raw("DROP SCHEMA IF EXISTS fluentkit_benchmark CASCADE").run()
        await self.databases.shutdownAsync()
    }

    private func createFixtures() async throws {
        try await self.sql.raw("DROP SCHEMA IF EXISTS fluentkit_benchmark CASCADE").run()
        try await self.sql.raw("CREATE SCHEMA fluentkit_benchmark").run()

        try await self.sql.raw("""
            CREATE TABLE fluentkit_benchmark.narrow_models (
                id BIGINT PRIMARY KEY,
                name TEXT NOT NULL,
                score BIGINT NOT NULL
            )
            """).run()
        try await self.sql.raw("""
            INSERT INTO fluentkit_benchmark.narrow_models (id, name, score)
            SELECT i, 'row-' || i, i * 7
            FROM generate_series(1, 1000) AS i
            """).run()

        try await self.sql.raw("""
            CREATE TABLE fluentkit_benchmark.wide_models (
                id BIGINT PRIMARY KEY,
                string_1 TEXT NOT NULL, string_2 TEXT NOT NULL,
                string_3 TEXT NOT NULL, string_4 TEXT NOT NULL,
                string_5 TEXT NOT NULL, string_6 TEXT NOT NULL,
                string_7 TEXT NOT NULL, string_8 TEXT NOT NULL,
                int_1 BIGINT NOT NULL, int_2 BIGINT NOT NULL,
                int_3 BIGINT NOT NULL, int_4 BIGINT NOT NULL,
                int_5 BIGINT NOT NULL, int_6 BIGINT NOT NULL,
                int_7 BIGINT NOT NULL, int_8 BIGINT NOT NULL,
                bool_1 BOOLEAN NOT NULL, bool_2 BOOLEAN NOT NULL,
                double_1 DOUBLE PRECISION NOT NULL,
                double_2 DOUBLE PRECISION NOT NULL
            )
            """).run()
        try await self.sql.raw("""
            INSERT INTO fluentkit_benchmark.wide_models
            SELECT
                i,
                'value-' || i, 'value-' || i, 'value-' || i, 'value-' || i,
                'value-' || i, 'value-' || i, 'value-' || i, 'value-' || i,
                i, i + 1, i + 2, i + 3, i + 4, i + 5, i + 6, i + 7,
                i % 2 = 0, i % 3 = 0, i * 1.25, i * 2.5
            FROM generate_series(1, 1000) AS i
            """).run()

        try await self.sql.raw("""
            CREATE TABLE fluentkit_benchmark.parent_models (
                id BIGINT PRIMARY KEY,
                name TEXT NOT NULL
            )
            """).run()
        try await self.sql.raw("""
            CREATE TABLE fluentkit_benchmark.child_models (
                id BIGINT PRIMARY KEY,
                parent_id BIGINT NOT NULL,
                name TEXT NOT NULL,
                payload TEXT NOT NULL
            )
            """).run()
        try await self.sql.raw("""
            INSERT INTO fluentkit_benchmark.parent_models (id, name)
            SELECT i, 'parent-' || i
            FROM generate_series(1, 100) AS i
            """).run()
        try await self.sql.raw("""
            INSERT INTO fluentkit_benchmark.child_models (id, parent_id, name, payload)
            SELECT
                ((parent_id - 1) * 10) + child_number,
                parent_id,
                'child-' || parent_id || '-' || child_number,
                repeat('x', 64)
            FROM generate_series(1, 100) AS parent_id
            CROSS JOIN generate_series(1, 10) AS child_number
            """).run()
        try await self.sql.raw("""
            CREATE INDEX child_models_parent_id_idx
            ON fluentkit_benchmark.child_models (parent_id)
            """).run()
    }

    private func warmConnectionPool() async throws {
        for _ in 0..<10 {
            try await self.sql.raw("SELECT 1").run()
        }
    }
}

enum BenchmarkSetupError: Error, CustomStringConvertible {
    case missingDatabaseURL
    case databaseUnavailable

    var description: String {
        switch self {
        case .missingDatabaseURL:
            "Set FLUENT_BENCHMARK_DATABASE_URL before running PostgreSQL benchmarks."
        case .databaseUnavailable:
            "The PostgreSQL benchmark database could not be created."
        }
    }
}

private final class ContextHolder: @unchecked Sendable {
    var value: PostgresBenchmarkContext?
}

func postgresBenchmark(
    _ name: String,
    configuration: Benchmark.Configuration? = nil,
    _ body: @escaping @Sendable (Benchmark, PostgresBenchmarkContext) async throws -> Void
) {
    let holder = ContextHolder()
    let configuration = configuration ?? .init(
        metrics: [.wallClock, .cpuTotal, .mallocCountTotal, .mallocBytesCount],
        timeUnits: .microseconds,
        warmupIterations: 3,
        maxDuration: .seconds(3),
        maxIterations: 2_000
    )

    Benchmark(
        name,
        configuration: configuration,
        closure: { benchmark, context in
            try await body(benchmark, context)
        },
        setup: {
            let context = try await PostgresBenchmarkContext.start()
            holder.value = context
            return context
        },
        teardown: {
            await holder.value?.shutdown()
            holder.value = nil
        }
    )
}
