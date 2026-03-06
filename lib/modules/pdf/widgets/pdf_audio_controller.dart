import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:task_8/core/theme/app_colors.dart';
import 'package:task_8/modules/pdf/pdfprovider.dart';

class PdfAudioController {
  final AudioPlayer audioPlayer;
  final PdfProvider pdfProvider;

  PdfAudioController({required this.audioPlayer, required this.pdfProvider});

  List<String> getAudioLangs() {
    final audioLangs = <String>[];
    if (pdfProvider.audioList != null) {
      for (var audio in pdfProvider.audioList!) {
        if (audio.langCode != null && !audioLangs.contains(audio.langCode)) {
          audioLangs.add(audio.langCode!);
        }
      }
    }
    return audioLangs;
  }

  String? getAudioUrl(String langCode) {
    if (pdfProvider.audioList != null) {
      for (var audio in pdfProvider.audioList!) {
        if (audio.langCode == langCode) return audio.url;
      }
    }
    return null;
  }

  void showAudioLanguageMenu({
    required BuildContext context,
    required GlobalKey key,
    required String selectedAudioLang,
    required Function(String) onSelected,
  }) {
    final audioLangs = getAudioLangs();
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
    showMenu(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: audioLangs.map((lang) {
        final isSelected = lang == selectedAudioLang;
        return PopupMenuItem<String>(
          value: lang,
          child: Row(
            children: [
              const Icon(Icons.language, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                lang == 'ar' ? 'Arabic' : 'English',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primaryColor : Colors.black,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
            ],
          ),
        );
      }).toList(),
    ).then((lang) {
      if (lang != null) onSelected(lang);
    });
  }
}
