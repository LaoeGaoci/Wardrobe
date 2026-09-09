import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../../models/clothing.dart';
import '../../services/auth_service.dart';
import '../../services/clothing_repository.dart';
import '../../widgets/clothing_card.dart';
import '../../main.dart';

import '../clothing/add_clothing_page.dart';
import '../clothing/clothing_detail_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  // 衣柜数据
  final ClothingRepository _repository =
      ClothingRepository.instance;

  String selectedCategory = '全部';

  final List<String> categories = [
    '全部',
    '上衣',
    '外套',
    '羽绒服',
    '裤子',
    '鞋子',
    '配饰',
  ];

  List<Clothing> get filteredClothes {
    final currentUser =
        AuthService.instance.currentUser;

    final mine = _repository.clothes
        .where(
          (item) => item.ownerId == currentUser.id,
    )
        .toList();

    if (selectedCategory == '全部') {
      return mine;
    }

    return mine
        .where(
          (item) => item.category == selectedCategory,
    )
        .toList();
  }

  Future<void> _addClothing() async {
    CameraDescription? backCamera;

    for (final camera in cameras) {
      if (camera.lensDirection ==
          CameraLensDirection.back) {
        backCamera = camera;
        break;
      }
    }

    if (backCamera == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('未找到后置摄像头'),
        ),
      );

      return;
    }

    final clothing = await Navigator.push<Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) => AddClothingPage(
          camera: backCamera!,
          ownerId:
          AuthService.instance.currentUser.id,
        ),
      ),
    );

    if (clothing != null && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final clothes = filteredClothes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的衣柜',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 通知功能
            },
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          // 搜索
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                12,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索衣物',
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: ChoiceChip(
                      label: Text(category),
                      selected:
                      selectedCategory == category,
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

          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),

          // 衣物 Grid
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: clothes.isEmpty
                ? const SliverToBoxAdapter(
              child: _EmptyWardrobe(),
            )
                : SliverGrid(
              delegate:
              SliverChildBuilderDelegate(
                    (context, index) {
                  final clothing =
                  clothes[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ClothingDetailPage(
                                clothing: clothing,
                              ),
                        ),
                      );
                    },
                    child: ClothingCard(
                      clothing: clothing,
                    ),
                  );
                },
                childCount: clothes.length,
              ),
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

      floatingActionButton: FloatingActionButton(
        onPressed: _addClothing,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyWardrobe extends StatelessWidget {
  const _EmptyWardrobe();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无衣物',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}