# Changelog

## [0.2.0-wip]

### Changed

- Semantic conventions updated to the current OTel registry: deprecated
  attribute keys are no longer emitted or asserted (`db.system` ->
  `db.system.name`, `db.operation` -> `db.operation.name`); docs and
  tests now reference the current keys.
- Dependency floors raised to `dartastic_opentelemetry ^1.1.0-beta.12` and
  `dartastic_opentelemetry_api ^1.0.0-rc.1`. The previous floors declared
  compatibility with API versions that predate the semconv enums this
  package uses and could not actually resolve-and-compile.
- `repository` URL corrected to the canonical `Dartastic` org casing so
  pub.dev repository verification succeeds.

### Added

- `tracedIsarCall<R>({operation, collection, invoke})` —
  generic helper that opens a CLIENT span with
  `db.system.name=isar`, `db.operation.name`, `db.collection.name`
  around an Isar operation. Wrap individual collection calls or your
  data-layer methods.
- `tracedIsarWriteTxn<R>(body)` — convenience for
  `isar.writeTxn(...)` wrapped in a span.
- `tracedIsarReadTxn<R>(body)` — same for read transactions.
- Zone-scoped suppression
  (`runWithoutIsarInstrumentation` / async variant).
- Runnable `example/main.dart` (console exporter, no network).
- 4 tests via the generic helper.
