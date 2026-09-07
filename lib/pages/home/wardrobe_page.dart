import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/clothing.dart';
import '../../widgets/clothing_card.dart';
import '../clothing/clothing_detail_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
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
    final mine = clothes
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

  @override
  Widget build(BuildContext context) {
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
            sliver: filteredClothes.isEmpty
                ? const SliverToBoxAdapter(
              child: _EmptyWardrobe(),
            )
                : SliverGrid(
              delegate:
              SliverChildBuilderDelegate(
                    (context, index) {
                  final clothing =
                  filteredClothes[index];

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
                childCount:
                filteredClothes.length,
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
        onPressed: () {
          // TODO: 添加衣物
        },
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