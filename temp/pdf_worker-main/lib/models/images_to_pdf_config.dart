class ImageScale {
  const ImageScale({required this.maxWidth, required this.maxHeight});

  final int maxWidth;
  final int maxHeight;

  Map<String, dynamic> toJson() => {
    'maxWidth': maxWidth,
    'maxHeight': maxHeight,
  };
}

class ImagesToPdfConfig {
  const ImagesToPdfConfig({required this.rescale, this.keepAspectRatio = true});

  final ImageScale rescale;
  final bool keepAspectRatio;

  Map<String, dynamic> toJson() => {
    'rescale': rescale.toJson(),
    'keepAspectRatio': keepAspectRatio,
  };

  factory ImagesToPdfConfig.a4Config() {
    return ImagesToPdfConfig(
      rescale: ImageScale(maxWidth: 595*2, maxHeight: 842*2),
      keepAspectRatio: true,
    );
  }
}
