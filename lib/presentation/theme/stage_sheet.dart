import 'package:flutter/material.dart';

import 'app_theme.dart';

enum StagePanelMode {
  /// Home: the panel takes its intrinsic height at the bottom; the stage
  /// fills the rest and extends behind the panel by [StagePanelLayout.overlap]
  /// (the pot tucks slightly behind the ritual panel, per Design 3).
  panelIntrinsic,

  /// Mood: the stage takes a clamped fraction of the height; the sheet fills
  /// the remainder and overlaps the stage.
  stageFraction,
}

/// Single-pass stage/panel composition (ADR: Sprint 5.1). No post-frame
/// measuring, responsive at any viewport and text scale.
class StagePanelLayout extends StatelessWidget {
  const StagePanelLayout({
    super.key,
    required this.mode,
    required this.stage,
    required this.panel,
  });

  static const double overlap = 28;

  /// The panel may never consume more than this share of the region, so the
  /// plant stage stays visible even at extreme text scales.
  static const double maxPanelFraction = 0.75;

  final StagePanelMode mode;
  final Widget stage;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _StagePanelDelegate(mode),
      children: [
        // Paint order: stage first, panel above it.
        LayoutId(id: _Slot.stage, child: stage),
        LayoutId(id: _Slot.panel, child: panel),
      ],
    );
  }
}

enum _Slot { stage, panel }

class _StagePanelDelegate extends MultiChildLayoutDelegate {
  _StagePanelDelegate(this.mode);

  final StagePanelMode mode;

  @override
  void performLayout(Size size) {
    const overlap = StagePanelLayout.overlap;

    switch (mode) {
      case StagePanelMode.panelIntrinsic:
        final panelSize = layoutChild(
          _Slot.panel,
          BoxConstraints(
            minWidth: size.width,
            maxWidth: size.width,
            maxHeight: size.height * StagePanelLayout.maxPanelFraction,
          ),
        );
        positionChild(_Slot.panel, Offset(0, size.height - panelSize.height));
        final stageHeight = (size.height - panelSize.height + overlap).clamp(
          0.0,
          size.height,
        );
        layoutChild(
          _Slot.stage,
          BoxConstraints.tight(Size(size.width, stageHeight)),
        );
        positionChild(_Slot.stage, Offset.zero);

      case StagePanelMode.stageFraction:
        final stageHeight = (size.height * 0.26).clamp(120.0, 260.0);
        layoutChild(
          _Slot.stage,
          BoxConstraints.tight(Size(size.width, stageHeight)),
        );
        positionChild(_Slot.stage, Offset.zero);
        final panelHeight = size.height - stageHeight + overlap;
        layoutChild(
          _Slot.panel,
          BoxConstraints.tight(Size(size.width, panelHeight)),
        );
        positionChild(_Slot.panel, Offset(0, stageHeight - overlap));
    }
  }

  @override
  bool shouldRelayout(_StagePanelDelegate oldDelegate) =>
      oldDelegate.mode != mode;
}

/// The raised ritual surface from Design 3: rounded top corners and a quiet
/// sheet handle. Hosts Home's state block and Mood's selection sheet.
///
/// [expand] is true when the panel is given a bounded height (stageFraction
/// mode) and the child should fill it; false lets the panel size to content
/// (panelIntrinsic mode).
class RitualPanel extends StatelessWidget {
  const RitualPanel({super.key, required this.child, this.expand = false});

  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTokens.surfaceRaised,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppTokens.textSecondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (expand)
            Expanded(child: child)
          else
            // Sizes to content normally; when the layout caps the panel
            // (extreme text scales on short screens) the content scrolls
            // instead of overflowing.
            Flexible(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}
