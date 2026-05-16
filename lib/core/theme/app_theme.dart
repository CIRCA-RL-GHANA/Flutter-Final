import 'package:flutter/material.dart';
import '../design/ive_text.dart';
import '../design/ive_tokens.dart';

/// The application theme.
///
/// We ship a single, dark, brand-true ThemeData built on Ive tokens. The
/// `lightTheme` getter remains for compatibility but currently mirrors the
/// dark theme — the product is designed dark-first.
class AppTheme {
  AppTheme._();

  /// Backwards-compatible alias. The product is dark-first.
  static ThemeData get lightTheme => darkTheme;

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: IveTokens.bg,
      canvasColor: IveTokens.bg,
      dividerColor: IveTokens.hairline,
      colorScheme: ColorScheme.fromSeed(
        seedColor: IveTokens.accent,
        brightness: Brightness.dark,
        primary: IveTokens.accent,
        onPrimary: Colors.white,
        secondary: IveTokens.accent,
        surface: IveTokens.surface,
        onSurface: IveTokens.label,
        error: IveTokens.danger,
        onError: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: IveType.buildTextTheme().apply(
        bodyColor: IveTokens.label,
        displayColor: IveTokens.label,
      ),
      primaryTextTheme: IveType.buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: IveTokens.bg.withValues(alpha: 0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: IveTokens.s5,
        iconTheme: const IconThemeData(color: IveTokens.label, size: 22),
        actionsIconTheme: const IconThemeData(color: IveTokens.label, size: 22),
        titleTextStyle: IveType.headline,
        toolbarTextStyle: IveType.headline,
      ),
      cardTheme: const CardThemeData(
        color: IveTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: IveTokens.brSm,
          side: BorderSide(color: IveTokens.hairline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: IveTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: IveType.title3,
        contentTextStyle: IveType.callout,
        shape: const RoundedRectangleBorder(
          borderRadius: IveTokens.brMd,
          side: BorderSide(color: IveTokens.hairline),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: IveTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rLg)),
          side: BorderSide(color: IveTokens.hairline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: IveTokens.surface,
        contentTextStyle: IveType.callout.copyWith(color: IveTokens.label),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: IveTokens.brSm,
          side: BorderSide(color: IveTokens.hairline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: IveTokens.hairline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: IveTokens.label, size: 22),
      listTileTheme: ListTileThemeData(
        iconColor: IveTokens.labelSecondary,
        textColor: IveTokens.label,
        titleTextStyle: IveType.headline,
        subtitleTextStyle: IveType.footnote,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: IveTokens.s5, vertical: IveTokens.s2),
        minVerticalPadding: IveTokens.s3,
        horizontalTitleGap: IveTokens.s4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: IveTokens.surface,
        selectedColor: IveTokens.accent.withValues(alpha: 0.14),
        labelStyle: IveType.subhead,
        secondaryLabelStyle: IveType.subhead.copyWith(color: IveTokens.accent),
        side: const BorderSide(color: IveTokens.hairline),
        shape: const RoundedRectangleBorder(borderRadius: IveTokens.brXs),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: IveTokens.label,
        unselectedLabelColor: IveTokens.labelSecondary,
        labelStyle: IveType.subhead.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: IveType.subhead,
        indicatorColor: IveTokens.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: IveTokens.hairline,
        overlayColor: WidgetStatePropertyAll(IveTokens.accentSoft),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? IveTokens.accent
                : IveTokens.surfaceRaised),
        trackOutlineColor: const WidgetStatePropertyAll(IveTokens.hairline),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: IveTokens.hairline, width: 1.4),
        shape: const RoundedRectangleBorder(borderRadius: IveTokens.brXs),
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? IveTokens.accent
                : Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? IveTokens.accent
                : IveTokens.labelTertiary),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: IveTokens.accent,
        inactiveTrackColor: IveTokens.hairline,
        thumbColor: IveTokens.accent,
        overlayColor: IveTokens.accentSoft,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: IveTokens.accent,
        linearTrackColor: IveTokens.hairline,
        circularTrackColor: IveTokens.hairline,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, IveTokens.tap),
          backgroundColor: IveTokens.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: IveTokens.accent.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: IveTokens.brMd),
          padding: const EdgeInsets.symmetric(
              horizontal: IveTokens.s5, vertical: IveTokens.s3),
          textStyle: IveType.bodyEmphasis,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, IveTokens.tap),
          foregroundColor: IveTokens.label,
          side: const BorderSide(color: IveTokens.hairline, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: IveTokens.brMd),
          padding: const EdgeInsets.symmetric(
              horizontal: IveTokens.s5, vertical: IveTokens.s3),
          textStyle: IveType.bodyEmphasis,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: IveTokens.accent,
          textStyle: IveType.bodyEmphasis,
          padding: const EdgeInsets.symmetric(
              horizontal: IveTokens.s3, vertical: IveTokens.s2),
          shape: const RoundedRectangleBorder(borderRadius: IveTokens.brXs),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: IveTokens.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IveTokens.rLg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: IveTokens.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: IveTokens.s4, vertical: IveTokens.s4),
        hintStyle: IveType.body.copyWith(color: IveTokens.labelTertiary),
        labelStyle: IveType.subhead,
        floatingLabelStyle: IveType.subhead.copyWith(color: IveTokens.accent),
        helperStyle: IveType.footnote,
        errorStyle: IveType.footnote.copyWith(color: IveTokens.danger),
        prefixIconColor: IveTokens.labelSecondary,
        suffixIconColor: IveTokens.labelSecondary,
        border: const OutlineInputBorder(
          borderRadius: IveTokens.brSm,
          borderSide: IveTokens.hairlineSide,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: IveTokens.brSm,
          borderSide: IveTokens.hairlineSide,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: IveTokens.brSm,
          borderSide: BorderSide(color: IveTokens.accent, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: IveTokens.brSm,
          borderSide: BorderSide(color: IveTokens.danger, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: IveTokens.brSm,
          borderSide: BorderSide(color: IveTokens.danger, width: 1.5),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: IveTokens.accent,
        selectionColor: Color(0x3322BDD8),
        selectionHandleColor: IveTokens.accent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: IveTokens.bg,
        selectedItemColor: IveTokens.accent,
        unselectedItemColor: IveTokens.labelTertiary,
        selectedLabelStyle:
            IveType.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: IveType.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: IveTokens.bg,
        indicatorColor: IveTokens.accent.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
            IveType.caption.copyWith(color: IveTokens.label)),
        iconTheme: const WidgetStatePropertyAll(
            IconThemeData(color: IveTokens.label, size: 22)),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 64,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: IveTokens.surfaceRaised,
          border: IveTokens.cardBorder,
          borderRadius: IveTokens.brXs,
        ),
        textStyle: IveType.footnote,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux:   ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
