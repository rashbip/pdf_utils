package com.rashbip.pdf_utils

import android.app.Activity
import android.graphics.BitmapFactory
import android.graphics.Color
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import com.tom_roush.pdfbox.pdmodel.graphics.image.JPEGFactory
import com.tom_roush.pdfbox.pdmodel.graphics.image.LosslessFactory
import com.tom_roush.pdfbox.pdmodel.graphics.state.PDExtendedGraphicsState
import com.tom_roush.pdfbox.util.Matrix
import kotlinx.coroutines.*
import java.io.File

enum class WatermarkPlacement {
    TOP_LEFT, TOP_CENTER, TOP_RIGHT,
    CENTER_LEFT, CENTER, CENTER_RIGHT,
    BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT,
    CUSTOM
}

suspend fun getWatermarkedPDFPath(
    path: String,
    text: String,
    imagePath: String?,
    fontSize: Float,
    colorHex: String,
    backgroundColorHex: String?,
    opacity: Float,
    placement: WatermarkPlacement,
    customX: Float?,
    customY: Float?,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            val font = PDType1Font.HELVETICA_BOLD
            
            // Hex to RGB
            val textColor = Color.parseColor(colorHex)
            val r = Color.red(textColor) / 255f
            val g = Color.green(textColor) / 255f
            val b = Color.blue(textColor) / 255f
            
            val bgColor = backgroundColorHex?.let { Color.parseColor(it) }
            val br = bgColor?.let { Color.red(it) / 255f }
            val bg = bgColor?.let { Color.green(it) / 255f }
            val bb = bgColor?.let { Color.blue(it) / 255f }

            // Image decoding
            val imageFile = imagePath?.let { File(it) }?.takeIf { it.exists() }
            val imageWidthOrig: Float
            val imageHeightOrig: Float
            if (imageFile != null && text.contains("{image}")) {
                val opts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(imagePath, opts)
                imageWidthOrig = opts.outWidth.toFloat()
                imageHeightOrig = opts.outHeight.toFloat()
            } else {
                imageWidthOrig = 0f
                imageHeightOrig = 0f
            }

            doc.pages.forEach { page ->
                val width = page.mediaBox.width
                val height = page.mediaBox.height
                
                val parts = if (imageFile != null && text.contains("{image}")) {
                    val split = text.split("{image}")
                    split.getOrNull(0) to split.getOrNull(1)
                } else {
                    text to null
                }
                
                val prefix = parts.first ?: ""
                val suffix = parts.second ?: ""
                
                val prefixWidth = font.getStringWidth(prefix) / 1000 * fontSize
                val suffixWidth = if (suffix != null) font.getStringWidth(suffix) / 1000 * fontSize else 0f
                val scaledImageWidth = if (imageHeightOrig > 0) imageWidthOrig * (fontSize / imageHeightOrig) else 0f
                val totalWidth = prefixWidth + scaledImageWidth + suffixWidth
                
                val margin = 50f
                var (x, y) = when (placement) {
                    WatermarkPlacement.TOP_LEFT -> margin to (height - margin - fontSize)
                    WatermarkPlacement.TOP_CENTER -> (width - totalWidth) / 2 to (height - margin - fontSize)
                    WatermarkPlacement.TOP_RIGHT -> (width - totalWidth - margin) to (height - margin - fontSize)
                    WatermarkPlacement.CENTER_LEFT -> margin to (height - fontSize) / 2
                    WatermarkPlacement.CENTER -> (width - totalWidth) / 2 to (height - fontSize) / 2
                    WatermarkPlacement.CENTER_RIGHT -> (width - totalWidth - margin) to (height - fontSize) / 2
                    WatermarkPlacement.BOTTOM_LEFT -> margin to margin
                    WatermarkPlacement.BOTTOM_CENTER -> (width - totalWidth) / 2 to margin
                    WatermarkPlacement.BOTTOM_RIGHT -> (width - totalWidth - margin) to margin
                    WatermarkPlacement.CUSTOM -> (customX ?: 0f) to (customY ?: 0f)
                }

                PDPageContentStream(doc, page, PDPageContentStream.AppendMode.APPEND, true, true).use { cs ->
                    // Set Opacity
                    val graphicsState = PDExtendedGraphicsState()
                    graphicsState.nonStrokingAlphaConstant = opacity
                    graphicsState.strokingAlphaConstant = opacity
                    cs.setGraphicsStateParameters(graphicsState)
                    
                    // Background
                    if (br != null && bg != null && bb != null) {
                        cs.setNonStrokingColor(br, bg, bb)
                        cs.addRect(x - 5f, y - 5f, totalWidth + 10f, fontSize + 10f)
                        cs.fill()
                    }
                    
                    cs.setNonStrokingColor(r, g, b)
                    
                    // Prefix
                    if (prefix.isNotEmpty()) {
                        cs.beginText()
                        cs.setFont(font, fontSize)
                        cs.setTextMatrix(Matrix.getTranslateInstance(x, y))
                        cs.showText(prefix)
                        cs.endText()
                    }
                    
                    // Image
                    if (imageFile != null && scaledImageWidth > 0) {
                        val bitmap = BitmapFactory.decodeFile(imagePath)
                        val pdImage = if (imagePath!!.lowercase().endsWith(".jpg") || imagePath.lowercase().endsWith(".jpeg")) {
                            JPEGFactory.createFromImage(doc, bitmap)
                        } else {
                            LosslessFactory.createFromImage(doc, bitmap)
                        }
                        cs.drawImage(pdImage, x + prefixWidth, y, scaledImageWidth, fontSize)
                    }
                    
                    // Suffix
                    if (suffix != null && suffix.isNotEmpty()) {
                        cs.beginText()
                        cs.setFont(font, fontSize)
                        cs.setTextMatrix(Matrix.getTranslateInstance(x + prefixWidth + scaledImageWidth, y))
                        cs.showText(suffix)
                        cs.endText()
                    }
                }
            }
            
            val out = File.createTempFile("watermarked_", ".pdf")
            doc.save(out)
            out.absolutePath
        }
    }
}
