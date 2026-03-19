package com.rashbip.pdf_utils

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.itextpdf.kernel.pdf.PdfDocument
import com.itextpdf.kernel.pdf.PdfReader
import com.itextpdf.kernel.pdf.canvas.parser.PdfTextExtractor
import com.itextpdf.kernel.pdf.canvas.parser.listener.LocationTextExtractionStrategy
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File
import java.io.PrintWriter
import java.io.FileOutputStream
import kotlin.concurrent.thread

/** PdfUtilsPlugin */
class PdfUtilsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private val mainHandler: Handler by lazy { Handler(Looper.getMainLooper()) }
    private val coroutineScope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pdf_utils")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "compressPdf" -> {
                val filePath = call.argument<String>("filePath")
                val quality = call.argument<Int>("quality") ?: 80
                val scale = call.argument<Double>("scale") ?: 1.0
                val unEmbedFonts = call.argument<Boolean>("unEmbedFonts") ?: false
                
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path is null or activity is not available", null)
                    return
                }

                coroutineScope.launch {
                    try {
                        val compressedPath = getCompressedPDFPath(
                            sourceFilePath = filePath,
                            imageQuality = quality,
                            imageScale = scale,
                            unEmbedFonts = unEmbedFonts,
                            context = activity!!
                        )
                        result.success(compressedPath)
                    } catch (e: Exception) {
                        result.error("COMPRESS_FAILED", "Failed to compress PDF", e.message)
                    }
                }
            }
            "watermarkPdf" -> {
                val filePath = call.argument<String>("filePath")
                val text = call.argument<String>("text") ?: ""
                val fontSize = call.argument<Double>("fontSize") ?: 20.0
                val layerStr = call.argument<String>("layer") ?: "OverContent"
                val opacity = call.argument<Double>("opacity") ?: 0.5
                val rotation = call.argument<Double>("rotation") ?: 45.0
                val color = call.argument<String>("color") ?: "#000000"
                val positionStr = call.argument<String>("position") ?: "Center"
                
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path is null or activity is not available", null)
                    return
                }

                val layer = if (layerStr == "UnderContent") WatermarkLayer.UnderContent else WatermarkLayer.OverContent
                val position = try {
                    PositionType.valueOf(positionStr)
                } catch (e: Exception) {
                    PositionType.Center
                }

                coroutineScope.launch {
                    try {
                        val watermarkedPath = getWatermarkedPDFPath(
                            sourceFilePath = filePath,
                            text = text,
                            fontSize = fontSize,
                            watermarkLayer = layer,
                            opacity = opacity,
                            rotationAngle = rotation,
                            watermarkColor = color,
                            positionType = position,
                            customPositionXCoordinatesList = emptyList(),
                            customPositionYCoordinatesList = emptyList(),
                            context = activity!!
                        )
                        result.success(watermarkedPath)
                    } catch (e: Exception) {
                        result.error("WATERMARK_FAILED", "Failed to watermark PDF", e.message)
                    }
                }
            }
            "splitPdfByPageCount" -> {
                val filePath = call.argument<String>("filePath")
                val pageCount = call.argument<Int>("pageCount") ?: 1
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path or activity null", null)
                    return
                }
                coroutineScope.launch {
                    try {
                        val paths = getSplitPDFPathsByPageCount(filePath, pageCount, activity!!)
                        result.success(paths)
                    } catch (e: Exception) {
                        result.error("SPLIT_FAILED", "Failed to split PDF", e.message)
                    }
                }
            }
            "splitPdfByPageNumbers" -> {
                val filePath = call.argument<String>("filePath")
                val pageNumbers = call.argument<List<Int>>("pageNumbers") ?: listOf()
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path or activity null", null)
                    return
                }
                coroutineScope.launch {
                    try {
                        val paths = getSplitPDFPathsByPageNumbers(filePath, pageNumbers, activity!!)
                        result.success(paths)
                    } catch (e: Exception) {
                        result.error("SPLIT_FAILED", "Failed to split PDF", e.message)
                    }
                }
            }
            "handlePageManipulation" -> {
                val filePath = call.argument<String>("filePath")
                val reorder = call.argument<List<Int>>("reorder") ?: listOf()
                val delete = call.argument<List<Int>>("delete") ?: listOf()
                val rotateMap = call.argument<List<Map<String, Int>>>("rotate") ?: listOf()
                
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path or activity null", null)
                    return
                }

                val rotationInfo = rotateMap.map { 
                    PageRotationInfo(it["pageNumber"] ?: 1, it["rotationAngle"] ?: 0)
                }

                coroutineScope.launch {
                    try {
                        val newPath = getPDFPageRotatorDeleterReorder(
                            filePath, reorder, delete, rotationInfo, activity!!
                        )
                        result.success(newPath)
                    } catch (e: Exception) {
                        result.error("MANIPULATION_FAILED", "Failed to manipulate PDF pages", e.message)
                    }
                }
            }
            "getValidityAndProtection" -> {
                val filePath = call.argument<String>("filePath")
                val password = call.argument<String>("password") ?: ""
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path or activity null", null)
                    return
                }
                coroutineScope.launch {
                    try {
                        val info = getPdfValidityAndProtection(filePath, password, activity!!)
                        result.success(info)
                    } catch (e: Exception) {
                        result.error("CHECK_FAILED", "Failed to check PDF", e.message)
                    }
                }
            }
            "encryptPdf" -> {
                val filePath = call.argument<String>("filePath")
                val ownerPassword = call.argument<String>("ownerPassword") ?: ""
                val userPassword = call.argument<String>("userPassword") ?: ""
                val permissions = call.argument<Map<String, Boolean>>("permissions") ?: mapOf()
                
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path or activity null", null)
                    return
                }

                coroutineScope.launch {
                    try {
                        val encryptedPath = getPdfEncrypted(
                            filePath,
                            ownerPassword,
                            userPassword,
                            permissions["allowPrinting"] ?: false,
                            permissions["allowModifyContents"] ?: false,
                            permissions["allowCopy"] ?: false,
                            permissions["allowModifyAnnotations"] ?: false,
                            permissions["allowFillIn"] ?: false,
                            permissions["allowScreenReaders"] ?: false,
                            permissions["allowAssembly"] ?: false,
                            permissions["allowDegradedPrinting"] ?: false,
                            permissions["aes40"] ?: false,
                            permissions["aes128"] ?: true,
                            permissions["encryptionAES128"] ?: false,
                            permissions["encryptEmbeddedFilesOnly"] ?: false,
                            permissions["doNotEncryptMetadata"] ?: false,
                            activity!!
                        )
                        result.success(encryptedPath)
                    } catch (e: Exception) {
                        result.error("ENCRYPT_FAILED", "Failed to encrypt PDF", e.message)
                    }
                }
            }
            "decryptPdf" -> {
                val filePath = call.argument<String>("filePath")
                val password = call.argument<String>("password") ?: ""
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path or activity null", null)
                    return
                }
                coroutineScope.launch {
                    try {
                        val decryptedPath = getPdfDecrypted(filePath, password, activity!!)
                        result.success(decryptedPath)
                    } catch (e: Exception) {
                        result.error("DECRYPT_FAILED", "Failed to decrypt PDF", e.message)
                    }
                }
            }
            "getPagesSize" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "File path or activity null", null)
                    return
                }
                coroutineScope.launch {
                    try {
                        val sizes = getPDFPagesSize(filePath, activity!!)
                        result.success(sizes)
                    } catch (e: Exception) {
                        result.error("GET_SIZE_FAILED", "Failed to get page sizes", e.message)
                    }
                }
            }
            "mergePdfs" -> {
                val filesPath = call.argument<List<String>>("filesPath")
                if (filesPath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "Files path or activity null", null)
                    return
                }
                coroutineScope.launch {
                    try {
                        val mergedPath = getMergedPDFPath(filesPath, activity!!)
                        result.success(mergedPath)
                    } catch (e: Exception) {
                        result.error("MERGE_FAILED", "Failed to merge PDFs", e.message)
                    }
                }
            }
            "nativeImagesToPdf" -> {
                val imagesPath = call.argument<List<String>>("imagesPath")
                val createSingle = call.argument<Boolean>("createSingle") ?: true
                if (imagesPath == null || activity == null) {
                    result.error("INVALID_ARGUMENTS", "Images path or activity null", null)
                    return
                }
                coroutineScope.launch {
                    try {
                        val paths = getPdfsFromImages(imagesPath, createSingle, activity!!)
                        result.success(paths)
                    } catch (e: Exception) {
                        result.error("CONVERT_FAILED", "Failed to convert images to PDF", e.message)
                    }
                }
            }
            "pdfToImages" -> {
                val inputPath = call.argument<String>("inputPath")
                val outputDirectory = call.argument<String>("outputDirectory")
                val configMap = call.argument<Map<String, Any?>>("config")
                if (inputPath == null || outputDirectory == null) {
                    result.error("INVALID_ARGUMENTS", "Input path or output directory is null", null)
                    return
                }
                val config = PdfToImagesConfig(configMap)
                executeInBackground(
                    task = {
                        PdfToImageHelper.pdfToImages(inputPath, outputDirectory, config)
                    },
                    onSuccess = { imagesPath ->
                        result.success(imagesPath)
                    },
                    onError = { e ->
                        result.error("PDF_TO_IMAGES_FAILED", "Failed to convert PDF to images", e.message)
                    },
                )
            }
            "pdfToLongImage" -> {
                val inputPath = call.argument<String>("inputPath")
                val outputPath = call.argument<String>("outputPath")
                val configMap = call.argument<Map<String, Any?>>("config")
                if (inputPath == null || outputPath == null) {
                    result.error("INVALID_ARGUMENTS", "Input path or output path is null", null)
                    return
                }
                val config = PdfToImagesConfig(configMap)
                executeInBackground(
                    task = {
                        PdfToImageHelper.pdfToLongImage(inputPath, outputPath, config)
                    },
                    onSuccess = { longImagePath ->
                        result.success(longImagePath)
                    },
                    onError = { e ->
                        result.error("PDF_TO_LONG_IMAGE_FAILED", "Failed to convert PDF to long image", e.message)
                    },
                )
            }
            "initDoc" -> {
                val path = call.argument<String>("path") ?: ""
                val password = call.argument<String>("password") ?: ""
                executeInBackground(
                    task = {
                        getDocInfo(path, password)
                    },
                    onSuccess = { data ->
                        result.success(data)
                    },
                    onError = { e ->
                        result.error("INIT_DOC_FAILED", e.message, null)
                    }
                )
            }
            "getDocPageText" -> {
                val path = call.argument<String>("path") ?: ""
                val pageNumber = call.argument<Int>("number") ?: 1
                val password = call.argument<String>("password") ?: ""
                executeInBackground(
                    task = {
                        extractPageText(path, pageNumber, password)
                    },
                    onSuccess = { text ->
                        result.success(text)
                    },
                    onError = { e ->
                        result.error("GET_PAGE_TEXT_FAILED", e.message, null)
                    }
                )
            }
            "getDocText" -> {
                val path = call.argument<String>("path") ?: ""
                val missingPagesNumbers = call.argument<List<Int>>("missingPagesNumbers") ?: listOf()
                val password = call.argument<String>("password") ?: ""
                executeInBackground(
                    task = {
                        extractFullText(path, missingPagesNumbers, password)
                    },
                    onSuccess = { texts ->
                        result.success(texts)
                    },
                    onError = { e ->
                        result.error("GET_DOC_TEXT_FAILED", e.message, null)
                    }
                )
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getDocInfo(path: String, password: String): Map<String, Any> {
        val file = File(path)
        val reader = PdfReader(file).setUnethicalReading(true)
        if (password.isNotEmpty()) {
            reader.setUnethicalReading(true)
        }
        PdfDocument(reader).use { doc ->
            val length = doc.numberOfPages
            val info = doc.documentInfo
            
            return hashMapOf(
                "length" to length,
                "info" to hashMapOf(
                    "author" to (info.author ?: ""),
                    "creationDate" to (info.getMoreInfo("CreationDate") ?: ""),
                    "modificationDate" to (info.getMoreInfo("ModDate") ?: ""),
                    "creator" to (info.creator ?: ""),
                    "producer" to (info.producer ?: ""),
                    "keywords" to (info.keywords?.split(",")?.map { it.trim() } ?: listOf<String>()),
                    "title" to (info.title ?: ""),
                    "subject" to (info.subject ?: "")
                )
            )
        }
    }

    private fun extractPageText(path: String, pageNumber: Int, password: String): String {
        val file = File(path)
        val reader = PdfReader(file).setUnethicalReading(true)
        PdfDocument(reader).use { doc ->
            if (pageNumber > 0 && pageNumber <= doc.numberOfPages) {
                val page = doc.getPage(pageNumber)
                return PdfTextExtractor.getTextFromPage(page, LocationTextExtractionStrategy())
            }
            return ""
        }
    }

    private fun extractFullText(path: String, missingPagesNumbers: List<Int>, password: String): List<String> {
        val file = File(path)
        val reader = PdfReader(file).setUnethicalReading(true)
        val results = mutableListOf<String>()
        PdfDocument(reader).use { doc ->
            missingPagesNumbers.forEach { pageNum ->
                if (pageNum > 0 && pageNum <= doc.numberOfPages) {
                    val page = doc.getPage(pageNum)
                    results.add(PdfTextExtractor.getTextFromPage(page, LocationTextExtractionStrategy()))
                }
            }
        }
        return results
    }

    private fun <T> executeInBackground(
        task: () -> T,
        onSuccess: (T) -> Unit,
        onError: (Exception) -> Unit,
    ) {
        thread(start = true) {
            try {
                val res = task()
                mainHandler.post { onSuccess(res) }
            } catch (e: Exception) {
                mainHandler.post { onError(e) }
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
