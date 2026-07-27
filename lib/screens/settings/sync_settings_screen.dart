import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/sync_bloc/sync_status_cubit.dart';
import '../../services/network_environment.dart';
import '../../services/pos_repository.dart';
import '../../services/pos_sync_manager.dart';

class SyncSettingsScreen extends StatefulWidget {
  static const String routeName = '/sync_settings';

  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  int _pendingRows = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() => _refreshPendingCount();

  Future<void> _refreshPendingCount() async {
    if (!NetworkConfiguration.usesBackend) return;
    try {
      final count = await PosRepository.instance.pendingSyncCount();
      if (!mounted) return;
      setState(() {
        _pendingRows = count;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _syncNow() async {
    if (!NetworkConfiguration.usesBackend) return;
    await context.read<SyncStatusCubit>().retry();
    await _refreshPendingCount();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !NetworkConfiguration.usesBackend) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<SyncStatusCubit, PosSyncState>(
      builder: (context, syncState) {
        final color = syncState.online ? Colors.green : Colors.red;
        final isBusy = syncState.syncing || _loading;
        return Scaffold(
          appBar: AppBar(title: const Text('Sync Settings')),
          body: RefreshIndicator(
            onRefresh: _refreshPendingCount,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.circle, color: color, size: 14),
                    title: Text(
                      syncState.online ? 'connected' : 'disconnected',
                    ),
                    subtitle: const Text('Backend connectivity status'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: Text('$_pendingRows unsynchronized data row(s)'),
                    subtitle: syncState.conflicts > 0
                        ? Text(
                            '${syncState.conflicts} conflict(s) need attention',
                          )
                        : const Text(
                            'Pending local changes waiting for upload',
                          ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isBusy || !syncState.online ? null : _syncNow,
                  icon: syncState.syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(syncState.syncing ? 'Syncing...' : 'Sync data'),
                ),
                if (!syncState.online)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Connect to the internet before syncing data.'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
