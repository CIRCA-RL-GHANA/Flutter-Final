import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ive_text.dart';
import '../design/ive_tokens.dart';

/// The application theme.
///
/// We ship a single, dark, brand-true ThemeData built on Ive tokens. The
/// `lightTheme` getter remains for compatibility but currently mirrors the
/// dark theme  the product is designed dark-first.
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
        foregroundColor: IveTokens.label,
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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
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
        // Fallback style for any unconverted showSnackBar calls.
        // New code should use AppToast instead.
        backgroundColor: IveTokens.surfaceRaised,
        contentTextStyle: IveType.callout.copyWith(color: IveTokens.label),
        actionTextColor: IveTokens.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        width: 480, // cap width  avoids full-screen bar on wide viewports
        shape: RoundedRectangleBorder(
          borderRadius: IveTokens.brSm,
          side: BorderSide(color: IveTokens.hairline2, width: 1),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        overlayColor: const WidgetStatePropertyAll(IveTokens.accentSoft),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: IveTokens.brSm,
          borderSide: BorderSide(
              color: IveTokens.hairline.withValues(alpha: 0.4)),
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
          TargetPlatform.iOS:     ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS:   ZoomPageTransitionsBuilder(),
          TargetPlatform.linux:   ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
      //  Filled extra components so raw Material widgets used in older
      //     screens still render with the Ive vocabulary. 
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: IveTokens.label,
          highlightColor: IveTokens.accentSoft,
          hoverColor: IveTokens.accentSoft,
          minimumSize: const Size.square(IveTokens.tap),
          padding: const EdgeInsets.all(IveTokens.s2),
          shape: const RoundedRectangleBorder(borderRadius: IveTokens.brSm),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: IveTokens.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: IveTokens.brSm,
          side: BorderSide(color: IveTokens.hairline),
        ),
        textStyle: IveType.callout,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: IveType.body,
        menuStyle: const MenuStyle(
          backgroundColor: WidgetStatePropertyAll(IveTokens.surfaceRaised),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: IveTokens.brSm,
            side: BorderSide(color: IveTokens.hairline),
          )),
        ),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(IveTokens.surfaceRaised),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: IveTokens.brSm,
            side: BorderSide(color: IveTokens.hairline),
          )),
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: IveTokens.labelSecondary,
        collapsedIconColor: IveTokens.labelSecondary,
        textColor: IveTokens.label,
        collapsedTextColor: IveTokens.label,
        tilePadding: EdgeInsets.symmetric(horizontal: IveTokens.s5),
        childrenPadding:
            EdgeInsets.symmetric(horizontal: IveTokens.s5, vertical: IveTokens.s2),
        shape: Border(),
        collapsedShape: Border(),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: const WidgetStatePropertyAll(IveTokens.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        side: const WidgetStatePropertyAll(
            BorderSide(color: IveTokens.hairline)),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: IveTokens.brMd,
        )),
        textStyle: WidgetStatePropertyAll(IveType.body),
        hintStyle: WidgetStatePropertyAll(
            IveType.body.copyWith(color: IveTokens.labelTertiary)),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: IveTokens.s4)),
      ),
      searchViewTheme: SearchViewThemeData(
        backgroundColor: IveTokens.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        side: const BorderSide(color: IveTokens.hairline),
        shape: const RoundedRectangleBorder(borderRadius: IveTokens.brMd),
        headerHintStyle:
            IveType.body.copyWith(color: IveTokens.labelTertiary),
        headerTextStyle: IveType.body,
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: IveTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        contentTextStyle: IveType.callout,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: IveTokens.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(IveTokens.rLg)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? IveTokens.accent.withValues(alpha: 0.14)
                  : IveTokens.surface),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? IveTokens.accent
                  : IveTokens.label),
          side: const WidgetStatePropertyAll(
              BorderSide(color: IveTokens.hairline)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: IveTokens.brSm)),
          textStyle: WidgetStatePropertyAll(IveType.subhead),
        ),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: IveTokens.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dataTableTheme: DataTableThemeData(
        dataRowColor: const WidgetStatePropertyAll(Colors.transparent),
        headingRowColor: const WidgetStatePropertyAll(IveTokens.surface),
        dividerThickness: 1,
        headingTextStyle:
            IveType.subhead.copyWith(color: IveTokens.labelSecondary),
        dataTextStyle: IveType.body,
        columnSpacing: IveTokens.s6,
        horizontalMargin: IveTokens.s5,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
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
    );
  }
}
