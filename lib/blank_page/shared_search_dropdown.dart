import 'package:bkkpet/blank_page/custom_textfield.dart';
import 'package:bkkpet/blank_page/app_field_styles.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

const String _kCustomInputToken = '__custom_input__';

class SharedSearchDropdownField extends StatefulWidget {
  const SharedSearchDropdownField({
    super.key,
    required this.label,
    required this.valueText,
    required this.options,
    required this.onSelected,
    this.hintText = 'เลือกข้อมูล',
    this.searchHintText = 'ค้นหา',
    this.required = false,
    this.enabled = true,
    this.allowCustomInput = false,
    this.customInputLabel = 'อื่นๆ',
  });

  final String label;
  final String? valueText;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String hintText;
  final String searchHintText;
  final bool required;
  final bool enabled;
  final bool allowCustomInput;
  final String customInputLabel;

  @override
  State<SharedSearchDropdownField> createState() =>
      _SharedSearchDropdownFieldState();
}

class _SharedSearchDropdownFieldState extends State<SharedSearchDropdownField> {
  final _customCtrl = TextEditingController();
  final _customFocusNode = FocusNode();
  String? _customErrorText;
  bool _showCustomInput = false;

  @override
  void dispose() {
    _customCtrl.dispose();
    _customFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _SearchDropdownSheet(
            title: widget.label,
            searchHintText: widget.searchHintText,
            options: widget.options,
            allowCustomInput: widget.allowCustomInput,
            customInputLabel: widget.customInputLabel,
          ),
    );

    if (picked == null) return;

    if (picked == _kCustomInputToken) {
      setState(() {
        _showCustomInput = true;
        _customErrorText = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _customFocusNode.requestFocus();
      });
      return;
    }

    setState(() {
      _showCustomInput = false;
      _customErrorText = null;
      _customCtrl.clear();
    });
    widget.onSelected(picked);
  }

  void _submitCustom() {
    final text = _customCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _customErrorText = 'กรุณากรอกข้อมูล');
      return;
    }

    final normalized = text.toLowerCase();
    final duplicate = widget.options.any(
      (item) => item.trim().toLowerCase() == normalized,
    );
    if (duplicate) {
      setState(
        () =>
            _customErrorText =
                'ข้อมูลนี้มีอยู่ในรายการแล้ว กรุณาเลือกจากรายการ',
      );
      return;
    }

    setState(() {
      _showCustomInput = false;
      _customErrorText = null;
    });
    widget.onSelected(text);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = (widget.valueText ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: buildAppFieldLabel(widget.label, required: widget.required),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.enabled ? () => _openPicker(context) : null,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: widget.enabled ? Colors.white : AppColors.greyscale_25,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyscale_200),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color:
                        widget.enabled
                            ? AppColors.greyscale_400
                            : AppColors.greyscale_300,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hasValue ? widget.valueText! : widget.hintText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            hasValue
                                ? AppColors.greyscale_900
                                : AppColors.greyscale_300,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color:
                        widget.enabled
                            ? AppColors.greyscale_400
                            : AppColors.greyscale_300,
                  ),
                ],
              ),
            ),
          ),
          if (widget.allowCustomInput && _showCustomInput) ...[
            const SizedBox(height: 10),
            _InlineCustomInput(
              title: widget.customInputLabel,
              controller: _customCtrl,
              focusNode: _customFocusNode,
              errorText: _customErrorText,
              onChanged: (_) => setState(() => _customErrorText = null),
              onSubmit: _submitCustom,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchDropdownSheet extends StatefulWidget {
  const _SearchDropdownSheet({
    required this.title,
    required this.searchHintText,
    required this.options,
    required this.allowCustomInput,
    required this.customInputLabel,
  });

  final String title;
  final String searchHintText;
  final List<String> options;
  final bool allowCustomInput;
  final String customInputLabel;

  @override
  State<_SearchDropdownSheet> createState() => _SearchDropdownSheetState();
}

class _SearchDropdownSheetState extends State<_SearchDropdownSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    final filtered =
        widget.options
            .where(
              (item) =>
                  item.toLowerCase().contains(_searchCtrl.text.toLowerCase()) &&
                  (!widget.allowCustomInput ||
                      item.trim() != widget.customInputLabel.trim()),
            )
            .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 560),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyscale_200,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ปิด'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomSearchField(
                  controller: _searchCtrl,
                  hintText: widget.searchHintText,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child:
                    filtered.isEmpty && !widget.allowCustomInput
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'ไม่พบข้อมูลที่ค้นหา',
                              style: TextStyle(
                                color: AppColors.greyscale_400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                        : ListView.separated(
                          shrinkWrap: true,
                          itemCount:
                              filtered.length +
                              (widget.allowCustomInput ? 1 : 0),
                          separatorBuilder:
                              (_, __) => Divider(
                                height: 1,
                                color: AppColors.greyscale_50,
                              ),
                          itemBuilder: (context, index) {
                            if (widget.allowCustomInput &&
                                index == filtered.length) {
                              return ListTile(
                                leading: Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: AppColors.primarySecondary,
                                ),
                                title: Text(widget.customInputLabel),
                                subtitle: const Text(
                                  'พิมพ์ข้อมูลใหม่ในช่องด้านล่างของฟอร์ม',
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.greyscale_300,
                                ),
                                onTap:
                                    () => Navigator.pop(
                                      context,
                                      _kCustomInputToken,
                                    ),
                              );
                            }

                            final itemIndex = index;
                            final item = filtered[itemIndex];
                            return ListTile(
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.greyscale_400,
                              ),
                              title: Text(item),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineCustomInput extends StatelessWidget {
  const _InlineCustomInput({
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onChanged,
    required this.onSubmit,
  });

  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greenlight.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'โน๊ต: พิมพ์$titleใหม่ได้ตรงนี้',
            style: TextStyle(fontSize: 11.5, color: AppColors.greyscale_400),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: 'พิมพ์$titleใหม่',
              filled: true,
              fillColor: Colors.white,
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyscale_200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyscale_200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text('เพิ่มข้อมูล'),
            ),
          ),
        ],
      ),
    );
  }
}
