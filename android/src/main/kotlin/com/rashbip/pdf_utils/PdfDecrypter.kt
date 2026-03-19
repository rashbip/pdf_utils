package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import kotlinx.coroutines.*
import java.io.File

suspend fun getPdfDecrypted(path: String, password: String, context: Activity): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path), password).use { doc ->
            doc.isAllSecurityToBeRemoved = true
            val out = File.createTempFile("decrypted_", ".pdf")
            doc.save(out)
            out.absolutePath
        }
    }
}
