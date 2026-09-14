import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/clothing.dart';
import '../../network/api_client.dart';
import '../../widgets/info_row.dart';
import 'edit_clothing_page.dart';

class ClothingDetailPage extends StatefulWidget {
  final Clothing clothing;

  const ClothingDetailPage({
    super.key,
    required this.clothing,
  });

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  late Clothing _clothing;

  @override
  void initState() {
    super.initState();
    _clothing = widget.clothing;
  }

  Future<void> _editCard() async {
    final updated = await Navigator.push<Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) => EditClothingPage(clothing: _clothing),
      ),
    );

    if (updated == null || !mounted) return;
    setState(() => _clothing = updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clothingDetails)),
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
                InfoRow(
                  title: l10n.brand,
                  value: _clothing.brand ?? l10n.notSet,
                ),
                InfoRow(
                  title: l10n.category,
                  value: localizedCategory(context, _clothing.category),
                ),
                InfoRow(
                  title: l10n.color,
                  value: _clothing.color,
                ),
                InfoRow(
                  title: l10n.season,
                  value: localizedSeason(context, _clothing.season),
                ),
                InfoRow(
                  title: l10n.price,
                  value: _clothing.price == null
                      ? l10n.notSet
                      : '¥${_clothing.price}',
                ),
                InfoRow(
                  title: l10n.visibility,
                  value: localizedVisibility(context, _clothing.visibility),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _editCard,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.editCard),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (_clothing.imagePath.isEmpty) {
      return _buildImageError();
    }

    if (_clothing.imageType == ClothingImageType.local) {
      return Image.file(
        File(_clothing.imagePath),
        height: 420,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageError(),
      );
    }

    return Image.network(
      _remoteImageUrl(),
      headers: ApiClient.instance.authorizationHeaders,
      height: 420,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageError(),
    );
  }

  String _remoteImageUrl() {
    final resolved = ApiClient.instance.resolveUrl(_clothing.imagePath);
    final uri = Uri.parse(resolved);

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'v': _clothing.updatedAt.millisecondsSinceEpoch.toString(),
      },
    ).toString();
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
