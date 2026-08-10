import 'dart:ui';

import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> banners;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Color activeColor;
  final Color inactiveColor;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.height = 180,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.activeColor = AppColors.greenlight,
    this.inactiveColor = AppColors.greyscale_200,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerHeight =
            constraints.maxWidth < 360
                ? widget.height.clamp(130.0, 160.0)
                : widget.height.clamp(150.0, 190.0);

        return Column(
          children: [
            SizedBox(
              height: bannerHeight,
              width: double.infinity,
              child: CarouselSlider.builder(
                itemCount: widget.banners.length,
                itemBuilder: (context, index, realIndex) {
                  final banner = widget.banners[index];

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          banner,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                        Image.asset(
                          banner,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  height: bannerHeight,
                  viewportFraction: 1,
                  autoPlay: widget.autoPlay,
                  autoPlayInterval: widget.autoPlayInterval,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: currentIndex == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color:
                        currentIndex == index
                            ? widget.activeColor
                            : widget.inactiveColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
