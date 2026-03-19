import PDFKit
import UIKit

enum PdfMergerError: Error {
    case notFileUrl
    case fileNotFound
    case writeFailed

    case emptyFilesPath
}

class PdfMerger {

    func choosePagesIndexToMerge(
        inputPath: String,
        outputPath: String,
        pagesIndex: [Int],
        onProgress: ((_ current: Int, _ total: Int) -> Void)? = nil
    ) throws -> String {
        let url = URL(fileURLWithPath: inputPath)
        guard url.isFileURL else {
            throw PdfMergerError.notFileUrl
        }
        let pdfDocument = PDFDocument(url: url)
        guard pdfDocument != nil else {
            throw PdfMergerError.fileNotFound
        }

        let pdfDocumentToMerge = PDFDocument.init()
        pagesIndex.reversed().forEach {
            if let page = pdfDocument?.page(at: $0) {
                pdfDocumentToMerge.insert(page, at: 0)
                onProgress?($0 + 1, pagesIndex.count)
            }
        }
        let success = pdfDocumentToMerge.write(toFile: outputPath)
        guard success else {
            throw PdfMergerError.writeFailed
        }
        return outputPath
    }

    func mergePdfFiles(
        filesPath: [String],
        outputPath: String
    ) throws -> String {
        guard !filesPath.isEmpty else {
            throw PdfMergerError.emptyFilesPath
        }
        let mergedPDF = PDFDocument()
        var pageIndex = 0
        for path in filesPath {
            guard let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) else { continue }

            for index in 0..<pdfDocument.pageCount {
                guard let page = pdfDocument.page(at: index) else { continue }
                mergedPDF.insert(page, at: pageIndex)
                pageIndex += 1
            }
        }
        guard mergedPDF.write(to: URL(fileURLWithPath: outputPath)) else {
            throw PdfMergerError.writeFailed
        }
        return outputPath
    }

    func imagesToPdf(
        imagesPath: [String],
        outputPath: String,
        config: ImagesToPdfConfig?
    ) throws -> String {
        return try ImagesToPdfHelper.imagesToPdf(imagesPath: imagesPath, outputPath: outputPath, config: config ?? ImagesToPdfConfig.defaultConfig)
    }
}

