//
//  AIAssistantButton.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct AIAssistantButton: View {
    var body: some View {
        Menu {
            Button {
                print("Chat selected")
            } label: {
                Label("Chat", systemImage: "bubble.left")
            }
            
            Button {
                print("Talk selected")
            } label: {
                Label("Talk", systemImage: "waveform")
            }
            .disabled(true)
        } label: {
            Image(systemName: "sparkles")
                .font(.body.weight(.medium))
        }
    }
}

#Preview {
    AIAssistantButton()
}

