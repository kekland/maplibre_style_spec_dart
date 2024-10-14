class SpriteSource {
  const SpriteSource({this.id, required this.url});

  factory SpriteSource.fromJson(Map<String, dynamic> json) {
    return SpriteSource(
      id: json['id'] as String,
      url: json['url'] as String,
    );
  }

  final String? id;
  final String url;

  Uri getIndexUri({bool isHighDpi = false}) {
    return Uri.parse('$url${isHighDpi ? '@2x' : ''}.json');
  }

  Uri getImageUri({bool isHighDpi = false}) {
    return Uri.parse('$url${isHighDpi ? '@2x' : ''}.png');
  }
}

class Sprite {
  const Sprite({
    required this.sources,
  });

  final List<SpriteSource> sources;

  factory Sprite.fromJson(dynamic json) {
    if (json is String) {
      return Sprite(sources: [SpriteSource(url: json)]);
    } else if (json is List) {
      return Sprite(
          sources: json
              .map((e) => SpriteSource.fromJson(e as Map<String, dynamic>))
              .toList());
    } else {
      throw Exception('Invalid [Sprite] value: $json');
    }
  }
}

enum SpriteTextFit {
  stretchOrShrink,
  stretchOnly;

  static SpriteTextFit fromJson(String json) {
    return switch (json) {
      'stretchOrShrink' => SpriteTextFit.stretchOrShrink,
      'stretchOnly' => SpriteTextFit.stretchOnly,
      _ => throw Exception('Unsupported SpriteTextFit value: $json'),
    };
  }
}

class SpriteData {
  const SpriteData({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.pixelRatio,
    this.content,
    this.stretchX,
    this.stretchY,
    this.sdf = false,
    this.textFitWidth = SpriteTextFit.stretchOrShrink,
    this.textFitHeight = SpriteTextFit.stretchOrShrink,
  });

  factory SpriteData.fromJson(Map<String, dynamic> json) {
    return SpriteData(
      width: json['width'] as int,
      height: json['height'] as int,
      x: json['x'] as int,
      y: json['y'] as int,
      pixelRatio: (json['pixelRatio'] as num).toDouble(),
      content: json['content'] != null
          ? (json['content'] as List).cast<int>()
          : null,
      stretchX: json['stretchX'] != null
          ? (json['stretchX'] as List).cast<int>()
          : null,
      stretchY: json['stretchY'] != null
          ? (json['stretchY'] as List).cast<int>()
          : null,
      sdf: json['sdf'] != null ? json['sdf'] as bool : false,
      textFitWidth: json['textFitWidth'] != null
          ? SpriteTextFit.fromJson(json['textFitWidth'] as String)
          : SpriteTextFit.stretchOrShrink,
      textFitHeight: json['textFitHeight'] != null
          ? SpriteTextFit.fromJson(json['textFitHeight'] as String)
          : SpriteTextFit.stretchOrShrink,
    );
  }

  final int width;
  final int height;
  final int x;
  final int y;
  final double pixelRatio;

  final List<int>? content;
  final List<int>? stretchX;
  final List<int>? stretchY;
  final bool sdf;

  final SpriteTextFit textFitWidth;
  final SpriteTextFit textFitHeight;
}

class SpriteIndex {
  const SpriteIndex({
    required this.sprites,
  });

  factory SpriteIndex.fromJson(Map<String, dynamic> json) {
    return SpriteIndex(
      sprites: json.map((key, value) =>
          MapEntry(key, SpriteData.fromJson(value as Map<String, dynamic>))),
    );
  }

  final Map<String, SpriteData> sprites;
}
