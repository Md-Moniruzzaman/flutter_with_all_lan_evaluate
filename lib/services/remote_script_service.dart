import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RemoteScriptService {
  // --- Configuration ---
  // Replace with your actual API endpoint that serves the JS file.
  static final _scriptApiUrl = Uri.parse('https://api.example.com/invoice_processor.js');

  // Key for storing the script in local cache.
  static const _kInvoiceScriptCacheKey = 'invoice_processor_script';

  // Path to the local fallback script in your assets.
  static const _localFallbackScriptPath = 'assets/js/invoice_processor.js';

  /// Fetches the invoice processor script.
  ///
  /// It first tries to fetch the latest version from the API.
  /// If the API call fails (e.g., no internet), it tries to load from the local cache.
  /// If the cache is also empty, it falls back to the script bundled with the app in the assets folder.
  Future<String> getInvoiceProcessorScript() async {
    try {
      // 1. Try to fetch from the network API.
      final response = await http.get(_scriptApiUrl);
      if (response.statusCode == 200) {
        final script = response.body;
        // Cache the newly fetched script for future offline use.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kInvoiceScriptCacheKey, script);
        return script;
      }
    } catch (e) {
      // Network request failed. Proceed to cache/fallback.
      print('Network fetch failed: $e');
    }

    // 2. Try to load from local cache if network fails.
    final prefs = await SharedPreferences.getInstance();
    final cachedScript = prefs.getString(_kInvoiceScriptCacheKey);
    if (cachedScript != null && cachedScript.isNotEmpty) {
      return cachedScript;
    }

    // 3. As a last resort, load the fallback script from assets.
    return await rootBundle.loadString(_localFallbackScriptPath);
  }

  /// Removes the cached invoice processor script from local storage.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kInvoiceScriptCacheKey);
    print('Invoice processor script cache cleared.');
  }
}
