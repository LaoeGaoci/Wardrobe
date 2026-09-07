import '../models/app_user.dart';
import '../models/clothing.dart';
import '../models/friendship.dart';
import '../models/recommendation.dart';

final currentUser = AppUser(
  id: 'user_me',
  username: '小明',
);

final mother = AppUser(
  id: 'user_mother',
  username: '海',
);

final clothes = [
  Clothing(
    id: 'clothes_001',
    ownerId: 'user_me',
    name: '黑色羽绒服',
    imageUrl: 'https://images.unsplash.com/photo-1548883354-94bcfe321cbb',
    brand: 'Nike',
    category: '羽绒服',
    color: '黑色',
    season: '冬季',
    price: 899,
    visibility: ClothingVisibility.public,
  ),
  Clothing(
    id: 'clothes_002',
    ownerId: 'user_me',
    name: '灰色卫衣',
    imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7',
    brand: 'Adidas',
    category: '卫衣',
    color: '灰色',
    season: '秋季',
    price: 399,
    visibility: ClothingVisibility.public,
  ),
  Clothing(
    id: 'clothes_003',
    ownerId: 'user_me',
    name: '黑色运动裤',
    imageUrl: 'https://images.unsplash.com/photo-1552902865-b72c031ac5ea',
    brand: 'Nike',
    category: '裤子',
    color: '黑色',
    season: '四季',
    price: 299,
    visibility: ClothingVisibility.private,
  ),
  Clothing(
    id: 'clothes_004',
    ownerId: 'user_mother',
    name: '保暖羽绒服',
    imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f',
    brand: 'Uniqlo',
    category: '羽绒服',
    color: '白色',
    season: '冬季',
    price: 799,
    visibility: ClothingVisibility.public,
  ),
  Clothing(
    id: 'clothes_005',
    ownerId: 'user_mother',
    name: '保暖秋裤',
    imageUrl: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1',
    brand: 'Uniqlo',
    category: '裤子',
    color: '黑色',
    season: '冬季',
    price: 199,
    visibility: ClothingVisibility.public,
  ),
];

final friendships = [
  Friendship(
    id: 'friendship_001',
    ownerId: 'user_me',
    friendId: 'user_mother',
    nickname: '妈妈',
  ),
];

final recommendations = [
  Recommendation(
    id: 'recommendation_001',
    senderId: 'user_mother',
    receiverId: 'user_me',
    clothingIds: [
      'clothes_004',
      'clothes_005',
    ],
    message: '天气冷了，记得穿暖和一点。',
    createdAt: DateTime.now(),
  ),
];