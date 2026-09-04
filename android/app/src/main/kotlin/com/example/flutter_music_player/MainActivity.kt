package com.example.flutter_music_player

import android.content.Intent
import android.net.Uri
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.mume/ringtone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setRingtone" -> {
                    val uriString = call.argument<String>("uri")
                    val path = call.argument<String>("path")

                    val targetUri: Uri? = when {
                        !uriString.isNullOrEmpty() && uriString.startsWith("content://") ->
                            Uri.parse(uriString)
                        !path.isNullOrEmpty() ->
                            Uri.parse("file://$path")
                        else -> null
                    }

                    if (targetUri != null) {
                        val intent = Intent(Intent.ACTION_ATTACH_DATA).apply {
                            addCategory(Intent.CATEGORY_DEFAULT)
                            setDataAndType(targetUri, "audio/*")
                            putExtra("mimeType", "audio/*")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }

                        val chooser = Intent.createChooser(intent, "Set as")
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(chooser)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "deleteAudioFile" -> {
                    val uriString = call.argument<String>("uri")
                    if (!uriString.isNullOrEmpty() && uriString.startsWith("content://")) {
                        try {
                            val rows = contentResolver.delete(Uri.parse(uriString), null, null)
                            result.success(rows > 0)
                        } catch (e: SecurityException) {
                            result.error("SECURITY", e.message, null)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_URI", "Missing content URI", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}