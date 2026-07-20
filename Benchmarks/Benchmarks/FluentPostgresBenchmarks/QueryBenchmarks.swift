import Benchmark
import FluentPostgresDriver
import FluentSQL

private func rawNarrowRows(
    _ count: Int,
    using context: PostgresBenchmarkContext
) async throws -> [any SQLRow] {
    switch count {
    case 1:
        try await context.sql.raw("""
            SELECT id, name, score
            FROM fluentkit_benchmark.narrow_models
            ORDER BY id LIMIT 1
            """).all()
    case 100:
        try await context.sql.raw("""
            SELECT id, name, score
            FROM fluentkit_benchmark.narrow_models
            ORDER BY id LIMIT 100
            """).all()
    case 1_000:
        try await context.sql.raw("""
            SELECT id, name, score
            FROM fluentkit_benchmark.narrow_models
            ORDER BY id LIMIT 1000
            """).all()
    default:
        preconditionFailure("Unsupported row count: \(count)")
    }
}

private func rawWideRows(
    _ count: Int,
    using context: PostgresBenchmarkContext
) async throws -> [any SQLRow] {
    switch count {
    case 1:
        try await context.sql.raw("""
            SELECT * FROM fluentkit_benchmark.wide_models
            ORDER BY id LIMIT 1
            """).all()
    case 100:
        try await context.sql.raw("""
            SELECT * FROM fluentkit_benchmark.wide_models
            ORDER BY id LIMIT 100
            """).all()
    case 1_000:
        try await context.sql.raw("""
            SELECT * FROM fluentkit_benchmark.wide_models
            ORDER BY id LIMIT 1000
            """).all()
    default:
        preconditionFailure("Unsupported row count: \(count)")
    }
}

func registerPostgresQueryBenchmarks() {
    for rowCount in [1, 100, 1_000] {
        postgresBenchmark("Postgres/Raw/Narrow/\(rowCount)-rows") { _, context in
            blackHole(try await rawNarrowRows(rowCount, using: context))
        }

        postgresBenchmark("Postgres/Fluent/Narrow/\(rowCount)-rows") { _, context in
            let models = try await NarrowModel.query(on: context.database)
                .sort(\.$id)
                .limit(rowCount)
                .all()
            blackHole(models)
        }

        postgresBenchmark("Postgres/Direct/Narrow/\(rowCount)-rows") { _, context in
            let models = try await DirectNarrowModel.query(on: context.database)
                .sort(\.$id)
                .limit(rowCount)
                .all()
            blackHole(models)
        }

        postgresBenchmark("Postgres/Raw/Wide/\(rowCount)-rows") { _, context in
            blackHole(try await rawWideRows(rowCount, using: context))
        }

        postgresBenchmark("Postgres/Fluent/Wide/\(rowCount)-rows") { _, context in
            let models = try await WideModel.query(on: context.database)
                .sort(\.$id)
                .limit(rowCount)
                .all()
            blackHole(models)
        }

        postgresBenchmark("Postgres/Direct/Wide/\(rowCount)-rows") { _, context in
            let models = try await DirectWideModel.query(on: context.database)
                .sort(\.$id)
                .limit(rowCount)
                .all()
            blackHole(models)
        }
    }

    postgresBenchmark("Postgres/Fluent/EagerLoad/100-parents-1000-children") { _, context in
        let parents = try await ParentModel.query(on: context.database)
            .sort(\.$id)
            .with(\.$children)
            .all()
        blackHole(parents)
    }
}
