package com.hdpolover.ybbproject;

 import android.app.NotificationChannel;
 import android.app.NotificationManager;
 import android.os.Build;

 import io.flutter.app.FlutterApplication;
 import io.flutter.plugin.common.PluginRegistry;
 import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
 import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class Application extends FlutterApplication implements PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        FlutterFirebaseMessagingService.setPluginRegistrant(this);

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationChannel channel = new NotificationChannel("messages","Messages", NotificationManager.IMPORTANCE_LOW);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }

    @Override
    public void registerWith(PluginRegistry registry) {
       FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}