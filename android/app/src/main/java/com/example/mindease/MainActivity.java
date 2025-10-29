package com.example.mindease;

import android.Manifest;
import android.content.pm.PackageManager;
import android.telephony.SmsManager;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.mindease/sms";
    private static final int REQUEST_SMS = 1;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("sendSms")) {
                        String phone = call.argument("phone");
                        String message = call.argument("message");

                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                                != PackageManager.PERMISSION_GRANTED) {
                            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.SEND_SMS}, REQUEST_SMS);
                            result.error("PERMISSION_DENIED", "SMS permission denied", null);
                        } else {
                            try {
                                SmsManager smsManager = SmsManager.getDefault();
                                smsManager.sendTextMessage(phone, null, message, null, null);
                                result.success("SMS_SENT");
                            } catch (Exception e) {
                                result.error("SMS_FAILED", e.getMessage(), null);
                            }
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }
}
