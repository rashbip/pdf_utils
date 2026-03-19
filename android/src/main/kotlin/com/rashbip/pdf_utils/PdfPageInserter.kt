package com.rashbip.pdf_utils

import android.app.Activity
import android.graphics.BitmapFactory
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.common.PDRectangle
import com.tom_roush.pdfbox.pdmodel.graphics.image.JPEGFactory
import com.tom_roush.pdfbox.pdmodel.graphics.image.LosslessFactory
import kotlinx.coroutines.*
import java.io.File
import java.io.FileInputStream

suspend fun insertPageToPdf(
    sourcePath: String,
    insertPath: String,
    index: Int, // 1-based index where the new page will be (0 for start)
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(sourcePath)).use { mainDoc ->
            val insertFile = File(insertPath)
            
            // 1. Create the page(s) to insert
            val pagesToInsert = mutableListOf<PDPage>()
            val temporaryDoc = if (insertPath.lowercase().endsWith(".pdf")) {
                PDDocument.load(insertFile)
            } else {
                val doc = PDDocument()
                val pdImage = if (insertPath.lowercase().endsWith(".jpg") || insertPath.lowercase().endsWith(".jpeg")) {
                    JPEGFactory.createFromStream(doc, FileInputStream(insertFile))
                } else {
                    val bitmap = BitmapFactory.decodeFile(insertPath)
                    LosslessFactory.createFromImage(doc, bitmap)
                }
                val page = PDPage(PDRectangle(pdImage.width.toFloat(), pdImage.height.toFloat()))
                doc.addPage(page)
                PDPageContentStream(doc, page).use { cs -> cs.drawImage(pdImage, 0f, 0f) }
                doc
            }

            // 2. Add pages to mainDoc at specific index
            // In PDFBox 2.x, we add pages to the PDPageTree
            val totalPages = mainDoc.numberOfPages
            val targetIndex = index.coerceIn(0, totalPages)
            
            temporaryDoc.pages.forEachIndexed { i, page ->
                // Note: we must import the page if it's from another document
                val importedPage = mainDoc.importPage(page)
                
                // Move it to the right position if it's not simply appended
                if (targetIndex + i < mainDoc.numberOfPages - 1) {
                    // This is tricky in PDFBox 2.x as addPage always appends.
                    // We need to reorder the page tree.
                }
            }
            
            // Cleaner way for insertion at index in PDFBox 2.x:
            // Create a new document and add pages in order.
            val finalDoc = PDDocument()
            val tempPages = temporaryDoc.pages.map { finalDoc.importPage(it) }
            
            for (i in 0 until totalPages) {
                if (i == targetIndex) {
                    tempPages.forEach { finalDoc.addPage(it) }
                }
                finalDoc.addPage(finalDoc.importPage(mainDoc.getPage(i)))
            }
            if (targetIndex >= totalPages) {
                tempPages.forEach { finalDoc.addPage(it) }
            }

            val out = File.createTempFile("inserted_", ".pdf")
            finalDoc.save(out)
            finalDoc.close()
            temporaryDoc.close()
            out.absolutePath
        }
    }
}
