import 'package:flutter/material.dart';
import 'ive_app_bar.dart';
import 'ive_tokens.dart';

/// Standard page chrome. Use as the root of any screen for consistent
/// background, safe-area, and (optionally) a large-title header.
class IveScaffold extends StatelessWidget {
  const IveScaffold({
    super.key,
    this.appBar,
    this.largeTitle,
    this.largeTitleSubtitle,
    this.largeTitleTrailing,
    required this.child,
    this.floatingActionButton,
    this.bottomBar,
    this.padding = EdgeInsets.zero,
    this.background,
    this.resizeToAvoidBottomInset,
    this.safeAreaBottom = true,
    this.scrollable = false,
  });

  final IveAppBar? appBar;
  final String? largeTitle;
  final String? largeTitleSubtitle;
  final Widget? largeTitleTrailing;
  final Widget child;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final bool? resizeToAvoidBottomInset;
  final bool safeAreaBottom;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (largeTitle != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IveLargeTitle(
            title: largeTitle!,
            subtitle: largeTitleSubtitle,
            trailing: largeTitleTrailing,
          ),
          Expanded(child: child),
        ],
      );
    }
    if (scrollable) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: content,
      );
    } else if (padding != EdgeInsets.zero) {
      content = Padding(padding: padding, child: content);
    }
    return Scaffold(
      backgroundColor: background ?? IveTokens.bg,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(top: appBar == null, bottom: safeAreaBottom, child: content),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
    );
  }
}
