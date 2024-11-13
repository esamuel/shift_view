// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => AppState()
  ..shifts = (json['shifts'] as List<dynamic>)
      .map((e) => Shift.fromJson(e as Map<String, dynamic>))
      .toList()
  ..overtimeRules = (json['overtimeRules'] as List<dynamic>)
      .map((e) => OvertimeRule.fromJson(e as Map<String, dynamic>))
      .toList()
  ..festiveDays = (json['festiveDays'] as List<dynamic>)
      .map((e) => DateTime.parse(e as String))
      .toList()
  ..hourlyWage = (json['hourlyWage'] as num).toDouble()
  ..taxDeduction = (json['taxDeduction'] as num).toDouble()
  ..startOnSunday = json['startOnSunday'] as bool
  ..baseHoursWeekday = (json['baseHoursWeekday'] as num).toDouble()
  ..baseHoursSpecialDay = (json['baseHoursSpecialDay'] as num).toDouble();

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'shifts': instance.shifts,
      'overtimeRules': instance.overtimeRules,
      'festiveDays':
          instance.festiveDays.map((e) => e.toIso8601String()).toList(),
      'hourlyWage': instance.hourlyWage,
      'taxDeduction': instance.taxDeduction,
      'startOnSunday': instance.startOnSunday,
      'baseHoursWeekday': instance.baseHoursWeekday,
      'baseHoursSpecialDay': instance.baseHoursSpecialDay,
    };
