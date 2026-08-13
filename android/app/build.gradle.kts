import java.io.FileInputStream
import java.util.Properties

// 1. Şifre dosyamızı okumak için gerekli komutlar eklendi
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mcosoft.retroyapilacaklar" 
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Desugaring burada aktif ediliyor
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // 2. Mühür (Signing) ayarlarımız oluşturuldu
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.mcosoft.retroyapilacaklar"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 3. DÜZELTME: "debug" yazan yeri "release" olarak değiştirdik
            signingConfig = signingConfigs.getByName("release")
            
            // =========================================================
            // YENİ EKLENEN BÖLÜM: ProGuard / R8 Kurallarını Aktif Etme
            // (Gson TypeToken çökmesini engelleyecek kural dosyasına bağlanır)
            // =========================================================
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// Desugaring kütüphanesi en alta ekleniyor
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}