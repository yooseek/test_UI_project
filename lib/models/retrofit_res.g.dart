// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retrofit_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetrofitResponseModel<T> _$RetrofitResponseModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    RetrofitResponseModel<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      dataList: (json['dataList'] as List<dynamic>?)?.map(fromJsonT).toList(),
    );

Map<String, dynamic> _$RetrofitResponseModelToJson<T>(
  RetrofitResponseModel<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'code': instance.code,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'dataList': instance.dataList?.map(toJsonT).toList(),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
