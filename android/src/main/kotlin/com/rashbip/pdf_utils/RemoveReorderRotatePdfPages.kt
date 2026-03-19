package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import kotlinx.coroutines.*
import java.io.File

suspend fun getPDFPageRotatorDeleterReorder(
    path: String,
    reorder: List<Int>,
    delete: List<Int>,
    rotate: List<PageRotationInfo>,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            val total = doc.numberOfPages
            val deleteSet = delete.toSet()
            val rotateMap = rotate.associate { it.pageNumber to it.rotationAngle }
            
            val newDoc = PDDocument()
            val sequence = if (reorder.isNotEmpty()) reorder else (1..total).toList()
            
            sequence.forEach { originalIdx ->
                if (!deleteSet.contains(originalIdx)) {
                    val page = doc.getPage(originalIdx - 1)
                    val degrees = rotateMap[originalIdx] ?: 0
                    if (degrees != 0) {
                        page.rotation = (page.rotation + degrees) % 360
                    }
                    newDoc.addPage(page)
                }
            }
            
            val out = File.createTempFile("manipulated_", ".pdf")
            newDoc.save(out)
            newDoc.close()
            out.absolutePath
        }
    }
}
