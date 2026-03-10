// FineTune/Views/Components/VUMeter.swift
import SwiftUI

/// A vertical VU meter visualization for audio levels
/// Shows 8 bars that light up based on audio level with peak hold
struct VUMeter: View {
    let level: Float
    var isMuted: Bool = false

    @State private var peakLevel: Float = 0
    @State private var peakHoldTimer: Timer?

    private let barCount = DesignTokens.Dimensions.vuMeterBarCount

    var body: some View {
        HStack(spacing: DesignTokens.Dimensions.vuMeterBarSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                VUMeterBar(
                    index: index,
                    level: level,
                    peakLevel: peakLevel,
                    barCount: barCount,
                    isMuted: isMuted
                )
            }
        }
        .frame(width: DesignTokens.Dimensions.vuMeterWidth)
        .onChange(of: level) { _, newLevel in
            if newLevel > peakLevel {
                // New peak - capture and start decay timer
                peakLevel = newLevel
                startPeakDecayTimer()
            } else if peakLevel > newLevel && peakHoldTimer == nil {
                // Level dropped below peak and no timer running - start decay
                startPeakDecayTimer()
            }
        }
        .onDisappear {
            peakHoldTimer?.invalidate()
            peakHoldTimer = nil
        }
    }

    private func startPeakDecayTimer() {
        peakHoldTimer?.invalidate()
        // After hold period, start gradual decay using repeating timer
        peakHoldTimer = Timer.scheduledTimer(withTimeInterval: DesignTokens.Timing.vuMeterPeakHold, repeats: false) { [self] _ in
            // Start the gradual decay timer
            startGradualDecay()
        }
    }

    private func startGradualDecay() {
        peakHoldTimer?.invalidate()
        // Decay ~24dB over 2.8 seconds (BBC PPM standard)
        // At 30fps, that's ~84 frames, so decay rate ≈ 0.012 per frame (linear in amplitude)
        peakHoldTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [self] timer in
            let decayRate: Float = 0.012  // Per-frame decay
            if peakLevel > level {
                withAnimation(DesignTokens.Animation.vuMeterLevel) {
                    peakLevel = max(level, peakLevel - decayRate)
                }
            } else {
                // Peak has reached current level, stop decaying
                timer.invalidate()
                peakHoldTimer = nil
            }
        }
    }
}

/// Individual bar in the VU meter
private struct VUMeterBar: View {
    let index: Int
    let level: Float
    let peakLevel: Float
    let barCount: Int
    var isMuted: Bool = false

    /// dB thresholds for 8 bars covering 40dB range
    /// Matches professional audio meter standards (logarithmic scale)
    private static let dbThresholds: [Float] = [-40, -30, -20, -14, -10, -6, -3, 0]

    /// Threshold for this bar (0-1) using dB scale
    /// Converts dB to linear: 10^(dB/20)
    private var threshold: Float {
        let db = Self.dbThresholds[min(index, Self.dbThresholds.count - 1)]
        return powf(10, db / 20)
    }

    /// Whether this bar should be lit based on current level
    private var isLit: Bool {
        level >= threshold
    }

    /// Whether this bar is the peak indicator
    private var isPeakIndicator: Bool {
        // Find which bar the peak level falls into using dB thresholds
        var peakBarIndex = 0
        for i in 0..<Self.dbThresholds.count {
            let thresh = powf(10, Self.dbThresholds[i] / 20)
            if peakLevel >= thresh {
                peakBarIndex = i
            }
        }
        return index == peakBarIndex && peakLevel > level
    }

    /// Color for this bar based on its position and mute state
    /// Split: 4 green (0-3), 2 yellow (4-5), 1 orange (6), 1 red (7)
    private var barColor: Color {
        // When muted, show gray to indicate "app is active but muted"
        if isMuted {
            return DesignTokens.Colors.vuMuted
        }
        if index < 4 {
            return DesignTokens.Colors.vuGreen
        } else if index < 6 {
            return DesignTokens.Colors.vuYellow
        } else if index < 7 {
            return DesignTokens.Colors.vuOrange
        } else {
            return DesignTokens.Colors.vuRed
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(isLit || isPeakIndicator ? barColor : DesignTokens.Colors.vuUnlit)
            .frame(
                width: (DesignTokens.Dimensions.vuMeterWidth - CGFloat(barCount - 1) * DesignTokens.Dimensions.vuMeterBarSpacing) / CGFloat(barCount),
                height: DesignTokens.Dimensions.vuMeterBarHeight
            )
            .animation(DesignTokens.Animation.vuMeterLevel, value: isLit)
    }
}

// MARK: - Previews

#Preview("VU Meter - Horizontal") {
    ComponentPreviewContainer {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("0%")
                    .font(.caption)
                VUMeter(level: 0)
            }

            HStack {
                Text("25%")
                    .font(.caption)
                VUMeter(level: 0.25)
            }

            HStack {
                Text("50%")
                    .font(.caption)
                VUMeter(level: 0.5)
            }

            HStack {
                Text("75%")
                    .font(.caption)
                VUMeter(level: 0.75)
            }

            HStack {
                Text("100%")
                    .font(.caption)
                VUMeter(level: 1.0)
            }
        }
    }
}

#Preview("VU Meter - Animated") {
    struct AnimatedPreview: View {
        @State private var level: Float = 0

        var body: some View {
            ComponentPreviewContainer {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    VUMeter(level: level)

                    Slider(value: Binding(
                        get: { Double(level) },
                        set: { level = Float($0) }
                    ))
                }
            }
        }
    }
    return AnimatedPreview()
}
