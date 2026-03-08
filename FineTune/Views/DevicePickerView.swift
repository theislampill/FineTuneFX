// FineTune/Views/DevicePickerView.swift
import SwiftUI

struct DevicePickerView: View {
    let devices: [AudioDevice]
    let selectedDeviceUID: String
    let onDeviceSelected: (String) -> Void

    var body: some View {
        // Single lookup, cached for this render
        let selectedDevice = devices.first { $0.uid == selectedDeviceUID }
        let displayName = selectedDevice?.name ?? "Unknown Device"
        let displayIcon = selectedDevice?.icon

        Menu {
            ForEach(devices) { device in
                Button {
                    onDeviceSelected(device.uid)
                } label: {
                    HStack {
                        if let icon = device.icon {
                            Image(nsImage: icon)
                        } else {
                            Image(systemName: "hifispeaker")
                        }
                        Text(device.name)
                        if selectedDeviceUID == device.uid {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                if let icon = displayIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                } else {
                    Image(systemName: "hifispeaker")
                        .font(.caption)
                }
                Text(displayName)
                    .font(.caption)
                    .lineLimit(1)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                    .fill(.thinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                    .strokeBorder(DesignTokens.Colors.menuBorder, lineWidth: 0.5)
            }
        }
        .menuStyle(.borderlessButton)
    }
}
