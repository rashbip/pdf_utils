package com.example.pdf_worker

import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.encryption.AccessPermission
import com.tom_roush.pdfbox.pdmodel.encryption.InvalidPasswordException
import com.tom_roush.pdfbox.pdmodel.encryption.StandardProtectionPolicy
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.io.RandomAccessFile
import kotlin.io.use
import kotlin.text.Charsets

class PdfLocker {

    fun isEncryptedByTail(filePath: String): Boolean {
        val file = File(filePath)
        if (!file.exists()) {
            throw FileNotFoundException("File does not exist: $filePath")
        }

        try {
            return RandomAccessFile(file, "r").use { raf ->
                val fileLength = raf.length()
                if (fileLength <= 0) {
                    throw IOException("File is empty: $filePath")
                }

                val readSize = if (fileLength > 4096) 4096 else fileLength.toInt()
                raf.seek(fileLength - readSize)

                val buffer = ByteArray(readSize)
                raf.readFully(buffer)

                val tailString = String(buffer, Charsets.UTF_8)

                val trailerIndex = tailString.lastIndexOf("trailer")
                if (trailerIndex != -1) {
                    val dictStart = tailString.indexOf("<<", trailerIndex)
                    if (dictStart != -1) {
                        val dictEnd = tailString.indexOf(">>", dictStart)
                        if (dictEnd != -1) {
                            val trailerDict = tailString.substring(dictStart, dictEnd + 2)
                            if (trailerDict.contains("/Encrypt")) {
                                return@use true
                            }
                        }
                    }
                }

                return@use tailString.contains("/Encrypt")
            }
        } catch (exception: IOException) {
            throw exception
        }
    }

    fun isEncrypted(filePath: String): Boolean {
        val file = File(filePath)
        if (!file.exists()) {
            throw FileNotFoundException("PDF file not found: $filePath")
        }
        var document: PDDocument? = null
        return try {
            document = PDDocument.load(file, "")
            document?.isEncrypted ?: false
        } catch (exception: InvalidPasswordException) {
            true
        } catch (ioException: IOException) {
            throw ioException
        } catch (exception: Exception) {
            throw IOException("Failed to check PDF protection: ${exception.message}", exception)
        } finally {
            try {
                document?.close()
            } catch (closeException: IOException) {
                throw closeException
            }
        }
    }

    fun lock(filePath: String, userPassword: String, ownerPassword: String) {
        val file = File(filePath)
        if (!file.exists()) {
            throw FileNotFoundException("PDF file not found: $filePath")
        }
        PDDocument.load(file).use { document ->
            if (document.isEncrypted) {
                throw Exception("PDF file is already encrypted")
            }
            val accessPermission = AccessPermission()
            val protectionPolicy =
                    StandardProtectionPolicy(ownerPassword, userPassword, accessPermission).apply {
                        encryptionKeyLength = 128
                        permissions = accessPermission
                    }
            document.protect(protectionPolicy)
            document.save(file)
        }
    }

    fun unlock(filePath: String, password: String): Boolean {
        val file = File(filePath)
        if (!file.exists()) {
            throw FileNotFoundException("PDF file not found: $filePath")
        }
        PDDocument.load(file, password).use { document ->
            if (!document.isEncrypted) {
                throw Exception("PDF file is not encrypted")
            }
            document.isAllSecurityToBeRemoved = true
            document.save(file)
            return true
        }
    }
}
