package com.rashbip.pdf_utils

import android.app.Activity
import android.graphics.Color as AndroidColor
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import com.tom_roush.pdfbox.pdmodel.graphics.state.PDExtendedGraphicsState
import com.tom_roush.pdfbox.util.Matrix
import kotlinx.coroutines.*
import java.io.File

suspend fun getWatermarkedPDFPath(
    path: String,
    text: String,
    size: Float,
    opacity: Float,
    rotation: Float,
    colorHex: String,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            val font = PDType1Font.HELVETICA_BOLD
            val parsedColor = AndroidColor.parseColor(colorHex)
            val r = AndroidColor.red(parsedColor) / 255f
            val g = AndroidColor.green(parsedColor) / 255f
            val b = AndroidColor.blue(parsedColor) / 255f
            
            doc.pages.forEach { page ->
                PDPageContentStream(doc, page, PDPageContentStream.AppendMode.APPEND, true, true).use { cs ->
                    val state = PDExtendedGraphicsState()
                    state.nonStrokingAlphaConstant = opacity
                    cs.setGraphicsStateParameters(state)
                    cs.setNonStrokingColor(r, g, b)
                    cs.beginText()
                    cs.setFont(font, size)
                    
                    val width = page.mediaBox.width
                    val height = page.mediaBox.height
                    val textWidth = font.getStringWidth(text) / 1000 * size
                    
                    val tx = (width - textWidth) / 2
                    val ty = height / 2
                    
                    cs.setTextMatrix(Matrix.getRotateInstance(Math.toRadians(rotation.toDouble()), tx, ty))
                    cs.showText(text)
                    cs.endText()
                }
            }
            val out = File.createTempFile("watermarked_", ".pdf")
            doc.save(out)
            out.absolutePath
        }
    }
}
