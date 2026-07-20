import { SQL } from "bun";
import { asc } from "drizzle-orm";
import { drizzle } from "drizzle-orm/bun-sql";
import {
  bigint,
  boolean,
  doublePrecision,
  pgSchema,
  text,
} from "drizzle-orm/pg-core";
import { bench, do_not_optimize, run } from "mitata";

const databaseURL =
  process.env.FLUENT_BENCHMARK_DATABASE_URL ?? process.env.DATABASE_URL;

if (!databaseURL) {
  throw new Error(
    "Set FLUENT_BENCHMARK_DATABASE_URL or DATABASE_URL before running the Bun benchmarks.",
  );
}

const client = new SQL(databaseURL, { max: 1 });
const db = drizzle({ client });
const fixtureSchemaName = "fluentkit_benchmark_bun";
const fixtureSchema = pgSchema(fixtureSchemaName);

const narrowModels = fixtureSchema.table("narrow_models", {
  id: bigint("id", { mode: "number" }).primaryKey(),
  name: text("name").notNull(),
  score: bigint("score", { mode: "number" }).notNull(),
});

const wideModels = fixtureSchema.table("wide_models", {
  id: bigint("id", { mode: "number" }).primaryKey(),
  string1: text("string_1").notNull(),
  string2: text("string_2").notNull(),
  string3: text("string_3").notNull(),
  string4: text("string_4").notNull(),
  string5: text("string_5").notNull(),
  string6: text("string_6").notNull(),
  string7: text("string_7").notNull(),
  string8: text("string_8").notNull(),
  int1: bigint("int_1", { mode: "number" }).notNull(),
  int2: bigint("int_2", { mode: "number" }).notNull(),
  int3: bigint("int_3", { mode: "number" }).notNull(),
  int4: bigint("int_4", { mode: "number" }).notNull(),
  int5: bigint("int_5", { mode: "number" }).notNull(),
  int6: bigint("int_6", { mode: "number" }).notNull(),
  int7: bigint("int_7", { mode: "number" }).notNull(),
  int8: bigint("int_8", { mode: "number" }).notNull(),
  bool1: boolean("bool_1").notNull(),
  bool2: boolean("bool_2").notNull(),
  double1: doublePrecision("double_1").notNull(),
  double2: doublePrecision("double_2").notNull(),
});

async function createFixtures(): Promise<void> {
  await client.unsafe(`DROP SCHEMA IF EXISTS ${fixtureSchemaName} CASCADE`);
  await client.unsafe(`CREATE SCHEMA ${fixtureSchemaName}`);
  await client.unsafe(`
    CREATE TABLE ${fixtureSchemaName}.narrow_models (
      id BIGINT PRIMARY KEY,
      name TEXT NOT NULL,
      score BIGINT NOT NULL
    )
  `);
  await client.unsafe(`
    INSERT INTO ${fixtureSchemaName}.narrow_models (id, name, score)
    SELECT i, 'row-' || i, i * 7
    FROM generate_series(1, 1000) AS i
  `);
  await client.unsafe(`
    CREATE TABLE ${fixtureSchemaName}.wide_models (
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
  `);
  await client.unsafe(`
    INSERT INTO ${fixtureSchemaName}.wide_models
    SELECT
      i,
      'value-' || i, 'value-' || i, 'value-' || i, 'value-' || i,
      'value-' || i, 'value-' || i, 'value-' || i, 'value-' || i,
      i, i + 1, i + 2, i + 3, i + 4, i + 5, i + 6, i + 7,
      i % 2 = 0, i % 3 = 0, i * 1.25, i * 2.5
    FROM generate_series(1, 1000) AS i
  `);

  for (let index = 0; index < 10; index += 1) {
    await client`SELECT 1`;
  }
}

function rawNarrow(count: number) {
  return client`
    SELECT id, name, score
    FROM fluentkit_benchmark_bun.narrow_models
    ORDER BY id LIMIT ${count}
  `;
}

function rawWide(count: number) {
  return client`
    SELECT * FROM fluentkit_benchmark_bun.wide_models
    ORDER BY id LIMIT ${count}
  `;
}

for (const rowCount of [1, 100, 1_000]) {
  bench(`BunSQL/Objects/Narrow/${rowCount}-rows`, async () => {
    do_not_optimize(await rawNarrow(rowCount));
  });

  bench(`BunSQL/Values/Narrow/${rowCount}-rows`, async () => {
    do_not_optimize(await rawNarrow(rowCount).values());
  });

  bench(`Drizzle/Narrow/${rowCount}-rows`, async () => {
    do_not_optimize(
      await db
        .select()
        .from(narrowModels)
        .orderBy(asc(narrowModels.id))
        .limit(rowCount),
    );
  });

  bench(`BunSQL/Objects/Wide/${rowCount}-rows`, async () => {
    do_not_optimize(await rawWide(rowCount));
  });

  bench(`BunSQL/Values/Wide/${rowCount}-rows`, async () => {
    do_not_optimize(await rawWide(rowCount).values());
  });

  bench(`Drizzle/Wide/${rowCount}-rows`, async () => {
    do_not_optimize(
      await db
        .select()
        .from(wideModels)
        .orderBy(asc(wideModels.id))
        .limit(rowCount),
    );
  });
}

try {
  await createFixtures();
  const filter = process.env.BENCHMARK_FILTER;
  await run({
    throw: true,
    filter: filter ? new RegExp(filter) : undefined,
  });
} finally {
  await client.unsafe(`DROP SCHEMA IF EXISTS ${fixtureSchemaName} CASCADE`);
  await client.close();
}
