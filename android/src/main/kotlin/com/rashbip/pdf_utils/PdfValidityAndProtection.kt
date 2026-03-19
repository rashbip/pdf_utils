package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import kotlinx.coroutines.*
import java.io.File

suspend fun getPdfValidityAndProtection(path: String, password: String, context: Activity): List<Boolean?> {
    return withContext(Dispatchers.IO) {
        try {
            PDDocument.load(File(path), password).use { doc ->
                val ap = doc.currentAccessPermission
                listOf(
                    true, // isValid
                    doc.isEncrypted,
                    doc.isEncrypted,
                    ap?.canPrint() ?: true,
                    ap?.canModify() ?: true
                )
            }
        } catch (e: Exception) {
            listOf(false, null, null, null, null)
        }
    }
}
