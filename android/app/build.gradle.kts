// --------- IMPORTS NECESARIOS ---------
import java.util.Properties
// --------------------------------------

plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe ir después de android/kotlin
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    // Si usas Crashlytics/Firebase, agrega:
    // id("com.google.firebase.crashlytics")
}

// --------- BLOQUE DE CARGA DE PROPIEDADES ---------
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use {
        keystoreProperties.load(it)
    }
}
// --------------------------------------------------

android {
    namespace = "com.develop4God.habitus_faith"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.develop4God.habitus_faith"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        // Solo crea release si hay variables de entorno O key.properties presentes
        if (
            System.getenv("KEYSTORE_PATH") != null ||
            keystoreProperties.getProperty("storeFile") != null
        ) {
            create("release") {
                storeFile = file(
                    System.getenv("KEYSTORE_PATH") ?: keystoreProperties.getProperty("storeFile")
                )
                storePassword = System.getenv("KEYSTORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword")
                keyAlias = System.getenv("KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias")
                keyPassword = System.getenv("KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    lint {
        abortOnError = false
        checkReleaseBuilds = false
        baseline = file("lint-baseline.xml")
        disable += listOf("InvalidPackage", "PrivateApi")
    }

    buildTypes {
        release {
            // Solo usa signingConfig release si fue creado
            if (signingConfigs.findByName("release") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = false // pon true si quieres ProGuard para release firmado
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }

    // Opcional: Evita errores con recursos duplicados de dependencias
    packaging {
        resources {
            excludes.addAll(
                listOf(
                    "META-INF/DEPENDENCIES",
                    "META-INF/LICENSE",
                    "META-INF/LICENSE.txt",
                    "META-INF/license.txt",
                    "META-INF/NOTICE",
                    "META-INF/NOTICE.txt",
                    "META-INF/notice.txt",
                    "META-INF/ASL2.0",
                    "META-INF/*.kotlin_module"
                )
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.window:window:1.5.0")
    implementation("androidx.window:window-java:1.5.0")
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
    // Si usas Crashlytics (Firebase crash reporting), descomenta la línea abajo
    // implementation("com.google.firebase:firebase-crashlytics")
}

flutter {
    source = "../.."
}
