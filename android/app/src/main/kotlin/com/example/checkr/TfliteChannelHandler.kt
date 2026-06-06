package com.example.checkr

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.FileChannel

class TfliteChannelHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    private var interpreter: Interpreter? = null
    private val inputSize = 224
    private val channels = 3
    private val outputByteSize = 1 * inputSize * inputSize * channels * 4

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadModel" -> handleLoadModel(call, result)
            "runInference" -> handleRunInference(call, result)
            "isLoaded" -> result.success(interpreter != null)
            "dispose" -> {
                interpreter?.close()
                interpreter = null
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

            val options = Interpreter.Options().apply {
                setNumThreads(4)
            }
            interpreter?.close()
            interpreter = Interpreter(mapped, options)
            result.success(true)
        } catch (e: Throwable) {
            result.error("LOAD_FAILED", e.message, e.stackTraceToString())
        }
    }

    private fun handleRunInference(call: MethodCall, result: MethodChannel.Result) {
        val tflite = interpreter
        if (tflite == null) {
            result.error("NOT_LOADED", "Interpreter not loaded", null)
            return
        }
        val bytes = call.argument<ByteArray>("input")
        if (bytes == null) {
            result.error("BAD_ARGS", "Missing input bytes", null)
            return
        }
        if (bytes.size != outputByteSize) {
            result.error(
                "BAD_INPUT_SIZE",
                "Expected $outputByteSize bytes, got ${bytes.size}",
                null,
            )
            return
        }

        try {
            val inputBuffer = ByteBuffer.allocateDirect(outputByteSize).order(ByteOrder.nativeOrder())
            inputBuffer.put(bytes)
            inputBuffer.rewind()

            val outputBuffer = ByteBuffer.allocateDirect(outputByteSize).order(ByteOrder.nativeOrder())
            outputBuffer.rewind()

            tflite.run(inputBuffer, outputBuffer)

            val inputFloats = inputBuffer.asReadOnlyBuffer().order(ByteOrder.nativeOrder()).asFloatBuffer()
            inputFloats.rewind()
            val outputFloats = outputBuffer.asReadOnlyBuffer().order(ByteOrder.nativeOrder()).asFloatBuffer()
            outputFloats.rewind()

            var sum = 0.0
            val count = inputSize * inputSize * channels
            for (i in 0 until count) {
                val diff = inputFloats.get().toDouble() - outputFloats.get().toDouble()
                sum += diff * diff
            }
            val mse = sum / count

            result.success(
                mapOf(
                    "mseScore" to mse,
                    "isGenuine" to (mse <= THRESHOLD),
                ),
            )
        } catch (e: Throwable) {
            result.error("INFERENCE_FAILED", e.message, e.stackTraceToString())
        }
    }

    companion object {
        private const val THRESHOLD = 0.201362
    }
}
