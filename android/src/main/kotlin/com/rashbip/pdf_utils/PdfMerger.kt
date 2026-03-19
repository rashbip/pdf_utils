package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.multipdf.PDFMergerUtility
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

suspend fun getMergedPDFPath(
    paths: List<String>,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        val merger = PDFMergerUtility()
        val output = File.createTempFile("merged_", ".pdf")
        merger.destinationFileName = output.absolutePath
        paths.forEach { merger.addSource(File(it)) }
        merger.mergeDocuments(null)
        output.absolutePath
    }
}
