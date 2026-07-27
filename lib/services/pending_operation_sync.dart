import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../controller/DB_helper.dart';
import 'network_environment.dart';
import 'pos_api_client.dart';

class PendingOperationSync {
  final PosApiClient api;
  PendingOperationSync({PosApiClient? api}) : api = api ?? PosApiClient();

  Future<SyncSummary> synchronize() async {
    if (!NetworkConfiguration.usesBackend || kIsWeb) return const SyncSummary();
    final pending = await DBHelper.getPendingOperations();
    if (pending.isEmpty) return const SyncSummary();
    var succeeded = 0;
    var failed = 0;
    var conflicts = 0;
    final conflictMessages = <String>[];
    for (final row in pending) {
      try {
        final payload =
            jsonDecode(row['payload'] as String) as Map<String, dynamic>;
        final response = await api.request(
          'POST',
          '/api/v1/sync/upload',
          body: {
            'operations': [
              {
                ...payload,
                'retry_count': (row['retry_count'] as int? ?? 0) + 1,
              },
            ],
          },
        );
        final result = (response as Map)['results'] is List
            ? (response['results'] as List).first as Map
            : const {};
        if (result['status'] == 'accepted' || result['status'] == 'duplicate') {
          await DBHelper.database!.update(
            'pending_operations',
            {'sync_status': 'synchronized'},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          succeeded++;
        } else {
          final isConflict = result['status'] == 'conflict';
          await DBHelper.database!.update(
            'pending_operations',
            {
              'sync_status': isConflict ? 'conflict' : 'failed',
              'last_error':
                  result['message']?.toString() ?? 'Synchronization rejected',
              'retry_count': (row['retry_count'] as int? ?? 0) + 1,
            },
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          if (isConflict) conflicts++;
          if (isConflict) {
            conflictMessages.add(
              '${row['entity_type'] ?? 'operation'} ${row['entity_id'] ?? ''}: ${result['message'] ?? 'conflict'}',
            );
          }
          failed++;
        }
      } catch (error) {
        await DBHelper.database!.update(
          'pending_operations',
          {
            'retry_count': (row['retry_count'] as int? ?? 0) + 1,
            'last_error': error.toString(),
            'sync_status': 'failed',
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
        failed++;
      }
    }
    return SyncSummary(
      succeeded: succeeded,
      failed: failed,
      conflicts: conflicts,
      conflictMessages: conflictMessages,
    );
  }
}

class SyncSummary {
  final int succeeded;
  final int failed;
  final int conflicts;
  final List<String> conflictMessages;
  const SyncSummary({
    this.succeeded = 0,
    this.failed = 0,
    this.conflicts = 0,
    this.conflictMessages = const [],
  });
}
