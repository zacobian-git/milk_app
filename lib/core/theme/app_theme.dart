import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static const Color _milkWhite = Color(0xFFFFFDF7);
  static const Color _deepTeal = Color(0xFF176B63);
  static const Color _night = Color(0xFF0F1615);

  /// Status colours used for calendar cells, pills and legends.
  static const Color customLight = Color(0xFFC26A00);
  static const Color customDark = Color(0xFFFFB86B);

  static Color customColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? customDark
      : customLight;

  /// Money in the person's favour, such as an advance.
  static Color positiveColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF7FD8A6)
      : const Color(0xFF1E7A4A);

  static final ThemeData light = _build(
    ColorScheme.fromSeed(seedColor: _deepTeal, surface: _milkWhite),
    scaffold: _milkWhite,
    cardColor: Colors.white,
    cardBorder: const Color(0xFFE7ECE8),
  );

  static final ThemeData dark = _build(
    ColorScheme.fromSeed(
      seedColor: _deepTeal,
      brightness: Brightness.dark,
      surface: _night,
    ),
    scaffold: _night,
    cardColor: const Color(0xFF172120),
    cardBorder: const Color(0xFF243230),
  );

  static ThemeData _build(
    ColorScheme colors, {
    required Color scaffold,
    required Color cardColor,
    required Color cardBorder,
  }) {
    final radius16 = BorderRadius.circular(16);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: scaffold,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: cardBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius16),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colors.outlineVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: colors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),
      dividerTheme: DividerThemeData(color: cardBorder, space: 1),
    );
  }
}
