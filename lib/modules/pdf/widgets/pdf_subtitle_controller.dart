import 'package:flutter/material.dart';
import 'package:task_8/core/theme/app_colors.dart';
import 'package:task_8/modules/pdf/pdfprovider.dart';

class PdfSubtitleController {
  final PdfProvider pdfProvider;

  PdfSubtitleController({required this.pdfProvider});

  String getSlideTranscript(String langCode, int slideIndex) {
    final langs = pdfProvider.availableLanguages;
    if (langs == null) return '';
    String? transcript;
    for (var lang in langs) {
      if (lang.languageCode == langCode) {
        transcript = lang.data?.transcript;
        break;
      }
    }
    if (transcript == null || transcript.isEmpty) return '';
    transcript = transcript
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final RegExp slideRegex = RegExp(
      r'(Slide\s+\d+\s*:|شريحة\s+\d+\s*:)',
      caseSensitive: false,
    );
    final matches = slideRegex.allMatches(transcript).toList();
    if (matches.isEmpty) return transcript;
    if (slideIndex >= matches.length) slideIndex = matches.length - 1;
    final start = matches[slideIndex].end;
    final end = slideIndex + 1 < matches.length
        ? matches[slideIndex + 1].start
        : transcript.length;
    return transcript.substring(start, end).trim();
  }

  List<String> splitToChunks(String text, {int chunkSize = 80}) {
    final words = text.split(' ');
    final chunks = <String>[];
    String current = '';
    for (var word in words) {
      if ((current + ' ' + word).trim().length > chunkSize) {
        if (current.isNotEmpty) chunks.add(current.trim());
        current = word;
      } else {
        current = (current + ' ' + word).trim();
      }
    }
    if (current.isNotEmpty) chunks.add(current.trim());
    return chunks;
  }

  String getCurrentSubtitle(
    Duration position,
    int slideIndex,
    String subtitleLang,
  ) {
    final text = getSlideTranscript(subtitleLang, slideIndex);
    if (text.isEmpty) return '';
    final chunks = splitToChunks(text);
    if (chunks.isEmpty) return '';
    final frame = pdfProvider.frameList![slideIndex];
    final slideDuration = frame.duration ?? 60.0;
    final slideStart = frame.startTime ?? 0.0;
    final elapsed = position.inSeconds - slideStart;
    final progress = (elapsed / slideDuration).clamp(0.0, 1.0);
    final chunkIndex = (progress * chunks.length).floor().clamp(
      0,
      chunks.length - 1,
    );
    return chunks[chunkIndex];
  }

  String getDisplayText(
    String? selectedlanguage,
    String selected,
    int slideIndex,
  ) {
    final langCode = selectedlanguage ?? 'en';
    final langs = pdfProvider.availableLanguages;
    if (langs == null) return '';
    for (var lang in langs) {
      if (lang.languageCode == langCode) {
        if (selected == 'transcript')
          return getSlideTranscript(langCode, slideIndex);
        if (selected == 'summary25') return lang.data?.summary25 ?? '';
        if (selected == 'summary50') return lang.data?.summary50 ?? '';
      }
    }
    return '';
  }

  void showSubtitleMenu({
    required BuildContext context,
    required GlobalKey key,
    required bool showSubtitle,
    required String subtitleLang,
    required Function(String) onSelected,
  }) {
    final RenderBox button =
        key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem<String>(
          value: 'off',
          child: Row(
            children: [
              const Icon(Icons.subtitles_off, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Off',
                style: TextStyle(
                  fontSize: 15,
                  color: !showSubtitle ? AppColors.primaryColor : Colors.black,
                  fontWeight: !showSubtitle
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (!showSubtitle)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
            ],
          ),
        ),
        _buildSubtitleItem('en', 'English', showSubtitle, subtitleLang),
        _buildSubtitleItem('ar', 'Arabic', showSubtitle, subtitleLang),
      ],
    ).then((lang) {
      if (lang != null) onSelected(lang);
    });
  }

  PopupMenuItem<String> _buildSubtitleItem(
    String lang,
    String label,
    bool showSubtitle,
    String subtitleLang,
  ) {
    final isSelected = showSubtitle && subtitleLang == lang;
    return PopupMenuItem<String>(
      value: lang,
      child: Row(
        children: [
          const Icon(Icons.language, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryColor : Colors.black,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check_circle, color: AppColors.primaryColor, size: 18),
        ],
      ),
    );
  }
}
