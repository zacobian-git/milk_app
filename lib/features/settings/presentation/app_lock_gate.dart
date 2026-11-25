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

  /// Re-lock only after the app was really in the background for a while.
  /// Share sheets, file pickers and the fingerprint prompt itself briefly
  /// make the app inactive, and must not trigger another unlock.
  static const _relockAfter = Duration(seconds: 30);
  DateTime? _backgroundedAt;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final locked = ref.read(appSettingsProvider).value?.appLockEnabled ?? false;
    if (!locked) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      _backgroundedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (since != null &&
          !_authenticating &&
          DateTime.now().difference(since) >= _relockAfter) {
        setState(() => _unlocked = false);
        unawaited(_authenticate());
      }
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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 52,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  strings.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(strings.appLocked, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _authenticating ? null : _authenticate,
                  icon: _authenticating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fingerprint_rounded),
                  label: Text(strings.unlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
