import Flutter
import UIKit

public class PdfWorkerPlugin: NSObject, FlutterPlugin {
  private let pdfLocker = PdfLocker()
  private let pdfMerger = PdfMerger()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pdf_worker", binaryMessenger: registrar.messenger())
    let instance = PdfWorkerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "isEncryptedByTail":
      guard let args = call.arguments as? [String: Any],
        let filePath = args["filePath"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing filePath", details: nil))
        return
      }
      do {
        let isEncrypted = try pdfLocker.isEncryptedByTail(filePath: filePath)
        result(isEncrypted)
      } catch {
        result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
      }
    case "isEncrypted":
      guard let args = call.arguments as? [String: Any],
        let filePath = args["filePath"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing filePath", details: nil))
        return
      }
      do {
        let isEncrypted = try pdfLocker.isEncrypted(filePath: filePath)
        result(isEncrypted)
      } catch {
        result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
      }
    case "lock":
      guard let args = call.arguments as? [String: Any],
        let filePath = args["filePath"] as? String,
        let userPassword = args["userPassword"] as? String,
        let ownerPassword = args["ownerPassword"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing filePath or password", details: nil))
        return
      }
      do {
        try pdfLocker.lock(
          filePath: filePath, ownerPassword: ownerPassword, userPassword: userPassword)
        result(true)
      } catch {
        result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
      }
    case "unlock":
      guard let args = call.arguments as? [String: Any],
        let filePath = args["filePath"] as? String,
        let password = args["password"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing filePath or password", details: nil))
        return
      }
      do {
        let isUnlocked = try pdfLocker.unlock(filePath: filePath, password: password)
        result(isUnlocked)
      } catch {
        result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
      }
    case "choosePagesIndexToMerge":
      guard let args = call.arguments as? [String: Any],
        let inputPath = args["inputPath"] as? String,
        let outputPath = args["outputPath"] as? String,
        let pagesIndex = args["pagesIndex"] as? [Int]
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing inputPath or outputPath or pagesIndex",
            details: nil))
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let mergedPath = try self.pdfMerger.choosePagesIndexToMerge(
            inputPath: inputPath,
            outputPath: outputPath,
            pagesIndex: pagesIndex)
          DispatchQueue.main.async {
            result(mergedPath)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
          }
        }
      }
    case "mergePdfFiles":
      guard let args = call.arguments as? [String: Any],
        let filesPath = args["filesPath"] as? [String],
        let outputPath = args["outputPath"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing filesPath or outputPath", details: nil))
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let mergedPath = try self.pdfMerger.mergePdfFiles(
            filesPath: filesPath,
            outputPath: outputPath)
          DispatchQueue.main.async {
            result(mergedPath)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
          }
        }
      }

    case "mergeImagesToPdf":
      guard let args = call.arguments as? [String: Any],
        let imagesPath = args["imagesPath"] as? [String],
        let outputPath = args["outputPath"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing imagesPath or outputPath", details: nil))
        return
      }
      let configDict = args["config"] as? [String: Any]
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let outputPath = try self.pdfMerger.imagesToPdf(
            imagesPath: imagesPath,
            outputPath: outputPath,
            config: ImagesToPdfConfig(from: configDict))
          DispatchQueue.main.async {
            result(outputPath)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
          }
        }
      }
    case "pdfToImages":
      guard let args = call.arguments as? [String: Any],
        let inputPath = args["inputPath"] as? String,
        let outputDirectory = args["outputDirectory"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing inputPath or outputDirectory", details: nil))
        return
      }
      let configDict = args["config"] as? [String: Any]
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let imagesPath: [String] = try PdfToImageHelper.pdfToImages(
            inputPath: inputPath,
            outputDirectory: outputDirectory,
            config: PdfToImagesConfig(from: configDict))
          DispatchQueue.main.async {
            result(imagesPath)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
          }
        }
      }
    case "pdfToLongImage":
      guard let args = call.arguments as? [String: Any],
        let inputPath = args["inputPath"] as? String,
        let outputPath = args["outputPath"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENTS", message: "Missing inputPath or outputPath", details: nil))
        return
      }
      let configDict = args["config"] as? [String: Any]
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let outputPath = try PdfToImageHelper.pdfToLongImage(
            inputPath: inputPath,
            outputPath: outputPath,
            config: PdfToImagesConfig(from: configDict))
          DispatchQueue.main.async {
            result(outputPath)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "File not found", details: nil))
          }
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

