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
    skillProgress: json['skillProgress'] as List,
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
      'skillProgress': instance.skillProgress,
      'expModifierPercentage': instance.expModifierPercentage,
      'lootModifierPercentage': instance.lootModifierPercentage,
      'criticalHitChance': instance.criticalHitChance,
      'dodgeChance': instance.dodgeChance,
      'inventory': instance.inventory,
      'equipped': instance.equipped,
      'bloodSteal': instance.bloodSteal,
    };

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    name: json['name'] as String,
    id: json['id'] as String,
    behaviours: json['behaviours'] as Map<String, dynamic>,
    equip: json['equip'] as String,
    description: json['description'] as String,
    cost: json['cost'] as int,
    time: json['time'] as int,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'behaviours': instance.behaviours,
      'equip': instance.equip,
      'description': instance.description,
      'cost': instance.cost,
      'time': instance.time,
    };
