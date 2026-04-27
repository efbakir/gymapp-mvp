//
//  RestTimerLiveActivity.swift
//  Unit
//
//  Live Activity view for rest timer (Lock Screen / Dynamic Island).
//  ActivityKit is iOS-only; this file is compiled only for iOS.
//

#if os(iOS)
import ActivityKit
import WidgetKit
import SwiftUI

struct RestTimerLiveActivityView: View {
    let context: ActivityViewContext<RestTimerAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "timer")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Rest")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText(countsDown: true))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Dynamic Island

enum RestTimerLiveActivityIsland {
    static func dynamicIsland(context: ActivityViewContext<RestTimerAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                Image(systemName: "timer")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            DynamicIslandExpandedRegion(.center) {
                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText(countsDown: true))
            }
            DynamicIslandExpandedRegion(.bottom) {
                Text("Rest")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        } compactLeading: {
            Image(systemName: "timer")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
        } compactTrailing: {
            Text(context.state.endDate, style: .timer)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText(countsDown: true))
        } minimal: {
            Image(systemName: "timer")
                .font(.system(size: 14, weight: .semibold))
        }
    }
}
#endif
