@preconcurrency import Benchmark

let benchmarks: @Sendable () -> Void = {
    registerHydrationBenchmarks()
    registerPostgresQueryBenchmarks()
}
