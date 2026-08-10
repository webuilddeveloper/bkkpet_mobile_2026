import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_loading.dart';
import 'package:bkkpet/blank_page/category_chip.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_detail_page.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_storage.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_detail_page.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_storage.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/services/notification_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final List<Map<String, dynamic>> _categories = const [
    {'id': 0, 'name': 'ทั้งหมด'},
    {'id': 1, 'name': 'จดทะเบียน'},
    {'id': 2, 'name': 'จองวัคซีน'},
    {'id': 3, 'name': 'จองทำหมัน'},
    {'id': 4, 'name': 'อื่นๆ'},
  ];

  int _selectedCategory = 0;
  final Set<String> _selectedIds = <String>{};
  List<NotificationRecord> _items = [];
  bool _loading = true;

  bool get _selectionMode => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (mounted) setState(() => _loading = true);
    final items = await NotificationStorage.getAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
      _selectedIds.removeWhere((id) => !_items.any((item) => item.id == id));
    });
  }

  List<NotificationRecord> get _filteredItems {
    return _items.where((item) {
      switch (_selectedCategory) {
        case 1:
          return item.kind == 'registration';
        case 2:
          return item.kind == 'vaccine';
        case 3:
          return item.kind == 'sterilization';
        case 4:
          return item.kind != 'registration' &&
              item.kind != 'vaccine' &&
              item.kind != 'sterilization';
        default:
          return true;
      }
    }).toList();
  }

  String _formatDate(DateTime date) {
    const months = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  String _serviceLabel(NotificationRecord item) {
    switch (item.kind) {
      case 'registration':
        return 'จดทะเบียน';
      case 'vaccine':
        return 'ฉีดวัคซีน';
      case 'sterilization':
        return 'ทำหมัน';
      default:
        return item.serviceLabel ?? 'แจ้งเตือน';
    }
  }

  IconData _serviceIcon(NotificationRecord item) {
    switch (item.kind) {
      case 'registration':
        return Icons.app_registration_rounded;
      case 'vaccine':
        return Icons.vaccines_outlined;
      case 'sterilization':
        return Icons.content_cut_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  MockPetProfile? _petFor(NotificationRecord item) {
    return MockUserStore.findPetById(item.petId) ??
        MockUserStore.findPetByName(item.petName);
  }

  String _displayImage(NotificationRecord item) {
    final image = _petFor(item)?.image ?? item.petImage;
    if (image == null || image.trim().isEmpty) {
      return 'assets/icons/iconapp.png';
    }
    return image.trim();
  }

  String _displayName(NotificationRecord item) {
    final name = _petFor(item)?.name ?? item.petName?.trim();
    return (name == null || name.isEmpty) ? 'สัตว์เลี้ยงของคุณ' : name;
  }

  String _displayGender(NotificationRecord item) {
    final gender = _petFor(item)?.gender ?? item.petGender?.trim();
    return (gender == null || gender.isEmpty) ? 'ไม่ระบุเพศ' : gender;
  }

  String _detailDate(NotificationRecord item) {
    final date = item.scheduleDate ?? item.createdAt;
    final time = item.scheduleTime;
    return time == null || time.isEmpty
        ? _formatDate(date)
        : '${_formatDate(date)} • $time';
  }

  Future<void> _openNotification(NotificationRecord item) async {
    await NotificationStorage.markRead(item.id);
    if (!mounted) return;
    setState(() {
      final index = _items.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isRead: true);
      }
    });

    if (item.kind == 'vaccine' && item.relatedId != null) {
      final record = await VaccineBookingStorage.getById(item.relatedId!);
      if (record != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VaccineBookingDetailPage(record: record),
          ),
        );
      }
    } else if (item.kind == 'sterilization' && item.relatedId != null) {
      final record = await SterilizationBookingStorage.getById(item.relatedId!);
      if (record != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SterilizationBookingDetailPage(record: record),
          ),
        );
      }
    } else if (mounted) {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greyscale_900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: AppColors.greyscale_800,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('ปิด'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    await _loadItems();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectOne(String id) {
    setState(() => _selectedIds.add(id));
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  Future<void> _markAllRead() async {
    await NotificationStorage.markAllRead();
    await _loadItems();
    _clearSelection();
  }

  Future<void> _clearAll() async {
    await NotificationStorage.clearAll();
    await _loadItems();
    _clearSelection();
  }

  Future<void> _markSelectedRead() async {
    for (final id in _selectedIds.toList()) {
      await NotificationStorage.markRead(id);
    }
    await _loadItems();
    _clearSelection();
  }

  Future<void> _deleteSelected() async {
    for (final id in _selectedIds.toList()) {
      await NotificationStorage.remove(id);
    }
    await _loadItems();
    _clearSelection();
  }

  Future<void> _removeOne(String id) async {
    await NotificationStorage.remove(id);
    await _loadItems();
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final unreadCount = _items.where((item) => !item.isRead).length;
    final hasSelection = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'แจ้งเตือน',
        onBack: () => Navigator.pop(context),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          // padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 12,
            //     offset: const Offset(0, -2),
            //   ),
            // ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          hasSelection ? _markSelectedRead : _markAllRead,
                      child: const Text('อ่านทั้งหมด'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: hasSelection ? _deleteSelected : _clearAll,
                      child: const Text('ลบทั้งหมด'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body:
          _loading
              ? const Center(child: AppLoadingIndicator())
              : AppRefreshIndicator(
                onRefresh: _loadItems,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  children: [
                    CategoryChip(
                      items: _categories,
                      selectedId: _selectedCategory,
                      primaryColor: AppColors.primary,
                      onSelected: (id) {
                        _clearSelection();
                        setState(() => _selectedCategory = id);
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.greenlight.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 18,
                            color: AppColors.primarySecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              unreadCount > 0
                                  ? 'คุณมีแจ้งเตือนใหม่ $unreadCount รายการ'
                                  : 'แจ้งเตือนทั้งหมดถูกอ่านแล้ว',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primarySecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'ยังไม่มีแจ้งเตือน',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.greyscale_900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'เมื่อมีการจดทะเบียน จองวัคซีน หรือจองทำหมันสำเร็จ รายการจะแสดงที่หน้านี้',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.55,
                                color: AppColors.greyscale_400,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationCard(
                            item: item,
                            selected: _selectedIds.contains(item.id),
                            selectionMode: _selectionMode,
                            onTap: () {
                              if (_selectionMode) {
                                _toggleSelection(item.id);
                              } else {
                                _openNotification(item);
                              }
                            },
                            onLongPress: () {
                              if (_selectedIds.isEmpty) {
                                _selectOne(item.id);
                              } else {
                                _toggleSelection(item.id);
                              }
                            },
                            onDelete: () => _removeOne(item.id),
                            serviceLabel: _serviceLabel(item),
                            serviceIcon: _serviceIcon(item),
                            displayImage: _displayImage(item),
                            displayName: _displayName(item),
                            displayGender: _displayGender(item),
                            detailText: _detailDate(item),
                          ),
                        ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    required this.serviceLabel,
    required this.serviceIcon,
    required this.displayImage,
    required this.displayName,
    required this.displayGender,
    required this.detailText,
  });

  final NotificationRecord item;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final String serviceLabel;
  final IconData serviceIcon;
  final String displayImage;
  final String displayName;
  final String displayGender;
  final String detailText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : item.isRead
                  ? Colors.white
                  : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected
                    ? AppColors.primary
                    : item.isRead
                    ? AppColors.greyscale_200
                    : AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          _NotificationPetImage(image: displayImage),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        item.isRead
                                            ? FontWeight.w700
                                            : FontWeight.w800,
                                    color: AppColors.greyscale_900,
                                  ),
                                ),
                                Text(
                                  displayGender,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.greyscale_400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectionMode)
                            Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color:
                                  selected
                                      ? AppColors.primary
                                      : AppColors.greyscale_300,
                              size: 20,
                            )
                          else
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                serviceIcon,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greenlight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'บริการ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.greyscale_900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    serviceLabel,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.greyscale_900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'วันที่',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.greyscale_900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detailText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.greyscale_900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // if (hasExtraText) ...[
            //   const SizedBox(height: 12),
            //   Text(
            //     item.message,
            //     style: TextStyle(
            //       fontSize: 13,
            //       height: 1.55,
            //       color: AppColors.greyscale_800,
            //     ),
            //   ),
            //   if (item.locationName != null &&
            //       item.locationName!.isNotEmpty) ...[
            //     const SizedBox(height: 8),
            //     Text(
            //       item.locationName!,
            //       style: TextStyle(
            //         fontSize: 12.5,
            //         fontWeight: FontWeight.w600,
            //         color: AppColors.primarySecondary,
            //       ),
            //     ),
            //   ],
            //   if (item.locationAddress != null &&
            //       item.locationAddress!.isNotEmpty) ...[
            //     const SizedBox(height: 3),
            //     Text(
            //       item.locationAddress!,
            //       style: TextStyle(
            //         fontSize: 12,
            //         color: AppColors.greyscale_400,
            //       ),
            //     ),
            //   ],
            // ],
          ],
        ),
      ),
    );
  }
}

class _NotificationPetImage extends StatelessWidget {
  const _NotificationPetImage({required this.image});

  final String image;

  static const String _fallbackImage = 'assets/icons/iconapp.png';

  @override
  Widget build(BuildContext context) {
    final imagePath = image.trim().isEmpty ? _fallbackImage : image.trim();
    final imageWidget =
        imagePath.startsWith('http')
            ? Image.network(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
            : Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            );

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: imageWidget,
    );
  }

  Widget _fallback() {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(10),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Image.asset(_fallbackImage, fit: BoxFit.contain),
    );
  }
}
