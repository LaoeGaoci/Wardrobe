import 'package:flutter/widgets.dart';

import '../models/clothing.dart';
import 'l10n.dart';

String localizedCategory(BuildContext context, String category) {
  final l10n = context.l10n;

  switch (category) {
    case '全部':
      return l10n.categoryAll;
    case '上衣':
      return l10n.categoryTop;
    case '外套':
      return l10n.categoryCoat;
    case '羽绒服':
      return l10n.categoryDownJacket;
    case '裤子':
      return l10n.categoryPants;
    case '帽子':
      return l10n.categoryHat;
    case '鞋子':
      return l10n.categoryShoes;
    case '配饰':
      return l10n.categoryAccessories;
    default:
      return category;
  }
}

String localizedSeason(BuildContext context, String season) {
  final l10n = context.l10n;

  switch (season) {
    case '春季':
      return l10n.seasonSpring;
    case '夏季':
      return l10n.seasonSummer;
    case '秋季':
      return l10n.seasonAutumn;
    case '冬季':
      return l10n.seasonWinter;
    default:
      return season;
  }
}

String localizedVisibility(
  BuildContext context,
  ClothingVisibility visibility,
) {
  return visibility == ClothingVisibility.public
      ? context.l10n.publicLabel
      : context.l10n.privateLabel;
}
