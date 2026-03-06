import 'package:flutter/material.dart';
import 'package:task_8/core/theme/app_colors.dart';
import 'package:task_8/modules/pdf/pdfprovider.dart';

class PdfVideoArea extends StatelessWidget {
  final PdfProvider provider;
  final bool isMuted;
  final bool showSubtitle;
  final String currentSubtitle;
  final String subtitleLang;
  final ScrollController thumbnailController;
  final GlobalKey headphonesKey;
  final GlobalKey subtitleKey;
  final VoidCallback onToggleMute;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onHeadphonesPress;
  final VoidCallback onSubtitlePress;
  final VoidCallback onKeywordsPress;
  final Function(int) onThumbnailTap;

  const PdfVideoArea({
    super.key,
    required this.provider,
    required this.isMuted,
    required this.showSubtitle,
    required this.currentSubtitle,
    required this.subtitleLang,
    required this.thumbnailController,
    required this.headphonesKey,
    required this.subtitleKey,
    required this.onToggleMute,
    required this.onPrevious,
    required this.onNext,
    required this.onHeadphonesPress,
    required this.onSubtitlePress,
    required this.onKeywordsPress,
    required this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * (10 / 16),
      color: Colors.black,
      child: Stack(
        children: [
          // الصورة
          provider.currentSlide != null
              ? Image.network(
                  provider.currentSlide!.url!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stack) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                )
              : const Center(child: Text('No Slides')),

          // Subtitle
          if (showSubtitle && currentSubtitle.isNotEmpty)
            Positioned(
              bottom: 50,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  currentSubtitle,
                  textAlign: TextAlign.center,
                  textDirection: subtitleLang == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black45,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: onToggleMute,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.navigate_before,
                      color: Colors.white,
                    ),
                    onPressed: provider.currentSlideIndex > 0
                        ? onPrevious
                        : null,
                  ),
                  Text(
                    '${provider.currentSlideIndex + 1} / ${provider.totalSlides}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next, color: Colors.white),
                    onPressed:
                        provider.currentSlideIndex < provider.totalSlides - 1
                        ? onNext
                        : null,
                  ),
                  const Spacer(),
                  IconButton(
                    key: headphonesKey,
                    icon: const Icon(Icons.headphones, color: Colors.white),
                    onPressed: onHeadphonesPress,
                  ),
                  IconButton(
                    key: subtitleKey,
                    icon: Icon(
                      Icons.subtitles,
                      color: showSubtitle
                          ? AppColors.primaryColor
                          : Colors.white,
                    ),
                    onPressed: onSubtitlePress,
                  ),
                  IconButton(
                    icon: const Icon(Icons.key, color: Colors.white, size: 25),
                    onPressed: onKeywordsPress,
                  ),
                ],
              ),
            ),
          ),

          // Thumbnails
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 45,
              color: Colors.black54,
              child: ListView.builder(
                controller: thumbnailController,
                scrollDirection: Axis.horizontal,
                itemCount: provider.totalSlides,
                itemBuilder: (context, index) {
                  final isSelected = index == provider.currentSlideIndex;
                  return GestureDetector(
                    onTap: () => onThumbnailTap(index),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.white38,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          provider.frameList![index].url!,
                          width: 55,
                          height: 37,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            width: 55,
                            height: 37,
                            color: Colors.grey[800],
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
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
