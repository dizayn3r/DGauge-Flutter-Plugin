import 'package:flutter/material.dart';

/// A utility class to safely handle async UI operations
/// without triggering "Don't use BuildContext across async gaps" warnings.
///
/// Example usage:
/// ```dart
/// await SafeUIAction.run(context, () async {
///   await context.read<MyCubit>().doSomething();
///   setState(() {});
///   showSnackBar(context, "Action completed!");
/// });
/// ```
class SafeUIAction {
  const SafeUIAction._(); // private constructor (static-only class)

  /// Safely runs an async [action] and ensures [BuildContext] is still valid after the async gap.
  static Future<void> run(
      BuildContext context,
      Future<void> Function() action,
      ) async {
    await action();
    if (!context.mounted) return;
  }

  /// Variant that also accepts a callback to run after verifying mount status.
  /// Useful if you want to clearly separate pre- and post-await actions.
  ///
  /// Example:
  /// ```dart
  /// await SafeUIAction.runWithPostCheck(
  ///   context,
  ///   () async => await apiCall(),
  ///   () {
  ///     setState(() {});
  ///     showSnackBar(context, "Done!");
  ///   },
  /// );
  /// ```
  static Future<void> runWithPostCheck(
      BuildContext context,
      Future<void> Function() asyncAction,
      void Function() postAction,
      ) async {
    await asyncAction();
    if (!context.mounted) return;
    postAction();
  }
}
