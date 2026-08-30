import 'package:flutter/widgets.dart';

const double kMobileBreakpoint = 720.0;
const double kDesktopBreakpoint = 1024.0;

enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(double width) {
  if (width >= kDesktopBreakpoint) return DeviceType.desktop;
  if (width >= kMobileBreakpoint) return DeviceType.tablet;
  return DeviceType.mobile;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  DeviceType get deviceType => getDeviceType(screenWidth);
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isWide => screenWidth >= kDesktopBreakpoint;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final type = context.deviceType;
    return builder(context, type);
  }
}

/// Helper to get adaptive column count for grids.
int getAdaptiveCrossAxisCount(BuildContext context, {int mobile = 3, int tablet = 4, int desktop = 6}) {
  final w = context.screenWidth;
  if (w >= 1600) return desktop + 1;
  if (w >= kDesktopBreakpoint) return desktop;
  if (w >= kMobileBreakpoint) return tablet;
  return mobile;
}

double getAdaptiveAspectRatio(BuildContext context, {double mobile = 0.62, double desktop = 0.65}) {
  return context.isDesktop ? desktop : mobile;
}
