import 'package:flutter/widgets.dart';

import '../models/clothing/clothing.dart';
import 'l10n.dart';

const List<String> clothingMainCategoryIds = [
  'tops',
  'bottoms',
  'one_piece',
  'sets',
  'underwear',
  'footwear',
  'accessories',
];

const Map<String, List<String>> clothingCategoryHierarchy = {
  'tops': [
    'tops.t-shirt',
    'tops.shirt',
    'tops.polo',
    'tops.tank',
    'tops.sweatshirt',
    'tops.knitwear',
    'tops.cardigan',
    'tops.vest',
    'tops.blazer',
    'tops.jacket',
    'tops.trench',
    'tops.coat',
    'tops.down_jacket',
    'tops.padded_jacket',
    'tops.shell_jacket',
    'tops.leather_jacket',
    'tops.sun_protective',
    'tops.other',
  ],
  'bottoms': [
    'bottoms.jeans',
    'bottoms.dress_pants',
    'bottoms.casual_pants',
    'bottoms.cargo_pants',
    'bottoms.sweatpants',
    'bottoms.leggings',
    'bottoms.wide_leg_pants',
    'bottoms.shorts',
    'bottoms.skirt',
    'bottoms.culottes',
    'bottoms.other',
  ],
  'one_piece': [
    'one_piece.dress',
    'one_piece.gown',
    'one_piece.jumpsuit',
    'one_piece.romper',
    'one_piece.overalls',
    'one_piece.pinafore',
    'one_piece.bodysuit',
    'one_piece.other',
  ],
  'sets': [
    'sets.suit',
    'sets.casual_set',
    'sets.tracksuit',
    'sets.knit_set',
    'sets.pajama_set',
    'sets.loungewear',
    'sets.swimwear',
    'sets.other',
  ],
  'underwear': [
    'underwear.bra',
    'underwear.briefs',
    'underwear.undershirt',
    'underwear.base_layer_top',
    'underwear.base_layer_bottom',
    'underwear.long_johns',
    'underwear.thermal_pants',
    'underwear.shapewear',
    'underwear.socks',
    'underwear.tights',
    'underwear.stockings',
    'underwear.other',
  ],
  'footwear': [
    'footwear.sneakers',
    'footwear.casual_shoes',
    'footwear.canvas_shoes',
    'footwear.dress_shoes',
    'footwear.loafers',
    'footwear.heels',
    'footwear.flats',
    'footwear.sandals',
    'footwear.slippers',
    'footwear.ankle_boots',
    'footwear.tall_boots',
    'footwear.rain_boots',
    'footwear.hiking_shoes',
    'footwear.other',
  ],
  'accessories': [
    'accessories.hat',
    'accessories.headwear',
    'accessories.scarf',
    'accessories.shawl',
    'accessories.gloves',
    'accessories.belt',
    'accessories.tie',
    'accessories.bow_tie',
    'accessories.sleeve',
    'accessories.other',
  ],
};

String? mainCategoryIdFor(String categoryId) {
  final separatorIndex = categoryId.indexOf('.');
  if (separatorIndex <= 0) {
    return null;
  }

  final mainCategoryId = categoryId.substring(0, separatorIndex);
  return clothingMainCategoryIds.contains(mainCategoryId)
      ? mainCategoryId
      : null;
}

String localizedMainCategory(BuildContext context, String mainCategoryId) {
  final l10n = context.l10n;

  switch (mainCategoryId) {
    case 'tops':
      return l10n.categoryGroupTops;
    case 'bottoms':
      return l10n.categoryGroupBottoms;
    case 'one_piece':
      return l10n.categoryGroupOnePiece;
    case 'sets':
      return l10n.categoryGroupSets;
    case 'underwear':
      return l10n.categoryGroupUnderwear;
    case 'footwear':
      return l10n.categoryGroupFootwear;
    case 'accessories':
      return l10n.categoryGroupAccessories;
    default:
      return mainCategoryId;
  }
}

String localizedCategory(BuildContext context, String categoryId) {
  final l10n = context.l10n;

  switch (categoryId) {
    case 'tops.t-shirt':
      return l10n.categoryTshirt;
    case 'tops.shirt':
      return l10n.categoryShirt;
    case 'tops.polo':
      return l10n.categoryPolo;
    case 'tops.tank':
      return l10n.categoryTank;
    case 'tops.sweatshirt':
      return l10n.categorySweatshirt;
    case 'tops.knitwear':
      return l10n.categoryKnitwear;
    case 'tops.cardigan':
      return l10n.categoryCardigan;
    case 'tops.vest':
      return l10n.categoryVest;
    case 'tops.blazer':
      return l10n.categoryBlazer;
    case 'tops.jacket':
      return l10n.categoryJacket;
    case 'tops.trench':
      return l10n.categoryTrench;
    case 'tops.coat':
      return l10n.categoryLongCoat;
    case 'tops.down_jacket':
      return l10n.categoryDownJacket;
    case 'tops.padded_jacket':
      return l10n.categoryPaddedJacket;
    case 'tops.shell_jacket':
      return l10n.categoryShellJacket;
    case 'tops.leather_jacket':
      return l10n.categoryLeatherJacket;
    case 'tops.sun_protective':
      return l10n.categorySunProtective;
    case 'tops.other':
      return l10n.categoryOtherTops;
    case 'bottoms.jeans':
      return l10n.categoryJeans;
    case 'bottoms.dress_pants':
      return l10n.categoryDressPants;
    case 'bottoms.casual_pants':
      return l10n.categoryCasualPants;
    case 'bottoms.cargo_pants':
      return l10n.categoryCargoPants;
    case 'bottoms.sweatpants':
      return l10n.categorySweatpants;
    case 'bottoms.leggings':
      return l10n.categoryLeggings;
    case 'bottoms.wide_leg_pants':
      return l10n.categoryWideLegPants;
    case 'bottoms.shorts':
      return l10n.categoryShorts;
    case 'bottoms.skirt':
      return l10n.categorySkirt;
    case 'bottoms.culottes':
      return l10n.categoryCulottes;
    case 'bottoms.other':
      return l10n.categoryOtherBottoms;
    case 'one_piece.dress':
      return l10n.categoryDress;
    case 'one_piece.gown':
      return l10n.categoryGown;
    case 'one_piece.jumpsuit':
      return l10n.categoryJumpsuit;
    case 'one_piece.romper':
      return l10n.categoryRomper;
    case 'one_piece.overalls':
      return l10n.categoryOveralls;
    case 'one_piece.pinafore':
      return l10n.categoryPinafore;
    case 'one_piece.bodysuit':
      return l10n.categoryBodysuit;
    case 'one_piece.other':
      return l10n.categoryOtherOnePiece;
    case 'sets.suit':
      return l10n.categorySuitSet;
    case 'sets.casual_set':
      return l10n.categoryCasualSet;
    case 'sets.tracksuit':
      return l10n.categoryTracksuit;
    case 'sets.knit_set':
      return l10n.categoryKnitSet;
    case 'sets.pajama_set':
      return l10n.categoryPajamaSet;
    case 'sets.loungewear':
      return l10n.categoryLoungewear;
    case 'sets.swimwear':
      return l10n.categorySwimwear;
    case 'sets.other':
      return l10n.categoryOtherSets;
    case 'underwear.bra':
      return l10n.categoryBra;
    case 'underwear.briefs':
      return l10n.categoryBriefs;
    case 'underwear.undershirt':
      return l10n.categoryUndershirt;
    case 'underwear.base_layer_top':
      return l10n.categoryBaseLayerTop;
    case 'underwear.base_layer_bottom':
      return l10n.categoryBaseLayerBottom;
    case 'underwear.long_johns':
      return l10n.categoryLongJohns;
    case 'underwear.thermal_pants':
      return l10n.categoryThermalPants;
    case 'underwear.shapewear':
      return l10n.categoryShapewear;
    case 'underwear.socks':
      return l10n.categorySocks;
    case 'underwear.tights':
      return l10n.categoryTights;
    case 'underwear.stockings':
      return l10n.categoryStockings;
    case 'underwear.other':
      return l10n.categoryOtherUnderwear;
    case 'footwear.sneakers':
      return l10n.categorySneakers;
    case 'footwear.casual_shoes':
      return l10n.categoryCasualShoes;
    case 'footwear.canvas_shoes':
      return l10n.categoryCanvasShoes;
    case 'footwear.dress_shoes':
      return l10n.categoryDressShoes;
    case 'footwear.loafers':
      return l10n.categoryLoafers;
    case 'footwear.heels':
      return l10n.categoryHeels;
    case 'footwear.flats':
      return l10n.categoryFlats;
    case 'footwear.sandals':
      return l10n.categorySandals;
    case 'footwear.slippers':
      return l10n.categorySlippers;
    case 'footwear.ankle_boots':
      return l10n.categoryAnkleBoots;
    case 'footwear.tall_boots':
      return l10n.categoryTallBoots;
    case 'footwear.rain_boots':
      return l10n.categoryRainBoots;
    case 'footwear.hiking_shoes':
      return l10n.categoryHikingShoes;
    case 'footwear.other':
      return l10n.categoryOtherFootwear;
    case 'accessories.hat':
      return l10n.categoryHat;
    case 'accessories.headwear':
      return l10n.categoryHeadwear;
    case 'accessories.scarf':
      return l10n.categoryScarf;
    case 'accessories.shawl':
      return l10n.categoryShawl;
    case 'accessories.gloves':
      return l10n.categoryGloves;
    case 'accessories.belt':
      return l10n.categoryBelt;
    case 'accessories.tie':
      return l10n.categoryTie;
    case 'accessories.bow_tie':
      return l10n.categoryBowTie;
    case 'accessories.sleeve':
      return l10n.categorySleeve;
    case 'accessories.other':
      return l10n.categoryOtherAccessories;
    default:
      return categoryId;
  }
}

String localizedCategoryPath(BuildContext context, String categoryId) {
  final mainCategoryId = mainCategoryIdFor(categoryId);
  final subCategory = localizedCategory(context, categoryId);

  if (mainCategoryId == null) {
    return subCategory;
  }

  return '${localizedMainCategory(context, mainCategoryId)} · $subCategory';
}

String localizedSeason(BuildContext context, String season) {
  final l10n = context.l10n;

  switch (season) {
    case '全季':
      return l10n.seasonAll;
    case '春季':
      return l10n.seasonSpring;
    case '夏季':
      return l10n.seasonSummer;
    case '秋季':
      return l10n.seasonAutumn;
    case '冬季':
      return l10n.seasonWinter;
    case '春秋':
      return l10n.seasonSpringAutumn;
    case '秋冬':
      return l10n.seasonAutumnWinter;
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
