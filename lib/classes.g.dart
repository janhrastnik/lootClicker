// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
    gold: json['gold'] as int,
    hp: json['hp'] as int,
    hpCap: json['hpCap'] as int,
    attack: json['attack'] as int,
    intelligence: json['intelligence'] as int,
    looting: json['looting'] as int,
    exp: json['exp'] as int,
    expCap: json['expCap'] as int,
    expModifierRaw: json['expModifierRaw'] as int,
    lootModifierRaw: json['lootModifierRaw'] as int,
    expModifierPercentage: (json['expModifierPercentage'] as num)?.toDouble(),
    lootModifierPercentage: (json['lootModifierPercentage'] as num)?.toDouble(),
    criticalHitDamage: json['criticalHitDamage'] as int,
    criticalHitChance: (json['criticalHitChance'] as num)?.toDouble(),
    dodgeChance: (json['dodgeChance'] as num)?.toDouble(),
    inventory: json['inventory'] as List,
    equipped: json['equipped'] as Map<String, dynamic>,
    bloodSteal: json['bloodSteal'] as bool,
    skillPoints: json['skillPoints'] as int,
    skillProgress: json['skill-progress'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'gold': instance.gold,
      'hp': instance.hp,
      'hpCap': instance.hpCap,
      'attack': instance.attack,
      'looting': instance.looting,
      'intelligence': instance.intelligence,
      'exp': instance.exp,
      'expCap': instance.expCap,
      'expModifierRaw': instance.expModifierRaw,
      'lootModifierRaw': instance.lootModifierRaw,
      'skillPoints': instance.skillPoints,
      'criticalHitDamage': instance.criticalHitDamage,
      'skill-progress': instance.skillProgress,
      'expModifierPercentage': instance.expModifierPercentage,
      'lootModifierPercentage': instance.lootModifierPercentage,
      'criticalHitChance': instance.criticalHitChance,
      'dodgeChance': instance.dodgeChance,
      'inventory': instance.inventory,
      'equipped': instance.equipped,
      'bloodSteal': instance.bloodSteal,
    };
