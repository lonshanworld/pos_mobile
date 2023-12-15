class AlertKnownPersonModel{
  final int id;
  final int alertId; // foreign key
  final int knownPersonId; // foreign key
  final DateTime knownTime;

  AlertKnownPersonModel({
    required this.id,
    required this.alertId,
    required this.knownPersonId,
    required this.knownTime,
  });

  AlertKnownPersonModel.fromJson(Map<String, dynamic> jsonData) :
      id = jsonData["id"],
      alertId = jsonData["alertId"],
      knownPersonId = jsonData["knownPersonId"],
      knownTime = DateTime.parse(jsonData["knownTime"]);

  Map<String, dynamic> toJson()=>{
    "id" : id,
    "alertId" : alertId,
    "knownPersonId" : knownPersonId,
    "knownTime" : knownTime.toString(),
  };
}