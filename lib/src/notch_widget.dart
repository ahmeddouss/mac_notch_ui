import 'dart:async';

import 'package:flutter/material.dart';



import 'package:mac_notch_ui/mac_notch_ui.dart';

class PositionedSize {
  final Size size;
  final double radius;

  PositionedSize(this.size, this.radius);

  static PositionedSize lerp(PositionedSize a, PositionedSize b, double t) {
    return PositionedSize(
      Size.lerp(a.size, b.size, t)!,
      lerpDouble(a.radius, b.radius, t)!,
    );
  }
}

class PositionedSizeTween extends Tween<PositionedSize> {
  PositionedSizeTween({super.begin, super.end});

  @override
  PositionedSize lerp(double t) => PositionedSize.lerp(begin!, end!, t);
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}

/// A widget that simulates the macOS notch UI.
///
/// This widget handles the animation and rendering of the notch.
/// It works in conjunction with the [MacNotchUi] plugin to synchronize
/// the native window size and position.
class MacNotchWidget extends StatefulWidget {
  /// Builder function for the content of the notch when open.
  ///
  /// The [close] callback can be called to close the notch programmatically.
  final Widget Function(VoidCallback close)? builder;

  /// Child widget to display in the notch.
  ///
  /// Used if [builder] is not provided.
  final Widget? child;
  /// The size of the notch when closed. Defaults to `Size(130, 30)`.
  final Size closedSize;

  /// The size of the notch when open. Defaults to `Size(400, 200)`.
  final Size openSize;

  /// The border radius when closed. Defaults to `10`.
  final double closedRadius;

  /// The border radius when open. Defaults to `24`.
  final double openRadius;

  /// The background color of the notch. Defaults to slightly transparent black.
  final Color color;

  /// The intensity of the blur effect. Defaults to `1.0`.
  final double blurIntensity;

  /// The opacity of the blur effect. Defaults to `1.0`.
  final double blurOpacity;

  const MacNotchWidget({
    super.key,
    this.builder,
    this.child,
    this.closedSize = const Size(130, 30),
    this.openSize = const Size(400, 200),
    this.closedRadius = 10,
    this.openRadius = 24,
    this.color = const Color(0x73000000), // Colors.black45 roughly
    this.blurIntensity = 1.0,
    this.blurOpacity = 1.0,
  /// Whether the notch is currently open.
  ///
  /// If provided, this widget becomes a controlled component.
  this.isOpen,

  /// Callback when the expansion state changes.
  this.onExpansionChanged,
  });

  /// Whether the notch is currently open.
  final bool? isOpen;

  /// Callback when the expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<MacNotchWidget> createState() => _MacNotchWidgetState();
}

class _MacNotchWidgetState extends State<MacNotchWidget> with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late AnimationController _sizeController;
  late Animation<double> _opacityAnimation;
  late Animation<PositionedSize> _sizeAnimation;
  
  bool _isOpen = false;
  bool _useBounce = true; // Use bounce for open/close, smooth for slider adjustments
  StreamSubscription<bool>? _hoverSubscription;

  Size _startSize = const Size(130, 30);
  Size _targetSize = const Size(130, 30);
  double _startRadius = 10;
  double _targetRadius = 10;
  PositionedSize? _lastSentSize;
  bool _drivingNativeAnimation = false;

  @override
  void initState() {
    super.initState();
    
    _opacityController = AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 500),
    );

    _sizeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
    );
    
    _startSize = widget.closedSize;
    _targetSize = widget.isOpen == true ? widget.openSize : widget.closedSize;
    _startRadius = widget.closedRadius;
    _targetRadius = widget.isOpen == true ? widget.openRadius : widget.closedRadius;

    _updateAnimations();

    _sizeController.addListener(_onAnimationTick);
    
    if (widget.isOpen == true) {
      _isOpen = true;
      _opacityController.value = 1.0;
      _sizeController.value = 1.0;
    }
    
    _listenToHoverZone();
  }
  
  @override
  void didUpdateWidget(MacNotchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate if size/radius target changed while in that state
    bool sizeChanged = oldWidget.closedSize != widget.closedSize || 
                       oldWidget.openSize != widget.openSize;
    bool radiusChanged = oldWidget.closedRadius != widget.closedRadius || 
                         oldWidget.openRadius != widget.openRadius;

    if (sizeChanged || radiusChanged) {
      _drivingNativeAnimation = false; // Take back control for parameter updates
      _startSize = _sizeAnimation.value.size;
      _targetSize = _isOpen ? widget.openSize : widget.closedSize;
      _startRadius = _sizeAnimation.value.radius;
      _targetRadius = _isOpen ? widget.openRadius : widget.closedRadius;
      
      _useBounce = true; // Use bounce for these transitions
      _updateAnimations();
      _sizeController.forward(from: 0);
    }
    
    // Handle external isOpen change
    if (widget.isOpen != null && widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen!) {
        _expand(notify: false);
      } else {
        _close(notify: false);
      }
    }
    
    // Update Blur Intensity Immediately if changed
    if (oldWidget.blurIntensity != widget.blurIntensity) {
        MacNotchUi().setBlurIntensity(widget.blurIntensity);
    }
  }

  void _expand({bool notify = true}) {
    if (!_isOpen) {
      if (notify) {
        widget.onExpansionChanged?.call(true);
      }
      setState(() {
        _isOpen = true;
        _useBounce = true;
        _drivingNativeAnimation = true; // Let Native handle the driver seat
        
        _startSize = _sizeAnimation.value.size;
        _targetSize = widget.openSize;
        _startRadius = _sizeAnimation.value.radius;
        _targetRadius = widget.openRadius;
        
        _updateAnimations();
        _sizeController.forward(from: 0);
        _opacityController.forward();
        
        // Trigger Native Animation
        MacNotchUi().animateWindowSize(
            widget.openSize.width, 
            widget.openSize.height,
            radius: widget.openRadius,
            duration: 0.5
        );
        
        // Return control after animation
        Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isOpen) _drivingNativeAnimation = false;
        });
      });
    }
  }

  Future<void> _close({bool notify = true}) async {
    if (_isOpen) {
      if (notify) {
        widget.onExpansionChanged?.call(false);
      }
      
      // 1. Hide content first
      await _opacityController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      
      if (!mounted) return;

      // 2. Then resize notch
      setState(() {
        _isOpen = false;
        _useBounce = true; 
        _drivingNativeAnimation = true; // Let Native handle the driver seat
        
        _startSize = _sizeAnimation.value.size;
        _targetSize = widget.closedSize;
        _startRadius = _sizeAnimation.value.radius;
        _targetRadius = widget.closedRadius;

        _updateAnimations();
        _sizeController.forward(from: 0);
        
        // Trigger Native Animation
        MacNotchUi().animateWindowSize(
            widget.closedSize.width, 
            widget.closedSize.height,
            radius: widget.closedRadius,
            duration: 0.5
        );
        
        // Return control after animation
        Future.delayed(const Duration(milliseconds: 500), () {
             if (mounted && !_isOpen) _drivingNativeAnimation = false;
        });
      });
    }
  }

  void _updateAnimations() {
      // Use easeOutBack to match Native implementation (which now uses EaseOutBack)
      final curve = _useBounce ? Curves.easeOutBack : Curves.easeOut;
      final movementCurve = CurvedAnimation(parent: _sizeController, curve: curve);
      
      _sizeAnimation = PositionedSizeTween(
        begin: PositionedSize(_startSize, _startRadius),
        end: PositionedSize(_targetSize, _targetRadius),
      ).animate(movementCurve);
      
      _opacityAnimation = CurvedAnimation(
        parent: _opacityController,
        curve: Curves.easeOut,
      );
  }

  void _onAnimationTick() {
    // We keep this purely to drive internal state/radius updates in sync with native.
    // Native window update calls are REMOVED to prevent channel lag.
    if (!mounted) return;
    
    // Only send window size updates if NOT driven by native animation (e.g. slider updates)
    if (!_drivingNativeAnimation) {
        final current = _sizeAnimation.value;
        
        // Optimization: Avoid sending duplicate frames to native side
        if (_lastSentSize != null && 
            _lastSentSize!.size == current.size && 
            _lastSentSize!.radius == current.radius) {
          return;
        }
        _lastSentSize = current;
        
        MacNotchUi().setWindowSize(
            current.size.width, 
            current.size.height,
            radius: current.radius
        );
    }
  }

  void _listenToHoverZone() {
    _hoverSubscription = MacNotchUi().onHoverZone.listen((inZone) {
      if (inZone && !_isOpen) {
        _expand();
      }
    });
  }

  @override
  void dispose() {
    _hoverSubscription?.cancel();
    _opacityController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine effective color
    // If user provides opacity, apply it to the color's alpha or override it?
    // User requested "prop for opacity". 
    // We will multiply the provided color's opacity by blurOpacity.
    final effectiveColor = widget.color.withValues(
      alpha: (widget.color.a * widget.blurOpacity).clamp(0.0, 1.0),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_opacityController, _sizeController]),
      builder: (context, child) {
        final current = _sizeAnimation.value;

        final currentRadius = current.radius;
        
        
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            // We use the openSize's width/height as a "max" constraint or 
            // simply let it fill the parent (which is the window).
            // But since the window ITSELF is resizing via setWindowSize, 
            // we should just let this fill the window.
            // However, the Align widget might center it. 
            // Actually, we want the flutter view to fill the native window entirely.
            width: double.infinity,
            height: double.infinity,
            child: ClipPath(
              clipper: NotchClipper(bottomCornerRadius: currentRadius),
              child: Container(
                color: effectiveColor,
                alignment: Alignment.topCenter,
                  child: ClipRect(
                    child: Opacity(
                      opacity: _opacityAnimation.value, // Fade in content
                      child: widget.builder != null 
                          ? widget.builder!(_close)
                          : widget.child,
                    ),
                  ),
              ),
            ),
          ),
        );
      },
    );
  }
}
