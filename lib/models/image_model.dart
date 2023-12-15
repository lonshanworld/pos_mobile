class ImageModel{
  final String id;
  final String imageTxt;

  ImageModel({
    required this.id,
    required this.imageTxt,
  });

  ImageModel.fromJson(Map<String , dynamic> jsonData) :
    id = jsonData["id"],
    imageTxt = jsonData["imageTxt"];

  Map<String, dynamic> toJson() =>{
    "id" : id,
    "imageTxt" : imageTxt,
  };
}