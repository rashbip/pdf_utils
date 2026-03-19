
enum ImageFormat {
  png('png'),
  jpg('jpg');

  final String value;
  const ImageFormat(this.value);
}

class PdfToImagesConfig {
  final List<int>? pagesIndex;
  final ImageFormat imgFormat;
  final int quality; // 0-99, 100 is default， only for lossy format jpg

  PdfToImagesConfig({
    this.pagesIndex,
    this.imgFormat = ImageFormat.png,
    this.quality = 100,
  });

  Map<String, dynamic> toJson() => {
    'pagesIndex': pagesIndex,
    'imgFormat': imgFormat.value,
    'quality': quality,
  };
}