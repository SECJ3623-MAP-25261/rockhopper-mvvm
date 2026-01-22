import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../view_model/app_lock_viewmodel.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final appLock = context.read<AppLockViewModel>();

    if (state == AppLifecycleState.paused) {
      // App goes to background → lock
      appLock.lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}


/*
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';
import '../view_model/app_lock_viewmodel.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final appLock = context.read<AppLockViewModel>();
    final syncService = context.read<SyncService>(); 

    if (state == AppLifecycleState.paused) {
      appLock.lockApp();
      syncService.syncNow();
    } else if (state == AppLifecycleState.resumed) {
      syncService.syncNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}*/