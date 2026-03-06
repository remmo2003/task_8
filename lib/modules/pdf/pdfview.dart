import 'package:flutter/material.dart';
import 'package:task_8/core/resources/ap_constant.dart';
import 'package:task_8/core/theme/app_colors.dart';
import 'package:task_8/modules/pdf/pdfprovider.dart';
import 'package:task_8/modules/pdf/widgets/dailog.dart';
import 'package:task_8/modules/pdf/widgets/dropdown.dart';
import 'package:task_8/modules/pdf/widgets/pdf_audio_controller.dart';
import 'package:task_8/modules/pdf/widgets/pdf_subtitle_controller.dart';
import 'package:task_8/modules/pdf/widgets/pdf_video_area.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

class PdfView extends StatefulWidget {
  const PdfView({super.key});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  PdfProvider? pdfProvider;
  late PdfAudioController _audioController;
  late PdfSubtitleController _subtitleController;

  bool isMuted = false;
  bool isPlaying = false;
  bool showSlider = false;
  String selected = "transcript";
  String? selectedlanguage = AppConstants.defult_language;
  String selectedAudioLang = AppConstants.defult_language;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  final ScrollController _thumbnailController = ScrollController();
  final GlobalKey _headphonesKey = GlobalKey();
  final GlobalKey _subtitleKey = GlobalKey();

  bool showSubtitle = false;
  String subtitleLang = 'en';
  String _currentSubtitle = '';
  bool _autoSlideEnabled = false;

  @override
  void initState() {
    super.initState();
    pdfProvider = PdfProvider();
    fetchData();

    _audioPlayer.durationStream.listen((d) {
      if (d != null)
        setState(() {
          _duration = d;
        });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
      if (pdfProvider != null && pdfProvider!.frameList != null) {
        if (_autoSlideEnabled) {
          final frames = pdfProvider!.frameList!;
          for (int i = frames.length - 1; i >= 0; i--) {
            final startTime = frames[i].startTime ?? 0.0;
            if (p.inMilliseconds / 1000.0 >= startTime) {
              if (pdfProvider!.currentSlideIndex != i) {
                setState(() {
                  _currentSubtitle = '';
                });
                pdfProvider!.goToSlide(i);
              }
              break;
            }
          }
        }
        if (showSubtitle) {
          final newSub = _subtitleController.getCurrentSubtitle(
            p,
            pdfProvider!.currentSlideIndex,
            subtitleLang,
          );
          if (newSub != _currentSubtitle)
            setState(() {
              _currentSubtitle = newSub;
            });
        }
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          isPlaying = false;
          showSlider = false;
          _position = Duration.zero;
          _currentSubtitle = '';
        }
      });
    });
  }

  void fetchData() async {
    await pdfProvider!.fetchPdfData();
    _audioController = PdfAudioController(
      audioPlayer: _audioPlayer,
      pdfProvider: pdfProvider!,
    );
    _subtitleController = PdfSubtitleController(pdfProvider: pdfProvider!);
    setState(() {});
  }

  Future<void> playAudio(String lang) async {
    setState(() {
      selectedAudioLang = lang;
      _autoSlideEnabled = false;
    });
    final url = _audioController.getAudioUrl(lang);
    if (url != null) {
      setState(() {
        showSlider = true;
      });
      final currentPosition = _position;
      final currentIndex = pdfProvider!.currentSlideIndex;
      final startTime = pdfProvider!.frameList![currentIndex].startTime ?? 0.0;
      await _audioPlayer.setUrl(url);
      final seekTo = currentPosition.inSeconds > 0
          ? currentPosition
          : Duration(milliseconds: (startTime * 1000).toInt());
      if (seekTo.inMilliseconds > 0) await _audioPlayer.seek(seekTo);
      if (pdfProvider!.currentSlideIndex != currentIndex)
        pdfProvider!.goToSlide(currentIndex);
      await _audioPlayer.play();
      setState(() {
        isPlaying = true;
        _autoSlideEnabled = true;
      });
    }
  }

  void onSlideChanged() {
    _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      showSlider = false;
      _position = Duration.zero;
      _duration = Duration.zero;
      _currentSubtitle = '';
      _autoSlideEnabled = false;
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _showKeywordsDialog(BuildContext context, provider) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(keywords: provider.keywords!),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pdfProvider == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider.value(
      value: pdfProvider!,
      child: Consumer<PdfProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final displayText = _subtitleController.getDisplayText(
            selectedlanguage,
            selected,
            provider.currentSlideIndex,
          );

          return Scaffold(
            backgroundColor: AppColors.lightColor,
            body: SafeArea(
              child: Column(
                children: [
                  PdfVideoArea(
                    provider: provider,
                    isMuted: isMuted,
                    showSubtitle: showSubtitle,
                    currentSubtitle: _currentSubtitle,
                    subtitleLang: subtitleLang,
                    thumbnailController: _thumbnailController,
                    headphonesKey: _headphonesKey,
                    subtitleKey: _subtitleKey,
                    onToggleMute: () => setState(() {
                      isMuted = !isMuted;
                      _audioPlayer.setVolume(isMuted ? 0 : 1);
                    }),
                    onPrevious: () {
                      onSlideChanged();
                      provider.previousSlide();
                    },
                    onNext: () {
                      onSlideChanged();
                      provider.nextSlide();
                    },
                    onHeadphonesPress: () {
                      final langs = _audioController.getAudioLangs();
                      if (langs.length == 1) {
                        playAudio(langs.first);
                      } else {
                        _audioController.showAudioLanguageMenu(
                          context: context,
                          key: _headphonesKey,
                          selectedAudioLang: selectedAudioLang,
                          onSelected: playAudio,
                        );
                      }
                    },
                    onSubtitlePress: () => _subtitleController.showSubtitleMenu(
                      context: context,
                      key: _subtitleKey,
                      showSubtitle: showSubtitle,
                      subtitleLang: subtitleLang,
                      onSelected: (lang) {
                        if (lang == 'off') {
                          setState(() {
                            showSubtitle = false;
                            _currentSubtitle = '';
                          });
                        } else {
                          setState(() {
                            showSubtitle = true;
                            subtitleLang = lang;
                            _currentSubtitle = '';
                          });
                        }
                      },
                    ),
                    onKeywordsPress: () =>
                        _showKeywordsDialog(context, provider),
                    onThumbnailTap: (index) {
                      onSlideChanged();
                      provider.goToSlide(index);
                    },
                  ),

                  if (showSlider)
                    Container(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            formatDuration(_position),
                            style: TextStyle(
                              color: AppColors.darkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: _position.inSeconds.toDouble().clamp(
                                0,
                                _duration.inSeconds.toDouble(),
                              ),
                              min: 0,
                              max: _duration.inSeconds.toDouble() > 0
                                  ? _duration.inSeconds.toDouble()
                                  : 1,
                              activeColor: AppColors.primaryColor,
                              onChanged: (value) {
                                _audioPlayer.seek(
                                  Duration(seconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: AppColors.primaryColor,
                              size: 30,
                            ),
                            onPressed: () async {
                              if (isPlaying) {
                                await _audioPlayer.pause();
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                await _audioPlayer.play();
                                setState(() {
                                  isPlaying = true;
                                });
                              }
                            },
                          ),
                          Text(
                            formatDuration(_duration),
                            style: TextStyle(
                              color: AppColors.darkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

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
                                    items: provider.languageCodes,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      for (
                                        int i = 0;
                                        i < provider.availableLanguages!.length;
                                        i++
                                      ) {
                                        if (value ==
                                            provider
                                                .availableLanguages![i]
                                                .languageCode) {
                                          provider.selectData(i);
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
                                      provider.selected(value);
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
                                  : (provider.selectedvalue ??
                                        provider.defaultSelectedValue() ??
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
