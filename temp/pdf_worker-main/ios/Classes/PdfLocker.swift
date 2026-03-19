import Foundation
import PDFKit

enum PdfLockerError: Error {
    case fileNotFound
    case invalidPassword
    case pdfContextFailed
    case dataWriteFailed

    var nsError: NSError {
        switch self {
        case .fileNotFound:
            return NSError(
                domain: "PdfLockerError", code: 3001,
                userInfo: [NSLocalizedDescriptionKey: "File not found"])
        case .invalidPassword:
            return NSError(
                domain: "PdfLockerError", code: 3002,
                userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
        case .pdfContextFailed:
            return NSError(
                domain: "PdfLockerError", code: 3003,
                userInfo: [NSLocalizedDescriptionKey: "PDF context failed"])
        case .dataWriteFailed:
            return NSError(
                domain: "PdfLockerError", code: 3004,
                userInfo: [NSLocalizedDescriptionKey: "Data write failed"])
        }
    }
}

class PdfLocker {

    func isEncryptedByTail(filePath: String) throws -> Bool {
        let fileURL = URL(fileURLWithPath: filePath)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw PdfLockerError.fileNotFound
        }
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            defer { try? fileHandle.close() }

            let fileLength = try fileHandle.seekToEnd()
            let readSize = UInt64(min(fileLength, 4096))

            guard readSize > 0 else {
                throw PdfLockerError.fileNotFound
            }

            try fileHandle.seek(toOffset: fileLength - readSize)
            let buffer = fileHandle.readData(ofLength: Int(readSize))
            let tailString = String(decoding: buffer, as: UTF8.self)

            if let trailerRange = tailString.range(of: "trailer", options: [.backwards]) {
                let dictSearchRange = trailerRange.lowerBound..<tailString.endIndex
                if let dictStartRange = tailString.range(of: "<<", range: dictSearchRange),
                    let dictEndRange = tailString.range(
                        of: ">>", range: dictStartRange.upperBound..<tailString.endIndex)
                {
                    let trailerDict = tailString[
                        dictStartRange.lowerBound..<dictEndRange.upperBound]
                    if trailerDict.contains("/Encrypt") {
                        return true
                    }
                }
            }

            if tailString.contains("/Encrypt") {
                return true
            }
            return false
        } catch {
            throw PdfLockerError.dataWriteFailed
        }
    }

    func isEncrypted(filePath: String) throws -> Bool {
        let url = URL(fileURLWithPath: filePath)
        guard let pdfDocument = PDFDocument(url: url) else {
            throw PdfLockerError.fileNotFound
        }
        return pdfDocument.isEncrypted
    }

    func lock(filePath: String, ownerPassword: String, userPassword: String) throws {
        let url = URL(fileURLWithPath: filePath)
        guard let pdfDocument = PDFDocument(url: url) else {
            throw PdfLockerError.fileNotFound
        }

        let data = NSMutableData()
        let options: [CFString: Any] = [
            kCGPDFContextUserPassword: userPassword,
            kCGPDFContextOwnerPassword: ownerPassword,
            kCGPDFContextEncryptionKeyLength: 128,
        ]

        guard let consumer = CGDataConsumer(data: data as CFMutableData),
            let context = CGContext(consumer: consumer, mediaBox: nil, options as CFDictionary)
        else {
            throw PdfLockerError.pdfContextFailed
        }

        for i in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            var mediaBox = page.bounds(for: .mediaBox)
            context.beginPage(mediaBox: &mediaBox)
            context.drawPDFPage(page.pageRef!)
            context.endPage()
        }

        context.closePDF()
        // 写入加密后的 data
        // 新pdf 覆盖到原路径
        let isSuccess = data.write(to: url, atomically: true)
        if !isSuccess {
            throw PdfLockerError.dataWriteFailed
        }
    }

    func unlock(filePath: String, password: String) throws -> Bool {
        let url = URL(fileURLWithPath: filePath)
        guard let pdfDocument = PDFDocument(url: url) else {
            throw PdfLockerError.fileNotFound
        }
        let result = pdfDocument.unlock(withPassword: password)
        guard result else {
            return false
        }
        // 创建一个新的 PDF 文档，把所有页面复制进去
        let newDoc = PDFDocument()
        for i in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: i) {
                newDoc.insert(page, at: i)
            }
        }
        // 保存时不会带加密
        if newDoc.write(to: url) {
            return true
        }
        throw PdfLockerError.dataWriteFailed
    }

}
