import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sync_bloc/sync_status_cubit.dart';
import '../services/pos_sync_manager.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();
    return BlocBuilder<SyncStatusCubit, PosSyncState>(
      builder: (context, state) {
        if (state.syncing) {
          return const LinearProgressIndicator(minHeight: 2);
        }
        if (state.failed == 0 && state.error == null && state.conflicts == 0) return const SizedBox.shrink();
        return Material(
          color: Colors.red.shade700,
          child: InkWell(
            onTap: () => context.read<SyncStatusCubit>().retry(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.sync_problem, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.conflicts > 0
                          ? 'Synchronization conflict (${state.conflicts}): ${state.conflictMessages.take(2).join(' | ')}'
                          : 'Synchronization failed (${state.failed}). Tap to retry.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.refresh, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
