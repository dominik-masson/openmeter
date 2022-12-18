package com.example.openmeter

import android.content.pm.PackageManager
import android.hardware.camera2.CameraManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.example.openmeter/main"
    private val enableTorch = "enableTorch"
    private val disableTorch = "disableTorch"
    private val torchAvailable = "torchAvailable"

    private var cameraManager: CameraManager? = null
    private var cameraID: String? = null

    @RequiresApi(Build.VERSION_CODES.M)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        cameraManager = context.getSystemService(CAMERA_SERVICE) as CameraManager

        try {
            cameraID = cameraManager!!.cameraIdList[0]
        } catch (e: java.lang.Exception) {
            Log.d("TorchController", "Could not fetch camera id, the plugin won't work.")
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == torchAvailable) {
                isTorchAvailable(result)
            }
            if (call.method == enableTorch) {
                enableTorch(result)
            }
            if (call.method == disableTorch) {
                disableTorch(result)
            }
        }
    }


    private fun isTorchAvailable(result: MethodChannel.Result) {
        result.success(context.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH))
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun enableTorch(result: MethodChannel.Result) {
        if (cameraID != null) {
            try {
                cameraManager!!.setTorchMode(cameraID!!, true)
                result.success(null)
            } catch (e: Exception) {
                result.error(
                    "ERROR_DISABLE_TORCH_EXISTENT_USE",
                    "There is an existent camera user, cannot disable torch: $e",
                    null
                )
            }
        } else {
            result.error(
                "ERROR_DISABLE_TORCH_NOT_AVAILABLE",
                "Torch is not available", null
            )
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun disableTorch(result: MethodChannel.Result) {
        if (cameraID != null) {

            try {
                cameraManager!!.setTorchMode(cameraID!!, false)
                result.success(null)
            } catch (e: java.lang.Exception) {
                result.error(
                    "ERROR_DISABLE_TORCH_EXISTENT_USE",
                    "There is an existent camera user, cannot disable torch: $e",
                    null
                )
            }

        } else {
            result.error(
                "ERROR_DISABLE_TORCH_NOT_AVAILABLE",
                "Torch is not available", null
            )
        }
    }
}
