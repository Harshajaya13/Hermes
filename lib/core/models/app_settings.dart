import 'dart:convert';

class AppearanceSettings {
  final String fontSize; // 'Small', 'Medium', 'Large'
  final String visualDensity; // 'Comfortable', 'Compact'
  final bool reducedMotion;
  final bool oledBlack;

  const AppearanceSettings({
    this.fontSize = 'Medium',
    this.visualDensity = 'Comfortable',
    this.reducedMotion = false,
    this.oledBlack = true,
  });

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'visualDensity': visualDensity,
        'reducedMotion': reducedMotion,
        'oledBlack': oledBlack,
      };

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) => AppearanceSettings(
        fontSize: json['fontSize'] as String? ?? 'Medium',
        visualDensity: json['visualDensity'] as String? ?? 'Comfortable',
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        oledBlack: json['oledBlack'] as bool? ?? true,
      );

  AppearanceSettings copyWith({
    String? fontSize,
    String? visualDensity,
    bool? reducedMotion,
    bool? oledBlack,
  }) {
    return AppearanceSettings(
      fontSize: fontSize ?? this.fontSize,
      visualDensity: visualDensity ?? this.visualDensity,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      oledBlack: oledBlack ?? this.oledBlack,
    );
  }
}
