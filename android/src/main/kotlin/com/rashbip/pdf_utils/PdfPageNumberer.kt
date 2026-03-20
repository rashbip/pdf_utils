package com.rashbip.pdf_utils

import android.app.Activity
import android.graphics.BitmapFactory
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import com.tom_roush.pdfbox.pdmodel.graphics.image.JPEGFactory
import com.tom_roush.pdfbox.pdmodel.graphics.image.LosslessFactory
import com.tom_roush.pdfbox.util.Matrix
import kotlinx.coroutines.*
import java.io.File
import java.io.FileInputStream

suspend fun addPageNumbersToPdf(
    path: String,
    customText: String?, // If null, use "Page n of m"
    imagePath: String?,
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
            
            // Pre-calculate image if provided
            val imageFile = imagePath?.let { File(it) }?.takeIf { it.exists() }
            val imageWidthOrig: Float
            val imageHeightOrig: Float
            
            if (imageFile != null && customText?.contains("{image}") == true) {
                val opts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(imagePath, opts)
                imageWidthOrig = opts.outWidth.toFloat()
                imageHeightOrig = opts.outHeight.toFloat()
            } else {
                imageWidthOrig = 0f
                imageHeightOrig = 0f
            }

            for (i in 0 until totalPages) {
                val pageNumber = i + 1
                if (targetSet == null || targetSet.contains(pageNumber)) {
                    val page = doc.getPage(i)
                    val width = page.mediaBox.width
                    val height = page.mediaBox.height
                    
                    val rawText = customText ?: "Page $pageNumber of $totalPages"
                    val processedText = rawText.replace("{n}", pageNumber.toString()).replace("{total}", totalPages.toString())
                    
                    val parts = if (imageFile != null && processedText.contains("{image}")) {
                        val split = processedText.split("{image}")
                        split.getOrNull(0) to split.getOrNull(1)
                    } else {
                        processedText to null
                    }
                    
                    val prefix = parts.first ?: ""
                    val suffix = parts.second ?: ""
                    
                    val prefixWidth = font.getStringWidth(prefix) / 1000 * fontSize
                    val suffixWidth = if (suffix != null) font.getStringWidth(suffix) / 1000 * fontSize else 0f
                    
                    val scaledImageWidth = if (imageHeightOrig > 0) (imageWidthOrig * (fontSize / imageHeightOrig)) else 0f
                    val totalWidth = prefixWidth + scaledImageWidth + suffixWidth
                    
                    val margin = 30f
                    val (baseX, baseY) = when (placement) {
                        TextPlacement.TOP_LEFT -> margin to (height - margin)
                        TextPlacement.TOP_CENTER -> (width - totalWidth) / 2 to (height - margin)
                        TextPlacement.TOP_RIGHT -> (width - totalWidth - margin) to (height - margin)
                        TextPlacement.BOTTOM_LEFT -> margin to margin
                        TextPlacement.BOTTOM_CENTER -> (width - totalWidth) / 2 to margin
                        TextPlacement.BOTTOM_RIGHT -> (width - totalWidth - margin) to margin
                    }
                    
                    PDPageContentStream(doc, page, PDPageContentStream.AppendMode.APPEND, true, true).use { cs ->
                        // Draw Prefix
                        if (prefix.isNotEmpty()) {
                            cs.beginText()
                            cs.setFont(font, fontSize)
                            cs.setTextMatrix(Matrix.getTranslateInstance(baseX, baseY))
                            cs.showText(prefix)
                            cs.endText()
                        }
                        
                        // Draw Image
                        if (imageFile != null && scaledImageWidth > 0) {
                            val bitmap = BitmapFactory.decodeFile(imagePath)
                            val pdImage = if (imagePath!!.lowercase().endsWith(".jpg") || imagePath.lowercase().endsWith(".jpeg")) {
                                JPEGFactory.createFromImage(doc, bitmap)
                            } else {
                                LosslessFactory.createFromImage(doc, bitmap)
                            }
                            
                            val imgX = baseX + prefixWidth
                            // Align bottom of image with baseline of text approximately
                            val imgY = baseY 
                            
                            cs.drawImage(pdImage, imgX, imgY, scaledImageWidth, fontSize)
                        }
                        
                        // Draw Suffix
                        if (suffix.isNotEmpty()) {
                            cs.beginText()
                            cs.setFont(font, fontSize)
                            cs.setTextMatrix(Matrix.getTranslateInstance(baseX + prefixWidth + scaledImageWidth, baseY))
                            cs.showText(suffix)
                            cs.endText()
                        }
                    }
                }
            }
            
            val out = File.createTempFile("numbered_img_", ".pdf")
            doc.save(out)
            out.absolutePath
        }
    }
}
