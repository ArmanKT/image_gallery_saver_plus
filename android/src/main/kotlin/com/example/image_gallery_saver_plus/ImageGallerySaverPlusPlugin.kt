package com.example.image_gallery_saver_plus

import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.io.File
import java.io.FileInputStream
import java.io.IOException

/** ImageGallerySaverPlusPlugin */
class ImageGallerySaverPlusPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private var applicationContext: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.applicationContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "image_gallery_saver_plus")
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "saveImageToGallery" -> {
                val image = call.argument<ByteArray?>("imageBytes")
                val quality = call.argument<Int?>("quality")
                val name = call.argument<String?>("name")

                result.success(
                    saveImageToGallery(
                        BitmapFactory.decodeByteArray(
                            image ?: ByteArray(0),
                            0,
                            image?.size ?: 0
                        ), quality, name
                    )
                )
            }

            "saveFileToGallery" -> {
                val path = call.argument<String?>("file")
                val name = call.argument<String?>("name")
                result.success(saveFileToGallery(path, name))
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        methodChannel.setMethodCallHandler(null)
    }

    private fun generateUri(extension: String = "", name: String? = null): Uri? {
        val fileName = name ?: System.currentTimeMillis().toString()
        val mimeType = getMIMEType(extension)
        val isVideo = mimeType?.startsWith("video") == true

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // >= android 10
            val uri = when {
                isVideo -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                else -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH, when {
                        isVideo -> Environment.DIRECTORY_MOVIES
                        else -> Environment.DIRECTORY_PICTURES
                    }
                )
                if (mimeType != null) {
                    put(
                        when {
                            isVideo -> MediaStore.Video.Media.MIME_TYPE
                            else -> MediaStore.Images.Media.MIME_TYPE
                        }, mimeType
                    )
                }
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            applicationContext?.contentResolver?.insert(uri, values)

        } else {
            generateLegacyFileUri(isVideo, fileName, extension)
        }
    }

    @Suppress("DEPRECATION")
    private fun generateLegacyFileUri(isVideo: Boolean, fileName: String, extension: String): Uri {
        val storePath =
            Environment.getExternalStoragePublicDirectory(
                when {
                    isVideo -> Environment.DIRECTORY_MOVIES
                    else -> Environment.DIRECTORY_PICTURES
                }
            ).absolutePath
        val appDir = File(storePath).apply {
            if (!exists()) {
                mkdirs()
            }
        }

        val file =
            File(appDir, if (extension.isNotEmpty()) "$fileName.$extension" else fileName)
        return Uri.fromFile(file)
    }

    /**
     * get file Mime Type
     *
     * @param extension extension
     * @return file Mime Type
     */
    private fun getMIMEType(extension: String): String? {
        return if (extension.isNotEmpty()) {
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.lowercase())
        } else {
            null
        }
    }

    /**
     * Send storage success notification
     *
     * @param context context
     * @param fileUri file path
     */
    private fun sendBroadcast(context: Context, fileUri: Uri?) {
        fileUri?.takeIf { it.scheme == "file" }?.path?.let { path ->
            MediaScannerConnection.scanFile(context, arrayOf(path), null, null)
        }
    }

    private fun finishPendingMedia(context: Context, fileUri: Uri?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || fileUri == null) {
            return
        }
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.IS_PENDING, 0)
        }
        context.contentResolver.update(fileUri, values, null, null)
    }

    private fun deleteFailedMedia(context: Context, fileUri: Uri?) {
        when (fileUri?.scheme) {
            "file" -> fileUri.path?.let { File(it).delete() }
            null -> return
            else -> context.contentResolver.delete(fileUri, null, null)
        }
    }

    private fun saveImageToGallery(
        bmp: Bitmap?,
        quality: Int?,
        name: String?
    ): HashMap<String, Any?> {
        // check parameters
        if (bmp == null || quality == null) {
            return SaveResultModel(false, null, "parameters error").toHashMap()
        }
        // check applicationContext
        val context = applicationContext
            ?: return SaveResultModel(false, null, "applicationContext null").toHashMap()
        var fileUri: Uri? = null
        var success = false
        try {
            fileUri = generateUri("jpg", name = name)
            if (fileUri != null) {
                context.contentResolver.openOutputStream(fileUri)?.use { fos ->
                    success = bmp.compress(Bitmap.CompressFormat.JPEG, quality.coerceIn(0, 100), fos)
                    fos.flush()
                }
            }
        } catch (e: IOException) {
            deleteFailedMedia(context, fileUri)
            return SaveResultModel(false, null, e.toString()).toHashMap()
        } finally {
            bmp.recycle()
        }
        return if (success) {
            finishPendingMedia(context, fileUri)
            sendBroadcast(context, fileUri)
            SaveResultModel(fileUri.toString().isNotEmpty(), fileUri.toString(), null).toHashMap()
        } else {
            deleteFailedMedia(context, fileUri)
            SaveResultModel(false, null, "saveImageToGallery fail").toHashMap()
        }
    }


    private fun saveFileToGallery(filePath: String?, name: String?): HashMap<String, Any?> {
        // check parameters
        if (filePath == null) {
            return SaveResultModel(false, null, "parameters error").toHashMap()
        }
        val context = applicationContext ?: return SaveResultModel(
            false,
            null,
            "applicationContext null"
        ).toHashMap()

        var fileUri: Uri? = null
        var success = false

        try {
            val originalFile = File(filePath)
            if (!originalFile.exists()) {
                return SaveResultModel(false, null, "$filePath does not exist").toHashMap()
            }

            fileUri = generateUri(originalFile.extension, name) ?: return SaveResultModel(
                false, null, "Failed to generate URI"
            ).toHashMap()

            context.contentResolver.openOutputStream(fileUri)?.use { outputStream ->
                FileInputStream(originalFile).use { fileInputStream ->
                    val copied = fileInputStream.copyTo(outputStream)
                    if (copied < 1) {
                        throw IOException("No bytes copied. File might be empty.")
                    }
                    success = true
                }
            }
        } catch (e: IOException) {
            deleteFailedMedia(context, fileUri)
            return SaveResultModel(false, null, e.toString()).toHashMap()
        }

        return if (success) {
            finishPendingMedia(context, fileUri)
            sendBroadcast(context, fileUri)
            SaveResultModel(true, fileUri.toString(), null).toHashMap()
        } else {
            deleteFailedMedia(context, fileUri)
            SaveResultModel(false, null, "saveFileToGallery failed").toHashMap()
        }
    }

    class SaveResultModel(
        var isSuccess: Boolean,
        var filePath: String? = null,
        var errorMessage: String? = null
    ) {
        fun toHashMap(): HashMap<String, Any?> {
            val hashMap = HashMap<String, Any?>()
            hashMap["isSuccess"] = isSuccess
            hashMap["filePath"] = filePath
            hashMap["errorMessage"] = errorMessage
            return hashMap
        }
    }

}
