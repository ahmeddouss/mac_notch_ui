import 'package:flutter/material.dart';
import 'package:mac_notch_ui/mac_notch_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _macNotchUiPlugin = MacNotchUi();
  double _blurIntensity = 1.0;
  double _opacity = 0.45;
  Color _baseColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _initNotch();
  }

  Future<void> _initNotch() async {
    // Initialize the window mode to be transparent, full screen, and waiting for notch events
    await _macNotchUiPlugin.enableNotchMode(blurIntensity: _blurIntensity);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: MacNotchWidget(
          blurIntensity: _blurIntensity,
          color: _baseColor,
          blurOpacity: _opacity,
          builder: (close) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Notch Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  
                  // Color Picker (Simple Cycle)
                   Row(
                      children: [
                          const Text('Color: ', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text(_baseColor == Colors.black ? "BLACK" : "BLUE", style: const TextStyle(color: Colors.yellow, fontSize: 12)),
                          const Spacer(),
                          SizedBox(
                            height: 24,
                            child: ElevatedButton(
                                onPressed: () {
                                    setState(() {
                                        _baseColor = _baseColor == Colors.black ? Colors.blue.shade900 : Colors.black;
                                    });
                                },
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                child: const Text('Change', style: TextStyle(fontSize: 10)),
                            ),
                          )
                      ],
                  ),
                  
                  // Blur Intensity Slider
                  Row(
                      children: [
                          const Text('Blur: ', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(trackHeight: 2.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0)),
                                child: Slider(
                                    value: _blurIntensity,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: (v) => setState(() => _blurIntensity = v),
                                    activeColor: Colors.purpleAccent,
                                ),
                              )
                          ),
                          Text(_blurIntensity.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                  ),

                  // Opacity Slider
                  Row(
                      children: [
                          const Text('Opacity: ', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(trackHeight: 2.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0)),
                                child: Slider(
                                    value: _opacity,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: (v) => setState(() => _opacity = v),
                                    activeColor: Colors.blue,
                                ),
                              )
                          ),
                          Text(_opacity.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                  ),
                  
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: close,
                      child: const Text('Close', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
