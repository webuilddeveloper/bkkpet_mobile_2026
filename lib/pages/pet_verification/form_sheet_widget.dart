import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ================================================================
/// ฟิลด์ฟอร์มสำหรับใช้กับ FormBottomSheet
/// ================================================================
class SheetFormField {
  const SheetFormField({
    required this.label,
    required this.controller,
    this.icon,
    this.required = false,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool required;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
}

/// ================================================================
/// Bottom sheet ฟอร์มใช้ซ้ำได้ทั่วแอป (แจ้งหาย/พบสัตว์, คำขอโอนเจ้าของ ฯลฯ)
///
/// onConfirm ควร return true เมื่อบันทึกสำเร็จ (จะปิดชีตให้อัตโนมัติ)
/// และ return false เมื่อข้อมูลไม่ครบ (จะแสดงข้อความแจ้งเตือนในชีต)
/// ================================================================
class FormBottomSheet extends StatefulWidget {
  const FormBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.fields,
    required this.onConfirm,
    this.confirmColor,
    this.additionalChildren = const [],
  });

  final String title;
  final String subtitle;
  final String confirmLabel;
  final List<SheetFormField> fields;
  final Future<bool> Function() onConfirm;
  final Color? confirmColor;
  final List<Widget> additionalChildren;

  @override
  State<FormBottomSheet> createState() => _FormBottomSheetState();
}

class _FormBottomSheetState extends State<FormBottomSheet> {
  bool _submitting = false;
  bool _showError = false;

  Future<void> _handleConfirm() async {
    setState(() => _submitting = true);
    final ok = await widget.onConfirm();
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _showError = !ok;
    });
    if (ok && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor = widget.confirmColor ?? AppColors.primary;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.greyscale_200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                    ],
                  ),
                ),

                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.greyscale_50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final field in widget.fields)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 6,
                                left: 2,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: field.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.greyscale_900,
                                  ),
                                  children:
                                      field.required
                                          ? const [
                                            TextSpan(
                                              text: ' *',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ]
                                          : null,
                                ),
                              ),
                            ),
                            TextField(
                              controller: field.controller,
                              keyboardType: field.keyboardType,
                              inputFormatters: field.inputFormatters,
                              maxLines: field.maxLines,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: field.hint,
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.greyscale_300,
                                ),
                                prefixIcon:
                                    field.icon != null
                                        ? Icon(
                                          field.icon,
                                          size: 18,
                                          color: AppColors.greyscale_400,
                                        )
                                        : null,
                                filled: true,
                                fillColor: AppColors.greyscale_25,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.greyscale_200,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.greyscale_200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: confirmColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...widget.additionalChildren,
                    if (_showError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'กรุณากรอกข้อมูลที่จำเป็น (ช่องที่มีเครื่องหมาย *) ให้ครบถ้วน',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    _submitting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          widget.confirmLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
