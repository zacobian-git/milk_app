import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/features/settings/application/app_settings_provider.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _unlocked = true;
  bool _authenticating = false;
  bool _lockInitialized = false;

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
    final locked = ref.read(appSettingsProvider).value?.appLockEnabled;
    if (locked == true && state == AppLifecycleState.inactive) {
      setState(() => _unlocked = false);
    } else if (locked == true && state == AppLifecycleState.resumed) {
      unawaited(_authenticate());
    }
  }

  Future<void> _authenticate() async {
    if (_authenticating) {
      return;
    }
    setState(() => _authenticating = true);
    try {
      final authenticated = await LocalAuthentication().authenticate(
        localizedReason: AppLocalizations.of(context)!.authReason,
        persistAcrossBackgrounding: true,
      );
      if (mounted) {
        setState(() => _unlocked = authenticated);
      }
    } on LocalAuthException catch (error, stackTrace) {
      _report(error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _report(error, stackTrace);
    } finally {
      if (mounted) {
        setState(() => _authenticating = false);
      }
    }
  }

  void _report(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app lock',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider).value;
    if (settings != null && !_lockInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _lockInitialized = true;
          _unlocked = !settings.appLockEnabled;
        });
        if (settings.appLockEnabled) {
          unawaited(_authenticate());
        }
      });
    }
    if (settings?.appLockEnabled != true || (_lockInitialized && _unlocked)) {
      return widget.child;
    }
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 16),
            Text(strings.appLocked),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _authenticating ? null : _authenticate,
              child: _authenticating
                  ? const CircularProgressIndicator()
                  : Text(strings.unlock),
            ),
          ],
        ),
      ),
    );
  }
}
