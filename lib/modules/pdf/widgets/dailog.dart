import 'package:flutter/material.dart';
import 'package:task_8/core/theme/app_colors.dart';
import 'package:task_8/modules/pdf/models/Keyword.dart';

class CustomDialog extends StatefulWidget {
  final List<Keyword> keywords;

  const CustomDialog({super.key, required this.keywords});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.keywords.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 1, color: Colors.white),
          itemBuilder: (context, index) {
            final keyword = widget.keywords[index];
            final isExpanded = _expandedIndex == index;
            final definition = keyword.definition ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          keyword.word ?? '',
                          style: TextStyle(
                            color: AppColors.darkColor,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 22,
                            color: AppColors.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      right: 12,
                      left: 12,
                      bottom: 12,
                      top: 4,
                    ),
                    child: Text(
                      definition,
                      style: TextStyle(
                        color: AppColors.darkColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
