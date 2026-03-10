// FineTune/Views/Components/EQPresetPicker.swift
import SwiftUI

struct EQPresetPicker: View {
    let selectedPreset: EQPreset?
    let onPresetSelected: (EQPreset) -> Void

    var body: some View {
        GroupedDropdownMenu(
            sections: Array(EQPreset.Category.allCases),
            itemsForSection: { EQPreset.presets(for: $0) },
            sectionTitle: { $0.rawValue },
            selectedItem: selectedPreset,
            maxHeight: 280,
            width: 100,
            popoverWidth: 150,
            onSelect: onPresetSelected
        ) { selected in
            Text(selected?.name ?? "Custom")
        } itemContent: { preset, isSelected in
            HStack {
                Text(preset.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EQPresetPicker(selectedPreset: .rock) { _ in }
        EQPresetPicker(selectedPreset: nil) { _ in }
        EQPresetPicker(selectedPreset: .vocalClarity) { _ in }
    }
    .padding()
    .background(Color.black)
}
