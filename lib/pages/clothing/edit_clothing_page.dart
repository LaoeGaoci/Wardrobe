import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _formKey =
  GlobalKey<FormState>();

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

    final clothing =
        widget.clothing;

    _nameController =
        TextEditingController(
          text: clothing.name,
        );

    _brandController =
        TextEditingController(
          text: clothing.brand ?? '',
        );

    _colorController =
        TextEditingController(
          text: clothing.color,
        );

    _priceController =
        TextEditingController(
          text: clothing.price
              ?.toString() ??
              '',
        );

    _selectedCategory =
        clothing.category;

    _selectedSeason =
        clothing.season;

    _visibility =
        clothing.visibility;
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
    final source =
    await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  8,
                ),
                child: Align(
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    '更换衣物图片',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                ),
                title: const Text(
                  '拍照',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
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
                    context,
                    ImageSource.gallery,
                  );
                },
              ),

              const SizedBox(
                height: 8,
              ),
            ],
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

      if (image == null ||
          !mounted) {
        return;
      }

      setState(() {
        _newImage = image;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '选择图片失败：$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // Save
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final rawPrice =
      _priceController.text.trim();

      final double? price =
      rawPrice.isEmpty
          ? null
          : double.parse(
        rawPrice,
      );

      /// 不使用 copyWith，
      /// 因为这里需要允许 brand / price
      /// 真正变成 null。
      final requestClothing =
      Clothing(
        id: widget.clothing.id,
        ownerId:
        widget.clothing.ownerId,

        name:
        _nameController
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

        category:
        _selectedCategory,

        color:
        _colorController
            .text
            .trim(),

        season:
        _selectedSeason,

        price: price,

        imagePath:
        widget.clothing
            .imagePath,

        imageType:
        widget.clothing
            .imageType,

        visibility:
        _visibility,

        createdAt:
        widget.clothing
            .createdAt,

        updatedAt:
        widget.clothing
            .updatedAt,
      );

      /// 1. 修改 D1 中的衣物信息。
      Clothing updated =
      await _repository
          .updateClothing(
        requestClothing,
      );

      /// 2. 用户真的选择了新图片时，
      /// 才上传 R2。
      final newImage =
          _newImage;

      if (newImage != null) {
        updated =
        await _repository
            .uploadClothingImage(
          clothingId:
          updated.id,
          imagePath:
          newImage.path,
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '保存失败：$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '编辑卡片',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.all(
            16,
          ),
          children: [
            _buildImageEditor(),

            const SizedBox(
              height: 24,
            ),

            TextFormField(
              controller:
              _nameController,
              decoration:
              const InputDecoration(
                labelText: '名称',
                border:
                OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return '请输入衣物名称';
                }

                if (value
                    .trim()
                    .length >
                    100) {
                  return '名称不能超过100个字符';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(
              controller:
              _brandController,
              decoration:
              const InputDecoration(
                labelText: '品牌',
                hintText:
                '可留空',
                border:
                OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null &&
                    value
                        .trim()
                        .length >
                        100) {
                  return '品牌不能超过100个字符';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            DropdownButtonFormField<
                String>(
              value:
              _selectedCategory,
              decoration:
              const InputDecoration(
                labelText: '分类',
                border:
                OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (category) {
                  return DropdownMenuItem<
                      String>(
                    value:
                    category,
                    child:
                    Text(
                      category,
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedCategory =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(
              controller:
              _colorController,
              decoration:
              const InputDecoration(
                labelText: '颜色',
                border:
                OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return '请输入颜色';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            DropdownButtonFormField<
                String>(
              value:
              _selectedSeason,
              decoration:
              const InputDecoration(
                labelText: '季节',
                border:
                OutlineInputBorder(),
              ),
              items: _seasons
                  .map(
                    (season) {
                  return DropdownMenuItem<
                      String>(
                    value: season,
                    child:
                    Text(
                      season,
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedSeason =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(
              controller:
              _priceController,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              decoration:
              const InputDecoration(
                labelText: '价格',
                prefixText: '¥ ',
                hintText:
                '可留空',
                border:
                OutlineInputBorder(),
              ),
              validator: (value) {
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
                  return '请输入有效价格';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 24,
            ),

            _buildVisibility(),

            const SizedBox(
              height: 32,
            ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed:
                _saving
                    ? null
                    : _save,
                icon: _saving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.save_outlined,
                ),
                label: Text(
                  _saving
                      ? '正在保存'
                      : '保存修改',
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageEditor() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          '衣物图片',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          child: SizedBox(
            height: 320,
            width:
            double.infinity,
            child:
            _buildImage(),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        OutlinedButton.icon(
          onPressed:
          _saving
              ? null
              : _selectImage,
          icon: const Icon(
            Icons
                .photo_camera_outlined,
          ),
          label: Text(
            _newImage == null
                ? '更换图片'
                : '重新选择图片',
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final newImage =
        _newImage;

    if (newImage != null) {
      return Image.file(
        File(
          newImage.path,
        ),
        fit: BoxFit.cover,
      );
    }

    final clothing =
        widget.clothing;

    if (clothing
        .imagePath
        .isEmpty) {
      return _buildImageError();
    }

    if (clothing.imageType ==
        ClothingImageType.local) {
      return Image.file(
        File(
          clothing.imagePath,
        ),
        fit: BoxFit.cover,
        errorBuilder:
            (
            context,
            error,
            stackTrace,
            ) {
          return _buildImageError();
        },
      );
    }

    return Image.network(
      _remoteImageUrl(
        clothing,
      ),
      headers:
      ApiClient
          .instance
          .authorizationHeaders,
      fit: BoxFit.cover,
      errorBuilder:
          (
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
    ApiClient.instance
        .resolveUrl(
      clothing.imagePath,
    );

    final uri =
    Uri.parse(
      resolved,
    );

    return uri
        .replace(
      queryParameters: {
        ...uri
            .queryParameters,
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
      color:
      Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons
              .image_not_supported_outlined,
          size: 56,
          color:
          Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildVisibility() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          '可见性',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        RadioListTile<
            ClothingVisibility>(
          title:
          const Text(
            'Private',
          ),
          subtitle:
          const Text(
            '只有你可以看到',
          ),
          value:
          ClothingVisibility
              .private,
          groupValue:
          _visibility,
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _visibility =
                  value;
            });
          },
        ),

        RadioListTile<
            ClothingVisibility>(
          title:
          const Text(
            'Public',
          ),
          subtitle:
          const Text(
            '好友可以看到',
          ),
          value:
          ClothingVisibility
              .public,
          groupValue:
          _visibility,
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _visibility =
                  value;
            });
          },
        ),
      ],
    );
  }
}