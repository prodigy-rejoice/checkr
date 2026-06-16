package com.example.checkr

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import io.flutter.FlutterInjector
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.flex.FlexDelegate
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.FileChannel

class TfliteChannelHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    private var interpreter: Interpreter? = null
    private var flexDelegate: FlexDelegate? = null
    private val inputSize = 224
    private val channels = 3
    private val floatCount = inputSize * inputSize * channels
    private val bufferSize = floatCount * 4

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadModel" -> handleLoadModel(call, result)
            "runInference" -> handleRunInference(call, result)
            "isLoaded" -> result.success(interpreter != null)
            "dispose" -> {
                interpreter?.close()
                interpreter = null
                flexDelegate?.close()
                flexDelegate = null
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleLoadModel(call: MethodCall, result: MethodChannel.Result) {
        try {
            val assetPath = call.argument<String>("assetPath")
                ?: "assets/models/naira_autoencoder_v2.tflite"
            val key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(assetPath)
            val afd = context.assets.openFd(key)
            val input = FileInputStream(afd.fileDescriptor)
            val mapped = input.channel.map(
                FileChannel.MapMode.READ_ONLY,
                afd.startOffset,
                afd.declaredLength,
            )
            input.close()
            afd.close()

            flexDelegate?.close()
            flexDelegate = FlexDelegate()
            val options = Interpreter.Options().apply {
                setNumThreads(4)
                addDelegate(flexDelegate)
            }
            interpreter?.close()
            interpreter = Interpreter(mapped, options)
            println("[TfliteChannelHandler] Model loaded successfully")
            result.success(true)
        } catch (e: Throwable) {
            println("[TfliteChannelHandler] loadModel failed: ${e.message}")
            result.error("LOAD_FAILED", e.message, e.stackTraceToString())
        }
    }

    private fun handleRunInference(call: MethodCall, result: MethodChannel.Result) {
        val tflite = interpreter
        if (tflite == null) {
            result.error("NOT_LOADED", "Interpreter not loaded", null)
            return
        }

        val imagePath = call.argument<String>("imagePath")
        if (imagePath == null) {
            result.error("BAD_ARGS", "Missing imagePath", null)
            return
        }

        println("[TfliteChannelHandler] Decoding image: $imagePath")

        try {
            val raw = BitmapFactory.decodeFile(imagePath)
                ?: throw IllegalArgumentException("Failed to decode image at $imagePath")

            val bitmap = Bitmap.createScaledBitmap(raw, inputSize, inputSize, true)
            if (raw !== bitmap) raw.recycle()

            println("[TfliteChannelHandler] Bitmap resized to ${bitmap.width}x${bitmap.height}")

            val inputFloats = FloatArray(floatCount)
            var idx = 0
            for (y in 0 until inputSize) {
                for (x in 0 until inputSize) {
                    val pixel = bitmap.getPixel(x, y)
                    inputFloats[idx++] = (Color.red(pixel).toFloat() / 127.5f) - 1.0f
                    inputFloats[idx++] = (Color.green(pixel).toFloat() / 127.5f) - 1.0f
                    inputFloats[idx++] = (Color.blue(pixel).toFloat() / 127.5f) - 1.0f
                }
            }
            bitmap.recycle()

            println("[TfliteChannelHandler] Preprocessing done. Float array size: ${inputFloats.size}")

            val inputBuffer = ByteBuffer.allocateDirect(bufferSize).order(ByteOrder.nativeOrder())
            for (f in inputFloats) inputBuffer.putFloat(f)
            inputBuffer.rewind()

            val outputBuffer = ByteBuffer.allocateDirect(bufferSize).order(ByteOrder.nativeOrder())

            tflite.run(inputBuffer, outputBuffer)

            outputBuffer.rewind()
            val outputFloatBuffer = outputBuffer.asFloatBuffer()

            var sum = 0.0
            for (i in 0 until floatCount) {
                val diff = inputFloats[i].toDouble() - outputFloatBuffer.get().toDouble()
                sum += diff * diff
            }
            val mse = sum / floatCount

            println("[TfliteChannelHandler] Inference complete. MSE = $mse")

            result.success(mse)
        } catch (e: Throwable) {
            println("[TfliteChannelHandler] Inference failed: ${e.message}\n${e.stackTraceToString()}")
            result.error("INFERENCE_FAILED", e.message, e.stackTraceToString())
        }
    }
}
