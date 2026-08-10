import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/chat/message_chat.dart';
import 'package:bkkpet/pages/consult/consult_booking_page.dart';
import 'package:bkkpet/pages/consult/consult_favorite_storage.dart';
import 'package:bkkpet/pages/consult/consult_page_models.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ConsultFavoriteDoctorsPage extends StatefulWidget {
  const ConsultFavoriteDoctorsPage({super.key});

  @override
  State<ConsultFavoriteDoctorsPage> createState() =>
      _ConsultFavoriteDoctorsPageState();
}

class _ConsultFavoriteDoctorsPageState extends State<ConsultFavoriteDoctorsPage> {
  late Future<Set<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = ConsultFavoriteStorage.getAll();
  }

  void _reload() {
    setState(() => _future = ConsultFavoriteStorage.getAll());
  }

  List<ConsultDoctor> _favoriteDoctors(Set<String> ids) {
    return consultDoctors.where((doctor) => ids.contains(doctor.id)).toList();
  }

  Future<void> _toggleFavorite(String doctorId) async {
    await ConsultFavoriteStorage.toggle(doctorId);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarMainApp(
        title: 'รายการหมอที่ถูกใจ',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<Set<String>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final ids = snapshot.data ?? <String>{};
          final items = _favoriteDoctors(ids);

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 48,
                      color: AppColors.greyscale_300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ยังไม่มีหมอที่กดถูกใจไว้',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'กดรูปหัวใจบนการ์ดหมอจากหน้าหลักเพื่อบันทึกไว้ที่หน้านี้',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.greenlight.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  'แตะการ์ดเพื่อจองนัด แชท หรือดูรายละเอียดหมอได้ทันที',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primarySecondary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final doctor in items) ...[
                _FavoriteDoctorCard(
                  doctor: doctor,
                  isFavorite: true,
                  onFavoriteTap: () => _toggleFavorite(doctor.id),
                  onReviewTap: () {
                    showInfoDialog(
                      context: context,
                      icon: Icons.star_rounded,
                      title: 'รีวิวหมอ',
                      message:
                          '${doctor.name}\nคะแนนเฉลี่ย ${doctor.rating.toStringAsFixed(1)} จากประสบการณ์ ${doctor.experienceYears} ปี',
                      color: AppColors.primary,
                    );
                  },
                  onChatTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageChatPage(
                          doctorName: doctor.name,
                          profileImage: doctor.imageUrl,
                          isOnline: doctor.isOnlineNow,
                        ),
                      ),
                    );
                  },
                  onBookingTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultBookingPage(doctor: doctor),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FavoriteDoctorCard extends StatelessWidget {
  const _FavoriteDoctorCard({
    required this.doctor,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onReviewTap,
    required this.onChatTap,
    required this.onBookingTap,
  });

  final ConsultDoctor doctor;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onReviewTap;
  final VoidCallback onChatTap;
  final VoidCallback onBookingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              doctor.imageUrl,
              width: 92,
              height: 112,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onFavoriteTap,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.greyscale_400,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Tag(label: doctor.clinic),
                    _Tag(label: doctor.area),
                    _Tag(label: '${doctor.experienceYears} ปี'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onReviewTap,
                      child: const Text('รีวิว'),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: onChatTap,
                      child: const Text('แชท'),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: onBookingTap,
                      child: const Text('จองนัด'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.primarySecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
