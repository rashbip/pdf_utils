package com.example.pdf_worker

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Paint
import android.graphics.pdf.PdfDocument
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import kotlin.math.min
import kotlin.math.roundToInt

data class ImageScale(
    val maxWidth: Int,
    val maxHeight: Int,
)

data class ImagesToPdfConfig(
    val rescale: ImageScale,
    val keepAspectRatio: Boolean,
)

object ImagesToPdfHelper {
    fun imagesToPdf(
        imagesPath: List<String>,
        outputPath: String,
        config: ImagesToPdfConfig? = null,
    ): String {
        if (imagesPath.isEmpty()) {
            throw IllegalArgumentException("Images path list is empty")
        }

        val files = imagesPath.map { File(it) }
        val missingFiles = files.filterNot { it.exists() }
        if (missingFiles.isNotEmpty()) {
            throw FileNotFoundException(
                "File does not exist: ${missingFiles.joinToString(", ") { it.path }}"
            )
        }

        val outputFile = File(outputPath)
        outputFile.parentFile?.let { parent ->
            if (!parent.exists() && !parent.mkdirs()) {
                throw IOException("Unable to create parent directories for $outputPath")
            }
        }

        val pdfDocument = PdfDocument()
        try {
            var pageIndex = 0
            files.forEachIndexed { _, file ->
                val bitmap = decodeBitmapWithConfig(file.absolutePath, config)
                if (bitmap != null && bitmap.width > 0 && bitmap.height > 0) {
                    val pageInfo = PdfDocument.PageInfo.Builder(bitmap.width, bitmap.height, pageIndex + 1).create()
                    val page = pdfDocument.startPage(pageInfo)
                    val canvas = page.canvas
                    val paint = Paint(Paint.ANTI_ALIAS_FLAG)
                    canvas.drawBitmap(bitmap, 0f, 0f, paint)
                    pdfDocument.finishPage(page)
                    bitmap.recycle()
                    pageIndex++
                } 
            }

            FileOutputStream(outputFile).use { stream ->
                pdfDocument.writeTo(stream)
            }
        } finally {
            pdfDocument.close()
        }

        return outputFile.path
    }

    private fun decodeBitmapWithConfig(
        imagePath: String,
        config: ImagesToPdfConfig?,
    ): Bitmap? {
        val original = BitmapFactory.decodeFile(imagePath) ?: return null
        val (targetWidth, targetHeight) = resolveTargetSize(original, config)

        if (targetWidth == original.width && targetHeight == original.height) {
            return original
        }

        val scaledBitmap = Bitmap.createScaledBitmap(original, targetWidth, targetHeight, true)
        original.recycle()
        return scaledBitmap
    }

    private fun resolveTargetSize(
        bitmap: Bitmap,
        config: ImagesToPdfConfig?,
    ): Pair<Int, Int> {
        if (config == null) {
            return bitmap.width to bitmap.height
        }

        val widthLimit = config.rescale.maxWidth
        val heightLimit = config.rescale.maxHeight

        if (widthLimit <= 0 && heightLimit <= 0) {
            return bitmap.width to bitmap.height
        }

        val originalWidth = bitmap.width
        val originalHeight = bitmap.height

        return if (config.keepAspectRatio) {
            val pair = when {
                widthLimit > 0 && heightLimit > 0 -> {
                    val widthScale = widthLimit.toFloat() / originalWidth
                    val heightScale = heightLimit.toFloat() / originalHeight
                    val scaleFactor = min(widthScale, heightScale)
                    val scaledWidth = (originalWidth * scaleFactor).roundToInt().coerceAtLeast(1)
                    val scaledHeight = (originalHeight * scaleFactor).roundToInt().coerceAtLeast(1)
                    scaledWidth to scaledHeight
                }

                widthLimit > 0 && heightLimit <= 0 -> {
                    val scaleFactor = widthLimit.toFloat() / originalWidth
                    val scaledHeight = (originalHeight * scaleFactor).roundToInt().coerceAtLeast(1)
                    widthLimit.coerceAtLeast(1) to scaledHeight
                }

                heightLimit > 0 && widthLimit <= 0 -> {
                    val scaleFactor = heightLimit.toFloat() / originalHeight
                    val scaledWidth = (originalWidth * scaleFactor).roundToInt().coerceAtLeast(1)
                    scaledWidth to heightLimit.coerceAtLeast(1)
                }

                else -> originalWidth to originalHeight
            }
            pair
        } else {
            val targetWidth = if (widthLimit > 0) widthLimit else originalWidth
            val targetHeight = if (heightLimit > 0) heightLimit else originalHeight
            targetWidth.coerceAtLeast(1) to targetHeight.coerceAtLeast(1)
        }
    }
}