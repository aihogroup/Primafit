import 'package:flutter/widgets.dart';

/// [PopScope] with the familiar `onWillPop` contract: the route pops only
/// when [onWillPop] resolves to `true`.
///
/// Replaces the deprecated `WillPopScope` (which breaks Android 14+
/// predictive back) while keeping existing "leave this page?" callbacks
/// unchanged.
class ConfirmPopScope extends StatelessWidget {
  const ConfirmPopScope({super.key, required this.onWillPop, required this.child});

  final Future<bool> Function() onWillPop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await onWillPop() && navigator.mounted) navigator.pop(result);
      },
      child: child,
    );
  }
}
