import 'package:flutter/material.dart';

enum ScreenshotCategory {
  otp,
  bills,
  receipts,
  memes,
  notes,
  trading,
  bankInfo,
  tickets,
  shopping,
  crypto,
  miscellaneous,
}

extension ScreenshotCategoryExtension on ScreenshotCategory {
  String get displayName {
    switch (this) {
      case ScreenshotCategory.otp:
        return 'OTP';
      case ScreenshotCategory.bills:
        return 'Bills';
      case ScreenshotCategory.receipts:
        return 'Receipts';
      case ScreenshotCategory.memes:
        return 'Memes';
      case ScreenshotCategory.notes:
        return 'Notes';
      case ScreenshotCategory.trading:
        return 'Trading';
      case ScreenshotCategory.bankInfo:
        return 'Bank Info';
      case ScreenshotCategory.tickets:
        return 'Tickets';
      case ScreenshotCategory.shopping:
        return 'Shopping';
      case ScreenshotCategory.crypto:
        return 'Crypto';
      case ScreenshotCategory.miscellaneous:
        return 'Miscellaneous';
    }
  }

  String get emoji {
    switch (this) {
      case ScreenshotCategory.otp:
        return '🔐';
      case ScreenshotCategory.bills:
        return '💡';
      case ScreenshotCategory.receipts:
        return '🧾';
      case ScreenshotCategory.memes:
        return '😂';
      case ScreenshotCategory.notes:
        return '📝';
      case ScreenshotCategory.trading:
        return '📈';
      case ScreenshotCategory.bankInfo:
        return '🏦';
      case ScreenshotCategory.tickets:
        return '🎫';
      case ScreenshotCategory.shopping:
        return '🛍️';
      case ScreenshotCategory.crypto:
        return '₿';
      case ScreenshotCategory.miscellaneous:
        return '📁';
    }
  }

  Color get color {
    switch (this) {
      case ScreenshotCategory.otp:
        return const Color(0xFF6C63FF);
      case ScreenshotCategory.bills:
        return const Color(0xFFFF6B6B);
      case ScreenshotCategory.receipts:
        return const Color(0xFF4ECDC4);
      case ScreenshotCategory.memes:
        return const Color(0xFFFFBE0B);
      case ScreenshotCategory.notes:
        return const Color(0xFF3A86FF);
      case ScreenshotCategory.trading:
        return const Color(0xFF06D6A0);
      case ScreenshotCategory.bankInfo:
        return const Color(0xFF118AB2);
      case ScreenshotCategory.tickets:
        return const Color(0xFFFF9F1C);
      case ScreenshotCategory.shopping:
        return const Color(0xFFE63946);
      case ScreenshotCategory.crypto:
        return const Color(0xFFF7931A);
      case ScreenshotCategory.miscellaneous:
        return const Color(0xFF8D99AE);
    }
  }

  IconData get icon {
    switch (this) {
      case ScreenshotCategory.otp:
        return Icons.lock_outline;
      case ScreenshotCategory.bills:
        return Icons.receipt_long_outlined;
      case ScreenshotCategory.receipts:
        return Icons.receipt_outlined;
      case ScreenshotCategory.memes:
        return Icons.sentiment_very_satisfied_outlined;
      case ScreenshotCategory.notes:
        return Icons.note_outlined;
      case ScreenshotCategory.trading:
        return Icons.trending_up;
      case ScreenshotCategory.bankInfo:
        return Icons.account_balance_outlined;
      case ScreenshotCategory.tickets:
        return Icons.confirmation_number_outlined;
      case ScreenshotCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ScreenshotCategory.crypto:
        return Icons.currency_bitcoin;
      case ScreenshotCategory.miscellaneous:
        return Icons.folder_outlined;
    }
  }
}

class CategoryStats {
  final ScreenshotCategory category;
  final int count;
  final DateTime? latestScreenshot;

  const CategoryStats({
    required this.category,
    required this.count,
    this.latestScreenshot,
  });
}
