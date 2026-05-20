class CrashReportModel {
  final int id;
  final String errorMessage;
  final String stackTrace;
  final String? deviceInfo;
  final String? userInfo;
  final String appVersion;
  final String platform;
  final DateTime timestamp;
  final String errorType;
  final bool isSynced;

  CrashReportModel({
    required this.id,
    required this.errorMessage,
    required this.stackTrace,
    this.deviceInfo,
    this.userInfo,
    required this.appVersion,
    required this.platform,
    required this.timestamp,
    required this.errorType,
    this.isSynced = false,
  });

  factory CrashReportModel.fromMap(Map<String, dynamic> map) {
    return CrashReportModel(
      id: map['id'] as int,
      errorMessage: map['errorMessage'] as String,
      stackTrace: map['stackTrace'] as String,
      deviceInfo: map['deviceInfo'] as String?,
      userInfo: map['userInfo'] as String?,
      appVersion: map['appVersion'] as String,
      platform: map['platform'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      errorType: map['errorType'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'deviceInfo': deviceInfo,
      'userInfo': userInfo,
      'appVersion': appVersion,
      'platform': platform,
      'timestamp': timestamp.toIso8601String(),
      'errorType': errorType,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'deviceInfo': deviceInfo,
      'userInfo': userInfo,
      'appVersion': appVersion,
      'platform': platform,
      'timestamp': timestamp.toIso8601String(),
      'errorType': errorType,
    };
  }

  CrashReportModel copyWith({
    int? id,
    String? errorMessage,
    String? stackTrace,
    String? deviceInfo,
    String? userInfo,
    String? appVersion,
    String? platform,
    DateTime? timestamp,
    String? errorType,
    bool? isSynced,
  }) {
    return CrashReportModel(
      id: id ?? this.id,
      errorMessage: errorMessage ?? this.errorMessage,
      stackTrace: stackTrace ?? this.stackTrace,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      userInfo: userInfo ?? this.userInfo,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      timestamp: timestamp ?? this.timestamp,
      errorType: errorType ?? this.errorType,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
