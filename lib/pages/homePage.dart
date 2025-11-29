import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_js/flutter_js.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  String _jsResult = 'Press the button to evaluate JS from API';
  JavascriptRuntime? _jsRuntime;
  int a = 10;
  int b = 8;
  @override
  void initState() {
    super.initState();
    _jsRuntime = getJavascriptRuntime();
  }

  @override
  void dispose() {
    _jsRuntime?.dispose();
    super.dispose();
  }

  Future<void> evaluateJsFromApi() async {
    print('evaluateJsFromApi called');
    setState(() {
      _jsResult = 'Loading...';
    });

    try {
      // 1. Fetch JS code from an API.
      // Replace with your actual API endpoint.
      // For this example, we'll use a mock response that returns a simple JS function.
      // final response = await http.get(Uri.parse('https://your-api.com/get-js-code'));
      // final jsCode = response.body;

      // Mocking the API response for demonstration purposes.
      // This JS code defines a function and immediately calls it.
      var jsCode = "(() => { return `The sum is ${a + b}`; })();";
      // var val = jsCode.replaceAll('a', a.toString()).replaceAll('b', b.toString());

      // 2. Evaluate the JavaScript code.
      final result = _jsRuntime?.evaluate(jsCode);

      print(result?.stringResult);

      // 3. Update the UI with the result.
      setState(() {
        _jsResult = result?.stringResult ?? 'No result from JS';
      });
    } catch (e) {
      setState(() {
        _jsResult = 'Error evaluating JS: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JS Evaluator'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_jsResult, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          a = 20;
          b = 30;
          evaluateJsFromApi();
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
