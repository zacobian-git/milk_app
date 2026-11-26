import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/widgets/common_widgets.dart';
import 'package:milk_app/features/settings/application/app_settings_provider.dart';
import 'package:milk_app/features/settings/presentation/app_lock_gate.dart';
import 'package:milk_app/l10n/app_localizations.dart';

class AppStartupGate extends ConsumerStatefulWidget {
  const AppStartupGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends ConsumerState<AppStartupGate> {
  static const _minimumSplashDuration = Duration(milliseconds: 900);

  late final Timer _splashTimer;
  bool _minimumDurationElapsed = false;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(_minimumSplashDuration, () {
      if (mounted) {
        setState(() => _minimumDurationElapsed = true);
      }
    });
  }

  @override
  void dispose() {
    _splashTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    if (settings.hasError) {
      return Scaffold(
        body: ErrorState(onRetry: () => ref.invalidate(appSettingsProvider)),
      );
    }
    if (settings.isLoading || !_minimumDurationElapsed) {
      return const AppStartupScreen();
    }
    return AppLockGate(child: widget.child);
  }
}

class AppStartupScreen extends StatelessWidget {
  const AppStartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    Color.lerp(colors.primary, colors.tertiary, 0.7)!,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -85,
            child: _SplashOrb(
              size: 290,
              color: colors.onPrimary.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: -155,
            left: -100,
            child: _SplashOrb(
              size: 320,
              color: colors.onPrimary.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        color: colors.onPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: colors.onPrimary.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        size: 66,
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      strings.appTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        strings.appDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.82),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox.square(
                      dimension: 30,
                      child: CircularProgressIndicator(
                        value: 0.72,
                        strokeWidth: 3,
                        color: colors.onPrimary,
                        backgroundColor: colors.onPrimary.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashOrb extends StatelessWidget {
  const _SplashOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
