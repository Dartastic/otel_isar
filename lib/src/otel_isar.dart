// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'isar_suppression.dart';

const _tracerName = 'otel_isar';
const _dbSystem = 'isar';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

/// Generic helper. Opens a CLIENT span named
/// `isar <operation> [<collection>]` carrying `db.system=isar`,
/// `db.operation`, and `db.collection.name` (when supplied).
///
/// Isar uses code-generated collection accessors
/// (`isar.users.put(...)`) so there's no clean interceptor seam;
/// the most portable instrumentation point is to wrap individual
/// call sites or your data-access methods with this helper.
Future<R> tracedIsarCall<R>({
  required String operation,
  String? collection,
  required Future<R> Function() invoke,
}) async {
  if (isarInstrumentationSuppressed()) return invoke();
  final name =
      collection != null ? 'isar $operation $collection' : 'isar $operation';
  final span = _tracer().startSpan(
    name,
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(<String, Object>{
      Database.dbSystem.key: _dbSystem,
      Database.dbSystemName.key: _dbSystem,
      Database.dbOperation.key: operation,
      Database.dbOperationName.key: operation,
      if (collection != null) Database.dbCollectionName.key: collection,
    }),
  );
  try {
    return await invoke();
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

/// Convenience for write transactions
/// (`isar.writeTxn(...)`).
Future<R> tracedIsarWriteTxn<R>(Future<R> Function() body) {
  return tracedIsarCall<R>(operation: 'write_txn', invoke: body);
}

/// Convenience for read transactions
/// (`isar.txn(...)`).
Future<R> tracedIsarReadTxn<R>(Future<R> Function() body) {
  return tracedIsarCall<R>(operation: 'read_txn', invoke: body);
}
