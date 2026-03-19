package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.multipdf.Splitter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

suspend fun getSplitPDFPathsByPageCount(path: String, count: Int, context: Activity): List<String>? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            val splitter = Splitter()
            splitter.setSplitAtPage(count)
            splitter.split(doc).map { segment ->
                val out = File.createTempFile("split_", ".pdf")
                segment.save(out)
                segment.close()
                out.absolutePath
            }
        }
    }
}

suspend fun getSplitPDFPathsByPageNumbers(path: String, indices: List<Int>, context: Activity): List<String>? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            val total = doc.numberOfPages
            val results = mutableListOf<String>()
            val sortedIndices = indices.filter { it in 1..total }.sorted()
            
            var last = 1
            for (idx in sortedIndices) {
                if (idx > last) {
                    results.add(savePages(doc, last, idx - 1))
                }
                last = idx
            }
            if (last <= total) {
                results.add(savePages(doc, last, total))
            }
            results
        }
    }
}

private fun savePages(source: PDDocument, start: Int, end: Int): String {
    val doc = PDDocument()
    for (i in start..end) {
        doc.addPage(source.getPage(i - 1))
    }
    val out = File.createTempFile("segment_", ".pdf")
    doc.save(out)
    doc.close()
    return out.absolutePath
}
