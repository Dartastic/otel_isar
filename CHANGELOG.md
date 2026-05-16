# Changelog

## [0.1.0-beta.1-wip]

### Added

- `tracedIsarCall<R>({operation, collection, invoke})` —
  generic helper that opens a CLIENT span with
  `db.system=isar`, `db.operation`, `db.collection.name` around
  an Isar operation. Wrap individual collection calls or your
  data-layer methods.
- `tracedIsarWriteTxn<R>(body)` — convenience for
  `isar.writeTxn(...)` wrapped in a span.
- `tracedIsarReadTxn<R>(body)` — same for read transactions.
- Zone-scoped suppression
  (`runWithoutIsarInstrumentation` / async variant).
- 4 tests via the generic helper.
