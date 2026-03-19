package com.rashbip.pdf_utils

import android.app.Activity
import android.graphics.BitmapFactory
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.common.PDRectangle
import com.tom_roush.pdfbox.pdmodel.graphics.image.JPEGFactory
import com.tom_roush.pdfbox.pdmodel.graphics.image.LosslessFactory
import kotlinx.coroutines.*
import java.io.File
import java.io.FileInputStream

suspend fun getPdfsFromImages(
    images: List<String>,
    single: Boolean,
    context: Activity
): List<String> {
    return withContext(Dispatchers.IO) {
        if (single) {
            val doc = PDDocument()
            images.forEach { path ->
                val imageFile = File(path)
                val pdImage = if (path.lowercase().endsWith(".jpg") || path.lowercase().endsWith(".jpeg")) {
                    JPEGFactory.createFromStream(doc, FileInputStream(imageFile))
                } else {
                    val bitmap = BitmapFactory.decodeFile(path)
                    LosslessFactory.createFromImage(doc, bitmap)
                }
                val page = PDPage(PDRectangle(pdImage.width.toFloat(), pdImage.height.toFloat()))
                doc.addPage(page)
                PDPageContentStream(doc, page).use { cs -> cs.drawImage(pdImage, 0f, 0f) }
            }
            val out = File.createTempFile("converted_", ".pdf")
            doc.save(out)
            doc.close()
            listOf(out.absolutePath)
        } else {
            images.map { path ->
                val doc = PDDocument()
                val imageFile = File(path)
                val pdImage = if (path.lowercase().endsWith(".jpg") || path.lowercase().endsWith(".jpeg")) {
                    JPEGFactory.createFromStream(doc, FileInputStream(imageFile))
                } else {
                    val bitmap = BitmapFactory.decodeFile(path)
                    LosslessFactory.createFromImage(doc, bitmap)
                }
                val page = PDPage(PDRectangle(pdImage.width.toFloat(), pdImage.height.toFloat()))
                doc.addPage(page)
                PDPageContentStream(doc, page).use { cs -> cs.drawImage(pdImage, 0f, 0f) }
                val out = File.createTempFile("converted_", ".pdf")
                doc.save(out)
                doc.close()
                out.absolutePath
            }
        }
    }
}
