package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.encryption.AccessPermission
import com.tom_roush.pdfbox.pdmodel.encryption.StandardProtectionPolicy
import kotlinx.coroutines.*
import java.io.File

suspend fun getPdfEncrypted(
    path: String,
    owner: String,
    user: String,
    allowPrinting: Boolean,
    allowModifyContents: Boolean,
    allowCopy: Boolean,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            val ap = AccessPermission()
            ap.setCanPrint(allowPrinting)
            ap.setCanModify(allowModifyContents)
            ap.setCanExtractContent(allowCopy)
            
            val policy = StandardProtectionPolicy(owner, user, ap)
            policy.encryptionKeyLength = 128
            doc.protect(policy)
            
            val out = File.createTempFile("encrypted_", ".pdf")
            doc.save(out)
            out.absolutePath
        }
    }
}
