# Bun and Drizzle comparison

This package frames FluentKit's PostgreSQL results against a lightweight typed
query layer from the JavaScript ecosystem. It measures three paths:

- Bun SQL value arrays, which avoid column-name object materialization.
- Bun SQL's normal row objects.
- Drizzle ORM's typed query builder using its native Bun SQL driver.

All paths use a single warmed connection and the same narrow and wide table
shapes and row counts as the Swift benchmarks. Fixtures live in the dedicated
`fluentkit_benchmark_bun` schema and are removed after each run.

Drizzle is intentionally a lightweight, SQL-oriented query layer rather than an
Active Record implementation. This makes it a useful comparison for deciding
whether a small typed Swift layer could retain good ergonomics without Fluent's
per-model property-wrapper machinery.

## Running

Install the locked dependencies and run with the same PostgreSQL endpoint used
by the Swift suite:

```console
cd Benchmarks/Bun
bun install --frozen-lockfile
export FLUENT_BENCHMARK_DATABASE_URL='postgres://user:password@localhost:5432/database'
bun run benchmark
```

Set `BENCHMARK_FILTER` to a regular expression to run a subset:

```console
BENCHMARK_FILTER='(Drizzle|BunSQL/Objects)/Wide/1000-rows' bun run benchmark
```

## Initial local result

Measured on an Apple M4 with Bun 1.3.14 against PostgreSQL on the same host:

| Rows and shape | Bun SQL objects | Drizzle | Fluent direct | Fluent reflective |
| --- | ---: | ---: | ---: | ---: |
| Narrow, 1 | 167 us | 186 us | 169 us | 183 us |
| Wide, 1 | 159 us | 204 us | 280 us | 368 us |
| Narrow, 100 | 196 us | 217 us | 985 us | 1,239 us |
| Wide, 100 | 280 us | 358 us | 3,494 us | 5,538 us |
| Narrow, 1,000 | 383 us | 482 us | 6,390 us | 9,634 us |
| Wide, 1,000 | 1,200 us | 1,730 us | 29,966 us | 49,349 us |

Mitata reports means while the Swift table above uses medians, so the table is a
framing comparison rather than a cross-runtime league table. Allocation metrics
are not comparable across the JavaScriptCore, Bun SQL native, and Swift heaps.
The size of the multi-row differences is nevertheless well outside harness or
summary-statistic noise.
