import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/clothing.dart';
import '../../services/auth_service.dart';
import '../../services/clothing_repository.dart';
import '../../services/friend_service.dart';
import '../../widgets/clothing_card.dart';

import '../clothing/add_clothing_page.dart';
import '../clothing/clothing_detail_page.dart';
import '../notification/notification.dart';

class WardrobePage
    extends StatefulWidget {
  const WardrobePage({
    super.key,
  });

  @override
  State<WardrobePage>
  createState() =>
      _WardrobePageState();
}

class _WardrobePageState
    extends State<WardrobePage> {
  final ClothingRepository
  _repository =
      ClothingRepository.instance;

  final FriendService
  _friendService =
      FriendService.instance;

  bool _isLoading = true;

  String? _loadError;

  String _searchKeyword = '';

  String selectedCategory =
      '全部';

  final List<String>
  categories = [
    '全部',
    '上衣',
    '外套',
    '羽绒服',
    '裤子',
    '鞋子',
    '配饰',
  ];

  @override
  void initState() {
    super.initState();

    _friendService.addListener(
      _onFriendChanged,
    );
    /// App 进入主页面后，
    /// 主动取得收到的好友申请，
    /// 用于更新通知数量。
    Future.microtask(() async {
      try {
        await _friendService
            .refreshReceivedRequests();
      } on FriendException {
        /// 首页不因为好友申请同步失败而崩溃。
        ///
        /// 好友页面本身会提供完整错误提示。
      }
    });

    _loadClothes();
  }

  @override
  void dispose() {
    _friendService.removeListener(
      _onFriendChanged,
    );

    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // Data
  // ============================================================

  Future<void> _loadClothes({
    bool showLoading = true,
  }) async {
    final currentUser =
        AuthService
            .instance
            .currentUser;

    if (currentUser == null) {
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
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await _repository
          .fetchMyClothes();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    } on ClothingRepositoryException catch (e) {
      if (e.statusCode ==
          401) {
        AuthService
            .instance
            .logout();

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

  List<Clothing>
  get filteredClothes {
    final currentUser =
        AuthService
            .instance
            .currentUser;

    if (currentUser == null) {
      return const [];
    }

    Iterable<Clothing> result =
        _repository.clothes;

    if (selectedCategory !=
        '全部') {
      result = result.where(
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
      result = result.where(
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
      growable: false,
    );
  }

  // ============================================================
  // Add
  // ============================================================

  Future<void> _addClothing()
  async {
    final currentUser =
        AuthService
            .instance
            .currentUser;

    if (currentUser == null) {
      return;
    }

    CameraDescription?
    backCamera;

    for (final camera
    in cameras) {
      if (camera.lensDirection ==
          CameraLensDirection
              .back) {
        backCamera = camera;

        break;
      }
    }

    if (backCamera == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
          Text(
            '未找到后置摄像头',
          ),
        ),
      );

      return;
    }

    final clothing =
    await Navigator.push<
        Clothing>(
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

    if (clothing != null &&
        mounted) {
      await _loadClothes(
        showLoading: false,
      );
    }
  }

  // ============================================================
  // Detail
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

    /// 详情页可能修改了图片，
    /// 返回后重新同步服务端。
    await _loadClothes(
      showLoading: false,
    );
  }

  // ============================================================
  // Notification
  // ============================================================

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const NotificationPage(),
      ),
    );
  }

  Widget
  _buildNotificationButton() {
    final unreadCount =
        _friendService
            .receivedRequestCount;

    return Stack(
      clipBehavior:
      Clip.none,
      children: [
        IconButton(
          onPressed:
          _openNotifications,
          icon:
          const Icon(
            Icons
                .notifications_none,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 5,
            top: 3,
            child:
            Container(
              constraints:
              const BoxConstraints(
                minWidth:
                18,
                minHeight:
                18,
              ),
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal:
                4,
                vertical:
                2,
              ),
              decoration:
              BoxDecoration(
                color:
                Theme.of(
                  context,
                )
                    .colorScheme
                    .error,
                borderRadius:
                BorderRadius
                    .circular(
                  10,
                ),
              ),
              child: Text(
                unreadCount >
                    99
                    ? '99+'
                    : '$unreadCount',
                textAlign:
                TextAlign
                    .center,
                style:
                const TextStyle(
                  color:
                  Colors
                      .white,
                  fontSize:
                  10,
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),
            ),
          ),
      ],
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

    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          '我的衣柜',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        actions: [
          _buildNotificationButton(),
        ],
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

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets
            .all(
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
              _loadError ??
                  '衣柜加载失败',
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
              const Text(
                '重新加载',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeContent(
      List<Clothing> clothes,
      ) {
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
          // 搜索
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
                  '搜索衣物',
                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),
                  filled: true,
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

          // 分类
          SliverToBoxAdapter(
            child: SizedBox(
              height: 45,
              child:
              ListView.builder(
                scrollDirection:
                Axis.horizontal,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal:
                  12,
                ),
                itemCount:
                categories
                    .length,
                itemBuilder:
                    (context,
                    index) {
                  final category =
                  categories[
                  index];

                  return Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal:
                      4,
                    ),
                    child:
                    ChoiceChip(
                      label:
                      Text(
                        category,
                      ),
                      selected:
                      selectedCategory ==
                          category,
                      onSelected:
                          (_) {
                        setState(
                              () {
                            selectedCategory =
                                category;
                          },
                        );
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
              height: 12,
            ),
          ),

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
                  clothes[index];

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
          MainAxisAlignment
              .center,
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
              '暂无衣物',
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