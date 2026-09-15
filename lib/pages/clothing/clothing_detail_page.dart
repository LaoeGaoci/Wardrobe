import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/clothing.dart';
import '../../network/api_client.dart';
import '../../services/clothing_repository.dart';
import '../../widgets/info_row.dart';
import 'edit_clothing_page.dart';

class ClothingDetailPage
    extends StatefulWidget {
  final Clothing clothing;

  const ClothingDetailPage({
    super.key,
    required this.clothing,
  });

  @override
  State<ClothingDetailPage>
  createState() =>
      _ClothingDetailPageState();
}

class _ClothingDetailPageState
    extends State<ClothingDetailPage> {
  late Clothing _clothing;

  final ClothingRepository
  _repository =
      ClothingRepository.instance;

  bool _deleting = false;

  @override
  void initState() {
    super.initState();

    _clothing =
        widget.clothing;
  }

  // ============================================================
  // Edit
  // ============================================================

  Future<void> _editCard()
  async {
    final updated =
    await Navigator.push<
        Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditClothingPage(
              clothing:
              _clothing,
            ),
      ),
    );

    if (updated == null ||
        !mounted) {
      return;
    }

    setState(() {
      _clothing =
          updated;
    });
  }

  // ============================================================
  // Delete
  // ============================================================

  Future<void>
  _deleteClothing()
  async {
    if (_deleting) {
      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        final colorScheme =
            Theme.of(context)
                .colorScheme;

        return AlertDialog(
          icon: Icon(
            Icons
                .delete_outline,
            color:
            colorScheme.error,
          ),

          title:
          const Text(
            '删除衣物',
          ),

          content: Text(
            '确定要删除“${_clothing.name}”吗？\n\n'
                '删除后无法恢复。',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text(
                '取消',
              ),
            ),

            FilledButton(
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                colorScheme
                    .error,
                foregroundColor:
                colorScheme
                    .onError,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              const Text(
                '删除',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    try {
      // DELETE
      // /api/clothing/:id
      await _repository
          .deleteClothing(
        _clothing.id,
      );

      if (!mounted) {
        return;
      }

      // WardrobePage 在详情页返回后
      // 会重新调用 fetchMyClothes()，
      // 所以这里只需要正常返回。
      Navigator.pop(
        context,
      );
    } on ClothingRepositoryException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _deleting =
        false;
      });

      ScaffoldMessenger.of(
        context,
      )
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content:
            Text(
              e.message,
            ),
            behavior:
            SnackBarBehavior
                .floating,
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _deleting =
        false;
      });

      ScaffoldMessenger.of(
        context,
      )
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content:
            Text(
              '删除衣物失败，请稍后重试',
            ),
            behavior:
            SnackBarBehavior
                .floating,
          ),
        );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final l10n =
        context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n
              .clothingDetails,
        ),
      ),

      body: ListView(
        children: [
          _buildImage(),

          Padding(
            padding:
            const EdgeInsets
                .all(
              20,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  _clothing
                      .name,
                  style:
                  const TextStyle(
                    fontSize: 26,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                InfoRow(
                  title:
                  l10n.brand,
                  value:
                  _clothing
                      .brand ??
                      l10n
                          .notSet,
                ),

                InfoRow(
                  title:
                  l10n
                      .category,
                  value:
                  localizedCategory(
                    context,
                    _clothing
                        .category,
                  ),
                ),

                InfoRow(
                  title:
                  l10n.color,
                  value:
                  _clothing
                      .color,
                ),

                InfoRow(
                  title:
                  l10n.season,
                  value:
                  localizedSeason(
                    context,
                    _clothing
                        .season,
                  ),
                ),

                InfoRow(
                  title:
                  l10n.price,
                  value: _clothing
                      .price ==
                      null
                      ? l10n
                      .notSet
                      : '¥${_clothing.price}',
                ),

                InfoRow(
                  title:
                  l10n
                      .visibility,
                  value:
                  localizedVisibility(
                    context,
                    _clothing
                        .visibility,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                // ==================================================
                // Edit
                // ==================================================

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton
                      .icon(
                    onPressed:
                    _deleting
                        ? null
                        : _editCard,
                    icon:
                    const Icon(
                      Icons
                          .edit_outlined,
                    ),
                    label:
                    Text(
                      l10n
                          .editCard,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================================
                // Delete
                // ==================================================

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  OutlinedButton
                      .icon(
                    onPressed:
                    _deleting
                        ? null
                        : _deleteClothing,

                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      Theme.of(
                        context,
                      )
                          .colorScheme
                          .error,

                      side:
                      BorderSide(
                        color:
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .error,
                      ),
                    ),

                    icon:
                    _deleting
                        ? SizedBox(
                      width:
                      18,
                      height:
                      18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color:
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .error,
                      ),
                    )
                        : const Icon(
                      Icons
                          .delete_outline,
                    ),

                    label:
                    Text(
                      _deleting
                          ? '正在删除...'
                          : '删除衣物',
                    ),
                  ),
                ),

                // 防止部分 Android
                // 系统导航栏与按钮太近。
                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Image
  // ============================================================

  Widget _buildImage() {
    if (_clothing
        .imagePath
        .isEmpty) {
      return _buildImageError();
    }

    if (_clothing.imageType ==
        ClothingImageType.local) {
      return Image.file(
        File(
          _clothing.imagePath,
        ),
        height: 420,
        width:
        double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (
            context,
            error,
            stackTrace,
            ) {
          return _buildImageError();
        },
      );
    }

    return Image.network(
      _remoteImageUrl(),

      headers:
      ApiClient.instance
          .authorizationHeaders,

      height: 420,
      width:
      double.infinity,
      fit: BoxFit.cover,

      errorBuilder:
          (
          context,
          error,
          stackTrace,
          ) {
        return _buildImageError();
      },
    );
  }

  String _remoteImageUrl() {
    final resolved =
    ApiClient.instance
        .resolveUrl(
      _clothing.imagePath,
    );

    final uri =
    Uri.parse(
      resolved,
    );

    return uri
        .replace(
      queryParameters: {
        ...uri
            .queryParameters,

        // 防止修改图片后仍然命中旧缓存。
        'v': _clothing
            .updatedAt
            .millisecondsSinceEpoch
            .toString(),
      },
    )
        .toString();
  }

  Widget _buildImageError() {
    return Container(
      height: 420,
      color:
      Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons
              .image_not_supported_outlined,
          size: 56,
          color:
          Colors.grey.shade400,
        ),
      ),
    );
  }
}