import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/clothing.dart';
import '../../network/api_client.dart';
import '../../services/clothing_repository.dart';

class EditClothingPage extends StatefulWidget {
  final Clothing clothing;

  const EditClothingPage({
    super.key,
    required this.clothing,
  });

  @override
  State<EditClothingPage> createState() =>
      _EditClothingPageState();
}

class _EditClothingPageState
    extends State<EditClothingPage> {
  final _formKey = GlobalKey<FormState>();

  final ClothingRepository _repository =
      ClothingRepository.instance;

  final ImagePicker _imagePicker =
  ImagePicker();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _brandController;

  late final TextEditingController
  _colorController;

  late final TextEditingController
  _priceController;

  late String _selectedCategory;
  late String _selectedSeason;
  late ClothingVisibility _visibility;

  XFile? _newImage;

  bool _saving = false;

  final List<String> _categories = [
    '上衣',
    '外套',
    '羽绒服',
    '裤子',
    '帽子',
    '鞋子',
    '配饰',
  ];

  final List<String> _seasons = [
    '春季',
    '夏季',
    '秋季',
    '冬季',
  ];

  @override
  void initState() {
    super.initState();

    final clothing = widget.clothing;

    _nameController = TextEditingController(
      text: clothing.name,
    );

    _brandController = TextEditingController(
      text: clothing.brand ?? '',
    );

    _colorController = TextEditingController(
      text: clothing.color,
    );

    _priceController = TextEditingController(
      text: clothing.price?.toString() ?? '',
    );

    _selectedCategory = clothing.category;
    _selectedSeason = clothing.season;
    _visibility = clothing.visibility;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  // ============================================================
  // Image
  // ============================================================

  Future<void> _selectImage() async {
    if (_saving) {
      return;
    }

    final source =
    await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '更换衣物图片',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                  title: const Text('拍照'),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      ImageSource.camera,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  title: const Text(
                    '从相册选择',
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    try {
      final image =
      await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _newImage = image;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      final reason = localizedErrorMessage(
        context,
        e.toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '选择图片失败：$reason',
          ),
        ),
      );
    }
  }

  // ============================================================
  // Save
  // ============================================================

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      final rawPrice =
      _priceController.text.trim();

      final double? price =
      rawPrice.isEmpty
          ? null
          : double.parse(rawPrice);

      // 不使用 copyWith。
      //
      // 因为编辑页面需要允许 brand / price
      // 从已有值真正变成 null。
      final requestClothing = Clothing(
        id: widget.clothing.id,
        ownerId: widget.clothing.ownerId,

        name: _nameController.text.trim(),

        brand: _brandController.text
            .trim()
            .isEmpty
            ? null
            : _brandController.text.trim(),

        category: _selectedCategory,

        color: _colorController.text.trim(),

        season: _selectedSeason,

        price: price,

        // 更新基本资料时先保留旧图片。
        imagePath:
        widget.clothing.imagePath,

        imageType:
        widget.clothing.imageType,

        visibility: _visibility,

        createdAt:
        widget.clothing.createdAt,

        updatedAt:
        widget.clothing.updatedAt,
      );

      // 1. 更新 D1 中的衣物资料。
      Clothing updated =
      await _repository.updateClothing(
        requestClothing,
      );

      // 2. 如果用户选择了新图片，再上传 R2。
      final newImage = _newImage;

      if (newImage != null) {
        updated =
        await _repository.uploadClothingImage(
          clothingId: updated.id,
          imagePath: newImage.path,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        updated,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      final reason = localizedErrorMessage(
        context,
        e.toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.saveFailed(reason),
          ),
        ),
      );
    }
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '编辑衣物',
        ),

        // 不再提供右上角保存按钮。
        actions: const [],
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            14,
          ),

          children: [
            // 图片
            _buildImageEditor(),

            const SizedBox(height: 20),

            // ==================================================
            // 名称
            // ==================================================

            TextFormField(
              controller: _nameController,
              textInputAction:
              TextInputAction.next,
              enabled: !_saving,
              decoration:
              _buildInputDecoration(
                label: l10n.name,
                hint: l10n.nameExample,
                icon:
                Icons.checkroom_outlined,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return l10n
                      .clothingNameRequired;
                }

                if (value.trim().length >
                    100) {
                  return l10n.nameMax100;
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            // ==================================================
            // 品牌 + 颜色
            // ==================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                    _brandController,
                    textInputAction:
                    TextInputAction.next,
                    enabled: !_saving,
                    decoration:
                    _buildInputDecoration(
                      label: l10n.brand,
                      hint: l10n.optional,
                      icon:
                      Icons.sell_outlined,
                    ),
                    validator: (value) {
                      if (value != null &&
                          value
                              .trim()
                              .length >
                              100) {
                        return l10n
                            .brandMax100;
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    controller:
                    _colorController,
                    textInputAction:
                    TextInputAction.next,
                    enabled: !_saving,
                    decoration:
                    _buildInputDecoration(
                      label: l10n.color,
                      hint:
                      l10n.colorExample,
                      icon:
                      Icons.palette_outlined,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return l10n
                            .colorRequired;
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // 分类 + 季节
            // ==================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                  DropdownButtonFormField<
                      String>(
                    initialValue:
                    _selectedCategory,

                    isExpanded: true,

                    decoration:
                    _buildInputDecoration(
                      label: l10n.category,
                      icon:
                      Icons.category_outlined,
                    ),

                    items: _categories.map(
                          (category) {
                        return DropdownMenuItem<
                            String>(
                          value: category,
                          child: Text(
                            localizedCategory(
                              context,
                              category,
                            ),
                            overflow:
                            TextOverflow
                                .ellipsis,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: _saving
                        ? null
                        : (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setState(() {
                        _selectedCategory =
                            value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child:
                  DropdownButtonFormField<
                      String>(
                    initialValue:
                    _selectedSeason,

                    isExpanded: true,

                    decoration:
                    _buildInputDecoration(
                      label: l10n.season,
                      icon: Icons
                          .calendar_month_outlined,
                    ),

                    items: _seasons.map(
                          (season) {
                        return DropdownMenuItem<
                            String>(
                          value: season,
                          child: Text(
                            localizedSeason(
                              context,
                              season,
                            ),
                            overflow:
                            TextOverflow
                                .ellipsis,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: _saving
                        ? null
                        : (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setState(() {
                        _selectedSeason =
                            value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // 价格
            // ==================================================

            TextFormField(
              controller:
              _priceController,

              enabled: !_saving,

              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),

              textInputAction:
              TextInputAction.done,

              decoration:
              _buildInputDecoration(
                label: l10n.price,
                hint: l10n.optional,
                icon:
                Icons.payments_outlined,
                prefixText: '¥ ',
              ),

              validator: (value) {
                final text =
                    value?.trim() ?? '';

                if (text.isEmpty) {
                  return null;
                }

                final price =
                double.tryParse(text);

                if (price == null ||
                    price < 0) {
                  return l10n.validPrice;
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // Visibility
            // ==================================================

            _buildVisibilitySelector(),

            const SizedBox(height: 12),
          ],
        ),
      ),

      // ========================================================
      // 唯一的保存按钮
      // ========================================================

      bottomNavigationBar: SafeArea(
        top: false,

        // 与 AddClothingPage 一致，
        // 在系统 SafeArea 基础上额外向上留 28px。
        minimum: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          28,
        ),

        child: SizedBox(
          height: 52,

          child: FilledButton(
            onPressed:
            _saving
                ? null
                : _save,

            style:
            FilledButton.styleFrom(
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),
            ),

            child: _saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            )
                : const Text(
              '保存修改',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Image
  // ============================================================

  Widget _buildImageEditor() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(20),

      child: SizedBox(
        // 与新增衣物页面保持一致。
        height: 300,

        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),

            // 下方轻微渐变，
            // 保证更换图片按钮在浅色图片上也清晰。
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.center,
                      end: Alignment
                          .bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black
                            .withValues(
                          alpha: 0.22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 更换图片按钮直接放在图片中，
            // 不再额外占据一整行。
            Positioned(
              right: 12,
              bottom: 12,

              child:
              FilledButton.tonalIcon(
                onPressed:
                _saving
                    ? null
                    : _selectImage,

                icon: const Icon(
                  Icons
                      .photo_camera_outlined,
                  size: 18,
                ),

                label: Text(
                  _newImage == null
                      ? '更换图片'
                      : '重新选择',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final newImage = _newImage;

    // 用户刚选择的新图片。
    if (newImage != null) {
      return Image.file(
        File(newImage.path),
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildImageError();
        },
      );
    }

    final clothing =
        widget.clothing;

    if (clothing.imagePath.isEmpty) {
      return _buildImageError();
    }

    // 本地旧图片。
    if (clothing.imageType ==
        ClothingImageType.local) {
      return Image.file(
        File(clothing.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildImageError();
        },
      );
    }

    // R2 / 后端远程图片。
    return Image.network(
      _remoteImageUrl(clothing),

      headers:
      ApiClient.instance
          .authorizationHeaders,

      fit: BoxFit.cover,

      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return _buildImageError();
      },
    );
  }

  String _remoteImageUrl(
      Clothing clothing,
      ) {
    final resolved =
    ApiClient.instance.resolveUrl(
      clothing.imagePath,
    );

    final uri =
    Uri.parse(resolved);

    // 使用 updatedAt 避免编辑图片以后
    // Flutter / HTTP 缓存继续显示旧图。
    return uri
        .replace(
      queryParameters: {
        ...uri.queryParameters,

        'v': clothing
            .updatedAt
            .millisecondsSinceEpoch
            .toString(),
      },
    )
        .toString();
  }

  Widget _buildImageError() {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,

      child: Center(
        child: Icon(
          Icons
              .image_not_supported_outlined,
          size: 56,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
      ),
    );
  }

  // ============================================================
  // Visibility
  // ============================================================

  Widget _buildVisibilitySelector() {
    final l10n = context.l10n;

    final subtitle =
    _visibility ==
        ClothingVisibility.private
        ? l10n.privateSubtitle
        : l10n.publicSubtitle;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          l10n.visibility,

          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(
            fontWeight:
            FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,

          child: SegmentedButton<
              ClothingVisibility>(
            segments: [
              ButtonSegment(
                value:
                ClothingVisibility
                    .private,

                icon: const Icon(
                  Icons.lock_outline,
                ),

                label: Text(
                  l10n.privateLabel,
                ),
              ),

              ButtonSegment(
                value:
                ClothingVisibility
                    .public,

                icon: const Icon(
                  Icons.people_outline,
                ),

                label: Text(
                  l10n.publicLabel,
                ),
              ),
            ],

            selected: {
              _visibility,
            },

            showSelectedIcon: false,

            onSelectionChanged:
            _saving
                ? null
                : (values) {
              if (values
                  .isEmpty) {
                return;
              }

              setState(() {
                _visibility =
                    values.first;
              });
            },
          ),
        ),

        const SizedBox(height: 8),

        AnimatedSwitcher(
          duration:
          const Duration(
            milliseconds: 180,
          ),

          child: Text(
            subtitle,

            key: ValueKey(
              _visibility,
            ),

            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
              color:
              Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Input Style
  // ============================================================

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    String? prefixText,
  }) {
    final theme =
    Theme.of(context);

    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon:
      icon == null
          ? null
          : Icon(
        icon,
        size: 20,
      ),

      prefixText: prefixText,

      filled: true,

      fillColor: theme
          .colorScheme
          .surfaceContainerHighest
          .withValues(
        alpha: 0.45,
      ),

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      disabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color:
          theme.colorScheme.primary,
          width: 1.4,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color:
          theme.colorScheme.error,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color:
          theme.colorScheme.error,
          width: 1.4,
        ),
      ),
    );
  }
}