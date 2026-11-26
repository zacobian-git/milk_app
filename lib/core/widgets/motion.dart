import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:milk_app/core/utils/formatters.dart';

/// False when the person has asked the system to reduce motion. Every
/// decorative animation in the app checks this first.
bool motionEnabled(BuildContext context) =>
    !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

/// Fades and slides its child in once, after an optional stagger [delay].
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.08),
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (!motionEnabled(context)) {
      _controller.value = 1;
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  late final Animation<Offset> _position = Tween(
    begin: widget.offset,
    end: Offset.zero,
  ).animate(_curve);

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(position: _position, child: widget.child),
  );
}

/// Shrinks slightly while pressed, giving cards a tactile feel.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.scale = 0.97});

  final Widget child;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: AnimatedScale(
      scale: _pressed && motionEnabled(context) ? widget.scale : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}

/// Money that counts up from zero on first show and glides between values
/// when the amount changes.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({
    super.key,
    required this.amountPaise,
    required this.locale,
    this.style,
    this.compact = false,
  });

  final int amountPaise;
  final String locale;
  final TextStyle? style;
  final bool compact;

  String _format(int paise) =>
      compact ? formatMoneyCompact(paise, locale) : formatMoney(paise, locale);

  @override
  Widget build(BuildContext context) {
    if (!motionEnabled(context)) {
      return Text(_format(amountPaise), maxLines: 1, style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amountPaise.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) =>
          Text(_format(value.round()), maxLines: 1, style: style),
    );
  }
}

/// A slow, gentle milk wave along the bottom of a card. It sits behind a
/// RepaintBoundary so only the wave repaints, and stops on reduced motion.
class MilkWave extends StatefulWidget {
  const MilkWave({super.key, required this.color, this.height = 56});

  final Color color;
  final double height;

  @override
  State<MilkWave> createState() => _MilkWaveState();
}

class _MilkWaveState extends State<MilkWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (motionEnabled(context)) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: SizedBox(
      height: widget.height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WavePainter(animation: _controller, color: widget.color),
      ),
    ),
  );
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.animation, required this.color})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value * 2 * math.pi;
    _drawWave(canvas, size, phase, color.withValues(alpha: 0.18), 0.45, 1);
    _drawWave(canvas, size, -phase, color.withValues(alpha: 0.28), 0.6, 1.4);
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double phase,
    Color fill,
    double level,
    double frequency,
  ) {
    final amplitude = size.height * 0.14;
    final baseline = size.height * level;
    final path = Path()..moveTo(0, size.height);
    for (var x = 0.0; x <= size.width; x += 6) {
      final y =
          baseline +
          math.sin(x / size.width * 2 * math.pi * frequency + phase) *
              amplitude;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.color != color;
}

/// Small bar chart for a short series, such as six months of spending.
/// Bars grow in on first show; the last bar is highlighted.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.color,
    this.height = 36,
  });

  final List<int> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget chart(double progress) => CustomPaint(
      size: Size(double.infinity, height),
      painter: _BarsPainter(
        values: values,
        color: color,
        track: track,
        progress: progress,
      ),
    );
    if (!motionEnabled(context)) {
      return SizedBox(height: height, child: chart(1));
    }
    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        builder: (context, progress, _) => chart(progress),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({
    required this.values,
    required this.color,
    required this.track,
    required this.progress,
  });

  final List<int> values;
  final Color color;
  final Color track;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }
    final maxValue = values.reduce(math.max);
    const gap = 4.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;
    final radius = Radius.circular(math.min(4, barWidth / 2));
    for (var index = 0; index < values.length; index++) {
      final left = index * (barWidth + gap);
      final ratio = maxValue == 0 ? 0.0 : values[index] / maxValue;
      final barHeight = math.max(3.0, size.height * ratio * progress);
      final isLast = index == values.length - 1;
      canvas
        ..drawRRect(
          RRect.fromLTRBR(left, 0, left + barWidth, size.height, radius),
          Paint()..color = track.withValues(alpha: 0.5),
        )
        ..drawRRect(
          RRect.fromLTRBR(
            left,
            size.height - barHeight.clamp(0, size.height),
            left + barWidth,
            size.height,
            radius,
          ),
          Paint()..color = isLast ? color : color.withValues(alpha: 0.45),
        );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      !_sameValues(oldDelegate.values, values);

  static bool _sameValues(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }
}
