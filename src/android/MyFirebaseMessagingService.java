package com.gae.scaffolder.plugin;

import android.Manifest;
import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.hardware.display.DisplayManager;

import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;

import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.telecom.Connection;
import android.telecom.ConnectionService;
import android.telecom.PhoneAccount;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.util.Log;
import android.view.Display;
import android.view.textclassifier.TextClassification;

import java.io.Serializable;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import com.dmarc.cordovacall.CordovaCallLib;
import com.dmarc.cordovacall.MyConnectionService;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

/**
 * Created by Felipe Echanique on 08/06/2016.
 */
public class MyFirebaseMessagingService extends FirebaseMessagingService {

  private static final String TAG = "FCMPlugin";
  private static final String CHANNEL_ID = "vh_phone_calls";
  private static final CharSequence CHANNEL_NAME = "Care Team Notifications";
  private static final String CHANNEL_DESCRIPTION = "Notification Channels for your Health Care Team";
  private static final String NOTIFICATION_NAME = "FcmNotification";

  @Override
  public void onNewToken(String token) {
    // Get updated InstanceID token.
    Log.d(TAG, "Refreshed token: " + token);
    FCMPlugin.sendTokenRefresh(token);

    // TODO: Implement this method to send any registration to your app's servers.
    //sendRegistrationToServer(refreshedToken);
  }

  /**
   * Called when message is received.
   *
   * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
   */
  // [START receive_message]
  @Override
  public void onMessageReceived(RemoteMessage remoteMessage) {
    TelecomManager telecomManager = (TelecomManager) getSystemService(TELECOM_SERVICE);
        // TODO(developer): Handle FCM messages here.
        // If the application is in the foreground handle both data and notification messages here.
        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
        Log.d(TAG, "==> MyFirebaseMessagingService onMessageReceived");
         com.google.firebase.messaging.RemoteMessage.Notification notification = remoteMessage.getNotification();
      if(remoteMessage.getNotification() != null){
            Log.d(TAG, "\tNotification Title: " + remoteMessage.getNotification().getTitle());
            Log.d(TAG, "\tNotification Message: " + remoteMessage.getNotification().getBody());
        }

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("wasTapped", false);

        if(remoteMessage.getNotification() != null){
            data.put("title", remoteMessage.getNotification().getTitle());
            data.put("body", remoteMessage.getNotification().getBody());
        }

        for (String key : remoteMessage.getData().keySet()) {
                Object value = remoteMessage.getData().get(key);
                Log.d(TAG, "\tKey: " + key + " Value: " + value);
                data.put(key, value);
        }

        Log.d(TAG, "\tNotification Data: " + data.toString());

        if(data.get("Type").equals("Video") && data.get("Action").equals("Request")) {

            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                String appName  = CordovaCallLib.getApplicationName(this);
                Bundle callInfo = new Bundle();
                PhoneAccountHandle handle = CordovaCallLib.getCurrentPhoneHandle(this, MyConnectionService.class.toString(), appName);
                MyConnectionService.registerPhoneHandle(appName, telecomManager, handle);
                MyConnectionService.receiveCall(telecomManager, callInfo, handle, "Care Team", (Serializable) data, NOTIFICATION_NAME);
            } else {
            // Phone Call Intent
              Intent i = new Intent(this, FCMPluginActivity.class)
                  .addCategory(Intent.CATEGORY_LAUNCHER)
                  .putExtra(NOTIFICATION_NAME, (Serializable) data)
                  .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(i);
            }
        } else if (data.get("Type").equals("Video") && data.get("Action").equals("Cancel")) {
            //cancel call

            Connection conn = MyConnectionService.getConnection();
            Log.d(TAG, "Canceling call from notification");
            if (conn != null && conn.getState() != Connection.STATE_ACTIVE) {
                conn.onDisconnect();
            } else {
                Log.d(TAG, "Connection already closed");
                FCMPlugin.sendPushPayload( data );
            }

        } else {
            FCMPlugin.sendPushPayload( data );
        }

    }
    // [END receive_message]
   
}
