# Changelog

## [0.3.2-wip]

## [0.3.1] - 2026-10-17

### Changed

- README: standard header naming the instrumented library, its supported platforms and project links; pubspec description to match.

## [0.3.0] - 2026-10-11

### Changed

- Requires `dartastic_opentelemetry_api >=1.0.0-rc.4 <1.0.0-rc.5`.
- **Breaking:** depends on `dartastic_opentelemetry_api` only, no
  longer on the SDK. The application chooses and initializes the
  OpenTelemetry SDK. Parameters and fields typed with SDK classes
  now use the API types (`APITracer`, `APISpan`, `APILogger`, ...);
  SDK instances are still accepted wherever an API type is expected.

## [0.2.0] - 2026-08-10

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
