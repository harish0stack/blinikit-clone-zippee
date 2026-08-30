# proguard-rules.pro
# Flutter + Supabase + Riverpod production ProGuard rules
# These prevent R8 from stripping classes that are accessed via reflection or JNI.

# ─── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ─── Kotlin ───────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**

# ─── Supabase / Ktor (HTTP client internals) ──────────────────────────────────
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# ─── OkHttp (used by Supabase Realtime WebSocket) ────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# ─── JSON serialization (used by Supabase PostgREST responses) ────────────────
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod

# ─── Hive (local cache) ───────────────────────────────────────────────────────
-keep class com.hivedb.** { *; }
-dontwarn com.hivedb.**

# ─── Razorpay (Phase 5) ───────────────────────────────────────────────────────
# -keep class com.razorpay.** { *; }  ← uncomment in Phase 5

# ─── Firebase / FCM (Phase 7) ────────────────────────────────────────────────
# -keep class com.google.firebase.** { *; }  ← uncomment in Phase 7

# ─── General safety rules ────────────────────────────────────────────────────
-keepattributes InnerClasses
-keep class **.R$* { *; }
