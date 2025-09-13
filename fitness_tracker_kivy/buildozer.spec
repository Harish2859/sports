[app]
title = FitnessTracker
package.name = fitnesstracker
package.domain = org.example

source.dir = .
source.include_exts = py,png,jpg,kv,atlas

version = 1.0
requirements = python3,kivy,opencv-python-headless,mediapipe,numpy

[buildozer]
log_level = 2

[android]
api = 33
minapi = 21
ndk = 25b
sdk = 33
arch = arm64-v8a,armeabi-v7a

permissions = CAMERA,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE,INTERNET

[android.gradle_dependencies]
implementation 'androidx.core:core:1.6.0'

[android.add_src]

[android.add_jars]

[android.add_aars]

[android.gradle_repositories]

[android.add_gradle_repositories]

[android.add_compile_options]

[android.add_packaging_options]

[android.add_aab_attribute]

[android.add_activity]

[android.entrypoint]
org.kivy.android.PythonActivity

[android.add_permissions]

[android.archs]
arm64-v8a, armeabi-v7a

[android.allow_backup]
True

[android.backup_rules]

[android.private_storage]
True

[android.add_activites]

[android.add_services]

[android.add_broadcast_receivers]

[android.orientation]
portrait

[android.icon]

[android.presplash]

[android.adaptive_icon]

[android.permissions]
android.permission.CAMERA
android.permission.WRITE_EXTERNAL_STORAGE
android.permission.READ_EXTERNAL_STORAGE

[android.add_java_dir]

[android.add_compile_options]

[android.release_artifact]
aab

[android.debug_artifact]
apk

[android.accept_sdk_license]
True