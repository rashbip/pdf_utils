import Flutter
import UIKit
import PDFKit

public class PdfUtilsPlugin: NSObject, FlutterPlugin {
  private let pdfLocker = PdfLocker()
  private let pdfMerger = PdfMerger()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pdf_utils", binaryMessenger: registrar.messenger())
    let instance = PdfUtilsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "isEncrypted":
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "File path is null", details: nil))
        return
      }
      do {
        let isEncrypted = try pdfLocker.isEncrypted(filePath: filePath)
        result(isEncrypted)
      } catch {
        result(FlutterError(code: "IS_ENCRYPTED_FAILED", message: error.localizedDescription, details: nil))
      }
    case "lock":
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String,
            let userPassword = args["userPassword"] as? String,
            let ownerPassword = args["ownerPassword"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "File path or password is null", details: nil))
        return
      }
      do {
        try pdfLocker.lock(filePath: filePath, ownerPassword: ownerPassword, userPassword: userPassword)
        result(true)
      } catch {
        result(FlutterError(code: "LOCK_FAILED", message: error.localizedDescription, details: nil))
      }
    case "unlock":
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String,
            let password = args["password"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "File path or password is null", details: nil))
        return
      }
      do {
        let success = try pdfLocker.unlock(filePath: filePath, password: password)
        result(success)
      } catch {
        result(FlutterError(code: "UNLOCK_FAILED", message: error.localizedDescription, details: nil))
      }
    case "mergePdfFiles":
      guard let args = call.arguments as? [String: Any],
            let filesPath = args["filesPath"] as? [String],
            let outputPath = args["outputPath"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Files path or output path is null", details: nil))
        return
      }
      do {
        let path = try pdfMerger.mergePdfFiles(filesPath: filesPath, outputPath: outputPath)
        result(path)
      } catch {
        result(FlutterError(code: "MERGE_PDF_FILES_FAILED", message: error.localizedDescription, details: nil))
      }
    case "choosePagesIndexToMerge":
      guard let args = call.arguments as? [String: Any],
            let inputPath = args["inputPath"] as? String,
            let outputPath = args["outputPath"] as? String,
            let pagesIndex = args["pagesIndex"] as? [Int] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Input path, output path or pages is null", details: nil))
        return
      }
      do {
        let path = try pdfMerger.choosePagesIndexToMerge(inputPath: inputPath, outputPath: outputPath, pagesIndex: pagesIndex)
        result(path)
      } catch {
        result(FlutterError(code: "CHOOSE_PAGES_TO_MERGE_FAILED", message: error.localizedDescription, details: nil))
      }
    case "mergeImagesToPdf":
      guard let args = call.arguments as? [String: Any],
            let imagesPath = args["imagesPath"] as? [String],
            let outputPath = args["outputPath"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Images path or output path is null", details: nil))
        return
      }
      do {
        let config = try ImagesToPdfConfig(from: args["config"] as? [String: Any])
        let path = try pdfMerger.imagesToPdf(imagesPath: imagesPath, outputPath: outputPath, config: config)
        result(path)
      } catch {
        result(FlutterError(code: "MERGE_IMAGES_TO_PDF_FAILED", message: error.localizedDescription, details: nil))
      }
    case "pdfToImages":
      guard let args = call.arguments as? [String: Any],
            let inputPath = args["inputPath"] as? String,
            let outputDirectory = args["outputDirectory"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Input path or output directory is null", details: nil))
        return
      }
      do {
        let config = PdfToImagesConfig(from: args["config"] as? [String: Any])
        let paths = try PdfToImageHelper.pdfToImages(inputPath: inputPath, outputDirectory: outputDirectory, config: config)
        result(paths)
      } catch {
        result(FlutterError(code: "PDF_TO_IMAGES_FAILED", message: error.localizedDescription, details: nil))
      }
    case "initDoc":
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Path is null", details: nil))
        return
      }
      let password = args["password"] as? String ?? ""
      initDoc(result: result, path: path, password: password)
    case "getDocPageText":
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String,
            let pageNumber = args["number"] as? Int else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Path or page number is null", details: nil))
        return
      }
      let password = args["password"] as? String ?? ""
      getDocPageText(result: result, path: path, password: password, pageNumber: pageNumber)
    case "getDocText":
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String,
            let missingPagesNumbers = args["missingPagesNumbers"] as? [Int] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Path or pages is null", details: nil))
        return
      }
      let password = args["password"] as? String ?? ""
      getDocText(result: result, path: path, password: password, missingPagesNumbers: missingPagesNumbers)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initDoc(result: @escaping FlutterResult, path: String, password: String) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard let doc = self.getDoc(path: path, password: password) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "INIT_DOC_FAILED", message: "Could not open document", details: nil))
        }
        return
      }
      let length = doc.pageCount
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
      
      let attrs = doc.documentAttributes ?? [:]
      let creationDate = (attrs[PDFDocumentAttribute.creationDateAttribute] as? Date).map { dateFormatter.string(from: $0) }
      let modificationDate = (attrs[PDFDocumentAttribute.modificationDateAttribute] as? Date).map { dateFormatter.string(from: $0) }
      
      let info: [String: Any] = [
        "author": attrs[PDFDocumentAttribute.authorAttribute] ?? "",
        "creationDate": creationDate ?? "",
        "modificationDate": modificationDate ?? "",
        "creator": attrs[PDFDocumentAttribute.creatorAttribute] ?? "",
        "producer": attrs[PDFDocumentAttribute.producerAttribute] ?? "",
        "keywords": attrs[PDFDocumentAttribute.keywordsAttribute] ?? "",
        "title": attrs[PDFDocumentAttribute.titleAttribute] ?? "",
        "subject": attrs[PDFDocumentAttribute.subjectAttribute] ?? ""
      ]
      let data: [String: Any] = ["length": length, "info": info]
      DispatchQueue.main.async {
        result(data)
      }
    }
  }

  private func getDocPageText(result: @escaping FlutterResult, path: String, password: String, pageNumber: Int) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard let doc = self.getDoc(path: path, password: password),
            let page = doc.page(at: pageNumber - 1) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "GET_PAGE_TEXT_FAILED", message: "Could not get page text", details: nil))
        }
        return
      }
      let text = page.string ?? ""
      DispatchQueue.main.async {
        result(text)
      }
    }
  }

  private func getDocText(result: @escaping FlutterResult, path: String, password: String, missingPagesNumbers: [Int]) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard let doc = self.getDoc(path: path, password: password) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "GET_DOC_TEXT_FAILED", message: "Could not get doc text", details: nil))
        }
        return
      }
      var missingPagesTexts = [String]()
      for pageNumber in missingPagesNumbers {
        if let page = doc.page(at: pageNumber - 1) {
          missingPagesTexts.append(page.string ?? "")
        } else {
          missingPagesTexts.append("")
        }
      }
      DispatchQueue.main.async {
        result(missingPagesTexts)
      }
    }
  }

  private func getDoc(path: String, password: String = "") -> PDFDocument? {
    let url = URL(fileURLWithPath: path)
    guard let doc = PDFDocument(url: url) else { return nil }
    if doc.isEncrypted {
      if !doc.unlock(withPassword: password) {
        return nil
      }
    }
    return doc
  }
}
