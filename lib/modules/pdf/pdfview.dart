import 'package:flutter/material.dart';
import 'package:task_8/core/resources/ap_constant.dart';
import 'package:task_8/core/theme/app_colors.dart';
import 'package:task_8/modules/pdf/pdfprovider.dart';
import 'package:task_8/modules/pdf/widgets/audio_provider.dart';
import 'package:task_8/modules/pdf/widgets/dailog.dart';
import 'package:task_8/modules/pdf/widgets/dropdown.dart';
import 'package:task_8/modules/pdf/widgets/pdf_subtitle_controller.dart';
import 'package:task_8/modules/pdf/widgets/pdf_video_area.dart';
import 'package:provider/provider.dart';

class PdfView extends StatefulWidget {
  const PdfView({super.key});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  late PdfProvider _pdfProvider;
  late AudioProvider _audioProvider;
  late PdfSubtitleController _subtitleController;

  String selected = "transcript";
  String? selectedlanguage = AppConstants.defult_language;

  final ScrollController _thumbnailController = ScrollController();
  final GlobalKey _headphonesKey = GlobalKey();
  final GlobalKey _subtitleKey = GlobalKey();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pdfProvider = PdfProvider();
    _fetchData();
  }

  void _fetchData() async {
    await _pdfProvider.fetchPdfData();
    _audioProvider = AudioProvider(pdfProvider: _pdfProvider);
    _subtitleController = PdfSubtitleController(pdfProvider: _pdfProvider);
    setState(() {
      _initialized = true;
    });
  }

  void _showKeywordsDialog(BuildContext context, PdfProvider provider) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(keywords: provider.keywords!),
    );
  }

  @override
  void dispose() {
    _audioProvider.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _pdfProvider),
        ChangeNotifierProvider.value(value: _audioProvider),
      ],
      child: Consumer2<PdfProvider, AudioProvider>(
        builder: (context, pdfProv, audioProv, child) {
          if (pdfProv.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final displayText = _subtitleController.getDisplayText(
            selectedlanguage,
            selected,
            pdfProv.currentSlideIndex,
          );

          return Scaffold(
            backgroundColor: AppColors.lightColor,
            body: SafeArea(
              child: Column(
                children: [
                  // ===== منطقة الفيديو =====
                  PdfVideoArea(
                    provider: pdfProv,
                    isMuted: audioProv.isMuted,
                    showSubtitle: audioProv.showSubtitle,
                    currentSubtitle: audioProv.currentSubtitle,
                    subtitleLang: audioProv.subtitleLang,
                    thumbnailController: _thumbnailController,
                    headphonesKey: _headphonesKey,
                    subtitleKey: _subtitleKey,
                    onToggleMute: () => audioProv.toggleMute(),
                    onPrevious: () {
                      audioProv.onSlideChanged();
                      pdfProv.previousSlide();
                    },
                    onNext: () {
                      audioProv.onSlideChanged();
                      pdfProv.nextSlide();
                    },
                    onHeadphonesPress: () {
                      final langs = audioProv.getAudioLangs();
                      if (langs.length == 1) {
                        audioProv.playAudio(langs.first);
                      } else {
                        audioProv.showAudioLanguageMenu(
                          context: context,
                          key: _headphonesKey,
                          onSelected: (lang) => audioProv.playAudio(lang),
                        );
                      }
                    },
                    onSubtitlePress: () => audioProv.showSubtitleMenu(
                      context: context,
                      key: _subtitleKey,
                    ),
                    onKeywordsPress: () =>
                        _showKeywordsDialog(context, pdfProv),
                    onThumbnailTap: (index) {
                      audioProv.onSlideChanged();
                      pdfProv.goToSlide(index);
                    },
                  ),

                  // ===== Audio Slider =====
                  if (audioProv.showSlider)
                    Container(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            audioProv.formatDuration(audioProv.position),
                            style: TextStyle(
                              color: AppColors.darkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: audioProv.position.inSeconds
                                  .toDouble()
                                  .clamp(
                                    0,
                                    audioProv.duration.inSeconds.toDouble(),
                                  ),
                              min: 0,
                              max: audioProv.duration.inSeconds.toDouble() > 0
                                  ? audioProv.duration.inSeconds.toDouble()
                                  : 1,
                              activeColor: AppColors.primaryColor,
                              onChanged: (value) => audioProv.seekTo(
                                Duration(seconds: value.toInt()),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              audioProv.isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: AppColors.primaryColor,
                              size: 30,
                            ),
                            onPressed: () => audioProv.togglePlayPause(),
                          ),
                          Text(
                            audioProv.formatDuration(audioProv.duration),
                            style: TextStyle(
                              color: AppColors.darkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ===== النص =====
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomDropdown(
                                    hint: 'data language',
                                    value: selectedlanguage,
                                    items: pdfProv.languageCodes,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      for (
                                        int i = 0;
                                        i < pdfProv.availableLanguages!.length;
                                        i++
                                      ) {
                                        if (value ==
                                            pdfProv
                                                .availableLanguages![i]
                                                .languageCode) {
                                          pdfProv.selectData(i);
                                        }
                                      }
                                      setState(() {
                                        selectedlanguage = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomDropdown(
                                    hint: 'data format',
                                    value: selected,
                                    items: const [
                                      "summary25",
                                      "summary50",
                                      "transcript",
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      pdfProv.selected(value);
                                      setState(() {
                                        selected = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              selected == 'transcript'
                                  ? displayText
                                  : (pdfProv.selectedvalue ??
                                        pdfProv.defaultSelectedValue() ??
                                        ''),
                              style: TextStyle(
                                color: AppColors.darkColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
