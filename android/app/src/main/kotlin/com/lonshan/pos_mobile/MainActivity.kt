package com.nanonux.minipos

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val channelName = "nanonux/public_documents"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "saveBytes") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val bytes = call.argument<ByteArray>("bytes")
                        ?: throw IllegalArgumentException("Missing file bytes")
                    val fileName = sanitize(call.argument<String>("fileName"))
                    val directory = sanitizeDirectory(call.argument<String>("directory"))
                    result.success(saveToDocuments(bytes, fileName, directory))
                } catch (error: Exception) {
                    result.error("DOCUMENT_SAVE_FAILED", error.message, null)
                }
            }
    }

    private fun saveToDocuments(bytes: ByteArray, fileName: String, directory: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Files.FileColumns.DISPLAY_NAME, fileName)
                put(MediaStore.Files.FileColumns.MIME_TYPE, mimeType(fileName))
                put(
                    MediaStore.Files.FileColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_DOCUMENTS}/nanonux/$directory"
                )
                put(MediaStore.Files.FileColumns.IS_PENDING, 1)
            }
            val collection: Uri = MediaStore.Files.getContentUri("external")
            // Re-running migration should replace the existing file instead
            // of creating duplicate entries in public Documents.
            contentResolver.delete(
                collection,
                "${MediaStore.Files.FileColumns.DISPLAY_NAME} = ? AND " +
                    "${MediaStore.Files.FileColumns.RELATIVE_PATH} = ?",
                arrayOf(
                    fileName,
                    "${Environment.DIRECTORY_DOCUMENTS}/nanonux/$directory"
                )
            )
            val uri = contentResolver.insert(collection, values)
                ?: throw IllegalStateException("Could not create public Documents file")
            try {
                contentResolver.openOutputStream(uri)?.use { it.write(bytes) }
                    ?: throw IllegalStateException("Could not open public Documents file")
                values.clear()
                values.put(MediaStore.Files.FileColumns.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
                return resolvePath(uri) ?: uri.toString()
            } catch (error: Exception) {
                contentResolver.delete(uri, null, null)
                throw error
            }
        }

        @Suppress("DEPRECATION")
        val directoryFile = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS),
            "nanonux/$directory"
        )
        if (!directoryFile.exists() && !directoryFile.mkdirs()) {
            throw IllegalStateException("Could not create public Documents directory")
        }
        val file = File(directoryFile, fileName)
        file.writeBytes(bytes)
        return file.absolutePath
    }

    private fun resolvePath(uri: Uri): String? {
        val projection = arrayOf(MediaStore.Files.FileColumns.DATA)
        contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(MediaStore.Files.FileColumns.DATA)
                if (index >= 0) return cursor.getString(index)
            }
        }
        return null
    }

    private fun mimeType(fileName: String): String = when {
        fileName.endsWith(".pdf", true) -> "application/pdf"
        fileName.endsWith(".xlsx", true) ->
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        fileName.endsWith(".png", true) -> "image/png"
        fileName.endsWith(".jpg", true) || fileName.endsWith(".jpeg", true) -> "image/jpeg"
        else -> "application/octet-stream"
    }

    private fun sanitize(value: String?): String {
        val name = File(value ?: "file").name.replace(Regex("[^A-Za-z0-9._-]"), "_")
        return if (name.isBlank()) "file" else name
    }

    private fun sanitizeDirectory(value: String?): String =
        (value ?: "files").replace(Regex("[^A-Za-z0-9_-]"), "_")
}
