import 'package:flutter/material.dart';

class AccountDeletionRequestPresenter {
  const AccountDeletionRequestPresenter._();

  static String? statusLabel(String? status) {
    switch (status) {
      case 'scheduled':
        return 'Programada';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return null;
    }
  }

  static DateTime? parseTimestamp(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  static Duration? remainingTime(dynamic executeAfterValue) {
    final executeAfter = parseTimestamp(executeAfterValue);
    if (executeAfter == null) {
      return null;
    }
    final remaining = executeAfter.difference(DateTime.now().toUtc());
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  static bool canCancel(dynamic executeAfterValue) {
    final executeAfter = parseTimestamp(executeAfterValue);
    if (executeAfter == null) {
      return false;
    }
    return DateTime.now().toUtc().isBefore(executeAfter);
  }

  static String? countdownLabel(dynamic executeAfterValue) {
    final remaining = remainingTime(executeAfterValue);
    if (remaining == null) {
      return null;
    }
    if (remaining == Duration.zero) {
      return 'Pendiente de borrado';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h restantes';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${minutes}m restantes';
    }
    return '${remaining.inMinutes}m restantes';
  }

  static Color? countdownColor(BuildContext context, dynamic executeAfterValue) {
    final remaining = remainingTime(executeAfterValue);
    if (remaining == null) {
      return null;
    }
    final colorScheme = Theme.of(context).colorScheme;
    if (remaining == Duration.zero) {
      return colorScheme.error;
    }
    if (remaining <= const Duration(hours: 24)) {
      return colorScheme.tertiary;
    }
    return colorScheme.onSurfaceVariant;
  }

  static String formatTimestamp(dynamic value) {
    final timestamp = parseTimestamp(value);
    if (timestamp == null) {
      return '-';
    }
    final local = timestamp.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
