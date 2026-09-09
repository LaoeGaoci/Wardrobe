import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/clothing.dart';

class ClothingRepository {
  ClothingRepository._();

  static final ClothingRepository instance =
  ClothingRepository._();

  final List<Clothing> _clothes = [];

  List<Clothing> get clothes =>
      List.unmodifiable(_clothes);

  Future<String> saveImage(String sourcePath) async {
    final directory =
    await getApplicationDocumentsDirectory();

    final clothingDirectory =
    Directory('${directory.path}/clothing');

    if (!await clothingDirectory.exists()) {
      await clothingDirectory.create(
        recursive: true,
      );
    }

    final fileName =
        'clothing_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final targetPath =
        '${clothingDirectory.path}/$fileName';

    final sourceFile = File(sourcePath);

    await sourceFile.copy(targetPath);

    return targetPath;
  }

  Future<void> addClothing(
      Clothing clothing,
      ) async {
    _clothes.insert(0, clothing);
  }

  Future<void> updateClothing(
      Clothing clothing,
      ) async {
    final index = _clothes.indexWhere(
          (item) => item.id == clothing.id,
    );

    if (index == -1) {
      return;
    }

    _clothes[index] = clothing;
  }

  Future<void> deleteClothing(
      String id,
      ) async {
    _clothes.removeWhere(
          (clothing) => clothing.id == id,
    );
  }

  Clothing? getById(String id) {
    for (final clothing in _clothes) {
      if (clothing.id == id) {
        return clothing;
      }
    }

    return null;
  }
}