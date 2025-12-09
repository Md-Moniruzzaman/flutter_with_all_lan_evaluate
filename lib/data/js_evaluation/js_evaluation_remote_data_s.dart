import 'package:flutter_js/flutter_js.dart';

class JsEvaluationRemoteDataS {}

class JsEvaluationRemoteDataSource {
  final JavascriptRuntime _jsRuntime;

  JsEvaluationRemoteDataSource(this._jsRuntime);

  Future<String> evaluateJsCode(String jsCode) async {
    try {
      final result = _jsRuntime.evaluate(jsCode);
      return result.stringResult ?? 'No result from JS';
    } catch (e) {
      throw Exception('Error evaluating JavaScript: $e');
    }
  }
}
