package com.example.pdf_worker

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import androidx.core.graphics.createBitmap
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import kotlin.math.roundToInt

enum class ImageFormat(val extension: String) {
    PNG("png"),
    JPG("jpg")
}

class PdfToImagesConfig {
    var pagesIndex: List<Int>? = null
    var imgFormat: ImageFormat = ImageFormat.PNG
    var quality: Int = 100

    // 传入 map 参数 初始化
    constructor(configMap: Map<String, Any?>?) {
        configMap ?: return

        val rawPagesIndex = configMap["pagesIndex"]
        pagesIndex =
                (rawPagesIndex as? List<*>)?.takeIf { items -> items.all { it is Int } }?.map {
                    it as Int
                }

        val rawImgFormat = configMap["imgFormat"]
        imgFormat =
                when (rawImgFormat) {
                    is ImageFormat -> rawImgFormat
                    is String ->
                            runCatching { ImageFormat.valueOf(rawImgFormat) }
                                    .getOrDefault(imgFormat)
                    else -> imgFormat
                }

        val rawQuality = configMap["quality"]
        quality = (rawQuality as? Number)?.toInt() ?: quality
        quality = quality.coerceIn(0, 100)
    }

    constructor()
}

private data class PageDimension(val width: Int, val height: Int)

object PdfToImageHelper {
    // quality：整数，范围 0～100
    // 仅对 有损压缩格式（如 JPEG, WEBP_LOSSY） 有效；
    // 对 无损格式（如 PNG, WEBP_LOSSLESS） 无效（会被忽略）。
    fun pdfToImages(
            inputPath: String,
            outputDirectory: String,
            config: PdfToImagesConfig?
    ): List<String> {
        val file = File(inputPath)
        if (!file.exists()) {
            throw FileNotFoundException("File does not exist: $inputPath")
        }
        val config = config ?: PdfToImagesConfig()
        var format = Bitmap.CompressFormat.PNG
        format =
                when (config.imgFormat) {
                    ImageFormat.PNG -> Bitmap.CompressFormat.PNG
                    ImageFormat.JPG -> Bitmap.CompressFormat.JPEG
                }

        val fileDescriptor =
                ParcelFileDescriptor.open(File(inputPath), ParcelFileDescriptor.MODE_READ_ONLY)
        val renderer = PdfRenderer(fileDescriptor)
        val pageNumbers = config.pagesIndex ?: (0 until renderer.pageCount).toList()
        // check if pageNumbers is valid
        if (pageNumbers.any { it < 0 || it >= renderer.pageCount }) {
            renderer.close()
            fileDescriptor.close()
            throw IllegalArgumentException("pageNumbers is invalid")
        }

        val pdfImagesPath: MutableList<String> = mutableListOf()
        for (pageIndex in pageNumbers) {
            val page = renderer.openPage(pageIndex)
            val bitmap = try {
                renderPageToBitmap(page)
            } finally {
                page.close()
            }

            val imageName =
                    "split_page_${System.currentTimeMillis()}_${pageIndex + 1}.${config.imgFormat.extension}"
            pdfImagesPath.add("$outputDirectory/$imageName")
            val outputFile = File(outputDirectory, imageName)
            FileOutputStream(outputFile).use { out ->
                bitmap.compress(format, config.quality, out)
            }
            bitmap.recycle()
        }

        renderer.close()
        fileDescriptor.close()
        return pdfImagesPath
    }

    fun pdfToLongImage(inputPath: String, outputPath: String, config: PdfToImagesConfig?): String {
        val file = File(inputPath)
        if (!file.exists()) {
            throw FileNotFoundException("File does not exist: $inputPath")
        }
        val config = config ?: PdfToImagesConfig()
        var format = Bitmap.CompressFormat.PNG
        format =
                when (config.imgFormat) {
                    ImageFormat.PNG -> Bitmap.CompressFormat.PNG
                    ImageFormat.JPG -> Bitmap.CompressFormat.JPEG
                }

        val fileDescriptor =
                ParcelFileDescriptor.open(File(inputPath), ParcelFileDescriptor.MODE_READ_ONLY)
        val renderer = PdfRenderer(fileDescriptor)
        val pageNumbers = config.pagesIndex ?: (0 until renderer.pageCount).toList()
        // check if pageNumbers is valid
        if (pageNumbers.any { it < 0 || it >= renderer.pageCount }) {
            renderer.close()
            fileDescriptor.close()
            throw IllegalArgumentException("pageNumbers is invalid")
        }

        try {
            val pageSizes = mutableListOf<PageDimension>()
            for (pageIndex in pageNumbers) {
                val page = renderer.openPage(pageIndex)
                try {
                    val width = (page.width * RENDER_SCALE).roundToInt().coerceAtLeast(1)
                    val height = (page.height * RENDER_SCALE).roundToInt().coerceAtLeast(1)
                    pageSizes.add(PageDimension(width, height))
                } finally {
                    page.close()
                }
            }

            val totalHeightLong = pageSizes.fold(0L) { acc, size -> acc + size.height }
            val maxWidth = pageSizes.maxOfOrNull { it.width } ?: 0
            if (maxWidth <= 0 || totalHeightLong <= 0 || totalHeightLong > Int.MAX_VALUE) {
                throw IllegalArgumentException("Resulting image size is invalid or too large")
            }
            val totalHeight = totalHeightLong.toInt()

            val mergedImage = createBitmap(maxWidth, totalHeight)
            val mergedCanvas = Canvas(mergedImage)
            mergedCanvas.drawColor(Color.WHITE)

            var currentY = 0
            for ((index, pageIndex) in pageNumbers.withIndex()) {
                val page = renderer.openPage(pageIndex)
                val (width, height) = with(pageSizes[index]) { width to height }
                val pageBitmap = try {
                    renderPageToBitmap(page, width, height)
                } finally {
                    page.close()
                }
                mergedCanvas.drawBitmap(pageBitmap, 0f, currentY.toFloat(), null)
                currentY += height
                pageBitmap.recycle()
            }

            val outputFile = File(outputPath)
            outputFile.parentFile?.let { parent ->
                if (!parent.exists()) {
                    parent.mkdirs()
                }
            }
            val targetQuality = if (format == Bitmap.CompressFormat.PNG) 100 else config.quality
            FileOutputStream(outputFile).use { out ->
                if (!mergedImage.compress(format, targetQuality, out)) {
                    throw IllegalStateException("Failed to write merged image")
                }
            }
            mergedImage.recycle()
            return outputPath
        } finally {
            renderer.close()
            fileDescriptor.close()
        }
    }

    private fun renderPageToBitmap(page: PdfRenderer.Page): Bitmap {
        val width = (page.width * RENDER_SCALE).roundToInt().coerceAtLeast(1)
        val height = (page.height * RENDER_SCALE).roundToInt().coerceAtLeast(1)
        return renderPageToBitmap(page, width, height)
    }

    private fun renderPageToBitmap(page: PdfRenderer.Page, width: Int, height: Int): Bitmap {
        val bitmap = createBitmap(width, height)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)
        page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
        return bitmap
    }

    private const val RENDER_SCALE = 3.0f
}

