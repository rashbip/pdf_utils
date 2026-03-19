package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.graphics.image.PDImageXObject
import com.tom_roush.pdfbox.pdmodel.graphics.form.PDFormXObject
import com.tom_roush.pdfbox.text.PDFTextStripper
import kotlinx.coroutines.*
import java.io.File

suspend fun removeBlankPagesFromPdf(
    path: String,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { sourceDoc ->
            val resultDoc = PDDocument()
            val stripper = PDFTextStripper()
            val totalPages = sourceDoc.numberOfPages
            
            for (i in 0 until totalPages) {
                val page = sourceDoc.getPage(i)
                
                // 1. Check for text
                stripper.startPage = i + 1
                stripper.endPage = i + 1
                val text = stripper.getText(sourceDoc).trim()
                
                // 2. Check for images/forms in resources
                var hasGraphics = false
                val resources = page.resources
                if (resources != null) {
                    for (name in resources.xObjectNames) {
                        val xObject = resources.getXObject(name)
                        if (xObject is PDImageXObject || xObject is PDFormXObject) {
                            hasGraphics = true
                            break
                        }
                    }
                }
                
                // 3. Keep page if it has text OR graphics
                if (text.isNotEmpty() || hasGraphics) {
                    resultDoc.addPage(resultDoc.importPage(page))
                }
            }
            
            val out = File.createTempFile("cleaned_", ".pdf")
            resultDoc.save(out)
            resultDoc.close()
            out.absolutePath
        }
    }
}
