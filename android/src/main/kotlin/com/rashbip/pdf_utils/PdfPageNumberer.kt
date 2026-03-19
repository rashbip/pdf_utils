package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import com.tom_roush.pdfbox.util.Matrix
import kotlinx.coroutines.*
import java.io.File

enum class TextPlacement {
    TOP_LEFT, TOP_CENTER, TOP_RIGHT,
    BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT
}

suspend fun addPageNumbersToPdf(
    path: String,
    customText: String?, // If null, use "Page n of m"
    fontSize: Float,
    placement: TextPlacement,
    pagesIndex: List<Int>?,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            val totalPages = doc.numberOfPages
            val font = PDType1Font.HELVETICA
            val targetSet = pagesIndex?.toSet()
            
            for (i in 0 until totalPages) {
                val pageNumber = i + 1
                if (targetSet == null || targetSet.contains(pageNumber)) {
                    val page = doc.getPage(i)
                    val width = page.mediaBox.width
                    val height = page.mediaBox.height
                    
                    val textToDraw = customText?.replace("{n}", pageNumber.toString())?.replace("{total}", totalPages.toString())
                        ?: "Page $pageNumber of $totalPages"
                    
                    val textWidth = font.getStringWidth(textToDraw) / 1000 * fontSize
                    val margin = 30f
                    
                    val (x, y) = when (placement) {
                        TextPlacement.TOP_LEFT -> margin to (height - margin)
                        TextPlacement.TOP_CENTER -> (width - textWidth) / 2 to (height - margin)
                        TextPlacement.TOP_RIGHT -> (width - textWidth - margin) to (height - margin)
                        TextPlacement.BOTTOM_LEFT -> margin to margin
                        TextPlacement.BOTTOM_CENTER -> (width - textWidth) / 2 to margin
                        TextPlacement.BOTTOM_RIGHT -> (width - textWidth - margin) to margin
                    }
                    
                    PDPageContentStream(doc, page, PDPageContentStream.AppendMode.APPEND, true, true).use { cs ->
                        cs.beginText()
                        cs.setFont(font, fontSize)
                        cs.setTextMatrix(Matrix.getTranslateInstance(x, y))
                        cs.showText(textToDraw)
                        cs.endText()
                    }
                }
            }
            
            val out = File.createTempFile("numbered_", ".pdf")
            doc.save(out)
            out.absolutePath
        }
    }
}
