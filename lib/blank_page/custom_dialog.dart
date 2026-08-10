import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const String appLoadingLottie = 'assets/lotties/loading.json';
const String appSuccessLottie = 'assets/lotties/Checked.json';
const String appFailedLottie = 'assets/lotties/fail.json';
const String appErrorLottie = 'assets/lotties/error.json';
const String appExitLottie = 'assets/lotties/Exit.json';
const String appDeleteLottie = 'assets/lotties/Delete.json';

String _infoLottieAsset({required IconData icon, required String title}) {
  if (icon == Icons.check_circle_outline_rounded ||
      icon == Icons.check_circle_rounded ||
      title.contains('สำเร็จ') ||
      title.contains('เรียบร้อย')) {
    return appSuccessLottie;
  }
  if (icon == Icons.cancel_outlined ||
      icon == Icons.cancel_rounded ||
      title.contains('ไม่สำเร็จ') ||
      title.contains('ล้มเหลว')) {
    return appFailedLottie;
  }
  return appErrorLottie;
}

class _DialogVisualIcon extends StatelessWidget {
  const _DialogVisualIcon({
    required this.icon,
    required this.color,
    this.asset,
  });

  final IconData icon;
  final Color color;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(asset == null ? 0 : 6),
        child:
            asset == null
                ? Icon(icon, color: color, size: 42)
                : Lottie.asset(asset!, fit: BoxFit.contain),
      ),
    );
  }
}

Future<void> showConfirmDialog({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String message,
  required String confirmText,
  required Color confirmColor,
  required Future<void> Function() onConfirm,
  String cancelText = 'ยกเลิก',
  bool barrierDismissible = true,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        scrollable: true,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: confirmColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: confirmColor,
                      side: BorderSide(
                        color: confirmColor.withValues(alpha: 0.65),
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await onConfirm();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// dialog สำหรับ "แจ้งผลลัพธ์" (สำเร็จ/ผิดพลาด/แจ้งเตือนทั่วไป) มีปุ่มเดียว
Future<void> showInfoDialog({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String message,
  required Color color,
  String buttonText = 'ตกลง',
  bool barrierDismissible = false,
  VoidCallback? onClose,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final lottieAsset = _infoLottieAsset(icon: icon, title: title);

      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        scrollable: true,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogVisualIcon(icon: icon, asset: lottieAsset, color: color),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  onClose?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
