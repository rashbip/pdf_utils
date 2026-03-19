package com.rashbip.pdf_utils

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.text.PDFTextStripper
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
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
import kotlin.concurrent.thread

/** PdfUtilsPlugin */
class PdfUtilsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var pdfLocker: PdfLocker
    private lateinit var pdfMerger: PdfMerger
    private var activity: Activity? = null
    private val mainHandler: Handler by lazy { Handler(Looper.getMainLooper()) }
    private val coroutineScope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pdf_utils")
        channel.setMethodCallHandler(this)
        pdfLocker = PdfLocker()
        pdfMerger = PdfMerger()
        PDFBoxResourceLoader.init(flutterPluginBinding.applicationContext)
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
            "isEncrypted" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath == null) {
                    result.error("INVALID_ARGUMENTS", "File path is null", null)
                    return
                }
                try {
                    val isEncrypted = pdfLocker.isEncrypted(filePath)
                    result.success(isEncrypted)
                } catch (e: Exception) {
                    result.error("IS_ENCRYPTED_FAILED", "Failed to check if PDF is encrypted", e.message)
                }
            }
            "lock" -> {
                val filePath = call.argument<String>("filePath")
                val userPassword = call.argument<String>("userPassword")
                val ownerPassword = call.argument<String>("ownerPassword")
                if (filePath == null || userPassword == null || ownerPassword == null) {
                    result.error("INVALID_ARGUMENTS", "File path or password is null", null)
                    return
                }
                try {
                    pdfLocker.lock(filePath, userPassword, ownerPassword)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("LOCK_FAILED", "Failed to lock PDF", e.message)
                }
            }
            "unlock" -> {
                val filePath = call.argument<String>("filePath")
                val password = call.argument<String>("password")
                if (filePath == null || password == null) {
                    result.error("INVALID_ARGUMENTS", "File path or password is null", null)
                    return
                }
                try {
                    val isUnlocked = pdfLocker.unlock(filePath, password)
                    result.success(isUnlocked)
                } catch (e: Exception) {
                    result.error("UNLOCK_FAILED", "Failed to unlock PDF", e.message)
                }
            }
            "mergePdfFiles" -> {
                val filesPath = call.argument<List<String>>("filesPath")
                val outputPath = call.argument<String>("outputPath")
                if (filesPath == null || outputPath == null) {
                    result.error("INVALID_ARGUMENTS", "Files path or output path is null", null)
                    return
                }
                executeInBackground(
                    task = {
                        pdfMerger.mergePdfFiles(filesPath, outputPath)
                    },
                    onSuccess = { mergedPath ->
                        result.success(mergedPath)
                    },
                    onError = { e ->
                        result.error("MERGE_PDF_FILES_FAILED", "Failed to merge PDF files", e.message)
                    },
                )
            }
            "choosePagesIndexToMerge" -> {
                val inputPath = call.argument<String>("inputPath")
                val outputPath = call.argument<String>("outputPath")
                val pagesIndex = call.argument<List<Int>>("pagesIndex")
                if (inputPath == null || outputPath == null || pagesIndex == null) {
                    result.error("INVALID_ARGUMENTS", "Input path, output path or pages is null", null)
                    return
                }
                executeInBackground(
                    task = {
                        pdfMerger.choosePagesIndexToMerge(inputPath, outputPath, pagesIndex)
                    },
                    onSuccess = { mergedPath ->
                        result.success(mergedPath)
                    },
                    onError = { e ->
                        result.error("CHOOSE_PAGES_TO_MERGE_FAILED", "Failed to choose pages to merge", e.message)
                    },
                )
            }
            "mergeImagesToPdf" -> {
                val imagesPath = call.argument<List<String>>("imagesPath")
                val outputPath = call.argument<String>("outputPath")
                val configMap = call.argument<Map<String, Any?>>("config")
                if (imagesPath == null || outputPath == null) {
                    result.error("INVALID_ARGUMENTS", "Images path or output path is null", null)
                    return
                }
                val config = parseImagesToPdfConfig(configMap)
                executeInBackground(
                    task = {
                        pdfMerger.mergeImagesToPdf(imagesPath, outputPath, config)
                    },
                    onSuccess = { mergedPath ->
                        result.success(mergedPath)
                    },
                    onError = { e ->
                        result.error("MERGE_IMAGES_TO_PDF_FAILED", "Failed to merge images to PDF", e.message)
                    },
                )
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
        PDDocument.load(file, password).use { doc ->
            val length = doc.numberOfPages
            val info = doc.documentInformation
            val creationDate = info.creationDate?.time?.toString()
            val modificationDate = info.modificationDate?.time?.toString()
            
            return hashMapOf(
                "length" to length,
                "info" to hashMapOf(
                    "author" to (info.author ?: ""),
                    "creationDate" to (creationDate ?: ""),
                    "modificationDate" to (modificationDate ?: ""),
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
        PDDocument.load(File(path), password).use { doc ->
            val stripper = PDFTextStripper()
            stripper.startPage = pageNumber
            stripper.endPage = pageNumber
            return stripper.getText(doc)
        }
    }

    private fun extractFullText(path: String, missingPagesNumbers: List<Int>, password: String): List<String> {
        PDDocument.load(File(path), password).use { doc ->
            val missingPagesTexts = arrayListOf<String>()
            val stripper = PDFTextStripper()
            missingPagesNumbers.forEach {
                stripper.startPage = it
                stripper.endPage = it
                missingPagesTexts.add(stripper.getText(doc))
            }
            return missingPagesTexts
        }
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

    private fun parseImagesToPdfConfig(configMap: Map<String, Any?>?): ImagesToPdfConfig? {
        configMap ?: return null
        val rescaleMap = configMap["rescale"] as? Map<*, *> ?: return null
        val widthValue = (rescaleMap["maxWidth"] as? Number)?.toInt() ?: 0
        val heightValue = (rescaleMap["maxHeight"] as? Number)?.toInt() ?: 0
        val keepAspectRatio = configMap["keepAspectRatio"] as? Boolean != false
        return ImagesToPdfConfig(
            rescale = ImageScale(widthValue, heightValue),
            keepAspectRatio = keepAspectRatio,
        )
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
