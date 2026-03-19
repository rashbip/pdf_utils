package com.example.pdf_worker

import com.tom_roush.pdfbox.pdmodel.PDDocument
import java.io.File
import java.io.FileNotFoundException

class PdfMerger {
    fun choosePagesIndexToMerge(
            inputPath: String,
            outputPath: String,
            pagesIndex: List<Int>,
            onProgress: ((current: Int, total: Int) -> Unit)? = null
    ): String {
        val file = File(inputPath)
        if (!file.exists()) {
            throw FileNotFoundException("File does not exist: $inputPath")
        }
        val sourceDocument = PDDocument.load(file)
        val mergedDocument = PDDocument()

        if (pagesIndex.isEmpty()) {
            throw IllegalArgumentException("Pages index is empty")
        }
        if (pagesIndex.any { it < 0 || it >= sourceDocument.numberOfPages }) {
            throw IllegalArgumentException("Pages index is out of range")
        }
        pagesIndex.forEachIndexed { index, pageNumber ->
            val page = sourceDocument.getPage(pageNumber)
            mergedDocument.addPage(page)
            onProgress?.invoke(index + 1, pagesIndex.size)
        }

        mergedDocument.save(File(outputPath))

        sourceDocument.close()
        mergedDocument.close()
        return outputPath
    }

    fun mergePdfFiles(filesPath: List<String>, outputPath: String): String {
        val files = filesPath.map { File(it) }
        if (files.any { !it.exists() }) {
            throw FileNotFoundException("File does not exist: ${filesPath.joinToString(", ")}")
        }
        val sourceDocuments = files.map { PDDocument.load(it) }
        val mergedDocument = PDDocument()
        sourceDocuments.forEach { doc ->
            val pages = doc.pages // 这是 PDPageTree
            pages.forEach { page -> mergedDocument.addPage(page) }
        }
        mergedDocument.save(File(outputPath))
        sourceDocuments.forEach { it.close() }
        mergedDocument.close()
        return outputPath
    }

    fun mergeImagesToPdf(
        imagesPath: List<String>,
        outputPath: String,
        config: ImagesToPdfConfig? = null,
    ): String {
        return ImagesToPdfHelper.imagesToPdf(imagesPath, outputPath, config)
    }
}
