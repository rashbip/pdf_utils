package com.rashbip.pdf_utils

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.tom_roush.pdfbox.cos.COSName
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.graphics.image.JPEGFactory
import com.tom_roush.pdfbox.pdmodel.graphics.image.PDImageXObject
import kotlinx.coroutines.*
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

suspend fun getCompressedPDFPath(
    path: String,
    quality: Int,
    scale: Double,
    context: Activity
): String? {
    return withContext(Dispatchers.IO) {
        PDDocument.load(File(path)).use { doc ->
            // 1. Remove Structure Tree (bloat)
            doc.documentCatalog.structureTreeRoot = null
            
            // 2. Iterate through all pages and resources to find images
            doc.pages.forEach { page ->
                val resources = page.resources
                resources.xObjectNames.forEach { name ->
                    val xObject = resources.getXObject(name)
                    if (xObject is PDImageXObject) {
                        // Re-compress image if it's large or not JPEG
                        val bitmap = xObject.image
                        
                        // Scale if requested
                        val scaledBitmap = if (scale < 1.0) {
                            Bitmap.createScaledBitmap(
                                bitmap,
                                (bitmap.width * scale).toInt().coerceAtLeast(1),
                                (bitmap.height * scale).toInt().coerceAtLeast(1),
                                true
                            )
                        } else {
                            bitmap
                        }
                        
                        val outStream = ByteArrayOutputStream()
                        scaledBitmap.compress(Bitmap.CompressFormat.JPEG, quality, outStream)
                        
                        val newImage = JPEGFactory.createFromStream(doc, outStream.toByteArray().inputStream())
                        
                        // Replace in resources
                        resources.put(name, newImage)
                        
                        if (scaledBitmap != bitmap) {
                            scaledBitmap.recycle()
                        }
                        bitmap.recycle()
                    }
                }
            }
            
            val out = File.createTempFile("compressed_", ".pdf")
            doc.save(out)
            out.absolutePath
        }
    }
}
