import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'notch_shape.dart';

import 'package:mac_notch_ui/mac_notch_ui.dart';

class MacNotchWidget extends StatefulWidget {
  final Widget Function(VoidCallback close)? builder;
  final Widget? child;
  final Size closedSize;
  final Size openSize;
  final double closedRadius;
  final double openRadius;
  final Color color;
  final double blurIntensity;
  final double blurOpacity;

  const MacNotchWidget({
    Key? key,
    this.builder,
    this.child,
    this.closedSize = const Size(130, 30),
    this.openSize = const Size(400, 200),
    this.closedRadius = 10,
    this.openRadius = 24,
    this.color = const Color(0x73000000), // Colors.black45 roughly
    this.blurIntensity = 1.0,
    this.blurOpacity = 1.0,
  }) : super(key: key);

  @override
  State<MacNotchWidget> createState() => _MacNotchWidgetState();
}

class _MacNotchWidgetState extends State<MacNotchWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Size> _sizeAnimation;
  late Animation<double> _radiusAnimation;
  
  bool _isOpen = false;
  StreamSubscription<bool>? _hoverSubscription;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 600),
    );
    
    _updateAnimations();

    _controller.addListener(_onAnimationTick);
    
    _listenToHoverZone();
  }
  
  @override
  void didUpdateWidget(MacNotchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate if size/radius target changed
    if (oldWidget.closedSize != widget.closedSize || 
        oldWidget.openSize != widget.openSize ||
        oldWidget.closedRadius != widget.closedRadius ||
        oldWidget.openRadius != widget.openRadius) {
      _updateAnimations();

      // IF we are currently idle (not animating), we might need to snap the native window 
      // to the new size immediately.
      if (!_controller.isAnimating) {
        if (_isOpen) {
             // If open and openSize changed, update strictly to openSize
            MacNotchUi().setWindowSize(
                widget.openSize.width, 
                widget.openSize.height,
                radius: widget.openRadius
            );
        } else {
            // If closed and closedSize changed, update strictly to closedSize
            MacNotchUi().setWindowSize(
                widget.closedSize.width, 
                widget.closedSize.height,
                radius: widget.closedRadius
            );
        }
      }
    }
    
    // Update Blur Intensity Immediately if changed
    if (oldWidget.blurIntensity != widget.blurIntensity) {
        MacNotchUi().setBlurIntensity(widget.blurIntensity);
    }
  }

  void _updateAnimations() {
      // Curve for Size/Radius (can overshoot)
      final movementCurve = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
      
      _sizeAnimation = Tween<Size>(
          begin: widget.closedSize, 
          end: widget.openSize
      ).animate(movementCurve);
      
      _radiusAnimation = Tween<double>(
          begin: widget.closedRadius, 
          end: widget.openRadius
      ).animate(movementCurve);
      
      // Curve for Opacity (Strictly 0.0 -> 1.0)
      _animation = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      );
  }

  void _onAnimationTick() {
      // Sync Native Window Size and Radius
      MacNotchUi().setWindowSize(
          _sizeAnimation.value.width, 
          _sizeAnimation.value.height,
          radius: _radiusAnimation.value
      );
  }

  void _listenToHoverZone() {
    _hoverSubscription = MacNotchUi().onHoverZone.listen((inZone) {
      if (inZone && !_isOpen) {
        // Expand
        // We do NOT call enableNotchMode here anymore to avoid visual flickering.
        // setWindowSize is sufficient as long as mode was enabled once.
        setState(() {
          _isOpen = true;
          _controller.forward();
        });
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _hoverSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine effective color
    // If user provides opacity, apply it to the color's alpha or override it?
    // User requested "prop for opacity". 
    // We will multiply the provided color's opacity by blurOpacity.
    final effectiveColor = widget.color.withOpacity(
        (widget.color.opacity * widget.blurOpacity).clamp(0.0, 1.0)
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentSize = _sizeAnimation.value;
        final currentRadius = _radiusAnimation.value;
        
        
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
                alignment: Alignment.center,
                child: Opacity(
                  opacity: _animation.value, // Fade in content
                  child: OverflowBox(
                      minWidth: widget.openSize.width, 
                      maxWidth: widget.openSize.width,
                      minHeight: widget.openSize.height,
                      maxHeight: widget.openSize.height,
                      child: widget.builder != null 
                          ? widget.builder!(_close)
                          : widget.child
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
