package com.rashbip.pdf_utils

import android.app.Activity
import android.content.ContentResolver
import androidx.core.net.toUri
import com.itextpdf.kernel.pdf.PdfDocument
import com.itextpdf.kernel.pdf.PdfReader
import com.itextpdf.kernel.pdf.PdfWriter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

// For merging multiple pdf files.
suspend fun getMergedPDFPath(
    sourceFilesPaths: List<String>,
    context: Activity,
): String? {

    val resultPDFPath: String?

    withContext(Dispatchers.IO) {

        val utils = Utils()

        val begin = System.nanoTime()

        val contentResolver: ContentResolver = context.contentResolver

        val pdfWriterFile: File = File.createTempFile("writerTempFile", ".pdf")

        val pdfWriter = PdfWriter(pdfWriterFile)

        pdfWriter.setSmartMode(true)
        pdfWriter.compressionLevel = 9

        val pdfDocument = PdfDocument(pdfWriter)

        // One should call this method to preserve the outlines of the source pdf file, otherwise they
        // will be absent in the resultant document to which we copy pages. In this particular sample,
        // we copy pages from two documents into the third one, so we would like to keep the outlines
        // from both documents.
        pdfDocument.initializeOutlines()

        for (i in sourceFilesPaths.indices) {

            val uri = utils.getURI(sourceFilesPaths[i])

            val pdfReaderFile: File = File.createTempFile("readerTempFile", ".pdf")
            utils.copyDataFromSourceToDestDocument(
                sourceFileUri = uri,
                destinationFileUri = pdfReaderFile.toUri(),
                contentResolver = contentResolver
            )

            val pdfReader = PdfReader(pdfReaderFile).setUnethicalReading(true)
            pdfReader.setMemorySavingMode(true)

            val sourcePdfDoc = PdfDocument(pdfReader)

            sourcePdfDoc.copyPagesTo(
                1, sourcePdfDoc.numberOfPages, pdfDocument
            )

            sourcePdfDoc.close()
            pdfReader.close()

            utils.deleteTempFiles(listOfTempFiles = listOf(pdfReaderFile))

        }

        pdfDocument.close()
        pdfWriter.close()

        val end = System.nanoTime()
        println("Elapsed time in nanoseconds: ${end - begin}")

        resultPDFPath = pdfWriterFile.path
    }

    return resultPDFPath
}
