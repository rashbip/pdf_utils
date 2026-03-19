package com.rashbip.pdf_utils

import android.content.Context
import android.net.Uri
import java.io.*

class Utils {
    fun getURI(path: String): Uri {
        return if (path.startsWith("/")) Uri.fromFile(File(path)) else Uri.parse(path)
    }

    fun deleteTempFiles(files: List<File>) {
        files.forEach { it.delete() }
    }
}

data class PageRotationInfo(val pageNumber: Int, val rotationAngle: Int)
