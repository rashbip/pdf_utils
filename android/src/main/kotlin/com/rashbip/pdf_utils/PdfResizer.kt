package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.multipdf.LayerUtility
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.common.PDRectangle
import com.tom_roush.pdfbox.util.Matrix
import kotlinx.coroutines.*
import java.io.File

suspend fun resizePdfPages(
    path: String,
    targetWidth: Float,
    targetHeight: Float,
    pagesIndex: List<Int>?,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { sourceDoc ->
            val resultDoc = PDDocument()
            val layerUtility = LayerUtility(resultDoc)
            val resizeSet = pagesIndex?.toSet()
            
            sourceDoc.pages.forEachIndexed { idx, sourcePage ->
                val pageNumber = idx + 1
                if (resizeSet == null || resizeSet.contains(pageNumber)) {
                    // Create a new target page with requested dimensions
                    val targetPage = PDPage(PDRectangle(targetWidth, targetHeight))
                    resultDoc.addPage(targetPage)
                    
                    // Import source page as a form (xobject)
                    val form = layerUtility.importPageAsForm(sourceDoc, sourcePage)
                    
                    // Calculate scale to fit while maintaining aspect ratio
                    val sourceWidth = sourcePage.mediaBox.width
                    val sourceHeight = sourcePage.mediaBox.height
                    
                    val scaleX = targetWidth / sourceWidth
                    val scaleY = targetHeight / sourceHeight
                    val scale = Math.min(scaleX, scaleY)
                    
                    // Calculate centering offsets
                    val scaledWidth = sourceWidth * scale
                    val scaledHeight = sourceHeight * scale
                    val dx = (targetWidth - scaledWidth) / 2
                    val dy = (targetHeight - scaledHeight) / 2
                    
                    PDPageContentStream(resultDoc, targetPage, PDPageContentStream.AppendMode.APPEND, true, true).use { cs ->
                        cs.transform(Matrix.getTranslateInstance(dx, dy))
                        cs.transform(Matrix.getScaleInstance(scale, scale))
                        cs.drawForm(form)
                    }
                } else {
                    // Keep original page size
                    resultDoc.addPage(resultDoc.importPage(sourcePage))
                }
            }
            
            val out = File.createTempFile("resized_", ".pdf")
            resultDoc.save(out)
            resultDoc.close()
            out.absolutePath
        }
    }
}
