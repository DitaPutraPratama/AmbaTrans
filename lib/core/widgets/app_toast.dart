import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Short floating confirmation ("toast") after something was saved.
/// Replaces a toast that is still showing, so quick changes do not queue up.
void showAppToast(ScaffoldMessengerState messenger, String message) {
  final context = messenger.context;
  final colors = context.colors;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: colors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colors.success, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(message, style: TextStyle(color: colors.background)),
            ),
          ],
        ),
      ),
    );
}
