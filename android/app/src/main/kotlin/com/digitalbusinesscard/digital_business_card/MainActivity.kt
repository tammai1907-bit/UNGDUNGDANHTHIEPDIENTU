package com.digitalbusinesscard.digital_business_card

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val GALLERY_CHANNEL = "com.digitalbusinesscard.digital_business_card/gallery"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GALLERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveImage" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        val fileName = call.argument<String>("fileName") ?: "qr_card.png"
                        if (bytes == null || bytes.isEmpty()) {
                            result.error("INVALID_ARGS", "Dữ liệu ảnh trống", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val savedPath = saveImageToPictures(bytes, fileName)
                            result.success(savedPath)
                        } catch (e: Exception) {
                            result.error("SAVE_ERROR", e.message ?: "Không thể lưu ảnh", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveImageToPictures(bytes: ByteArray, fileName: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_PICTURES}/DanhThiepDienTu"
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = applicationContext.contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                ?: throw IllegalStateException("Không thể tạo bản ghi ảnh trong MediaStore")

            try {
                resolver.openOutputStream(uri)?.use { outputStream ->
                    outputStream.write(bytes)
                    outputStream.flush()
                } ?: throw IllegalStateException("Không thể mở luồng ghi ảnh")

                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(uri, contentValues, null, null)
                return uri.toString()
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
        } else {
            @Suppress("DEPRECATION")
            val picturesDir =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            val albumDir = File(picturesDir, "DanhThiepDienTu")
            if (!albumDir.exists()) {
                albumDir.mkdirs()
            }
            val imageFile = File(albumDir, fileName)
            FileOutputStream(imageFile).use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            }
            MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(imageFile.absolutePath),
                arrayOf("image/png"),
                null
            )
            return imageFile.absolutePath
        }
    }
}
