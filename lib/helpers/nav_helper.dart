import 'package:flutter/material.dart';

/// Inserts a dimmed overlay with a centered spinner, waits, then removes it.
/// Uses Overlay instead of showDialog to avoid Navigator stack conflicts
/// (e.g. when called right after closing a drawer).
OverlayEntry _showLoadingOverlay(BuildContext context) {
  final entry = OverlayEntry(
    builder: (_) => Material(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1EAA83),
          strokeWidth: 3.5,
        ),
      ),
    ),
  );
  Overlay.of(context).insert(entry);
  return entry;
}

/// Shows a dimmed loading overlay with a spinner, then navigates to [destination]
/// with a slide transition (old page slides left, new page slides right).
///
/// [replace] — if true, uses pushReplacement instead of push.
/// [removeAll] — if true, uses pushAndRemoveUntil (clears stack).
/// [loadingDuration] — how long the loading spinner is shown (default 600ms).
Future<T?> navigateWithLoading<T>(
  BuildContext context, {
  required Widget destination,
  bool replace = false,
  bool removeAll = false,
  Duration loadingDuration = const Duration(milliseconds: 600),
}) async {
  final overlay = _showLoadingOverlay(context);

  await Future.delayed(loadingDuration);

  overlay.remove();

  if (!context.mounted) return null;

  // Build the slide route
  final route = PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => destination,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Incoming page slides in from the right
      final inOffset = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

      // Outgoing page slides out to the left
      final outOffset =
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.3, 0.0),
          ).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOut,
            ),
          );

      return SlideTransition(
        position: outOffset,
        child: SlideTransition(position: inOffset, child: child),
      );
    },
  );

  if (!context.mounted) return null;

  if (removeAll) {
    return Navigator.pushAndRemoveUntil(context, route, (r) => false);
  } else if (replace) {
    return Navigator.pushReplacement(context, route);
  } else {
    return Navigator.push(context, route);
  }
}

/// Same slide transition but for named routes (e.g. '/dashboard').
/// Shows a dimmed loading overlay first.
Future<T?> navigateNamedWithLoading<T>(
  BuildContext context, {
  required String routeName,
  bool replace = false,
  Duration loadingDuration = const Duration(milliseconds: 600),
}) async {
  final overlay = _showLoadingOverlay(context);

  await Future.delayed(loadingDuration);

  overlay.remove();

  if (!context.mounted) return null;

  if (replace) {
    return Navigator.pushReplacementNamed(context, routeName);
  } else {
    return Navigator.pushNamed(context, routeName);
  }
}

/// Pop current route with loading animation (for back buttons).
Future<void> popWithLoading(
  BuildContext context, {
  Duration loadingDuration = const Duration(milliseconds: 600),
}) async {
  final overlay = _showLoadingOverlay(context);

  await Future.delayed(loadingDuration);

  overlay.remove();

  if (!context.mounted) return;
  Navigator.pop(context);
}
