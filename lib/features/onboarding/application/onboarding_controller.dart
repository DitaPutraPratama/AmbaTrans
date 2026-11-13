import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/channel_providers.dart';
import '../../../core/platform/permissions_channel.dart';

enum OnboardingStep { language, overlay, notifications, ready }

@immutable
class OnboardingState {
  const OnboardingState({
    required this.steps,
    required this.index,
    required this.permissions,
  });

  final List<OnboardingStep> steps;
  final int index;
  final PermissionStatus permissions;

  OnboardingStep get step => steps[index];
  bool get isFirst => index == 0;
  bool get isLast => index == steps.length - 1;

  OnboardingState copyWith({int? index, PermissionStatus? permissions}) =>
      OnboardingState(
        steps: steps,
        index: index ?? this.index,
        permissions: permissions ?? this.permissions,
      );
}

/// Whether onboarding is finished; decides the first screen.
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final all = await ref.read(settingsChannelProvider).getAll();
  return all['onboarding_done'] == true;
});

final onboardingControllerProvider =
    AsyncNotifierProvider.autoDispose<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

class OnboardingController extends AsyncNotifier<OnboardingState> {
  @override
  Future<OnboardingState> build() async {
    final permissions = await ref.read(permissionsChannelProvider).getStatus();
    return OnboardingState(
      // Notifications are granted by default before Android 13: that step is skipped then.
      steps: [
        OnboardingStep.language,
        OnboardingStep.overlay,
        if (!permissions.notifications) OnboardingStep.notifications,
        OnboardingStep.ready,
      ],
      index: 0,
      permissions: permissions,
    );
  }

  void next() {
    final current = state.requireValue;
    if (current.isLast) return;
    state = AsyncData(current.copyWith(index: current.index + 1));
  }

  void back() {
    final current = state.requireValue;
    if (current.isFirst) return;
    state = AsyncData(current.copyWith(index: current.index - 1));
  }

  /// Re-reads permissions, e.g. when returning from system settings.
  Future<void> refreshPermissions() async {
    final permissions = await ref.read(permissionsChannelProvider).getStatus();
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(permissions: permissions));
  }

  Future<void> openOverlaySettings() =>
      ref.read(permissionsChannelProvider).openOverlaySettings();

  Future<void> requestNotifications() async {
    await ref.read(permissionsChannelProvider).requestNotifications();
    await refreshPermissions();
  }

  /// Marks onboarding as done; the caller navigates to Home.
  Future<void> finish() async {
    await ref.read(settingsChannelProvider).set('onboarding_done', true);
    ref.invalidate(onboardingDoneProvider);
  }
}
