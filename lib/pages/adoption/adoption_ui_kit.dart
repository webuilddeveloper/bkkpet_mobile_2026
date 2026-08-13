import 'package:bkkpet/blank_page/app_field_styles.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdoptionSectionCard extends StatelessWidget {
  const AdoptionSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.greyscale_900,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class AdoptionFormField extends StatelessWidget {
  const AdoptionFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.required = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool required;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: buildAppFieldLabel(label, required: required),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            validator:
                validator ??
                (required
                    ? (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'กรุณากรอกข้อมูล'
                            : null
                    : null),
            decoration:
                buildAppInputDecoration(
                  hintText: hint,
                  prefixIcon:
                      icon != null
                          ? Icon(
                            icon,
                            size: 18,
                            color: AppColors.greyscale_400,
                          )
                          : null,
                ).copyWith(
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class AdoptionDropdown extends StatelessWidget {
  const AdoptionDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: buildAppFieldLabel(label),
          ),
          DropdownButtonFormField<String>(
            initialValue: value,
            items:
                options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            isDense: true,
            style: TextStyle(fontSize: 14, color: AppColors.greyscale_900),
            decoration: buildAppInputDecoration(hintText: label),
          ),
        ],
      ),
    );
  }
}

class AdoptionCheckRow extends StatelessWidget {
  const AdoptionCheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: value,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => onChanged(v ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: AppColors.greyscale_900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ชิปเลือกได้ ใช้ทั้งใน filter sheet และหน้าจองเวลา
class AdoptionChoiceChip extends StatelessWidget {
  const AdoptionChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyscale_200,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                disabled
                    ? AppColors.greyscale_300
                    : selected
                    ? AppColors.primary
                    : AppColors.greyscale_800,
          ),
        ),
      ),
    );
  }
}

class AdoptionTag extends StatelessWidget {
  const AdoptionTag({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.greyscale_800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.greyscale_50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// รูปตัวแทนสัตว์เลี้ยง (ใช้แทนรูปจริงจนกว่าจะต่อ API/รูปถ่ายจริง)
class AdoptionPetAvatarPlaceholder extends StatelessWidget {
  const AdoptionPetAvatarPlaceholder({
    super.key,
    required this.species,
    this.imageAsset,
    this.height = 150,
    this.borderRadius = 16,
    this.fillWidth = false,
  });

  final String species;
  final String? imageAsset;
  final double height;
  final double borderRadius;
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final isDog = species == 'สุนัข';
    // return Container(
    //   height: height,
    //   width: height * 2,
    //   decoration: BoxDecoration(
    //     color:
    //         isDog
    //             ? AppColors.greenlight.withOpacity(0.5)
    //             : AppColors.greyscale_50,
    //     borderRadius: BorderRadius.circular(borderRadius),
    //   ),
    //   alignment: Alignment.center,

    //   child: Image.asset(
    //     isDog ? "assets/images/dog.png" : "assets/images/cat.png",
    //     height: height * 0.34,
    //     color: isDog ? AppColors.primary : AppColors.greyscale_800,
    //   ),
    // );
    return Center(
      child: Container(
        height: height,
        width: fillWidth ? double.infinity : height * 2,
        decoration: BoxDecoration(
          color:
              isDog
                  ? AppColors.greenlight.withOpacity(0.5)
                  : AppColors.greyscale_50,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias, // กันรูปเลยมุมโค้ง
        child:
            imageAsset != null && imageAsset!.isNotEmpty
                ? Image.asset(
                  imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Image.asset(
                        isDog
                            ? 'assets/images/dog2.avif'
                            : 'assets/images/cat2.jpeg',
                        fit: BoxFit.contain,
                      ),
                )
                : Image.asset(
                  isDog ? "assets/images/dog2.avif" : "assets/images/cat2.jpeg",
                  fit: BoxFit.cover, // แสดงเต็มโดยไม่ตัด
                ),
      ),
    );
  }
}

class AdoptionPrimaryButton extends StatelessWidget {
  const AdoptionPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child:
            loading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

/// แถบปุ่มยึดด้านล่างจอ ใช้ร่วมกันทุกหน้าฟอร์ม
class AdoptionBottomBar extends StatelessWidget {
  const AdoptionBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
