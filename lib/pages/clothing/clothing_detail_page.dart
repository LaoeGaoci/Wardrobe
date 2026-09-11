import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/clothing.dart';
import '../../services/clothing_repository.dart';
import '../../widgets/info_row.dart';

class ClothingDetailPage extends StatefulWidget {
  final Clothing clothing;

  const ClothingDetailPage({super.key, required this.clothing});

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  final ClothingRepository _clothingRepository = ClothingRepository.instance;

  final ImagePicker _imagePicker = ImagePicker();

  late Clothing _clothing;

  bool _isChangingImage = false;

  @override
  void initState() {
    super.initState();

    _clothing = widget.clothing;
  }

  /// 修改衣物图片
  Future<void> _changeImage() async {
    if (_isChangingImage) {
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '更换衣物图片',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    await _pickAndSaveImage(source);
  }

  /// 选择并保存图片
  Future<void> _pickAndSaveImage(ImageSource source) async {
    try {
      setState(() {
        _isChangingImage = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null) {
        if (mounted) {
          setState(() {
            _isChangingImage = false;
          });
        }

        return;
      }

      // 将新图片复制到 App 的衣物图片目录。
      final savedPath = await _clothingRepository.saveImage(image.path);

      // 创建更新后的衣物对象。
      final updatedClothing = _clothing.copyWith(
        imagePath: savedPath,
        imageType: ClothingImageType.local,
        updatedAt: DateTime.now(),
      );

      // 保存衣物信息。
      await _clothingRepository.updateClothing(updatedClothing);

      if (!mounted) {
        return;
      }

      setState(() {
        _clothing = updatedClothing;
        _isChangingImage = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('衣物图片已更新'),
            duration: Duration(seconds: 2),
          ),
        );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isChangingImage = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('图片更新失败，请重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('衣物详情')),
      body: ListView(
        children: [
          _buildImage(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _clothing.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                InfoRow(title: '品牌', value: _clothing.brand ?? '未设置'),

                InfoRow(title: '类别', value: _clothing.category),

                InfoRow(title: '颜色', value: _clothing.color),

                InfoRow(title: '季节', value: _clothing.season),

                InfoRow(
                  title: '价格',
                  value: _clothing.price == null
                      ? '未设置'
                      : '¥${_clothing.price}',
                ),

                InfoRow(
                  title: '可见性',
                  value: _clothing.visibility == ClothingVisibility.public
                      ? 'Public'
                      : 'Private',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 衣物图片
  Widget _buildImage() {
    return GestureDetector(
      onTap: _changeImage,
      child: Stack(
        children: [
          _buildImageContent(),

          // 轻量的点击提示
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // 保存过程中显示加载状态
          if (_isChangingImage)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 根据图片类型显示图片
  Widget _buildImageContent() {
    if (_clothing.imageType == ClothingImageType.local) {
      return Image.file(
        File(_clothing.imagePath),
        height: 420,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }

    return Image.network(
      _clothing.imagePath,
      height: 420,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImageError();
      },
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 420,
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
