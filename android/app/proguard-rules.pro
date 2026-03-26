# ============================================
# ProGuard Rules for PROMPT Genie
# ============================================

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Gson / JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Retrofit (if used by plugins)
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Exceptions

# Keep model classes (Hive adapters)
-keep class ** extends com.google.protobuf.GeneratedMessageLite { *; }

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# Biometric / Local Auth
-keep class androidx.biometric.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Image Cropper
-keep class com.yalantis.ucrop.** { *; }

# Prevent R8 from stripping interface information
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Don't obfuscate model classes for proper serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Suppress warnings for missing classes
-dontwarn java.lang.invoke.StringConcatFactory
