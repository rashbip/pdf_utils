
import PDFKit
import UIKit

public struct ImageScale {
    let maxWidth: Int
    let maxHeight: Int
}

public struct ImagesToPdfConfig {
    let rescale: ImageScale
    let keepAspectRatio: Bool


    static var defaultConfig: ImagesToPdfConfig {
        // 保持原始比例，缩放到A4纸张大小
        ImagesToPdfConfig(rescale: ImageScale(maxWidth: 595 * 2, maxHeight: 842 * 2), keepAspectRatio: true)
    }
}


extension ImagesToPdfConfig {
  
  init?(from dict: [String: Any]?) throws {
    guard let dict = dict else { return nil }
    let scaleDic = dict["rescale"] as? [String: Any]
    guard let maxWidth = scaleDic?["maxWidth"] as? Int,
          let maxHeight = scaleDic?["maxHeight"] as? Int else {
      return nil
    }
    rescale = ImageScale(maxWidth: maxWidth, maxHeight: maxHeight)
    keepAspectRatio = dict["keepAspectRatio"] as? Bool ?? true
  }
}

class ImagesToPdfHelper {
    static func imagesToPdf(imagesPath: [String], outputPath: String, config: ImagesToPdfConfig) throws -> String {
        guard !imagesPath.isEmpty else {
            throw PdfMergerError.emptyFilesPath
        }
        let pdfDocument = PDFDocument()
        for path in imagesPath {
            guard let image = UIImage(contentsOfFile: path) else { continue }
            let processedImage = resizeImage(image: image, config: config)

            if let pdfPage = PDFPage(image: processedImage) {
                pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
            }
        }
        guard pdfDocument.write(to: URL(fileURLWithPath: outputPath)) else {
            throw PdfMergerError.writeFailed
        }
        return outputPath
    }

    private static func resizeImage(image: UIImage, config: ImagesToPdfConfig) -> UIImage {
        let targetSize = calculateImageSize(image: image, config: config)
        if targetSize.width == image.size.width && targetSize.height == image.size.height {
            return image
        }

        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: rendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private static func calculateImageSize(image: UIImage, config: ImagesToPdfConfig?) -> CGSize {
        guard let config = config else {
            return image.size
        }
        let originalWidth = image.size.width
        let originalHeight = image.size.height

        let widthLimit = CGFloat(config.rescale.maxWidth)
        let heightLimit = CGFloat(config.rescale.maxHeight)

        if widthLimit <= 0 && heightLimit <= 0 {
            return CGSize(width: originalWidth, height: originalHeight)
        }

        if config.keepAspectRatio {
            switch (widthLimit > 0, heightLimit > 0) {
            case (true, true):
                let widthScale = widthLimit / originalWidth
                let heightScale = heightLimit / originalHeight
                let scaleFactor = min(widthScale, heightScale, 1.0)
                return CGSize(
                    width: max(originalWidth * scaleFactor, 1.0),
                    height: max(originalHeight * scaleFactor, 1.0)
                )
            case (true, false):
                let scaleFactor = min(widthLimit / originalWidth, 1.0)
                return CGSize(
                    width: max(originalWidth * scaleFactor, 1.0),
                    height: max(originalHeight * scaleFactor, 1.0)
                )
            case (false, true):
                let scaleFactor = min(heightLimit / originalHeight, 1.0)
                return CGSize(
                    width: max(originalWidth * scaleFactor, 1.0),
                    height: max(originalHeight * scaleFactor, 1.0)
                )
            default:
                return CGSize(width: originalWidth, height: originalHeight)
            }
        } else {
            let targetWidth = widthLimit > 0 ? min(widthLimit, originalWidth) : originalWidth
            let targetHeight = heightLimit > 0 ? min(heightLimit, originalHeight) : originalHeight
            return CGSize(width: max(targetWidth, 1.0), height: max(targetHeight, 1.0))
        }
    }
}