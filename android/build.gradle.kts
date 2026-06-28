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
    project.evaluationDependsOn(":app")
}

subprojects {
    fun patch() {
        val androidExtension = extensions.findByName("android")
        if (androidExtension != null) {
            val android = androidExtension as? com.android.build.gradle.BaseExtension
            if (android != null && android.namespace == null) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestText = manifestFile.readText()
                    val packageRegex = Regex("""package="([^"]+)"""")
                    val match = packageRegex.find(manifestText)
                    if (match != null) {
                        android.namespace = match.groupValues[1]
                    } else {
                        android.namespace = "com.hermes.${name.replace("-", "_")}"
                    }
                } else {
                    android.namespace = "com.hermes.${name.replace("-", "_")}"
                }
            }
        }
    }
    if (state.executed) {
        patch()
    } else {
        afterEvaluate {
            patch()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
