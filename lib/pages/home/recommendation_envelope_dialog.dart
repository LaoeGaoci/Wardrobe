import 'package:flutter/material.dart';

import '../../models/clothing.dart';
import '../../models/clothing_recommendation.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/clothing_card.dart';

class RecommendationEnvelopeDialog
    extends StatefulWidget {
  final ClothingRecommendation
  recommendation;

  const RecommendationEnvelopeDialog({
    super.key,
    required this.recommendation,
  });

  @override
  State<RecommendationEnvelopeDialog>
  createState() =>
      _RecommendationEnvelopeDialogState();
}

class _RecommendationEnvelopeDialogState
    extends State<
        RecommendationEnvelopeDialog> {
  final RecommendationService
  _service =
      RecommendationService.instance;

  /// false：
  ///   还只是一个信封。
  ///
  /// true：
  ///   已经拆开，显示推荐内容。
  bool _opened = false;

  /// 正在请求 PATCH /read。
  bool _savingRead = false;

  // ============================================================
  // Open
  // ============================================================

  void _openEnvelope() {
    setState(() {
      _opened = true;
    });
  }

  // ============================================================
  // Close + mark read
  // ============================================================

  /// 用户点击“收好这封信”：
  ///
  /// PATCH /api/recommendations/:id/read
  ///
  /// 成功以后才真正关闭 Dialog。
  ///
  /// 这样可以保证：
  ///
  /// 服务器已读状态
  /// 和
  /// 首页信封队列
  ///
  /// 始终一致。
  Future<void> _closeLetter() async {
    if (_savingRead) {
      return;
    }

    setState(() {
      _savingRead = true;
    });

    try {
      await _service.markAsRead(
        widget.recommendation.id,
      );

      if (!mounted) {
        return;
      }

      /// true 表示：
      ///
      /// 这封信已经成功阅读并收好。
      Navigator.pop(
        context,
        true,
      );
    } on RecommendationException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _savingRead = false;
      });

      ScaffoldMessenger.of(
        context,
      )
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.message,
            ),
          ),
        );
    }
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final senderName =
        widget
            .recommendation
            .fromUser
            .username;

    final clothes =
        widget
            .recommendation
            .clothes;

    return Dialog(
      insetPadding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: AnimatedSize(
        duration:
        const Duration(
          milliseconds: 400,
        ),

        curve:
        Curves.easeInOut,

        child: _opened
            ? _buildOpenedLetter(
          senderName,
          clothes,
        )
            : _buildEnvelope(
          senderName,
        ),
      ),
    );
  }

  // ============================================================
  // Closed envelope
  // ============================================================

  Widget _buildEnvelope(
      String senderName,
      ) {
    return Padding(
      padding:
      const EdgeInsets.all(
        28,
      ),

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          const Icon(
            Icons.mail_outline,
            size: 96,
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            '你收到一封衣物推荐',
            style:
            Theme.of(
              context,
            )
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight:
              FontWeight.bold,
            ),
            textAlign:
            TextAlign.center,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '$senderName 给你寄来了一封信',
            style:
            Theme.of(
              context,
            )
                .textTheme
                .bodyMedium,
            textAlign:
            TextAlign.center,
          ),

          const SizedBox(
            height: 28,
          ),

          FilledButton.icon(
            onPressed:
            _openEnvelope,

            icon:
            const Icon(
              Icons
                  .markunread_outlined,
            ),

            label:
            const Text(
              '拆开信件',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Opened letter
  // ============================================================

  Widget _buildOpenedLetter(
      String senderName,
      List<Clothing> clothes,
      ) {
    return Padding(
      padding:
      const EdgeInsets.all(
        20,
      ),

      child: ConstrainedBox(
        constraints:
        const BoxConstraints(
          maxHeight: 600,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ----------------------------------------------------
            // Header
            // ----------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons
                      .drafts_outlined,
                  size: 28,
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    '来自 $senderName 的推荐',
                    style:
                    Theme.of(
                      context,
                    )
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ----------------------------------------------------
            // Message
            // ----------------------------------------------------

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                16,
              ),

              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  16,
                ),

                color:
                Theme.of(
                  context,
                )
                    .colorScheme
                    .surfaceContainerHighest,
              ),

              child: Text(
                widget
                    .recommendation
                    .message,

                style:
                Theme.of(
                  context,
                )
                    .textTheme
                    .bodyLarge,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              '推荐衣物',

              style:
              Theme.of(
                context,
              )
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ----------------------------------------------------
            // Clothes
            // ----------------------------------------------------

            Expanded(
              child: clothes.isEmpty
                  ? const Center(
                child: Text(
                  '推荐的衣物已经不存在了',
                ),
              )
                  : GridView.builder(
                itemCount:
                clothes.length,

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing:
                  10,
                  mainAxisSpacing:
                  10,
                  childAspectRatio:
                  0.72,
                ),

                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  return ClothingCard(
                    clothing:
                    clothes[
                    index
                    ],
                  );
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ----------------------------------------------------
            // Finish
            // ----------------------------------------------------

            SizedBox(
              width:
              double.infinity,

              child: FilledButton.icon(
                onPressed:
                _savingRead
                    ? null
                    : _closeLetter,

                icon: _savingRead
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),
                )
                    : const Icon(
                  Icons
                      .inventory_2_outlined,
                ),

                label: Text(
                  _savingRead
                      ? '正在收好'
                      : '收好这封信',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}