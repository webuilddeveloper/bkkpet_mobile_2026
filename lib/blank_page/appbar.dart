import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bkkpet/style_theme.dart';

/// -------------------------
/// Home AppBar (ของเดิม)
/// -------------------------
class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String welcomeText;
  final String profileImage;
  final String guestIconAsset;
  final bool isLoggedIn;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const AppBarHome({
    super.key,
    this.userName = 'นายทดสอบ',
    this.welcomeText = 'ยินดีต้อนรับ',
    this.profileImage = 'assets/images/profile_test.png',
    this.guestIconAsset = 'assets/icons/iconapp.png',
    this.isLoggedIn = true,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarProvider =
        isLoggedIn
            ? (profileImage.startsWith('assets/')
                ? AssetImage(profileImage)
                : FileImage(File(profileImage)) as ImageProvider)
            : AssetImage(guestIconAsset);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onProfileTap,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.greyscale_25,
                    border: Border.all(color: AppColors.greyscale_200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image(
                            image: avatarProvider,
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              welcomeText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.greyscale_400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoggedIn && onNotificationTap != null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: onNotificationTap,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.greyscale_50),
                        ),
                        child: Image.asset('assets/icons/notification.png'),
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                )
              else
                const SizedBox(width: 45, height: 45),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

/// -------------------------
/// Main AppBar (ใช้กับหน้าทั่วไป)
/// -------------------------

class AppBarMainApp extends StatelessWidget implements PreferredSizeWidget {
  const AppBarMainApp({
    super.key,
    required this.title,
    required this.onBack,
    this.actions,
  });

  final String title;
  final VoidCallback onBack;

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Stack(
            children: [
              /// เนื้อหา AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onBack,
                          child: Center(
                            child: Image.asset(
                              'assets/icons/Icon_back.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Title
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyscale_800,
                          ),
                        ),
                      ),
                    ),

                    /// Right Actions
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: actions == null ? 48 : (actions!.length * 48.0),
                        height: 48,
                        child:
                            actions == null
                                ? const SizedBox.shrink()
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: actions!,
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              /// เส้นด้านล่าง (เว้นซ้าย-ขวา)
              const Positioned(
                left: 32,
                right: 32,
                bottom: 0,
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xffF1F3F5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

/// -------------------------
/// Chat AppBar (หน้าปรึกษาแชทหมอ)
/// -------------------------

class AppBarChat extends StatelessWidget implements PreferredSizeWidget {
  const AppBarChat({
    super.key,
    required this.doctorName,
    required this.onBack,
    this.profileImage = 'assets/images/profile_test.png',
    this.isOnline = true,
    this.statusText,
    this.onCallTap,
    this.onMoreTap,
  });

  final String doctorName;
  final VoidCallback onBack;
  final String profileImage;
  final bool isOnline;

  /// ข้อความสถานะ เช่น "Active Now" ถ้าไม่ระบุจะใช้ค่า default ตามสถานะออนไลน์
  final String? statusText;

  final VoidCallback? onCallTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                /// Back Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greyscale_50,
                    border: Border.all(color: AppColors.greyscale_300),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.greyscale_800,
                    ),
                    onPressed: onBack,
                  ),
                ),
                SizedBox(width: 16),

                /// Avatar
                ClipOval(
                  child: Image.asset(
                    profileImage,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          color: AppColors.greyscale_50,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.greyscale_400,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 10),

                /// Name + status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        doctorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greyscale_800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText ?? (isOnline ? 'Active Now' : 'Offline'),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isOnline
                                  ? AppColors.greenlight
                                  : AppColors.greyscale_400,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Call Button
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.call_outlined,
                    size: 22,
                    color: AppColors.greyscale_800,
                  ),
                  onPressed: onCallTap,
                ),
                const SizedBox(width: 4),

                /// More Button
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    size: 22,
                    color: AppColors.greyscale_800,
                  ),
                  onPressed: onMoreTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
