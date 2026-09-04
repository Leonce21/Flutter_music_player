// android/build.gradle.kts
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // 1. FIX FOR AGP 8+ NAMESPACE ISSUE IN OLDER PLUGINS
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withId
        val getNamespaceMethod = androidExt.javaClass.methods.find { it.name == "getNamespace" }
        val setNamespaceMethod = androidExt.javaClass.methods.find { it.name == "setNamespace" }
        
        if (getNamespaceMethod != null && setNamespaceMethod != null) {
            val currentNamespace = getNamespaceMethod.invoke(androidExt) as? String
            if (currentNamespace.isNullOrEmpty()) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestText = manifestFile.readText()
                    val regex = Regex("package=\"([^\"]+)\"")
                    val match = regex.find(manifestText)
                    if (match != null) {
                        val packageName = match.groupValues[1]
                        setNamespaceMethod.invoke(androidExt, packageName)
                    }
                }
            }
        }
    }
}

// 2. FIX FOR JVM TARGET MISMATCH (Java 11 vs Kotlin 17)
// CRITICAL: gradle.projectsEvaluated guarantees this runs AFTER all plugins 
// (like on_audio_query) have completely finished configuring their tasks.
gradle.projectsEvaluated {
    subprojects {
        // Force Java 17 using the standard Gradle API (JavaCompile is implicitly imported)
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
        
        // Force Kotlin 17 via reflection (kept just in case)
        tasks.matching { it.javaClass.name.contains("KotlinCompile") }.configureEach {
            try {
                val getKotlinOptions = this.javaClass.methods.find { it.name == "getKotlinOptions" }
                if (getKotlinOptions != null) {
                    val kotlinOptions = getKotlinOptions.invoke(this)
                    val setJvmTarget = kotlinOptions.javaClass.methods.find { it.name == "setJvmTarget" }
                    setJvmTarget?.invoke(kotlinOptions, "17")
                }
            } catch (e: Exception) { /* Ignore */ }
        }
    }
}

subprojects {
    afterEvaluate {
        if (name == "on_audio_query_android") {
            val androidExt = extensions.findByName("android")
            if (androidExt is com.android.build.gradle.LibraryExtension) {
                androidExt.compileSdk = 34
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}