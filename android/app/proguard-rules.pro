# flutter_local_notifications paketinin çökmesini engellemek için Gson tiplerini koru
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken