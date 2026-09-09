import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../models/clothing.dart';
import '../../services/clothing_repository.dart';

class AddClothingPage extends StatefulWidget {
  final CameraDescription camera;
  final String ownerId;

  const AddClothingPage({
    super.key,
    required this.camera,
    required this.ownerId,
  });

  @override
  State<AddClothingPage> createState() =>
      _AddClothingPageState();
}

class _AddClothingPageState
    extends State<AddClothingPage> {
  late CameraController _cameraController;
  late Future<void> _cameraInitialization;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = '上衣';
  String _selectedSeason = '春季';
  ClothingVisibility _visibility =
      ClothingVisibility.private;

  XFile? _capturedImage;

  bool _saving = false;

  final List<String> _categories = [
    '上衣',
    '外套',
    '羽绒服',
    '裤子',
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

    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraInitialization =
        _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();

    _nameController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _cameraInitialization;

      if (_cameraController.value.isTakingPicture) {
        return;
      }

      final image =
      await _cameraController.takePicture();

      if (!mounted) return;

      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('拍照失败：$e'),
        ),
      );
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _saveClothing() async {
    if (_capturedImage == null) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final repository =
          ClothingRepository.instance;

      final imagePath =
      await repository.saveImage(
        _capturedImage!.path,
      );

      final now = DateTime.now();

      double? price;

      if (_priceController.text.trim().isNotEmpty) {
        price = double.tryParse(
          _priceController.text.trim(),
        );
      }

      final clothing = Clothing(
        id: now.microsecondsSinceEpoch.toString(),
        ownerId: widget.ownerId,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        imagePath: imagePath,
        imageType: ClothingImageType.local,
        category: _selectedCategory,
        color: _colorController.text.trim(),
        season: _selectedSeason,
        price: price,
        visibility: _visibility,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addClothing(clothing);

      if (!mounted) return;

      Navigator.pop(context, clothing);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败：$e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_capturedImage != null) {
      return _buildFormPage();
    }

    return _buildCameraPage();
  }

  Widget _buildCameraPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍摄衣物'),
      ),
      body: FutureBuilder<void>(
        future: _cameraInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController),

                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            width: 5,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '无法打开摄像头：${snapshot.error}',
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildFormPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加衣物'),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : _saveClothing,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePreview(),

            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例如：白色T恤',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return '请输入衣物名称';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: '品牌',
                hintText: '可选',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '分类',
                border: OutlineInputBorder(),
              ),
              items: _categories.map(
                    (category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: '颜色',
                hintText: '例如：白色',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return '请输入颜色';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedSeason,
              decoration: const InputDecoration(
                labelText: '季节',
                border: OutlineInputBorder(),
              ),
              items: _seasons.map(
                    (season) {
                  return DropdownMenuItem(
                    value: season,
                    child: Text(season),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedSeason = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: '价格',
                hintText: '可选',
                prefixText: '¥ ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            _buildVisibilitySelector(),

            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving
                  ? null
                  : _saveClothing,
              child: _saving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text('创建衣物'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(_capturedImage!.path),
            width: double.infinity,
            height: 360,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: _saving
              ? null
              : _retakePicture,
          icon: const Icon(Icons.camera_alt),
          label: const Text('重新拍摄'),
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          '可见性',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        RadioListTile<ClothingVisibility>(
          title: const Text('Private'),
          subtitle: const Text('只有你可以看到'),
          value: ClothingVisibility.private,
          groupValue: _visibility,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _visibility = value;
            });
          },
        ),

        RadioListTile<ClothingVisibility>(
          title: const Text('Public'),
          subtitle: const Text('好友可以看到'),
          value: ClothingVisibility.public,
          groupValue: _visibility,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _visibility = value;
            });
          },
        ),
      ],
    );
  }
}