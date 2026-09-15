import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../main.dart';
import '../../models/clothing.dart';
import '../../services/auth_service.dart';
import '../../services/clothing_repository.dart';
import '../../widgets/clothing_card.dart';
import '../clothing/add_clothing_page.dart';
import '../clothing/clothing_detail_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({
    super.key,
  });

  @override
  State<WardrobePage> createState() =>
      _WardrobePageState();
}

class _WardrobePageState
    extends State<WardrobePage> {
  final ClothingRepository _repository =
      ClothingRepository.instance;

  bool _isLoading =
  true;

  String? _loadError;

  String _searchKeyword =
      '';

  String selectedCategory =
      '全部';

  final List<String> categories = [
    '全部',
    '上衣',
    '外套',
    '羽绒服',
    '裤子',
    '帽子',
    '鞋子',
    '配饰',
  ];

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
        AuthService
            .instance
            .currentUser;

    if (currentUser ==
        null) {
      if (mounted) {
        setState(() {
          _isLoading =
          false;

          _loadError =
          null;
        });
      }

      return;
    }

    if (showLoading &&
        mounted) {
      setState(() {
        _isLoading =
        true;

        _loadError =
        null;
      });
    }

    try {
      await _repository
          .fetchMyClothes();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading =
        false;

        _loadError =
        null;
      });
    } on ClothingRepositoryException catch (e) {
      // 当前 Token 已经失效。
      //
      // logout 现在会同时：
      //
      // - 清除内存 Token
      // - 清除 Secure Storage Token
      // - 清除衣物缓存
      // - 通知 AuthGate
      //
      // AuthGate 随后会自动切换登录页面。
      if (e.statusCode ==
          401) {
        await AuthService
            .instance
            .logout();

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading =
        false;

        _loadError =
            e.message;
      });
    }
  }

  // ============================================================
  // Filter
  // ============================================================

  List<Clothing> get filteredClothes {
    final currentUser =
        AuthService
            .instance
            .currentUser;

    if (currentUser ==
        null) {
      return const [];
    }

    Iterable<Clothing> result =
        _repository.clothes;

    if (selectedCategory !=
        '全部') {
      result =
          result.where(
                (item) =>
            item.category ==
                selectedCategory,
          );
    }

    final keyword =
    _searchKeyword
        .trim()
        .toLowerCase();

    if (keyword.isNotEmpty) {
      result =
          result.where(
                (item) {
              final name =
              item.name
                  .toLowerCase();

              final brand =
              (item.brand ?? '')
                  .toLowerCase();

              return name.contains(
                keyword,
              ) ||
                  brand.contains(
                    keyword,
                  );
            },
          );
    }

    return result.toList(
      growable:
      false,
    );
  }

  // ============================================================
  // Add Clothing
  // ============================================================

  Future<void> _addClothing() async {
    final currentUser =
        AuthService
            .instance
            .currentUser;

    if (currentUser ==
        null) {
      return;
    }

    CameraDescription?
    backCamera;

    for (final camera in cameras) {
      if (camera.lensDirection ==
          CameraLensDirection.back) {
        backCamera =
            camera;

        break;
      }
    }

    if (backCamera ==
        null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
            context
                .l10n
                .rearCameraNotFound,
          ),
        ),
      );

      return;
    }

    final clothing =
    await Navigator
        .push<Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddClothingPage(
              camera:
              backCamera!,
              ownerId:
              currentUser.id,
            ),
      ),
    );

    if (clothing !=
        null &&
        mounted) {
      await _loadClothes(
        showLoading:
        false,
      );
    }
  }

  // ============================================================
  // Clothing Detail
  // ============================================================

  Future<void> _openClothingDetail(
      Clothing clothing,
      ) async {
    await Navigator
        .push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ClothingDetailPage(
              clothing:
              clothing,
            ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadClothes(
      showLoading:
      false,
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
      appBar:
      AppBar(
        title:
        Text(
          l10n.myWardrobe,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body:
      _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : _loadError !=
          null
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
  // Error
  // ============================================================

  Widget _buildLoadError() {
    final l10n =
        context.l10n;

    return Center(
      child:
      Padding(
        padding:
        const EdgeInsets.all(
          32,
        ),
        child:
        Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size:
              56,
            ),

            const SizedBox(
              height:
              16,
            ),

            Text(
              _loadError ==
                  null
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
              height:
              16,
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
  // Wardrobe
  // ============================================================

  Widget _buildWardrobeContent(
      List<Clothing> clothes,
      ) {
    final l10n =
        context.l10n;

    return RefreshIndicator(
      onRefresh: () =>
          _loadClothes(
            showLoading:
            false,
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
            child:
            Padding(
              padding:
              const EdgeInsets.fromLTRB(
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
                    BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // Categories
          // ====================================================

          SliverToBoxAdapter(
            child:
            SizedBox(
              height:
              45,
              child:
              ListView.builder(
                scrollDirection:
                Axis.horizontal,
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  12,
                ),
                itemCount:
                categories.length,
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final category =
                  categories[
                  index];

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal:
                      4,
                    ),
                    child:
                    ChoiceChip(
                      label:
                      Text(
                        localizedCategory(
                          context,
                          category,
                        ),
                      ),
                      selected:
                      selectedCategory ==
                          category,
                      onSelected:
                          (_) {
                        setState(() {
                          selectedCategory =
                              category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child:
            SizedBox(
              height:
              12,
            ),
          ),

          // ====================================================
          // Clothing Grid
          // ====================================================

          SliverPadding(
            padding:
            const EdgeInsets.all(
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

                  return GestureDetector(
                    onTap: () =>
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
// Empty Wardrobe
// ============================================================

class _EmptyWardrobe
    extends StatelessWidget {
  const _EmptyWardrobe();

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      height:
      300,
      child:
      Center(
        child:
        Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size:
              56,
              color:
              Theme.of(
                context,
              )
                  .colorScheme
                  .onSurfaceVariant,
            ),

            const SizedBox(
              height:
              16,
            ),

            Text(
              context
                  .l10n
                  .noClothing,
              style:
              Theme.of(
                context,
              ).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}