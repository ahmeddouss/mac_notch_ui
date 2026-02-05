import Cocoa
import FlutterMacOS

public class MacNotchUiPlugin: NSObject, FlutterPlugin {
  private var window: NSWindow?
  private var channel: FlutterMethodChannel?
  private var mouseMonitorTimer: Timer?
  private var isMouseInTriggerZone = false
  
  // Visual Effect View for Blur
  private var visualEffectView: NSVisualEffectView?
  private var shapeLayer: CAShapeLayer?

  // Store last known dimensions to restore view if removed
  private var lastWidth: Double = 130
  private var lastHeight: Double = 30
  private var lastRadius: Double = 10.0

  init(window: NSWindow?) {
      self.window = window
      super.init()
      startMouseMonitor()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mac_notch_ui", binaryMessenger: registrar.messenger)
    let instance = MacNotchUiPlugin(window: registrar.view?.window)
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "enableNotchMode":
        let args = call.arguments as? [String: Any]
        let width = args?["width"] as? Double ?? 130
        let height = args?["height"] as? Double ?? 30
        let blurIntensity = args?["blurIntensity"] as? Double ?? 1.0
        
        // Save dimensions
        self.lastWidth = width
        self.lastHeight = height
        
        enableNotchMode(width: width, height: height, blurIntensity: blurIntensity)
        result(nil)
    case "setWindowSize":
        guard let args = call.arguments as? [String: Any],
              let width = args["width"] as? Double,
              let height = args["height"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Width and height are required", details: nil))
            return
        }
        let radius = args["radius"] as? Double ?? 10.0
        
        // Save dimensions
        self.lastWidth = width
        self.lastHeight = height
        self.lastRadius = radius
        
        setWindowSize(width: width, height: height, radius: radius)
        result(nil)
    case "setBlurIntensity":
        guard let intensity = call.arguments as? Double else {
             result(FlutterError(code: "INVALID_ARGUMENTS", message: "Intensity required", details: nil))
             return
        }
        if let window = self.window ?? NSApp.windows.first {
             // If view is missing (was removed), use saved dimensions
             var frame = self.visualEffectView?.frame ?? NSRect(x: 0, y: 0, width: lastWidth, height: lastHeight)
             if frame.isEmpty {
                 frame = NSRect(x: 0, y: 0, width: lastWidth, height: lastHeight)
             }
             
             updateBlurView(layerFrame: frame, intensity: intensity, parentView: window.contentView)
             
             // Ensure shape is applied if view was just recreated
             if intensity > 0.01 {
                 updateNotchShape(width: lastWidth, height: lastHeight, bottomRadius: lastRadius)
             }
        }
        result(nil)
    case "animateWindow":
        guard let args = call.arguments as? [String: Any],
              let targetWidth = args["width"] as? Double,
              let targetHeight = args["height"] as? Double,
              let duration = args["duration"] as? Double else { // Duration in seconds
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments missing", details: nil))
            return
        }
        let targetRadius = args["radius"] as? Double ?? 10.0
        
        self.animateWindow(toWidth: targetWidth, toHeight: targetHeight, toRadius: targetRadius, duration: duration)
        result(nil)
    case "setScreenshareVisibility":
        guard let visible = call.arguments as? Bool else {
             result(FlutterError(code: "INVALID_ARGUMENTS", message: "Visible boolean required", details: nil))
             return
        }
        self.setScreenshareVisibility(visible: visible)
        result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Animation State
  private var animationTimer: Timer?
  private var animStartTime: TimeInterval = 0
  private var animDuration: TimeInterval = 0
  
  private var startWidth: Double = 0
  private var startHeight: Double = 0
  private var startRadius: Double = 0
  
  private var targetWidth: Double = 0
  private var targetHeight: Double = 0
  private var targetRadius: Double = 0

  private func animateWindow(toWidth: Double, toHeight: Double, toRadius: Double, duration: Double) {
      DispatchQueue.main.async {
          // Cancel existing
          self.animationTimer?.invalidate()
          
          guard let window = self.window ?? NSApp.windows.first else { return }
          let currentFrame = window.frame
          
          self.startWidth = currentFrame.width
          self.startHeight = currentFrame.height
          self.startRadius = self.lastRadius // Use last known radius as start
          
          self.targetWidth = toWidth
          self.targetHeight = toHeight
          self.targetRadius = toRadius
          
          self.animDuration = duration
          self.animStartTime = Date().timeIntervalSince1970
          
          // 60 FPS
          self.animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
              self?.onAnimationTick()
          }
      }
  }
  
  private func onAnimationTick() {
      let now = Date().timeIntervalSince1970
      let elapsed = now - animStartTime
      
      if elapsed >= animDuration {
          // Finish
          animationTimer?.invalidate()
          animationTimer = nil
          setWindowSize(width: targetWidth, height: targetHeight, radius: targetRadius)
          return
      }
      
      let t = elapsed / animDuration
      
      // Use EaseOutBack to match the "bounce" effect requested by user
      let c1 = 1.70158
      let c3 = c1 + 1
      let term = t - 1
      
      let curveValue = 1 + c3 * pow(term, 3) + c1 * pow(term, 2)
      
      let currentWidth = max(1.0, startWidth + (targetWidth - startWidth) * curveValue)
      let currentHeight = max(1.0, startHeight + (targetHeight - startHeight) * curveValue)
      let currentRadius = max(0.0, startRadius + (targetRadius - startRadius) * curveValue)
      
      setWindowSize(width: currentWidth, height: currentHeight, radius: currentRadius)
  }

  private func startMouseMonitor() {
      // Poll mouse position every 0.1s to detect top-center hover even if app is background
      mouseMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
          self?.checkMousePosition()
      }
  }
  
  private func checkMousePosition() {
      let mouseLoc = NSEvent.mouseLocation
      guard let screen = NSScreen.main else { return }
      let frame = screen.frame
      
      // Define Trigger Zone: Top 40 pixels, Center +/- 150 pixels
      let topThreshold = frame.maxY - 40
      let midX = frame.midX
      let xRange = (midX - 150)...(midX + 150)
      
      let inZone = mouseLoc.y > topThreshold && xRange.contains(mouseLoc.x)
      
      if inZone != isMouseInTriggerZone {
          isMouseInTriggerZone = inZone
          // Notify Flutter
          channel?.invokeMethod("onHoverZone", arguments: inZone)
      }
  }

  private func enableNotchMode(width: Double, height: Double, blurIntensity: Double) {
      DispatchQueue.main.async {
      // Use the registered window or fallback to the first window
          guard let targetWindow = self.window ?? NSApp.windows.first else { return }
          
          // Apply Notch-like window settings based on window type
          var styleMask: NSWindow.StyleMask = [.borderless, .fullSizeContentView]
          
          if targetWindow is NSPanel {
              styleMask.insert([.nonactivatingPanel, .utilityWindow, .hudWindow])
          }
          
          targetWindow.styleMask = styleMask
          
          // Make transparent
          targetWindow.isOpaque = false
          targetWindow.backgroundColor = .clear
          
          // Level: Status bar (above normal windows)
          targetWindow.level = .statusBar
          
          // No Shadow
          targetWindow.hasShadow = false
          
          // Collection Behavior
          targetWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
          
          // Configure Blur
          self.updateBlurView(layerFrame: NSRect(x: 0, y: 0, width: width, height: height), 
                              intensity: blurIntensity, 
                              parentView: targetWindow.contentView)
          
          if let flutterViewController = targetWindow.contentViewController as? FlutterViewController {
              flutterViewController.backgroundColor = .clear
          }
          
          // Initial Size
          self.setWindowSize(width: width, height: height, radius: 10.0, window: targetWindow)
          
          targetWindow.orderFrontRegardless()
      }
  }
    
    // Core logic to Create, Update, or Remove the blur view safely
    private func updateBlurView(layerFrame: NSRect, intensity: Double, parentView: NSView?) {
        guard let parentView = parentView else { return }
        
        let shouldBeVisible = intensity > 0.01
        
        // Remove if near zero intensity
        if !shouldBeVisible {
            self.visualEffectView?.removeFromSuperview()
            self.visualEffectView = nil
            self.shapeLayer = nil
            return
        }
        
        // Ensure View Exists
        let blurView: NSVisualEffectView
        if let existing = self.visualEffectView {
            blurView = existing
            if layerFrame != .zero { blurView.frame = layerFrame }
        } else {
             // Create new
            blurView = NSVisualEffectView(frame: layerFrame)
            blurView.blendingMode = .behindWindow
            blurView.state = .active
            blurView.wantsLayer = true
            
            // Mask
            let mask = CAShapeLayer()
            blurView.layer?.mask = mask
            self.shapeLayer = mask
            
            parentView.addSubview(blurView, positioned: .below, relativeTo: nil)
            self.visualEffectView = blurView
        }
        
        // Use standard HUD material for glass effect
        blurView.material = .hudWindow
        
        // Maps intensity to alpha
        blurView.alphaValue = CGFloat(intensity)
    }
  
  private func setWindowSize(width: Double, height: Double, radius: Double, window: NSWindow? = nil) {
      DispatchQueue.main.async {
          guard let targetWindow = window ?? self.window ?? NSApp.windows.first,
                let screen = NSScreen.main else { return }
          
          let screenFrame = screen.frame
          let newOriginX = screenFrame.minX + (screenFrame.width - width) / 2
          let newOriginY = screenFrame.maxY - height
          
          let newFrame = NSRect(x: newOriginX, y: newOriginY, width: width, height: height)
          
          // Update Window Frame
          targetWindow.setFrame(newFrame, display: false, animate: false)
          
          // Update Visual Effect View Frame
          if let blurView = self.visualEffectView {
              blurView.frame = targetWindow.contentView?.bounds ?? NSRect(x: 0, y: 0, width: width, height: height)
              
              // Update Mask
              self.updateNotchShape(width: width, height: height, bottomRadius: radius)
          }
      }
  }
    
    private func updateNotchShape(width: Double, height: Double, bottomRadius: Double) {
        guard let shapeLayer = self.shapeLayer else { return }
        
        let path = CGMutablePath()
        let topRadius = bottomRadius > 15 ? bottomRadius - 5 : 5
        
        // Logic replicated from NotchClipper (Top-Left origin logic)
        // We will construct it as if origin is Top-Left, then flip Y.
        
        // Coordinate system note:
        // Flutter (0,0) is top-left.
        // CAShapeLayer (customary) matching view logic: (0,0) is bottom-left?
        // Actually, let's construct it using standard CG logic and flip with transform.
        
        // rect.left = 0, rect.top = 0 (in Flutter local coords)
        // rect.width = width, rect.height = height
        
        // Start from top left corner (0,0)
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Top left inner curve
        // Control (topRadius, 0), End (topRadius, topRadius)
        path.addQuadCurve(to: CGPoint(x: topRadius, y: topRadius), control: CGPoint(x: topRadius, y: 0))
        
        // Left vertical line
        path.addLine(to: CGPoint(x: topRadius, y: height - bottomRadius))
        
        // Bottom left corner
        // Control (topRadius, height), End (topRadius + bottomRadius, height)
        path.addQuadCurve(to: CGPoint(x: topRadius + bottomRadius, y: height), control: CGPoint(x: topRadius, y: height))
        
        // Bottom horizontal line
        path.addLine(to: CGPoint(x: width - topRadius - bottomRadius, y: height))
        
        // Bottom right corner
        // Control (width - topRadius, height), End (width - topRadius, height - bottomRadius)
        path.addQuadCurve(to: CGPoint(x: width - topRadius, y: height - bottomRadius), control: CGPoint(x: width - topRadius, y: height))
        
        // Right vertical line
        path.addLine(to: CGPoint(x: width - topRadius, y: topRadius))
        
        // Top right inner curve
        // Control (width - topRadius, 0), End (width, 0)
        path.addQuadCurve(to: CGPoint(x: width, y: 0), control: CGPoint(x: width - topRadius, y: 0))
        
        // Close
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        
        // Apply Transform to flip Y for Native View (Bottom-Left origin)
        // Flutter y=0 corresponds to Native y=height.
        // Flutter y=height corresponds to Native y=0.
        // T(x, y) = (x, height - y)
        // Or scaling y by -1 and translating.
        
        var transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -CGFloat(height))
        
        // Note: CAShapeLayer path usage depends on layer geometry.
        // If the layer bounds are (0,0,w,h) and not flipped.
        // Let's assume standard behavior.
        
        if let transformedPath = path.copy(using: &transform) {
            shapeLayer.path = transformedPath
        } else {
            // Fallback
             shapeLayer.path = path
        }
    }

    private func setScreenshareVisibility(visible: Bool) {
        if #available(macOS 12.0, *) {
            DispatchQueue.main.async {
                guard let window = self.window ?? NSApp.windows.first else { return }
                // .none means hidden from capture
                // .readOnly means visible in capture (default behavior)
                window.sharingType = visible ? .readOnly : .none
            }
        }
    }
}
