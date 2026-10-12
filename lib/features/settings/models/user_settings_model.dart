class UserSettingsModel {
  final String appTheme;
  final String language;
  final String dateOfBirth;
  final String timezone;

  const UserSettingsModel({
    this.appTheme = 'Dark',
    this.language = 'ru',
    this.dateOfBirth = '2001-01-01',
    this.timezone = 'UTC',
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      appTheme: json['app_theme']?.toString() ?? 'Dark',
      language: json['language']?.toString() ?? 'ru',
      dateOfBirth: json['date_of_birth']?.toString() ?? '2001-01-01',
      timezone: json['timezone']?.toString() ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() => {
        'app_theme': appTheme,
        'language': language,
        'date_of_birth': dateOfBirth,
        'timezone': timezone,
      };

  UserSettingsModel copyWith({
    String? appTheme,
    String? language,
    String? dateOfBirth,
    String? timezone,
  }) {
    return UserSettingsModel(
      appTheme: appTheme ?? this.appTheme,
      language: language ?? this.language,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timezone: timezone ?? this.timezone,
    );
  }
}
