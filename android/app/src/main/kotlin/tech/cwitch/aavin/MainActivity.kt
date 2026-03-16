package tech.cwitch.aavin

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Disable window animations (VERY IMPORTANT for Razorpay)
        window.setWindowAnimations(0)

        // Ensure hardware acceleration is enabled
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )

        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        super.onResume()

        // Clear problematic flags that cause black / transparent screens
        window.clearFlags(
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
        )
    }
}
