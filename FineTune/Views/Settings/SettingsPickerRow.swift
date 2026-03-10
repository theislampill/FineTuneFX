// FineTune/Views/Settings/SettingsPickerRow.swift
import SwiftUI

/// Settings row with a picker/dropdown control
struct SettingsPickerRow<T: Hashable & Identifiable>: View where T: CustomStringConvertible {
    let icon: String
    let title: String
    let description: String?
    @Binding var selection: T
    let options: [T]

    var body: some View {
        SettingsRowView(icon: icon, title: title, description: description) {
            Picker("", selection: $selection) {
                ForEach(options) { option in
                    Text(option.description)
                        .tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(width: DesignTokens.Dimensions.settingsPickerWidth)
        }
    }
}

// MARK: - Preview Helper

private enum PreviewOption: String, Hashable, Identifiable, CaseIterable, CustomStringConvertible {
    case option1 = "Option 1"
    case option2 = "Option 2"
    case option3 = "Option 3"

    var id: String { rawValue }
    var description: String { rawValue }
}

// MARK: - Previews

#Preview("Picker Rows") {
    VStack(spacing: DesignTokens.Spacing.sm) {
        SettingsPickerRow(
            icon: "waveform",
            title: "Sample Picker",
            description: "A sample picker control",
            selection: .constant(PreviewOption.option1),
            options: PreviewOption.allCases
        )
    }
    .padding()
    .frame(width: 450)
    .darkGlassBackground()
    .environment(\.colorScheme, .dark)
}
