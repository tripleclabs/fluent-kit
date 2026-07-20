@preconcurrency import Benchmark
import FluentKit

private struct StaticDatabaseOutput: DatabaseOutput, @unchecked Sendable {
    let values: [FieldKey: any Sendable]

    func schema(_ schema: String) -> any DatabaseOutput {
        self
    }

    func contains(_ key: FieldKey) -> Bool {
        self.values[key] != nil
    }

    func decodeNil(_ key: FieldKey) throws -> Bool {
        guard self.values[key] != nil else {
            throw FluentError.missingField(name: key.description)
        }
        return false
    }

    func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T: Decodable {
        guard let value = self.values[key] else {
            throw FluentError.missingField(name: key.description)
        }
        guard let decoded = value as? T else {
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: [],
                    debugDescription: "Expected \(T.self) for \(key), got \(Swift.type(of: value))"
                )
            )
        }
        return decoded
    }

    var description: String {
        "StaticDatabaseOutput(\(self.values.keys.map(\.description).sorted()))"
    }
}

private let narrowOutput = StaticDatabaseOutput(values: [
    .id: 1,
    "name": "row-1",
    "score": 7,
])

private let wideOutput = StaticDatabaseOutput(values: [
    .id: 1,
    "string_1": "value-1",
    "string_2": "value-2",
    "string_3": "value-3",
    "string_4": "value-4",
    "string_5": "value-5",
    "string_6": "value-6",
    "string_7": "value-7",
    "string_8": "value-8",
    "int_1": 1,
    "int_2": 2,
    "int_3": 3,
    "int_4": 4,
    "int_5": 5,
    "int_6": 6,
    "int_7": 7,
    "int_8": 8,
    "bool_1": true,
    "bool_2": false,
    "double_1": 1.25,
    "double_2": 2.5,
])

func registerHydrationBenchmarks() {
    let hydrationConfiguration = Benchmark.Configuration(
        metrics: [.wallClock, .cpuTotal, .mallocCountTotal, .mallocBytesCount],
        timeUnits: .microseconds,
        warmupIterations: 10,
        maxDuration: .seconds(2),
        maxIterations: 100_000
    )

    Benchmark("Hydration/NarrowModel", configuration: hydrationConfiguration) { benchmark in
        do {
            let model = NarrowModel()
            try model.output(from: narrowOutput)
            blackHole(model)
        } catch {
            benchmark.error("Narrow model hydration failed: \(String(reflecting: error))")
        }
    }

    Benchmark("Hydration/DirectNarrowModel", configuration: hydrationConfiguration) { benchmark in
        do {
            let model = DirectNarrowModel()
            try model.output(from: narrowOutput)
            blackHole(model)
        } catch {
            benchmark.error("Direct narrow model hydration failed: \(String(reflecting: error))")
        }
    }

    Benchmark("Hydration/WideModel", configuration: hydrationConfiguration) { benchmark in
        do {
            let model = WideModel()
            try model.output(from: wideOutput)
            blackHole(model)
        } catch {
            benchmark.error("Wide model hydration failed: \(String(reflecting: error))")
        }
    }

    Benchmark("Hydration/DirectWideModel", configuration: hydrationConfiguration) { benchmark in
        do {
            let model = DirectWideModel()
            try model.output(from: wideOutput)
            blackHole(model)
        } catch {
            benchmark.error("Direct wide model hydration failed: \(String(reflecting: error))")
        }
    }
}
