import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/clothing.dart';
import '../../services/clothing_repository.dart';
import 'clothing_category_picker_page.dart';

class AddClothingPage
    extends StatefulWidget {
  /// Android 后置摄像头。
  ///
  /// 从相册添加时允许为 null，
  /// 因为此时根本不需要初始化 CameraController。
  final CameraDescription? camera;

  final String ownerId;

  /// 从系统相册选择的初始图片。
  ///
  /// null:
  /// 进入相机拍摄流程。
  ///
  /// 非 null:
  /// 直接进入衣物信息填写页面。
  final XFile? initialImage;

  const AddClothingPage({
    super.key,
    required this.ownerId,
    this.camera,
    this.initialImage,
  });

  @override
  State<AddClothingPage>
  createState() =>
      _AddClothingPageState();
}

class _AddClothingPageState
    extends State<AddClothingPage> {
  CameraController?
  _cameraController;

  Future<void>?
  _cameraInitialization;

  final _formKey =
  GlobalKey<FormState>();

  final _locationController =
  TextEditingController();

  final _brandController =
  TextEditingController();

  final _colorController =
  TextEditingController();

  final _priceController =
  TextEditingController();

  String _selectedCategory =
      'tops.t-shirt';

  String _selectedSeason =
      '春季';

  ClothingVisibility _visibility =
      ClothingVisibility.private;

  XFile? _capturedImage;

  bool _saving = false;

  final List<String> _seasons = [
    '全季',
    '春季',
    '夏季',
    '秋季',
    '冬季',
    '春秋',
    '秋冬',
  ];

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // 如果从相册进入，
    // 直接把图片作为当前图片，
    // 不初始化相机、不申请相机权限。
    // ----------------------------------------------------------

    _capturedImage =
        widget.initialImage;

    // ----------------------------------------------------------
    // 只有选择“拍照”进入时才真正初始化摄像头。
    // ----------------------------------------------------------

    if (_capturedImage == null) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _cameraController
        ?.dispose();

    _locationController
        .dispose();

    _brandController
        .dispose();

    _colorController
        .dispose();

    _priceController
        .dispose();

    super.dispose();
  }

  // ============================================================
  // Category
  // ============================================================

  Future<void>
  _selectCategory() async {
    if (_saving) {
      return;
    }

    final selected =
    await Navigator.push<
        String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ClothingCategoryPickerPage(
              currentCategory:
              _selectedCategory,
            ),
      ),
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    setState(() {
      _selectedCategory =
          selected;
    });
  }

  // ============================================================
  // Camera
  // ============================================================

  void _initializeCamera() {
    // 已经初始化过，不重复创建 Controller。
    if (_cameraController !=
        null) {
      return;
    }

    final camera =
        widget.camera;

    if (camera == null) {
      return;
    }

    final controller =
    CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraController =
        controller;

    _cameraInitialization =
        controller.initialize();
  }

  Future<void>
  _takePicture() async {
    final controller =
        _cameraController;

    final initialization =
        _cameraInitialization;

    if (controller == null ||
        initialization == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            context
                .l10n
                .rearCameraNotFound,
          ),
        ),
      );

      return;
    }

    try {
      await initialization;

      if (controller
          .value
          .isTakingPicture) {
        return;
      }

      final image =
      await controller
          .takePicture();

      if (!mounted) {
        return;
      }

      setState(() {
        _capturedImage =
            image;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n
                .takePhotoFailed(
              e.toString(),
            ),
          ),
        ),
      );
    }
  }

  /// 从表单页面返回相机重新拍摄。
  ///
  /// 如果最开始是从相册进入，
  /// 相机此时才会真正初始化。
  Future<void>
  _retakePicture() async {
    if (_saving) {
      return;
    }

    if (widget.camera ==
        null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            context
                .l10n
                .rearCameraNotFound,
          ),
        ),
      );

      return;
    }

    _initializeCamera();

    setState(() {
      _capturedImage =
      null;
    });
  }

  // ============================================================
  // Save
  // ============================================================

  Future<void>
  _saveClothing() async {
    final capturedImage =
        _capturedImage;

    if (capturedImage == null) {
      return;
    }

    if (!_formKey
        .currentState!
        .validate()) {
      return;
    }

    FocusScope.of(
      context,
    ).unfocus();

    setState(() {
      _saving = true;
    });

    final repository =
        ClothingRepository
            .instance;

    Clothing? created;

    try {
      final now =
      DateTime.now();

      final rawPrice =
      _priceController
          .text
          .trim();

      final price =
      rawPrice.isEmpty
          ? null
          : double.parse(
        rawPrice,
      );

      final draft =
      Clothing(
        id: '',

        ownerId:
        widget.ownerId,

        // 存放位置
        location:
        _locationController
            .text
            .trim(),

        brand:
        _brandController
            .text
            .trim()
            .isEmpty
            ? null
            : _brandController
            .text
            .trim(),

        imagePath:
        capturedImage.path,

        imageType:
        ClothingImageType
            .local,

        category:
        _selectedCategory,

        color:
        _colorController
            .text
            .trim(),

        season:
        _selectedSeason,

        price: price,

        visibility:
        _visibility,

        createdAt: now,
        updatedAt: now,
      );

      // --------------------------------------------------------
      // 1. 先创建衣物记录
      // --------------------------------------------------------

      created =
      await repository
          .addClothing(
        draft,
      );

      // --------------------------------------------------------
      // 2. 上传图片到后端 / R2
      //
      // 无论图片来自：
      //
      // - Android Camera
      // - Android 系统相册
      //
      // 到这里都只是一个本地文件 path，
      // 所以后端完全不需要修改。
      // --------------------------------------------------------

      final completed =
      await repository
          .uploadClothingImage(
        clothingId:
        created.id,
        imagePath:
        capturedImage.path,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        completed,
      );
    } catch (e) {
      // --------------------------------------------------------
      // 图片上传失败时，
      // 删除前面已经创建的衣物，
      // 避免数据库产生没有图片的残缺记录。
      // --------------------------------------------------------

      if (created != null) {
        try {
          await repository
              .deleteClothing(
            created.id,
          );
        } catch (_) {
          // 回滚失败不覆盖原始异常。
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      final reason =
      localizedErrorMessage(
        context,
        e.toString(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n
                .saveFailed(
              reason,
            ),
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
    // ----------------------------------------------------------
    // 没有图片：
    // 显示相机页面。
    //
    // 有图片：
    // 显示填写衣物信息页面。
    // ----------------------------------------------------------

    if (_capturedImage ==
        null) {
      return _buildCameraPage();
    }

    return _buildFormPage();
  }

  // ============================================================
  // Camera Page
  // ============================================================

  Widget _buildCameraPage() {
    final l10n =
        context.l10n;

    final controller =
        _cameraController;

    final initialization =
        _cameraInitialization;

    if (controller == null ||
        initialization == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.captureClothing,
          ),
        ),
        body: Center(
          child: Text(
            l10n.rearCameraNotFound,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.captureClothing,
        ),
      ),

      body:
      FutureBuilder<void>(
        future:
        initialization,

        builder: (
            context,
            snapshot,
            ) {
          if (snapshot
              .connectionState ==
              ConnectionState
                  .done) {
            return Stack(
              fit:
              StackFit.expand,

              children: [
                CameraPreview(
                  controller,
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,

                  child: SafeArea(
                    minimum:
                    const EdgeInsets
                        .only(
                      bottom: 24,
                    ),

                    child: Center(
                      child:
                      GestureDetector(
                        onTap:
                        _takePicture,

                        child:
                        Container(
                          width:
                          72,
                          height:
                          72,

                          decoration:
                          BoxDecoration(
                            shape:
                            BoxShape
                                .circle,

                            color:
                            Colors
                                .white,

                            border:
                            Border.all(
                              width:
                              5,
                              color:
                              Colors
                                  .grey
                                  .shade300,
                            ),

                            boxShadow:
                            [
                              BoxShadow(
                                blurRadius:
                                12,
                                color:
                                Colors
                                    .black
                                    .withValues(
                                  alpha:
                                  0.18,
                                ),
                              ),
                            ],
                          ),

                          child:
                          const Icon(
                            Icons
                                .camera_alt_rounded,
                            size:
                            32,
                            color:
                            Colors
                                .black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot
              .hasError) {
            return Center(
              child: Text(
                l10n.cameraOpenFailed(
                  '${snapshot.error}',
                ),
              ),
            );
          }

          return const Center(
            child:
            CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  // ============================================================
  // Form Page
  // ============================================================

  Widget _buildFormPage() {
    final l10n =
        context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.addClothing,
        ),
        actions:
        const [],
      ),

      body: Form(
        key:
        _formKey,

        child: ListView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior
              .onDrag,

          padding:
          const EdgeInsets
              .fromLTRB(
            16,
            12,
            16,
            14,
          ),

          children: [
            // ==================================================
            // Image
            // ==================================================

            _buildImagePreview(),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // Brand + Color
            // ==================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Expanded(
                  child:
                  TextFormField(
                    controller:
                    _brandController,

                    textInputAction:
                    TextInputAction
                        .next,

                    decoration:
                    _buildInputDecoration(
                      label:
                      l10n.brand,
                      hint:
                      l10n.optional,
                      icon:
                      Icons
                          .sell_outlined,
                    ),

                    validator:
                        (value) {
                      if (value !=
                          null &&
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

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                  TextFormField(
                    controller:
                    _colorController,

                    textInputAction:
                    TextInputAction
                        .next,

                    decoration:
                    _buildInputDecoration(
                      label:
                      l10n.color,

                      hint:
                      l10n
                          .colorExample,

                      icon:
                      Icons
                          .palette_outlined,
                    ),

                    validator:
                        (value) {
                      if (value ==
                          null ||
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

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // Category + Season
            // ==================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Expanded(
                  child:
                  _buildCategorySelector(),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                  DropdownButtonFormField<
                      String>(
                    initialValue:
                    _selectedSeason,

                    isExpanded:
                    true,

                    decoration:
                    _buildInputDecoration(
                      label:
                      l10n.season,

                      icon:
                      Icons
                          .calendar_month_outlined,
                    ),

                    items:
                    _seasons
                        .map(
                          (
                          season,
                          ) {
                        return DropdownMenuItem<
                            String>(
                          value:
                          season,

                          child:
                          Text(
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

                    onChanged:
                    _saving
                        ? null
                        : (
                        value,
                        ) {
                      if (value ==
                          null) {
                        return;
                      }

                      setState(
                            () {
                          _selectedSeason =
                              value;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // ==================================================
            // Storage location
            // ==================================================

            const SizedBox(
              height: 12,
            ),

            TextFormField(
              controller:
              _locationController,

              textInputAction:
              TextInputAction
                  .next,

              decoration:
              _buildInputDecoration(
                label:
                l10n
                    .storageLocation,

                hint:
                l10n
                    .storageLocationExample,

                icon:
                Icons
                    .inventory_2_outlined,
              ),

              validator:
                  (value) {
                if (value ==
                    null ||
                    value
                        .trim()
                        .isEmpty) {
                  return l10n
                      .storageLocationRequired;
                }

                if (value
                    .trim()
                    .length >
                    100) {
                  return l10n
                      .storageLocationMax100;
                }

                return null;
              },
            ),

            // ==================================================
            // Price
            // ==================================================

            const SizedBox(
              height: 12,
            ),

            TextFormField(
              controller:
              _priceController,

              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),

              textInputAction:
              TextInputAction
                  .done,

              decoration:
              _buildInputDecoration(
                label:
                l10n.price,

                hint:
                l10n.optional,

                icon:
                Icons
                    .payments_outlined,

                prefixText:
                '¥ ',
              ),

              validator:
                  (value) {
                final text =
                    value?.trim() ??
                        '';

                if (text.isEmpty) {
                  return null;
                }

                final price =
                double.tryParse(
                  text,
                );

                if (price == null ||
                    price < 0) {
                  return l10n
                      .validPrice;
                }

                return null;
              },
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // Visibility
            // ==================================================

            _buildVisibilitySelector(),

            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),

      // ========================================================
      // Create button
      // ========================================================

      bottomNavigationBar:
      SafeArea(
        top: false,

        minimum:
        const EdgeInsets
            .fromLTRB(
          16,
          8,
          16,
          28,
        ),

        child:
        SizedBox(
          height: 52,

          child:
          FilledButton(
            onPressed:
            _saving
                ? null
                : _saveClothing,

            style:
            FilledButton
                .styleFrom(
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  16,
                ),
              ),
            ),

            child:
            _saving
                ? const SizedBox(
              width:
              22,
              height:
              22,
              child:
              CircularProgressIndicator(
                strokeWidth:
                2.5,
              ),
            )
                : Text(
              l10n
                  .createClothing,
              style:
              const TextStyle(
                fontSize:
                16,
                fontWeight:
                FontWeight
                    .w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Category
  // ============================================================

  Widget
  _buildCategorySelector() {
    final l10n =
        context.l10n;

    return InkWell(
      onTap:
      _saving
          ? null
          : _selectCategory,

      borderRadius:
      BorderRadius.circular(
        14,
      ),

      child:
      InputDecorator(
        decoration:
        _buildInputDecoration(
          label:
          l10n.category,

          icon:
          Icons
              .category_outlined,
        ),

        child:
        Row(
          children: [
            Expanded(
              child:
              Text(
                localizedCategoryPath(
                  context,
                  _selectedCategory,
                ),
                maxLines:
                1,
                overflow:
                TextOverflow
                    .ellipsis,
              ),
            ),

            const SizedBox(
              width: 4,
            ),

            const Icon(
              Icons
                  .chevron_right_rounded,
              size:
              20,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Image
  // ============================================================

  Widget _buildImagePreview() {
    final capturedImage =
    _capturedImage!;

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        20,
      ),

      child:
      SizedBox(
        height:
        300,

        child:
        Stack(
          fit:
          StackFit.expand,

          children: [
            Image.file(
              File(
                capturedImage.path,
              ),
              fit:
              BoxFit.cover,
            ),

            Positioned.fill(
              child:
              DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment
                        .center,

                    end:
                    Alignment
                        .bottomCenter,

                    colors:
                    [
                      Colors
                          .transparent,

                      Colors.black
                          .withValues(
                        alpha:
                        0.22,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // Retake
            // ==================================================

            Positioned(
              right:
              12,
              bottom:
              12,

              child:
              FilledButton
                  .tonalIcon(
                onPressed:
                _saving
                    ? null
                    : _retakePicture,

                icon:
                const Icon(
                  Icons
                      .camera_alt_outlined,
                  size:
                  18,
                ),

                label:
                Text(
                  context
                      .l10n
                      .retakePhoto,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Visibility
  // ============================================================

  Widget
  _buildVisibilitySelector() {
    final l10n =
        context.l10n;

    final subtitle =
    _visibility ==
        ClothingVisibility
            .private
        ? l10n
        .privateSubtitle
        : l10n
        .publicSubtitle;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          l10n.visibility,

          style:
          Theme.of(
            context,
          )
              .textTheme
              .labelLarge
              ?.copyWith(
            fontWeight:
            FontWeight
                .w600,
          ),
        ),

        const SizedBox(
          height:
          10,
        ),

        SizedBox(
          width:
          double.infinity,

          child:
          SegmentedButton<
              ClothingVisibility>(
            segments:
            [
              ButtonSegment(
                value:
                ClothingVisibility
                    .private,

                icon:
                const Icon(
                  Icons
                      .lock_outline,
                ),

                label:
                Text(
                  l10n
                      .privateLabel,
                ),
              ),

              ButtonSegment(
                value:
                ClothingVisibility
                    .public,

                icon:
                const Icon(
                  Icons
                      .people_outline,
                ),

                label:
                Text(
                  l10n
                      .publicLabel,
                ),
              ),
            ],

            selected:
            {
              _visibility,
            },

            showSelectedIcon:
            false,

            onSelectionChanged:
            _saving
                ? null
                : (
                values,
                ) {
              if (values
                  .isEmpty) {
                return;
              }

              setState(
                    () {
                  _visibility =
                      values
                          .first;
                },
              );
            },
          ),
        ),

        const SizedBox(
          height:
          8,
        ),

        AnimatedSwitcher(
          duration:
          const Duration(
            milliseconds:
            180,
          ),

          child:
          Text(
            subtitle,

            key:
            ValueKey(
              _visibility,
            ),

            style:
            Theme.of(
              context,
            )
                .textTheme
                .bodySmall
                ?.copyWith(
              color:
              Theme.of(
                context,
              )
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

  InputDecoration
  _buildInputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    String? prefixText,
  }) {
    final theme =
    Theme.of(context);

    return InputDecoration(
      labelText:
      label,

      hintText:
      hint,

      prefixIcon:
      icon == null
          ? null
          : Icon(
        icon,
        size:
        20,
      ),

      prefixText:
      prefixText,

      filled:
      true,

      fillColor:
      theme
          .colorScheme
          .surfaceContainerHighest
          .withValues(
        alpha:
        0.45,
      ),

      contentPadding:
      const EdgeInsets
          .symmetric(
        horizontal:
        14,
        vertical:
        14,
      ),

      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius
            .circular(
          14,
        ),
        borderSide:
        BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius
            .circular(
          14,
        ),
        borderSide:
        BorderSide.none,
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius
            .circular(
          14,
        ),
        borderSide:
        BorderSide(
          color:
          theme
              .colorScheme
              .primary,
          width:
          1.4,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius
            .circular(
          14,
        ),
        borderSide:
        BorderSide(
          color:
          theme
              .colorScheme
              .error,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius
            .circular(
          14,
        ),
        borderSide:
        BorderSide(
          color:
          theme
              .colorScheme
              .error,
          width:
          1.4,
        ),
      ),
    );
  }
}