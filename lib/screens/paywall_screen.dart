import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({
    super.key,
    required this.onDismiss,
    required this.onPurchaseCompleted,
    required this.onRestoreCompleted,
  });

  final VoidCallback onDismiss;
  final VoidCallback onPurchaseCompleted;
  final VoidCallback onRestoreCompleted;

  @override
  Widget build(BuildContext context) {
    return PaywallView(
      displayCloseButton: true,
      onDismiss: onDismiss,
      onPurchaseCompleted: (customerInfo, storeTransaction) =>
          onPurchaseCompleted(),
      onRestoreCompleted: (_) => onRestoreCompleted(),
    );
  }
}
