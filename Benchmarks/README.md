# FluentKit performance benchmarks

This standalone package measures FluentKit's in-memory model hydration and its
PostgreSQL query paths. It is separate from the root package to avoid making a
database driver or benchmark framework a production dependency of FluentKit.

The `Direct` model variants contain hand-written versions of the property access
code that a future macro could generate. They map to the same PostgreSQL tables
as the ordinary reflective models, providing an otherwise like-for-like measure
of removing reflection from database input and output.

The PostgreSQL benchmarks create and remove only the dedicated
`fluentkit_benchmark` schema. Set the connection URL explicitly; credentials are
never stored in this repository:

```console
cd Benchmarks
export FLUENT_BENCHMARK_DATABASE_URL='postgres://user:password@localhost:5432/database'
swift package --disable-sandbox benchmark --target FluentPostgresBenchmarks
```

Always run through `swift package benchmark`, which builds optimized binaries.
Useful commands include:

```console
# Run only the in-memory hydration benchmarks.
swift package benchmark --target FluentPostgresBenchmarks --filter 'Hydration/.*'

# Compare reflective and generated-style PostgreSQL hydration paths.
swift package --disable-sandbox benchmark --target FluentPostgresBenchmarks --filter 'Postgres/(Fluent|Direct)/.*'

# Record and compare a local baseline.
swift package --disable-sandbox benchmark baseline update --baseline main
swift package --disable-sandbox benchmark baseline compare --baseline main

# Export raw histogram samples for external analysis.
swift package --disable-sandbox benchmark --target FluentPostgresBenchmarks --format histogramSamples
```

The database pool is created and warmed outside each measurement. PostgreSQL
fixtures are also created outside the measurement, so the reported query values
include pool checkout, SQL serialization, PostgreSQL protocol/execution, row
materialization, and (for Fluent cases) model hydration—but not connection or
fixture setup.

Allocation metrics include work performed by the asynchronous PostgreSQL client
and should be interpreted most carefully for the in-memory hydration benchmarks.
Keep the machine otherwise idle and compare results from the same Swift compiler,
build environment, and PostgreSQL configuration.

For a cross-runtime frame of reference, `Bun/` contains matching Bun SQL and
Drizzle benchmarks. See [the Bun comparison](Bun/README.md) for methodology,
commands, and the initial results.
