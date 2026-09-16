plugins {
    id("com.android.application")
    id("kotlin-android")

    // Google Services / Firebase
    id("com.google.gms.google-services")

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.wardrobe.wardrobe"

    // flutter_local_notifications 22.x requires compileSdk 36.
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility =
            JavaVersion.VERSION_17

        targetCompatibility =
            JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget =
            JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.wardrobe.wardrobe"

        minSdk = 24
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Existing project behavior retained.
            signingConfig =
                signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}

flutter {
    source = "../.."
}
