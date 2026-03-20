plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "tech.cwitch.aavin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    /** 🔹 FLAVOR SETUP */
    flavorDimensions += "client"

    /** 🔹 SIGNING CONFIGS */
    signingConfigs {

        create("namakkalRelease") {
            storeFile = file("aavinprocurenkl.jks")
            storePassword = "777888333"
            keyAlias = "aavinprocurenamakkal"
            keyPassword = "777888333"
        }

        create("cbeRelease") {
            storeFile = file("aavincbe-release-key.jks")
            storePassword = "000999888"
            keyAlias = "aavincbe"
            keyPassword = "000999888"
        }

        create("nilgirisRelease") {
            storeFile = file("aavinnilgiris-release.jks")
            storePassword = "222777000"
            keyAlias = "aavinnilgiris"
            keyPassword = "222777000"
        }
    }

    productFlavors {
        create("namakkal") {
            dimension = "client"
            applicationId = "tech.cwitch.aavinfleet.nkl"
            resValue("string", "app_name", "Aavin NKL")
            signingConfig = signingConfigs.getByName("namakkalRelease")
        }
        create("cbe") {
            dimension = "client"
            applicationId = "tech.cwitch.aavinfleet.cbe"
            resValue("string", "app_name", "Aavin CBE")
            signingConfig = signingConfigs.getByName("cbeRelease")
        }
        create("nilgiris") {
            dimension = "client"
            applicationId = "tech.cwitch.aavinnilgiris"
            resValue("string", "app_name", "AavinNilgiris")
            signingConfig = signingConfigs.getByName("nilgirisRelease")
        }
    }

    sourceSets {
        getByName("namakkal") {
            res.srcDirs("src/namakkal/res")
        }
        getByName("cbe") {
            res.srcDirs("src/cbe/res")
        }
        getByName("nilgiris") {
            res.srcDirs("src/nilgiris/res")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }

        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
