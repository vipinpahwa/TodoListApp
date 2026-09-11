//
//  ProgressHeaderView.swift
//  TodoListApp
//
//  Created by Vipin Pahwa on 11/09/26.
//

import SwiftUI

/// A compact card summarizing overall completion progress at the top of the list.
struct ProgressHeaderView: View {
    let completedCount: Int
    let totalCount: Int
    let progress: Double

    private var summary: String {
        totalCount == 0
            ? "No tasks yet"
            : "\(completedCount) of \(totalCount) tasks complete"
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: progress)
                Text(progress, format: .percent.precision(.fractionLength(0)))
                    .font(.caption2.bold())
                    .contentTransition(.numericText())
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("Your Progress")
                    .font(.subheadline.bold())
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            Spacer()
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.3), value: summary)
    }
}

#Preview {
    VStack {
        ProgressHeaderView(completedCount: 3, totalCount: 7, progress: 3.0 / 7.0)
        ProgressHeaderView(completedCount: 0, totalCount: 0, progress: 0)
    }
}
