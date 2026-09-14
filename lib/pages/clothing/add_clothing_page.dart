import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
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
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  late CameraController _cameraController;
  late Future<void> _cameraInitialization;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = '上衣';
  String _selectedSeason = '春季';
  ClothingVisibility _visibility = ClothingVisibility.private;
  XFile? _capturedImage;
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
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _cameraInitialization = _cameraController.initialize();
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
      if (_cameraController.value.isTakingPicture) return;

      final image = await _cameraController.takePicture();
      if (!mounted) return;

      setState(() => _capturedImage = image);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.takePhotoFailed(e.toString()))),
      );
    }
  }

  void _retakePicture() {
    setState(() => _capturedImage = null);
  }

  Future<void> _saveClothing() async {
    final capturedImage = _capturedImage;
    if (capturedImage == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final repository = ClothingRepository.instance;
    Clothing? created;

    try {
      final now = DateTime.now();
      final rawPrice = _priceController.text.trim();
      final price = rawPrice.isEmpty ? null : double.parse(rawPrice);

      final draft = Clothing(
        id: '',
        ownerId: widget.ownerId,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        imagePath: capturedImage.path,
        imageType: ClothingImageType.local,
        category: _selectedCategory,
        color: _colorController.text.trim(),
        season: _selectedSeason,
        price: price,
        visibility: _visibility,
        createdAt: now,
        updatedAt: now,
      );

      created = await repository.addClothing(draft);
      final completed = await repository.uploadClothingImage(
        clothingId: created.id,
        imagePath: capturedImage.path,
      );

      if (!mounted) return;
      Navigator.pop(context, completed);
    } catch (e) {
      if (created != null) {
        try {
          await repository.deleteClothing(created.id);
        } catch (_) {}
      }

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
    return _capturedImage != null ? _buildFormPage() : _buildCameraPage();
  }

  Widget _buildCameraPage() {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.captureClothing)),
      body: FutureBuilder<void>(
        future: _cameraInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
              child: Text(l10n.cameraOpenFailed('${snapshot.error}')),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFormPage() {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addClothing),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveClothing,
            child: Text(l10n.save),
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
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: l10n.nameExample,
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
                hintText: l10n.optional,
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
                hintText: l10n.colorExample,
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
                hintText: l10n.optional,
                prefixText: '¥ ',
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
            const SizedBox(height: 16),
            _buildVisibilitySelector(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _saveClothing,
              child: _saving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(l10n.createClothing),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          onPressed: _saving ? null : _retakePicture,
          icon: const Icon(Icons.camera_alt),
          label: Text(context.l10n.retakePhoto),
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
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
