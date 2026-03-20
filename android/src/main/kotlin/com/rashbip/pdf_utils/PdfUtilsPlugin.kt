package com.rashbip.pdf_utils

import android.app.Activity
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.text.PDFTextStripper
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.*
import java.io.File

class PdfUtilsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private val coroutineScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pdf_utils")
        channel.setMethodCallHandler(this)
        PDFBoxResourceLoader.init(flutterPluginBinding.applicationContext)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val activity = this.activity ?: return result.error("NO_ACTIVITY", "Activity is null", null)
        
        when (call.method) {
            "getPageCount" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val password = call.argument<String>("password") ?: ""
                executeInBackground(result) { 
                    PDDocument.load(File(filePath), password).use { it.numberOfPages }
                }
            }
            "initDoc", "getDocInfo" -> {
                val filePath = call.argument<String>("filePath") ?: call.argument<String>("path") ?: ""
                val password = call.argument<String>("password") ?: ""
                executeInBackground(result) {
                    PDDocument.load(File(filePath), password).use { doc ->
                        val info = doc.documentInformation
                        hashMapOf(
                            "length" to doc.numberOfPages,
                            "info" to hashMapOf(
                                "author" to (info.author ?: ""),
                                "creator" to (info.creator ?: ""),
                                "producer" to (info.producer ?: ""),
                                "title" to (info.title ?: ""),
                                "subject" to (info.subject ?: "")
                            )
                        )
                    }
                }
            }
            "getDocPageText", "extractPageText" -> {
                val filePath = call.argument<String>("filePath") ?: call.argument<String>("path") ?: ""
                val pageNumber = call.argument<Int>("pageNumber") ?: call.argument<Int>("number") ?: 1
                val password = call.argument<String>("password") ?: ""
                executeInBackground(result) {
                    PDDocument.load(File(filePath), password).use { doc ->
                        val stripper = PDFTextStripper()
                        stripper.startPage = pageNumber
                        stripper.endPage = pageNumber
                        stripper.getText(doc)
                    }
                }
            }
            "getDocText", "extractFullText" -> {
                val filePath = call.argument<String>("filePath") ?: call.argument<String>("path") ?: ""
                val pageNumbers = call.argument<List<Int>>("pageNumbers") ?: call.argument<List<Int>>("missingPagesNumbers") ?: listOf()
                val password = call.argument<String>("password") ?: ""
                executeInBackground(result) {
                    PDDocument.load(File(filePath), password).use { doc ->
                        val stripper = PDFTextStripper()
                        if (pageNumbers.isEmpty()) {
                            listOf(stripper.getText(doc))
                        } else {
                            pageNumbers.map { pageNum ->
                                stripper.startPage = pageNum
                                stripper.endPage = pageNum
                                stripper.getText(doc)
                            }
                        }
                    }
                }
            }
            "nativeImagesToPdf" -> {
                val imagesPath = call.argument<List<String>>("imagesPath") ?: listOf()
                val createSingle = call.argument<Boolean>("createSingle") ?: true
                executeInBackground(result) { getPdfsFromImages(imagesPath, createSingle, activity) }
            }
            "mergePdfs" -> {
                val filesPath = call.argument<List<String>>("filesPath") ?: listOf()
                executeInBackground(result) { getMergedPDFPath(filesPath, activity) }
            }
            "splitPdfByPageCount" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val pageCount = call.argument<Int>("pageCount") ?: 1
                executeInBackground(result) { getSplitPDFPathsByPageCount(filePath, pageCount, activity) }
            }
            "splitPdfByPageNumbers" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val pageNumbers = call.argument<List<Int>>("pageNumbers") ?: listOf()
                executeInBackground(result) { getSplitPDFPathsByPageNumbers(filePath, pageNumbers, activity) }
            }
            "addPage" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val insertPath = call.argument<String>("insertPath") ?: ""
                val index = call.argument<Int>("index") ?: 0
                executeInBackground(result) { insertPageToPdf(filePath, insertPath, index, activity) }
            }
            "addPageNumbers" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val customText = call.argument<String>("customText")
                val imagePath = call.argument<String>("imagePath")
                val fontSize = call.argument<Double>("fontSize") ?: 12.0
                val placementStr = call.argument<String>("placement") ?: "BOTTOM_CENTER"
                val placement = runCatching { TextPlacement.valueOf(placementStr) }.getOrDefault(TextPlacement.BOTTOM_CENTER)
                val pages = call.argument<List<Int>>("pages")
                executeInBackground(result) { addPageNumbersToPdf(filePath, customText, imagePath, fontSize.toFloat(), placement, pages, activity) }
            }
            "removeBlankPages" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                executeInBackground(result) { removeBlankPagesFromPdf(filePath, activity) }
            }
            "resizePdf" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val width = call.argument<Double>("width") ?: 595.0
                val height = call.argument<Double>("height") ?: 842.0
                val pages = call.argument<List<Int>>("pages")
                executeInBackground(result) { resizePdfPages(filePath, width.toFloat(), height.toFloat(), pages, activity) }
            }
            "handlePageManipulation" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val reorder = call.argument<List<Int>>("reorder") ?: emptyList()
                val delete = call.argument<List<Int>>("delete") ?: emptyList()
                val rotate = call.argument<List<Map<String, Int>>>("rotate") ?: emptyList()
                val rotateList = rotate.map { 
                    PageRotationInfo(it["pageNumber"] ?: 0, it["rotationAngle"] ?: 0)
                }
                executeInBackground(result) { getPDFPageRotatorDeleterReorder(filePath, reorder, delete, rotateList, activity) }
            }
            "compressPdf" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val quality = call.argument<Int>("quality") ?: 80
                val scale = call.argument<Double>("scale") ?: 1.0
                executeInBackground(result) { getCompressedPDFPath(filePath, quality, scale, activity) }
            }
            "watermarkPdf" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val text = call.argument<String>("text") ?: ""
                val fontSize = call.argument<Double>("fontSize") ?: 40.0
                val opacity = call.argument<Double>("opacity") ?: 0.3
                val rotation = call.argument<Double>("rotation") ?: 45.0
                val color = call.argument<String>("color") ?: "#000000"
                executeInBackground(result) { getWatermarkedPDFPath(filePath, text, fontSize.toFloat(), opacity.toFloat(), rotation.toFloat(), color, activity) }
            }
            "encryptPdf" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val userPassword = call.argument<String>("userPassword") ?: ""
                val ownerPassword = call.argument<String>("ownerPassword") ?: ""
                val perms = call.argument<Map<String, Boolean>>("permissions") ?: emptyMap()
                executeInBackground(result) { 
                    getPdfEncrypted(filePath, ownerPassword, userPassword, 
                        perms["allowPrinting"] ?: true, 
                        perms["allowModifyContents"] ?: true, 
                        perms["allowCopy"] ?: true, activity) 
                }
            }
            "decryptPdf" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val password = call.argument<String>("password") ?: ""
                executeInBackground(result) { getPdfDecrypted(filePath, password, activity) }
            }
            "getValidityAndProtection" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                val password = call.argument<String>("password") ?: ""
                executeInBackground(result) { getPdfValidityAndProtection(filePath, password, activity) }
            }
            "getPagesSize" -> {
                val filePath = call.argument<String>("filePath") ?: ""
                executeInBackground(result) { getPDFPagesSize(filePath, activity) }
            }
            "pdfToImages" -> {
                val pdfPath = call.argument<String>("inputPath") ?: ""
                val outputDirectory = call.argument<String>("outputDirectory") ?: ""
                val configMap = call.argument<Map<String, Any?>>("config")
                executeInBackground(result) {
                    PdfToImageHelper.pdfToImages(pdfPath, outputDirectory, PdfToImagesConfig(configMap))
                }
            }
            "pdfToLongImage" -> {
                val pdfPath = call.argument<String>("inputPath") ?: ""
                val outputPath = call.argument<String>("outputPath") ?: ""
                val configMap = call.argument<Map<String, Any?>>("config")
                executeInBackground(result) {
                    PdfToImageHelper.pdfToLongImage(pdfPath, outputPath, PdfToImagesConfig(configMap))
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun executeInBackground(result: MethodChannel.Result, block: suspend () -> Any?) {
        coroutineScope.launch {
            try {
                val data = block()
                withContext(Dispatchers.Main) { result.success(data) }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("PDF_ERROR", e.message, e.stackTraceToString())
                }
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }
}
