abstract class GeneralModel{
  factory GeneralModel.fromJson(Map<String, dynamic> jsonData) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson();
}