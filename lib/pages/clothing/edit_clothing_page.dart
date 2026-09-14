import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
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
  State<EditClothingPage> createState() => _EditClothingPageState();
}

class _EditClothingPageState extends State<EditClothingPage> {
  final _formKey = GlobalKey<FormState>();
  final ClothingRepository _repository = ClothingRepository.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _colorController;
  late final TextEditingController _priceController;

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
    '帽子',
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
    final clothing = widget.clothing;

    _nameController = TextEditingController(text: clothing.name);
    _brandController = TextEditingController(text: clothing.brand ?? '');
    _colorController = TextEditingController(text: clothing.color);
    _priceController = TextEditingController(
      text: clothing.price?.toString() ?? '',
    );
    _selectedCategory = clothing.category;
    _selectedSeason = clothing.season;
    _visibility = clothing.visibility;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final l10n = context.l10n;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.replaceClothingImage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(
                  bottomSheetContext,
                  ImageSource.camera,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseFromGallery),
                onTap: () => Navigator.pop(
                  bottomSheetContext,
                  ImageSource.gallery,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null || !mounted) return;
      setState(() => _newImage = image);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.imageSelectFailed(e.toString()))),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final rawPrice = _priceController.text.trim();
      final double? price = rawPrice.isEmpty ? null : double.parse(rawPrice);

      final requestClothing = Clothing(
        id: widget.clothing.id,
        ownerId: widget.clothing.ownerId,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        category: _selectedCategory,
        color: _colorController.text.trim(),
        season: _selectedSeason,
        price: price,
        imagePath: widget.clothing.imagePath,
        imageType: widget.clothing.imageType,
        visibility: _visibility,
        createdAt: widget.clothing.createdAt,
        updatedAt: widget.clothing.updatedAt,
      );

      Clothing updated = await _repository.updateClothing(requestClothing);

      final newImage = _newImage;
      if (newImage != null) {
        updated = await _repository.uploadClothingImage(
          clothingId: updated.id,
          imagePath: newImage.path,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);

      final reason = localizedErrorMessage(context, e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saveFailed(reason))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editCard)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImageEditor(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.clothingNameRequired;
                }
                if (value.trim().length > 100) {
                  return l10n.nameMax100;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: l10n.brand,
                hintText: l10n.leaveBlank,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.trim().length > 100) {
                  return l10n.brandMax100;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.category,
                border: const OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(localizedCategory(context, category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: InputDecoration(
                labelText: l10n.color,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.colorRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSeason,
              decoration: InputDecoration(
                labelText: l10n.season,
                border: const OutlineInputBorder(),
              ),
              items: _seasons.map((season) {
                return DropdownMenuItem<String>(
                  value: season,
                  child: Text(localizedSeason(context, season)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSeason = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.price,
                prefixText: '¥ ',
                hintText: l10n.leaveBlank,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;

                final price = double.tryParse(text);
                if (price == null || price < 0) {
                  return l10n.validPrice;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildVisibility(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? l10n.saving : l10n.saveChanges),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageEditor() {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.clothingImage,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 320,
            width: double.infinity,
            child: _buildImage(),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _saving ? null : _selectImage,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(
            _newImage == null ? l10n.changeImage : l10n.reselectImage,
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final newImage = _newImage;
    if (newImage != null) {
      return Image.file(File(newImage.path), fit: BoxFit.cover);
    }

    final clothing = widget.clothing;
    if (clothing.imagePath.isEmpty) return _buildImageError();

    if (clothing.imageType == ClothingImageType.local) {
      return Image.file(
        File(clothing.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageError(),
      );
    }

    return Image.network(
      _remoteImageUrl(clothing),
      headers: ApiClient.instance.authorizationHeaders,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageError(),
    );
  }

  String _remoteImageUrl(Clothing clothing) {
    final resolved = ApiClient.instance.resolveUrl(clothing.imagePath);
    final uri = Uri.parse(resolved);

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'v': clothing.updatedAt.millisecondsSinceEpoch.toString(),
      },
    ).toString();
  }

  Widget _buildImageError() {
    return Container(
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

  Widget _buildVisibility() {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.visibility,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        RadioListTile<ClothingVisibility>(
          title: Text(l10n.privateLabel),
          subtitle: Text(l10n.privateSubtitle),
          value: ClothingVisibility.private,
          groupValue: _visibility,
          onChanged: (value) {
            if (value != null) setState(() => _visibility = value);
          },
        ),
        RadioListTile<ClothingVisibility>(
          title: Text(l10n.publicLabel),
          subtitle: Text(l10n.publicSubtitle),
          value: ClothingVisibility.public,
          groupValue: _visibility,
          onChanged: (value) {
            if (value != null) setState(() => _visibility = value);
          },
        ),
      ],
    );
  }
}
