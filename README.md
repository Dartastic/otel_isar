# otel_isar

OpenTelemetry instrumentation for
[`package:isar`](https://pub.dev/packages/isar).

```dart
final id = await tracedIsarCall<int>(
  operation: 'put',
  collection: 'users',
  invoke: () => isar.users.put(user),
);

final user = await tracedIsarCall<User?>(
  operation: 'get',
  collection: 'users',
  invoke: () => isar.users.get(id),
);

await tracedIsarWriteTxn(() async {
  await isar.users.put(user);
  await isar.orders.put(order);
});
```

Each call opens a CLIENT span:
- name: `isar <op> [<collection>]`
- `db.system.name = isar`
- `db.operation.name = <op>`
- `db.collection.name = <collection>` (when applicable)

Isar uses code-generated collection accessors and doesn't expose
a per-query interceptor, so wrapping at the call site (or in
your data-layer methods) is the most portable instrumentation
point.

Suppression: `runWithoutIsarInstrumentationAsync`.

## License

Apache 2.0
