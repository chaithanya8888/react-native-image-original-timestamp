package com.imageoriginaltimestamp;

import androidx.annotation.NonNull;

import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import android.media.ExifInterface;

@ReactModule(name = ImageOriginalTimestampModule.NAME)
public class ImageOriginalTimestampModule extends ReactContextBaseJavaModule {
  public static final String NAME = "ImageOriginalTimestamp";

  public ImageOriginalTimestampModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  public void fetchTimeStamp(String url, Promise promise) {
    try {
      ExifInterface exif = new ExifInterface(url);
      String str_date = exif.getAttribute(ExifInterface.TAG_DATETIME_ORIGINAL);
      if (str_date != null) {
        DateFormat formatter = new SimpleDateFormat("yyyy:MM:dd HH:mm:ss");
        Date date = (Date) formatter.parse(str_date);
        promise.resolve(String.valueOf(date.getTime() / 1000));
      } else {
        promise.reject(new Error("No Exif Data Available"));
      }
    } catch (Exception e) {
      promise.reject(new Error(e.toString()));
    }
  }
}
