import 'package:json_annotation/json_annotation.dart';

part 'retrofit_res.g.dart';

@JsonSerializable(
    genericArgumentFactories: true
)
class RetrofitResponseModel<T> {
  bool success;
  String message;
  int code;
  T? data;
  List<T>? dataList;

  RetrofitResponseModel({required this.success, required this.message, required this.code, required this.data, required this.dataList});

  factory RetrofitResponseModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT,) => _$RetrofitResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => _$RetrofitResponseModelToJson(this, toJsonT);

  @override
  String toString() {
    return 'RetrofitResponseModel{success: $success, message: $message, code: $code, data: $data, dataList: $dataList}';
  }
}

