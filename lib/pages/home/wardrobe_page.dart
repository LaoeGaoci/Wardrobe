import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../../main.dart';
import '../../models/clothing.dart';
import '../../services/auth_service.dart';
import '../../services/clothing_repository.dart';
import '../../services/friend_service.dart';
import '../../widgets/clothing_card.dart';

import '../clothing/add_clothing_page.dart';
import '../clothing/clothing_detail_page.dart';
import '../notification/notification.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final ClothingRepository _repository = ClothingRepository.instance;

  final FriendService _friendService = FriendService.instance;

  String selectedCategory = '全部';

  final List<String> categories = ['全部', '上衣', '外套', '羽绒服', '裤子', '鞋子', '配饰'];

  @override
  void initState() {
    super.initState();

    // 监听好友申请数量变化，
    // 用于更新通知按钮上的未读数量。
    _friendService.addListener(_onFriendChanged);
  }

  @override
  void dispose() {
    _friendService.removeListener(_onFriendChanged);

    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 当前用户的衣物
  List<Clothing> get filteredClothes {
    final currentUser = AuthService.instance.currentUser;

    // 未登录时不显示衣物
    if (currentUser == null) {
      return [];
    }

    final mine = _repository.clothes
        .where((item) => item.ownerId == currentUser.id)
        .toList();

    // 显示全部
    if (selectedCategory == '全部') {
      return mine;
    }

    // 按分类筛选
    return mine.where((item) => item.category == selectedCategory).toList();
  }

  /// 添加衣物
  Future<void> _addClothing() async {
    final currentUser = AuthService.instance.currentUser;

    // 未登录
    if (currentUser == null) {
      return;
    }

    CameraDescription? backCamera;

    // 查找后置摄像头
    for (final camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        backCamera = camera;
        break;
      }
    }

    // 没有后置摄像头
    if (backCamera == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未找到后置摄像头')));

      return;
    }

    final clothing = await Navigator.push<Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddClothingPage(camera: backCamera!, ownerId: currentUser.id),
      ),
    );

    // 添加成功后刷新衣柜
    if (clothing != null && mounted) {
      setState(() {});
    }
  }

  /// 打开通知页面
  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPage()),
    );
  }

  /// 通知按钮
  Widget _buildNotificationButton() {
    final unreadCount = _friendService.receivedRequestCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: _openNotifications,
          icon: const Icon(Icons.notifications_none),
        ),

        // 有未读通知时显示角标
        if (unreadCount > 0)
          Positioned(
            right: 5,
            top: 3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clothes = filteredClothes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的衣柜',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [_buildNotificationButton()],
      ),

      body: CustomScrollView(
        slivers: [
          // 搜索
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索衣物',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // 分类
          SliverToBoxAdapter(
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 衣物 Grid
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: clothes.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyWardrobe())
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final clothing = clothes[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ClothingDetailPage(clothing: clothing),
                            ),
                          );
                        },
                        child: ClothingCard(clothing: clothing),
                      );
                    }, childCount: clothes.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                  ),
          ),
        ],
      ),

      // 添加衣物
      floatingActionButton: FloatingActionButton(
        onPressed: _addClothing,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 空衣柜
class _EmptyWardrobe extends StatelessWidget {
  const _EmptyWardrobe();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无衣物',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
