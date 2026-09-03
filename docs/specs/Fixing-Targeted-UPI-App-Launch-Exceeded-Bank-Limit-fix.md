# Spec: Fixing Targeted UPI App Launch + "Exceeded Bank Limit" Payment Failures
### Root-cause analysis of two persistent bugs, for the implementing agent
### Companion to `fampay-dev-payment-workaround.md` and `upi_detector_service.dart`

---

## 0. Summary — two unrelated bugs, both with concrete fixes

| Bug | Root cause | Fix effort |
|---|---|---|
| 1. Tapping PhonePe/FamPay/etc. still opens Google Pay | **Wrong package name for FamPay** (`com.famtechnology.fampay` doesn't exist — real one is `com.fampay.in`) + **no real on-device detection** (the app shows all four apps regardless of what's installed) + **silent untargeted fallback** when a targeted launch fails | Small, contained — Section 2 |
| 2. GPay shows "exceeded bank limit" on a ₹4 payment with no real limit | **Receiver VPA is a minor/teen FamPay PPI wallet**, which carries RBI-mandated low monthly aggregate caps independent of per-transaction amount — unrelated to your app being unpublished | Not a code fix — a receiver-account fix, Section 3 |

Neither of these is what your "latest iteration" writeup diagnosed. The `intent.setPackage()` MethodChannel approach in `MainActivity.kt` is architecturally correct and is genuinely the industry-standard pattern — the problem isn't that pattern, it's that the pieces feeding into it are wrong. Don't rebuild the native-channel approach again; fix what's actually broken.

---

## 1. Correcting the "why is `<queries>` needed" reasoning first

Your iteration's writeup frames the fix as being about `intent.setPackage()` bypassing Android's package-visibility restrictions. That's half right and worth being precise about, because it affects what you actually need to fix:

Per Android's own documentation on package visibility: **`startActivity()` does not require package visibility to start another app's activity — this is true for both implicit and explicit intents.** So `intent.setPackage("com.phonepe.app"); startActivity(intent)` was never going to be blocked by missing `<queries>` entries. That part of your diagnosis, while common, isn't actually why it wasn't working.

Where `<queries>` *does* matter is a different operation entirely: **checking whether an app is installed before you try to launch it** (`PackageManager.queryIntentActivities()` / `resolveActivity()`). Your current `getAvailableUpiApps()` doesn't do this check at all — it returns the hardcoded `knownUpiApps` list unconditionally:

```dart
static Future<List<UpiAppInfo>> getAvailableUpiApps() async {
  return knownUpiApps;  // ← always returns all 4, regardless of what's installed
}
```

This is the real Problem 1, and it's two layered bugs, not one.

---

## 2. Problem 1 — full root cause

### 2.1 Bug A: wrong FamPay package name

Your `knownUpiApps` constant has:
```dart
UpiAppInfo(
  name: 'FamApp UPI',
  packageName: 'com.famtechnology.fampay',   // ← this package does not exist
  ...
),
```

FamPay's real, Play-Store-verified Android package ID is **`com.fampay.in`** (confirmed directly from the Play Store listing URL: `play.google.com/store/apps/details?id=com.fampay.in`). `com.famtechnology.fampay` isn't a real installed package on any device, so every attempt to explicitly target it fails with `ActivityNotFoundException` inside your Kotlin code's `startActivity(intent)` call — this is caught by your `catch (e: Exception)` block, which calls `result.error("LAUNCH_FAILED", ...)`.

**Verify all four package names on an actual test device before trusting any of them, rather than trusting a hardcoded guess again:**
```bash
adb shell pm list packages | grep -iE "fampay|phonepe|paytm|nbu.paisa"
```
This will print the *actual* installed package IDs verbatim — use exactly what it prints, don't re-guess.

### 2.2 Bug B: the app never checks whether the target is actually installed

Even with the correct package name, your payment screen shows **all four apps unconditionally** — PhonePe and Paytm entries render and are tappable whether or not those apps are actually on the device. On a typical dev/test phone that only has GPay + FamPay installed (matching what your screenshots show), tapping "PhonePe" will *always* fail the targeted launch, because PhonePe genuinely isn't there — this isn't a bug to fix with better intent-flags, it's a UI bug: **you're offering the user a choice that doesn't exist on their device.**

### 2.3 Bug C: silent fallback to an untargeted intent masks both A and B

This is the part that actually produces the specific symptom you're seeing ("no matter what I tap, GPay opens"). Look at the end of `launchUpiPayment`:

```dart
// 1. Primary path: Native Android Intent.setPackage() launcher
if (Platform.isAndroid) {
  try {
    final success = await _nativeChannel.invokeMethod<bool>('launchUpiApp', {...});
    if (success == true) return true;
  } catch (e) {
    debugPrint('[UPI Native] Direct package launch note for $specificPackage: $e');
    // ← falls through silently, specificPackage is now discarded
  }
}

// 2. Fallback path: url_launcher — note this uses the bare `uri`,
//    which has NO package restriction on it at all
final uri = Uri.parse(upiUriString);
final success = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
```

When the targeted native launch fails (for either reason above), execution falls through to a **generic, untargeted** `upi://pay?...` intent with no `setPackage()` applied. Android then resolves that implicit intent using its own normal disambiguation logic — if there's only one UPI-capable app installed, or if one is set as the device's preferred handler, that's what opens, **regardless of which app the user actually tapped in your UI.** That's exactly "I tap FamPay, GPay opens" — the fallback silently substitutes a completely different, unrequested app instead of failing loudly.

This is the actual mechanism behind your screenshots: Image 1 (GPay, "exceeded bank limit") and Image 2 (a different app, generic "Pay" screen) are almost certainly two different fallback resolutions, not two successful *targeted* launches — the giveaway is that the underlying amount/payee/note are identical in both, which is exactly what you'd expect from the same untargeted `upi://pay?...` string being resolved differently by Android depending on which apps happened to be installed/default at the time.

### 2.4 The fix

**(a) Correct the package name catalog** — use only adb-verified real package names.

**(b) Add real on-device detection**, exposed through the same native channel (this operation genuinely does need the `<queries>` manifest block, unlike the launch call):

`AndroidManifest.xml`:
```xml
<manifest ...>
  <queries>
    <package android:name="com.google.android.apps.nbu.paisa.user" />
    <package android:name="com.phonepe.app" />
    <package android:name="net.one97.paytm" />
    <package android:name="com.fampay.in" />
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="upi" />
    </intent>
  </queries>
  ...
</manifest>
```

`MainActivity.kt` — add a detection method alongside the existing launcher:

```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.zippee.app/upi_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchUpiApp" -> {
                    // ... existing implementation, unchanged
                }
                "getInstalledUpiPackages" -> {
                    try {
                        val pm = packageManager
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
                        val resolveInfos = pm.queryIntentActivities(intent, 0)
                        val installedPackages = resolveInfos.map { it.activityInfo.packageName }
                        result.success(installedPackages)
                    } catch (e: Exception) {
                        result.error("DETECTION_FAILED", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
```

`upi_detector_service.dart` — replace the hardcoded return with a real query, and cache it for the session (per the earlier performance guidance — don't re-query on every rebuild):

```dart
class UpiDetectorService {
  static List<UpiAppInfo>? _cachedInstalledApps;

  /// Returns only the apps genuinely installed on this device, in
  /// knownUpiApps catalog order, plus the always-available "Any Other" entry.
  static Future<List<UpiAppInfo>> getAvailableUpiApps() async {
    if (_cachedInstalledApps != null) return _cachedInstalledApps!;

    List<String> installedPackages = [];
    if (Platform.isAndroid) {
      try {
        final result = await _nativeChannel.invokeMethod<List<dynamic>>(
          'getInstalledUpiPackages',
        );
        installedPackages = result?.cast<String>() ?? [];
      } catch (e) {
        debugPrint('[UPI] Detection failed, falling back to empty list: $e');
      }
    }

    final available = knownUpiApps.where((app) {
      if (app.packageName.isEmpty) return true; // "Any Other UPI App" always shown
      return installedPackages.contains(app.packageName);
    }).toList();

    _cachedInstalledApps = available;
    return available;
  }

  /// Call this once per payment session if you want to force a re-scan
  /// (e.g. user just installed a UPI app and returned to your screen).
  static void clearCache() => _cachedInstalledApps = null;
}
```

**(c) Stop silently falling back to an untargeted intent for named apps.** The fallback should only ever be used for the explicit "Any Other UPI App" entry (empty `packageName`, which is *supposed* to open the system chooser). For a named app the user specifically tapped, a failed targeted launch should surface an error, not silently substitute a different app:

```dart
static Future<bool> launchUpiPayment({
  required double amount,
  required String orderId,
  String payeeVpa = defaultReceiverVpa,
  String payeeName = defaultPayeeName,
  String? specificPackage,
}) async {
  final upiUriString = buildUpiUrl(amount: amount, orderId: orderId, payeeVpa: payeeVpa, payeeName: payeeName);

  if (Platform.isAndroid) {
    try {
      final success = await _nativeChannel.invokeMethod<bool>('launchUpiApp', {
        'uri': upiUriString,
        'packageName': specificPackage ?? '',
      });
      if (success == true) return true;
    } catch (e) {
      debugPrint('[UPI Native] launch failed for $specificPackage: $e');
      // Only fall through to untargeted resolution when the user picked
      // "Any Other UPI App" (empty package) — a named-app failure should
      // be reported, not silently redirected to a different app.
      if (specificPackage != null && specificPackage.isNotEmpty) {
        return false; // caller shows "App not available" — see payment_screen.dart change below
      }
    }
  }

  // Untargeted fallback — only reached for "Any Other UPI App" or non-Android
  final uri = Uri.parse(upiUriString);
  return await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

`payment_screen.dart` — handle the `false` result instead of assuming success:

```dart
void _handleUpiPay(double amount, UpiAppInfo app) async {
  final launched = await UpiDetectorService.launchUpiPayment(
    amount: amount,
    orderId: orderId,
    specificPackage: app.packageName,
  );

  if (!launched) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${app.name} isn\'t installed on this device')),
      );
    }
    return; // don't navigate to the confirming-payment screen for a launch that didn't happen
  }

  // ... existing controller.startPaymentFlow + navigation
}
```

With (a)+(b)+(c) together: the payment screen will only ever show apps genuinely on the device, tapping one will target it correctly via the (now-correct) explicit package intent, and a failure will be visible instead of silently opening an unrelated app.

---

## 3. Problem 2 — "Your money has not been debited. You've exceeded the bank limit for this payment."

### 3.1 Why "app not published" is not the cause

Google Play publication status has no bearing on NPCI/bank-side transaction decisioning. This decline message is a defined UPI/NPCI response rendered by the *payer's* app (Google Pay here) based on a decline code returned by the banking rails — it fires regardless of whether the *payee's* receiving app was published, sideloaded, or in debug. Rule this out as a variable.

### 3.2 The actual cause: your receiver account is a minor/teen PPI wallet, not a full bank account

You mentioned the receiving `@fam` VPA is registered under an **under-18 FamPay account**. This matters mechanically, not just as a compliance footnote:

- FamPay's own product description confirms its teen accounts require **both the teen and a parent to complete KYC** before the account is usable — this is consistent with it being a **Prepaid Payment Instrument (PPI)** under RBI's Master Direction on PPIs, not a regular full-KYC adult savings account. FamPay is explicitly marketed as UPI/card payments *without a bank account* for the 13–19 age bracket.
- RBI's PPI framework imposes **monthly aggregate loading/transaction caps** on these instruments that are independent of any single transaction's size. A ₹4 payment can be declined by the *issuing* bank/PPI operator not because ₹4 exceeds anything, but because the wallet's **cumulative monthly inbound total** (across all your repeated dev-testing transactions — every FamGateway test payment, every retry, every screenshot attempt) has already hit that cap. This produces exactly the symptom you're describing: the payer's own account is fine, the amount is trivially small, and it still fails — because the constraint is on the **receiving** side's aggregate cap, not the paying side or the single transaction.
- This also explains why the message is about a "bank limit" specifically rather than a generic "transaction declined" — GPay is surfacing the actual NPCI/issuer decline reason it received, which maps to a limit-exceeded code, not a fraud/risk block (those typically render differently, e.g. "for security reasons").

### 3.3 Fix

**For continued development/testing:** stop using the minor FamPay account as your receiver VPA for repeated test transactions. Use a **regular, full-KYC adult savings account's UPI ID** (yours or a team member's) as the dev receiver instead — standard full-KYC bank accounts carry RBI's much higher standard UPI limits (commonly cited as up to ₹1 lakh per transaction for P2P, higher for specific categories) and won't exhaust from routine dev testing the way a minor PPI wallet's monthly cap will.

**For the FamGateway "dev/demo" workaround specifically** (per the companion doc): you can keep using the FamPay `@fam` VPA for the actual demo/showcase moment, but budget for the fact that it has a real, low, RBI-mandated ceiling — don't run repeated test transactions against the same receiver account in the days/hours before a demo, or you risk it being capped out exactly when you need it to work.

**Longer-term (ties back to the compliance section of the earlier payment-collection spec):** a minor's PPI wallet was never a viable receiver account for a real marketplace collecting from many customers regardless of this specific bug — this reinforces that same conclusion, just via a very concrete, reproducible failure mode instead of an abstract compliance argument.

---

## 4. How production apps (Blinkit, Swiggy, Juspay, Razorpay) actually avoid both of these

- They perform **real on-device detection** before ever showing a "pay with X" option — an app that isn't installed simply never appears as a choice, so there's no failure mode to hit in the first place.
- Their receiver-side VPA is always a proper **merchant collection account** provisioned through a licensed Payment Aggregator (see the earlier `payment-collection-recommended-upi.md` doc), which carries commercial-grade limits, not a personal or minor PPI wallet's consumer-grade caps — so Problem 2's failure mode structurally can't occur for them.
- Failed targeted launches are treated as real failures with user-facing messaging ("app not available," "try another payment method"), never silently substituted with a different app the user didn't choose — silent substitution is a trust-breaking UX pattern no production payment flow uses deliberately.


