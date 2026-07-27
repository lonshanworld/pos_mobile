import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/alerts_bloc/alerts_cubit.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlertsCubit(),
      child: const _AlertDataView(),
    );
  }
}

class _AlertDataView extends StatefulWidget {
  const _AlertDataView();

  @override
  State<_AlertDataView> createState() => _AlertDataViewState();
}

class _AlertDataViewState extends State<_AlertDataView> {
  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() => context.read<AlertsCubit>().load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: BlocBuilder<AlertsCubit, AlertsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          if (state.alerts.isEmpty) {
            return const Center(child: Text('No alerts'));
          }
          return RefreshIndicator(
            onRefresh: context.read<AlertsCubit>().load,
            child: ListView.builder(
              itemCount: state.alerts.length,
              itemBuilder: (context, index) {
                final alert = state.alerts[index];
                return ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(alert['title']?.toString() ?? 'Alert'),
                  subtitle: Text(alert['description']?.toString() ?? ''),
                  trailing: alert['complete'] == true
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
