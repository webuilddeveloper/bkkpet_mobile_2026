import 'package:bkkpet/pages/adoption/adoption_application_page.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionDetailPage extends StatelessWidget {
  const AdoptionDetailPage({super.key, required this.pet});

  final AdoptionPet pet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: AdoptionPetAvatarPlaceholder(
                    species: pet.species,
                    imageAsset: pet.imageAsset,
                    height: 260,
                    borderRadius: 0,
                    fillWidth: true,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.greyscale_900,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.greyscale_400,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            pet.district,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyscale_400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AdoptionTag(
                            label: pet.species,
                            color: AppColors.primary,
                          ),
                          AdoptionTag(label: pet.breed),
                          AdoptionTag(label: pet.gender),
                          AdoptionTag(label: pet.ageLabel),
                          AdoptionTag(label: 'ขนาด${pet.size}'),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: _HealthBadge(
                              icon: Icons.medical_services_outlined,
                              label: 'ทำหมันแล้ว',
                              active: pet.sterilized,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _HealthBadge(
                              icon: Icons.vaccines_outlined,
                              label: 'วัคซีนครบ',
                              active: pet.vaccinated,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      AdoptionSectionCard(
                        icon: Icons.pets,
                        title: 'ลักษณะนิสัย',
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                pet.temperament
                                    .map((t) => AdoptionTag(label: t))
                                    .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AdoptionSectionCard(
                        icon: Icons.menu_book_outlined,
                        title: 'ประวัติความเป็นมา',
                        children: [
                          Text(
                            pet.history,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.greyscale_800,
                            ),
                          ),
                        ],
                      ),
                      if (pet.healthNote.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        AdoptionSectionCard(
                          icon: Icons.info_outline,
                          title: 'ข้อควรทราบด้านสุขภาพ',
                          children: [
                            Text(
                              pet.healthNote,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: AppColors.greyscale_800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AdoptionBottomBar(
              child: AdoptionPrimaryButton(
                label: 'สมัครขอรับเลี้ยง',
                icon: Icons.favorite,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AdoptionApplicationPage(
                            application: AdoptionApplication(pet: pet),
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.greyscale_900),
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.greyscale_200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : icon,
            size: 18,
            color: active ? AppColors.primary : AppColors.greyscale_400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.greyscale_400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
