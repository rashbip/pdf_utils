package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import kotlinx.coroutines.*
import java.io.File

suspend fun getPDFPagesSize(path: String, context: Activity): List<List<Double>> {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            (0 until doc.numberOfPages).map { idx ->
                val box = doc.getPage(idx).mediaBox
                listOf((idx + 1).toDouble(), box.width.toDouble(), box.height.toDouble())
            }
        }
    }
}
