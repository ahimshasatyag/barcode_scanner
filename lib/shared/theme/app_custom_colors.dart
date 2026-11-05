import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension tema khusus untuk warna-warna kustom yang didefinisikan dalam `theme.ts`,
/// termasuk warna elevasi, status kehadiran, cuti, form request, dan status lead.
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    required this.offPrimaryContainer,
    required this.card,
    required this.text,
    required this.border,
    required this.notification,
    required this.backdrop,
    required this.surfaceDisabled,
    required this.onSurfaceDisabled,
    // Elevation levels
    required this.elevationLevel0,
    required this.elevationLevel1,
    required this.elevationLevel2,
    required this.elevationLevel3,
    required this.elevationLevel4,
    required this.elevationLevel5,
    // Attendance status colors
    required this.statusPresent,
    required this.statusLate,
    required this.statusAbsent,
    required this.statusLeftEarly,
    required this.statusNoClockOut,
    // Cuti (Leave) status colors
    required this.statusPending,
    required this.statusApproved,
    required this.statusRejected,
    required this.statusCanceled,
    // Request Form status colors
    required this.statusDraft,
    required this.statusConfirmed,
    required this.statusPaid,
    // Lead status colors
    required this.statusNew,
    required this.statusOpen,
    required this.statusFail,
    required this.statusSuccess,
  });

  // UI Tokens
  final Color offPrimaryContainer;
  final Color card;
  final Color text;
  final Color border;
  final Color notification;
  final Color backdrop;
  final Color surfaceDisabled;
  final Color onSurfaceDisabled;

  // Elevation
  final Color elevationLevel0;
  final Color elevationLevel1;
  final Color elevationLevel2;
  final Color elevationLevel3;
  final Color elevationLevel4;
  final Color elevationLevel5;

  // Attendance
  final Color statusPresent;
  final Color statusLate;
  final Color statusAbsent;
  final Color statusLeftEarly;
  final Color statusNoClockOut;

  // Cuti
  final Color statusPending;
  final Color statusApproved;
  final Color statusRejected;
  final Color statusCanceled;

  // Request Form
  final Color statusDraft;
  final Color statusConfirmed;
  final Color statusPaid;

  // Lead
  final Color statusNew;
  final Color statusOpen;
  final Color statusFail;
  final Color statusSuccess;

  /// Alias getter untuk status Cancel pada form/lead
  Color get statusCancel => statusCanceled;

  /// Custom colors preset untuk Light Mode
  static const AppCustomColors light = AppCustomColors(
    offPrimaryContainer: AppColors.offPrimaryContainer,
    card: AppColors.card,
    text: AppColors.text,
    border: AppColors.border,
    notification: AppColors.notification,
    backdrop: AppColors.backdrop,
    surfaceDisabled: AppColors.surfaceDisabled,
    onSurfaceDisabled: AppColors.onSurfaceDisabled,
    elevationLevel0: AppColors.elevationLevel0,
    elevationLevel1: AppColors.elevationLevel1,
    elevationLevel2: AppColors.elevationLevel2,
    elevationLevel3: AppColors.elevationLevel3,
    elevationLevel4: AppColors.elevationLevel4,
    elevationLevel5: AppColors.elevationLevel5,
    statusPresent: AppColors.statusPresent,
    statusLate: AppColors.statusLate,
    statusAbsent: AppColors.statusAbsent,
    statusLeftEarly: AppColors.statusLeftEarly,
    statusNoClockOut: AppColors.statusNoClockOut,
    statusPending: AppColors.statusPending,
    statusApproved: AppColors.statusApproved,
    statusRejected: AppColors.statusRejected,
    statusCanceled: AppColors.statusCanceled,
    statusDraft: AppColors.statusDraft,
    statusConfirmed: AppColors.statusConfirmed,
    statusPaid: AppColors.statusPaid,
    statusNew: AppColors.statusNew,
    statusOpen: AppColors.statusOpen,
    statusFail: AppColors.statusFail,
    statusSuccess: AppColors.statusSuccess,
  );

  /// Custom colors preset untuk Dark Mode
  static const AppCustomColors dark = AppCustomColors(
    offPrimaryContainer: AppColors.offPrimaryContainerDark,
    card: AppColors.cardDark,
    text: AppColors.textDark,
    border: AppColors.borderDark,
    notification: AppColors.notificationDark,
    backdrop: AppColors.backdropDark,
    surfaceDisabled: AppColors.surfaceDisabledDark,
    onSurfaceDisabled: AppColors.onSurfaceDisabledDark,
    elevationLevel0: AppColors.elevationLevel0Dark,
    elevationLevel1: AppColors.elevationLevel1Dark,
    elevationLevel2: AppColors.elevationLevel2Dark,
    elevationLevel3: AppColors.elevationLevel3Dark,
    elevationLevel4: AppColors.elevationLevel4Dark,
    elevationLevel5: AppColors.elevationLevel5Dark,
    statusPresent: AppColors.statusPresent,
    statusLate: AppColors.statusLate,
    statusAbsent: AppColors.statusAbsent,
    statusLeftEarly: AppColors.statusLeftEarly,
    statusNoClockOut: AppColors.statusNoClockOut,
    statusPending: AppColors.statusPending,
    statusApproved: AppColors.statusApproved,
    statusRejected: AppColors.statusRejected,
    statusCanceled: AppColors.statusCanceled,
    statusDraft: AppColors.statusDraft,
    statusConfirmed: AppColors.statusConfirmed,
    statusPaid: AppColors.statusPaid,
    statusNew: AppColors.statusNew,
    statusOpen: AppColors.statusOpen,
    statusFail: AppColors.statusFail,
    statusSuccess: AppColors.statusSuccess,
  );

  /// Helper untuk mengambil warna berdasarkan nama status (seperti di theme.ts `statusColors`)
  Color? colorByStatusName(String status) {
    switch (status.trim()) {
      // Attendance
      case 'Present':
        return statusPresent;
      case 'Late':
        return statusLate;
      case 'Absent':
        return statusAbsent;
      case 'Left Early':
        return statusLeftEarly;
      case 'No Clock Out':
        return statusNoClockOut;

      // Cuti
      case 'Pending':
        return statusPending;
      case 'Approved':
        return statusApproved;
      case 'Rejected':
        return statusRejected;
      case 'Canceled':
      case 'CANCEL':
      case 'CANCELED':
        return statusCanceled;

      // Request Form
      case 'DRAFT':
        return statusDraft;
      case 'CONFIRMED':
        return statusConfirmed;
      case 'PAID':
        return statusPaid;

      // Lead Status
      case 'NEW':
        return statusNew;
      case 'OPEN':
        return statusOpen;
      case 'FAIL':
        return statusFail;
      case 'SUCCESS':
        return statusSuccess;

      default:
        return null;
    }
  }

  @override
  AppCustomColors copyWith({
    Color? offPrimaryContainer,
    Color? card,
    Color? text,
    Color? border,
    Color? notification,
    Color? backdrop,
    Color? surfaceDisabled,
    Color? onSurfaceDisabled,
    Color? elevationLevel0,
    Color? elevationLevel1,
    Color? elevationLevel2,
    Color? elevationLevel3,
    Color? elevationLevel4,
    Color? elevationLevel5,
    Color? statusPresent,
    Color? statusLate,
    Color? statusAbsent,
    Color? statusLeftEarly,
    Color? statusNoClockOut,
    Color? statusPending,
    Color? statusApproved,
    Color? statusRejected,
    Color? statusCanceled,
    Color? statusDraft,
    Color? statusConfirmed,
    Color? statusPaid,
    Color? statusNew,
    Color? statusOpen,
    Color? statusFail,
    Color? statusSuccess,
  }) {
    return AppCustomColors(
      offPrimaryContainer: offPrimaryContainer ?? this.offPrimaryContainer,
      card: card ?? this.card,
      text: text ?? this.text,
      border: border ?? this.border,
      notification: notification ?? this.notification,
      backdrop: backdrop ?? this.backdrop,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      onSurfaceDisabled: onSurfaceDisabled ?? this.onSurfaceDisabled,
      elevationLevel0: elevationLevel0 ?? this.elevationLevel0,
      elevationLevel1: elevationLevel1 ?? this.elevationLevel1,
      elevationLevel2: elevationLevel2 ?? this.elevationLevel2,
      elevationLevel3: elevationLevel3 ?? this.elevationLevel3,
      elevationLevel4: elevationLevel4 ?? this.elevationLevel4,
      elevationLevel5: elevationLevel5 ?? this.elevationLevel5,
      statusPresent: statusPresent ?? this.statusPresent,
      statusLate: statusLate ?? this.statusLate,
      statusAbsent: statusAbsent ?? this.statusAbsent,
      statusLeftEarly: statusLeftEarly ?? this.statusLeftEarly,
      statusNoClockOut: statusNoClockOut ?? this.statusNoClockOut,
      statusPending: statusPending ?? this.statusPending,
      statusApproved: statusApproved ?? this.statusApproved,
      statusRejected: statusRejected ?? this.statusRejected,
      statusCanceled: statusCanceled ?? this.statusCanceled,
      statusDraft: statusDraft ?? this.statusDraft,
      statusConfirmed: statusConfirmed ?? this.statusConfirmed,
      statusPaid: statusPaid ?? this.statusPaid,
      statusNew: statusNew ?? this.statusNew,
      statusOpen: statusOpen ?? this.statusOpen,
      statusFail: statusFail ?? this.statusFail,
      statusSuccess: statusSuccess ?? this.statusSuccess,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;

    return AppCustomColors(
      offPrimaryContainer: Color.lerp(offPrimaryContainer, other.offPrimaryContainer, t)!,
      card: Color.lerp(card, other.card, t)!,
      text: Color.lerp(text, other.text, t)!,
      border: Color.lerp(border, other.border, t)!,
      notification: Color.lerp(notification, other.notification, t)!,
      backdrop: Color.lerp(backdrop, other.backdrop, t)!,
      surfaceDisabled: Color.lerp(surfaceDisabled, other.surfaceDisabled, t)!,
      onSurfaceDisabled: Color.lerp(onSurfaceDisabled, other.onSurfaceDisabled, t)!,
      elevationLevel0: Color.lerp(elevationLevel0, other.elevationLevel0, t)!,
      elevationLevel1: Color.lerp(elevationLevel1, other.elevationLevel1, t)!,
      elevationLevel2: Color.lerp(elevationLevel2, other.elevationLevel2, t)!,
      elevationLevel3: Color.lerp(elevationLevel3, other.elevationLevel3, t)!,
      elevationLevel4: Color.lerp(elevationLevel4, other.elevationLevel4, t)!,
      elevationLevel5: Color.lerp(elevationLevel5, other.elevationLevel5, t)!,
      statusPresent: Color.lerp(statusPresent, other.statusPresent, t)!,
      statusLate: Color.lerp(statusLate, other.statusLate, t)!,
      statusAbsent: Color.lerp(statusAbsent, other.statusAbsent, t)!,
      statusLeftEarly: Color.lerp(statusLeftEarly, other.statusLeftEarly, t)!,
      statusNoClockOut: Color.lerp(statusNoClockOut, other.statusNoClockOut, t)!,
      statusPending: Color.lerp(statusPending, other.statusPending, t)!,
      statusApproved: Color.lerp(statusApproved, other.statusApproved, t)!,
      statusRejected: Color.lerp(statusRejected, other.statusRejected, t)!,
      statusCanceled: Color.lerp(statusCanceled, other.statusCanceled, t)!,
      statusDraft: Color.lerp(statusDraft, other.statusDraft, t)!,
      statusConfirmed: Color.lerp(statusConfirmed, other.statusConfirmed, t)!,
      statusPaid: Color.lerp(statusPaid, other.statusPaid, t)!,
      statusNew: Color.lerp(statusNew, other.statusNew, t)!,
      statusOpen: Color.lerp(statusOpen, other.statusOpen, t)!,
      statusFail: Color.lerp(statusFail, other.statusFail, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
    );
  }
}
