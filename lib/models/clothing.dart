enum ClothingVisibility {
  public,
  private,
}

class Clothing {
  final String id;
  final String ownerId;

  final String name;
  final String imageUrl;

  final String brand;
  final String category;
  final String color;
  final String season;

  final double? price;

  final ClothingVisibility visibility;

  Clothing({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.imageUrl,
    required this.brand,
    required this.category,
    required this.color,
    required this.season,
    this.price,
    this.visibility = ClothingVisibility.private,
  });
}