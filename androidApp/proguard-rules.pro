# YetiMatch ProGuard Rules

# Keep Kotlin serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}
-keep,includedescriptorclasses class com.daddoodev.yetimatch.**$$serializer { *; }
-keepclassmembers class com.daddoodev.yetimatch.** {
    *** Companion;
}
-keepclasseswithmembers class com.daddoodev.yetimatch.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep Compose
-dontwarn androidx.compose.**

# Keep Ktor
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# Keep Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
