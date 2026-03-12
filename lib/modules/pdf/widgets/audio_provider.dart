import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:task_8/modules/pdf/pdfprovider.dart';
import 'package:task_8/core/theme/app_colors.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PdfProvider pdfProvider;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;
  bool showSlider = false;
  bool isMuted = false;
  bool _autoSlideEnabled = false;
  String selectedAudioLang = 'en';

  // Subtitle
  bool showSubtitle = false;
  String subtitleLang = 'en';
  String currentSubtitle = '';

  Duration get duration => _duration;
  Duration get position => _position;
  AudioPlayer get audioPlayer => _audioPlayer;

  AudioProvider({required this.pdfProvider}) {
    _audioPlayer.durationStream.listen((d) {
      if (d != null) {
        _duration = d;
        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((p) {
      _position = p;

      // auto slide
      if (_autoSlideEnabled && pdfProvider.frameList != null) {
        final frames = pdfProvider.frameList!;
        for (int i = frames.length - 1; i >= 0; i--) {
          final startTime = frames[i].startTime ?? 0.0;
          if (p.inMilliseconds / 1000.0 >= startTime) {
            if (pdfProvider.currentSlideIndex != i) {
              currentSubtitle = '';
              pdfProvider.goToSlide(i);
            }
            break;
          }
        }
      }

      // subtitle
      if (showSubtitle && pdfProvider.frameList != null) {
        final newSub = _getCurrentSubtitle(p, pdfProvider.currentSlideIndex);
        if (newSub != currentSubtitle) {
          currentSubtitle = newSub;
        }
      }

      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        isPlaying = false;
        showSlider = false;
        _position = Duration.zero;
        currentSubtitle = '';
      }
      notifyListeners();
    });
  }

  String? getAudioUrl(String langCode) {
    if (pdfProvider.audioList != null) {
      for (var audio in pdfProvider.audioList!) {
        if (audio.langCode == langCode) return audio.url;
      }
    }
    return null;
  }

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

  Future<void> playAudio(String lang) async {
    selectedAudioLang = lang;
    _autoSlideEnabled = false;
    notifyListeners();

    final url = getAudioUrl(lang);
    if (url != null) {
      showSlider = true;
      notifyListeners();

      final currentPosition = _position;
      final currentIndex = pdfProvider.currentSlideIndex;
      final startTime = pdfProvider.frameList![currentIndex].startTime ?? 0.0;

      await _audioPlayer.setUrl(url);

      final seekTo = currentPosition.inSeconds > 0
          ? currentPosition
          : Duration(milliseconds: (startTime * 1000).toInt());
      if (seekTo.inMilliseconds > 0) await _audioPlayer.seek(seekTo);

      if (pdfProvider.currentSlideIndex != currentIndex) {
        pdfProvider.goToSlide(currentIndex);
      }

      await _audioPlayer.play();
      isPlaying = true;
      _autoSlideEnabled = true;
      notifyListeners();
    }
  }

  void onSlideChanged() {
    _audioPlayer.stop();
    isPlaying = false;
    showSlider = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    currentSubtitle = '';
    _autoSlideEnabled = false;
    notifyListeners();
  }

  void toggleMute() {
    isMuted = !isMuted;
    _audioPlayer.setVolume(isMuted ? 0 : 1);
    notifyListeners();
  }

  void togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      isPlaying = false;
    } else {
      await _audioPlayer.play();
      isPlaying = true;
    }
    notifyListeners();
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  void setSubtitle(String lang) {
    showSubtitle = true;
    subtitleLang = lang;
    currentSubtitle = '';
    notifyListeners();
  }

  void hideSubtitle() {
    showSubtitle = false;
    currentSubtitle = '';
    notifyListeners();
  }

  String _getCurrentSubtitle(Duration position, int slideIndex) {
    final text = _getSlideTranscript(subtitleLang, slideIndex);
    if (text.isEmpty) return '';
    final chunks = _splitToChunks(text);
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

  String _getSlideTranscript(String langCode, int slideIndex) {
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

  List<String> _splitToChunks(String text, {int chunkSize = 80}) {
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

  void showAudioLanguageMenu({
    required BuildContext context,
    required GlobalKey key,
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

  void showSubtitleMenu({
    required BuildContext context,
    required GlobalKey key,
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
        _buildSubtitleItem('en', 'English'),
        _buildSubtitleItem('ar', 'Arabic'),
      ],
    ).then((lang) {
      if (lang == null) return;
      if (lang == 'off')
        hideSubtitle();
      else
        setSubtitle(lang);
    });
  }

  PopupMenuItem<String> _buildSubtitleItem(String lang, String label) {
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

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
