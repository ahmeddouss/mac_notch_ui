import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  double _openWidth = 430.0;
  double _openHeight = 400.0; // Adjusted for a cleaner initial look
  double _openRadius = 24.0;
  
  // New Toggles
  bool _isExpanded = false;
  bool _isBigger = false;
  bool _showBlur = true;
  bool _isBlack = true;
  bool _isDarkMode = true;
  bool _showAdvanced = false;
  bool _showInScreenshare = true;

  final double _closedNotchWidth = 130.0;
  final double _closedNotchHeight = 30.0;

  @override
  void initState() {
    super.initState();
    _initNotch();
  }

  Future<void> _initNotch() async {
    // Initialize the window mode to be transparent, full screen, and waiting for notch events
    await _macNotchUiPlugin.enableNotchMode(blurIntensity: _blurIntensity);
    await _macNotchUiPlugin.setScreenshareVisibility(_showInScreenshare);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: MacNotchWidget(
          isOpen: _isExpanded,
          onExpansionChanged: (v) => setState(() => _isExpanded = v),
          closedSize: const Size(130, 30),
          openSize: _isBigger 
              ? Size(_openWidth + 100, _openHeight + 150) 
              : Size(_openWidth, _openHeight),
          openRadius: _openRadius,
          blurIntensity: _showBlur ? _blurIntensity : 0.0,
          color: _isDarkMode ? Colors.black : (_isBlack ? Colors.white.withOpacity(0.12) : Colors.white),
          blurOpacity: _isBlack ? 1 : _opacity,
          builder: (close) {
            final textColor = _isDarkMode ? Colors.white : Colors.black;
            final surfaceColor = _isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
            return Stack(
              children: [
                // Main Content
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 45, 20, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App View (Title)
                      const SizedBox(height: 20),

                      // Quick Controls Wrap
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildIconButton(
                            _isBigger ? CupertinoIcons.fullscreen_exit : CupertinoIcons.fullscreen,
                            "Size",
                            () => setState(() => _isBigger = !_isBigger),
                            _isBigger,
                          ),
                          _buildIconButton(
                            _showBlur ? CupertinoIcons.drop_fill : CupertinoIcons.drop,
                            "Blur",
                            () => setState(() => _showBlur = !_showBlur),
                            _showBlur,
                          ),
                          _buildIconButton(
                            _isDarkMode ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                            "Theme",
                            () => setState(() => _isDarkMode = !_isDarkMode),
                            _isDarkMode,
                          ),
                          _buildIconButton(
                            _isBlack ? CupertinoIcons.square_fill : CupertinoIcons.square_on_square,
                            "Base",
                            () => setState(() => _isBlack = !_isBlack),
                            _isBlack,
                          ),
                          _buildIconButton(
                            CupertinoIcons.slider_horizontal_3,
                            "Config",
                            () => setState(() => _showAdvanced = !_showAdvanced),
                            _showAdvanced,
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: textColor.withOpacity(0.1)),
                          ),
                          child: _showAdvanced 
                            ? Column(
                                children: [
                                  _buildSliderRow('Blur', _blurIntensity, 0, 1, Colors.purpleAccent, (v) => setState(() => _blurIntensity = v), _blurIntensity.toStringAsFixed(1)),
                                  const SizedBox(height: 10),
                                  _buildSliderRow('Opac', _opacity, 0, 1, Colors.blueAccent, (v) => setState(() => _opacity = v), _opacity.toStringAsFixed(1)),
                                  const SizedBox(height: 10),
                                  _buildSliderRow('Radius', _openRadius, 0, 50, Colors.cyanAccent, (v) => setState(() => _openRadius = v), '${_openRadius.round()}px'),
                                  const SizedBox(height: 10),
                                  _buildSliderRow('Width', _openWidth, 200, 600, Colors.greenAccent, (v) => setState(() => _openWidth = v), '${_openWidth.round()}px'),
                                  const SizedBox(height: 10),
                                  _buildSliderRow('Height', _openHeight, 100, 500, Colors.orangeAccent, (v) => setState(() => _openHeight = v), '${_openHeight.round()}px'),
                                  const SizedBox(height: 10),
                                  _buildSwitchRow('Screenshare Visible', _showInScreenshare, (v) {
                                    setState(() => _showInScreenshare = v);
                                    _macNotchUiPlugin.setScreenshareVisibility(v);
                                  }),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(Icons.apple, color: textColor.withOpacity(0.9), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Control Center',
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Customise your macOS notch experience with precision. Adjust blur intensity, layer opacity, corner radius, and dimensions in real-time to match your desktop aesthetic. Created with passion by Ahmed Douss.',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Bottom Label
                      Text(
                        'macOS Notch UI • v1.0.0',
                        style: TextStyle(
                          color: textColor.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Top Left Close Button
                Positioned(
                  top: 12,
                  left: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isExpanded = false);
                      close();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Top Right More Button
                Positioned(
                  top: 12,
                  right: 40,
                  child: GestureDetector(
                    onTap: () {
                      // Open link logic
                      print("Opening more info link: https://github.com/notch-ui");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'More',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap, bool isActive) {
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blueAccent : textColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? Colors.blueAccent : textColor.withOpacity(0.05),
              ),
            ),
            child: Icon(
              icon, 
              color: isActive ? Colors.white : textColor, 
              size: 20
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label, 
            style: TextStyle(
              color: textColor.withOpacity(0.5), 
              fontSize: 10, 
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    Color activeColor,
    ValueChanged<double> onChanged,
    String displayValue, {
    int? divisions,
  }) {
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 360, // Fixed logical width for the row to layout against
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                label,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0, elevation: 1),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                  activeTrackColor: activeColor,
                  inactiveTrackColor: textColor.withOpacity(0.1),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 45,
              child: Text(
                displayValue,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 360,
        child: Row(
          children: [
             SizedBox(
               width: 150,
               child: Text(
                 label, 
                 style: TextStyle(
                   color: textColor.withOpacity(0.8), 
                   fontSize: 13, 
                   fontWeight: FontWeight.w500
                 )
               ),
             ),
             const Spacer(),
             CupertinoSwitch(
               value: value, 
               onChanged: onChanged,
               activeColor: Colors.blueAccent,
             ),
          ],
        ),
      ),
    );
  }
}
