package com.rashbip.pdf_utils

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.print.PageRange
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintDocumentInfo
import android.print.PrintManager
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

fun printPdfFile(path: String, jobName: String, activity: Activity) {
    val printManager = activity.getSystemService(Context.PRINT_SERVICE) as? PrintManager ?: return
    
    val pda = object : PrintDocumentAdapter() {
        override fun onLayout(
            oldAttributes: PrintAttributes?,
            newAttributes: PrintAttributes,
            cancellationSignal: CancellationSignal?,
            callback: LayoutResultCallback,
            extras: Bundle?
        ) {
            if (cancellationSignal?.isCanceled == true) {
                callback.onLayoutCancelled()
                return
            }
            
            val pdfInfo = PrintDocumentInfo.Builder(jobName)
                .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
                .build()
            
            callback.onLayoutFinished(pdfInfo, true)
        }

        override fun onWrite(
            pages: Array<out PageRange>?,
            destination: ParcelFileDescriptor,
            cancellationSignal: CancellationSignal?,
            callback: WriteResultCallback
        ) {
            var input: FileInputStream? = null
            var output: FileOutputStream? = null
            
            try {
                input = FileInputStream(File(path))
                output = FileOutputStream(destination.fileDescriptor)
                
                val buf = ByteArray(1024)
                var bytesRead: Int
                while (input.read(buf).also { bytesRead = it } > 0) {
                    output.write(buf, 0, bytesRead)
                }
                
                callback.onWriteFinished(arrayOf(PageRange.ALL_PAGES))
            } catch (e: Exception) {
                callback.onWriteFailed(e.message)
            } finally {
                input?.close()
                output?.close()
            }
        }
    }
    
    printManager.print(jobName, pda, null)
}
