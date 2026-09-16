import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../main.dart';
import '../../models/clothing.dart';
import '../../services/auth_service.dart';
import '../../services/clothing_repository.dart';
import '../../services/image_cache_service.dart';
import '../../widgets/clothing_card.dart';
import '../clothing/add_clothing_page.dart';
import '../clothing/clothing_detail_page.dart';

enum _ClothingImageSource {
  camera,
  gallery,
}

class WardrobePage extends StatefulWidget {
  const WardrobePage({
    super.key,
  });

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final ClothingRepository _repository =
      ClothingRepository.instance;

  final ImageCacheService _imageCacheService =
      ImageCacheService.instance;

  final ImagePicker _imagePicker =
  ImagePicker();

  bool _isLoading = true;

  String? _loadError;

  String _searchKeyword = '';

  String _selectedMainCategory = 'all';

  @override
  void initState() {
    super.initState();

    _loadClothes();
  }

  // ============================================================
  // Load
  // ============================================================

  Future<void> _loadClothes({
    bool showLoading = true,
  }) async {
    final currentUser =
        AuthService.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = null;
        });
      }

      return;
    }

    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await _repository.fetchMyClothes();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    } on ClothingRepositoryException catch (e) {
      if (e.statusCode == 401) {
        await AuthService.instance.logout();

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = e.message;
      });
    }
  }

  // ============================================================
  // Filter
  // ============================================================

  List<Clothing> get filteredClothes {
    if (AuthService.instance.currentUser == null) {
      return const [];
    }

    Iterable<Clothing> result =
        _repository.clothes;

    if (_selectedMainCategory != 'all') {
      result = result.where(
            (item) =>
        mainCategoryIdFor(
          item.category,
        ) ==
            _selectedMainCategory,
      );
    }

    final keyword =
    _searchKeyword
        .trim()
        .toLowerCase();

    if (keyword.isNotEmpty) {
      result = result.where(
            (item) {
          final location =
          item.location.toLowerCase();

          final brand =
          (item.brand ?? '')
              .toLowerCase();

          final color =
          item.color.toLowerCase();

          final rawCategory =
          item.category.toLowerCase();

          final rawSeason =
          item.season.toLowerCase();

          final subCategory =
          localizedCategory(
            context,
            item.category,
          ).toLowerCase();

          final categoryPath =
          localizedCategoryPath(
            context,
            item.category,
          ).toLowerCase();

          final season =
          localizedSeason(
            context,
            item.season,
          ).toLowerCase();

          final mainCategoryId =
          mainCategoryIdFor(
            item.category,
          );

          final mainCategory =
          mainCategoryId == null
              ? ''
              : localizedMainCategory(
            context,
            mainCategoryId,
          ).toLowerCase();

          return location.contains(
            keyword,
          ) ||
              brand.contains(
                keyword,
              ) ||
              color.contains(
                keyword,
              ) ||
              rawCategory.contains(
                keyword,
              ) ||
              rawSeason.contains(
                keyword,
              ) ||
              subCategory.contains(
                keyword,
              ) ||
              categoryPath.contains(
                keyword,
              ) ||
              mainCategory.contains(
                keyword,
              ) ||
              season.contains(
                keyword,
              );
        },
      );
    }

    return result.toList(
      growable: false,
    );
  }

  // ============================================================
  // Image prefetch
  // ============================================================

  void _scheduleImagePrefetch(
      List<Clothing> clothes,
      int index,
      ) {
    if (index != 0 &&
        (index + 1) % 6 != 0) {
      return;
    }

    _imageCacheService
        .schedulePrecacheAhead(
      context,
      clothes,
      currentIndex: index,
      count: 6,
      maxWidth: 720,
    );
  }

  // ============================================================
  // Add clothing
  // ============================================================

  CameraDescription?
  _findBackCamera() {
    for (final camera in cameras) {
      if (camera.lensDirection ==
          CameraLensDirection.back) {
        return camera;
      }
    }

    return null;
  }

  Future<
      _ClothingImageSource?>
  _showImageSourcePicker() {
    return showModalBottomSheet<
        _ClothingImageSource>(
      context: context,
      showDragHandle: true,
      builder: (
          bottomSheetContext,
          ) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.only(
              bottom: 12,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Padding(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    20,
                    4,
                    20,
                    12,
                  ),
                  child: Align(
                    alignment:
                    Alignment
                        .centerLeft,
                    child: Text(
                      '添加衣物照片',
                      style:
                      Theme.of(
                        bottomSheetContext,
                      )
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                ),

                ListTile(
                  leading:
                  const Icon(
                    Icons
                        .camera_alt_outlined,
                  ),
                  title:
                  const Text(
                    '拍照',
                  ),
                  subtitle:
                  const Text(
                    '使用相机拍摄衣物',
                  ),
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                      _ClothingImageSource
                          .camera,
                    );
                  },
                ),

                ListTile(
                  leading:
                  const Icon(
                    Icons
                        .photo_library_outlined,
                  ),
                  title:
                  const Text(
                    '从相册选择',
                  ),
                  subtitle:
                  const Text(
                    '使用手机中已有的照片',
                  ),
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                      _ClothingImageSource
                          .gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addClothing() async {
    final currentUser =
        AuthService.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    // ----------------------------------------------------------
    // 1. 先让用户选择图片来源
    // ----------------------------------------------------------

    final source =
    await _showImageSourcePicker();

    if (source == null ||
        !mounted) {
      return;
    }

    final backCamera =
    _findBackCamera();

    XFile? initialImage;

    // ----------------------------------------------------------
    // 2. 从相册选择
    // ----------------------------------------------------------

    if (source ==
        _ClothingImageSource
            .gallery) {
      try {
        initialImage =
        await _imagePicker.pickImage(
          source:
          ImageSource.gallery,

          // 对衣物照片来说已经足够清晰，
          // 同时避免手机原图过大。
          imageQuality: 92,
        );
      } catch (e) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '读取相册失败：$e',
            ),
          ),
        );

        return;
      }

      // 用户取消了系统图片选择器。
      if (initialImage == null) {
        return;
      }
    }

    // ----------------------------------------------------------
    // 3. 拍照
    // ----------------------------------------------------------

    if (source ==
        _ClothingImageSource
            .camera &&
        backCamera == null) {
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

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // 4. 进入新增衣物页面
    //
    // camera:
    // - 拍照时使用
    // - 从相册进入后，如果用户点“重新拍摄”，也可以使用
    //
    // initialImage:
    // - 相册选择时非 null
    // - 拍照时为 null
    // ----------------------------------------------------------

    final clothing =
    await Navigator.push<
        Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddClothingPage(
              camera: backCamera,
              ownerId:
              currentUser.id,
              initialImage:
              initialImage,
            ),
      ),
    );

    if (clothing != null &&
        mounted) {
      await _loadClothes(
        showLoading: false,
      );
    }
  }

  // ============================================================
  // Clothing detail
  // ============================================================

  Future<void>
  _openClothingDetail(
      Clothing clothing,
      ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ClothingDetailPage(
              clothing: clothing,
            ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadClothes(
      showLoading: false,
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final clothes =
        filteredClothes;

    final l10n =
        context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myWardrobe,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : _loadError != null
          ? _buildLoadError()
          : _buildWardrobeContent(
        clothes,
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed:
        _addClothing,
        child:
        const Icon(
          Icons.add,
        ),
      ),
    );
  }

  // ============================================================
  // Load error
  // ============================================================

  Widget _buildLoadError() {
    final l10n =
        context.l10n;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .cloud_off_outlined,
              size: 56,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              _loadError == null
                  ? l10n
                  .wardrobeLoadFailed
                  : localizedErrorMessage(
                context,
                _loadError!,
              ),
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(
              height: 16,
            ),

            FilledButton.icon(
              onPressed:
              _loadClothes,
              icon:
              const Icon(
                Icons.refresh,
              ),
              label:
              Text(
                l10n.reload,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Wardrobe content
  // ============================================================

  Widget
  _buildWardrobeContent(
      List<Clothing> clothes,
      ) {
    final l10n =
        context.l10n;

    return RefreshIndicator(
      onRefresh: () =>
          _loadClothes(
            showLoading: false,
          ),

      child:
      CustomScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        slivers: [
          // ====================================================
          // Search
          // ====================================================

          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                16,
                8,
                16,
                12,
              ),
              child:
              TextField(
                onChanged:
                    (value) {
                  setState(() {
                    _searchKeyword =
                        value;
                  });
                },

                decoration:
                InputDecoration(
                  hintText:
                  l10n.searchClothing,

                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),

                  filled:
                  true,

                  fillColor:
                  Theme.of(
                    context,
                  )
                      .colorScheme
                      .surfaceContainerHighest,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                    borderSide:
                    BorderSide
                        .none,
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                    borderSide:
                    BorderSide
                        .none,
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                    borderSide:
                    BorderSide
                        .none,
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // Main category
          // ====================================================

          SliverToBoxAdapter(
            child:
            SizedBox(
              height: 45,
              child:
              ListView.separated(
                scrollDirection:
                Axis.horizontal,

                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal:
                  12,
                ),

                itemCount:
                clothingMainCategoryIds
                    .length +
                    1,

                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  width: 8,
                ),

                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final categoryId =
                  index == 0
                      ? 'all'
                      : clothingMainCategoryIds[
                  index -
                      1];

                  final label =
                  categoryId ==
                      'all'
                      ? l10n
                      .categoryAll
                      : localizedMainCategory(
                    context,
                    categoryId,
                  );

                  return ChoiceChip(
                    label:
                    Text(
                      label,
                    ),

                    selected:
                    _selectedMainCategory ==
                        categoryId,

                    onSelected:
                        (_) {
                      setState(() {
                        _selectedMainCategory =
                            categoryId;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child:
            SizedBox(
              height: 12,
            ),
          ),

          // ====================================================
          // Clothing grid
          // ====================================================

          SliverPadding(
            padding:
            const EdgeInsets
                .all(
              12,
            ),

            sliver:
            clothes.isEmpty
                ? const SliverToBoxAdapter(
              child:
              _EmptyWardrobe(),
            )
                : SliverGrid(
              delegate:
              SliverChildBuilderDelegate(
                    (
                    context,
                    index,
                    ) {
                  final clothing =
                  clothes[
                  index];

                  _scheduleImagePrefetch(
                    clothes,
                    index,
                  );

                  return GestureDetector(
                    onTap:
                        () =>
                        _openClothingDetail(
                          clothing,
                        ),
                    child:
                    ClothingCard(
                      clothing:
                      clothing,
                    ),
                  );
                },
                childCount:
                clothes.length,
              ),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                2,
                crossAxisSpacing:
                10,
                mainAxisSpacing:
                10,
                childAspectRatio:
                0.72,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Empty wardrobe
// ============================================================

class _EmptyWardrobe
    extends StatelessWidget {
  const _EmptyWardrobe();

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .checkroom_outlined,
              size: 56,
              color:
              Theme.of(
                context,
              )
                  .colorScheme
                  .onSurfaceVariant,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              context
                  .l10n
                  .noClothing,
              style:
              Theme.of(
                context,
              )
                  .textTheme
                  .titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}