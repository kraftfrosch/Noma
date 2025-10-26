//
//  AIAssistantButton.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct AIAssistantButton: View {
    @Binding var isChatActive: Bool
    @FocusState.Binding var isChatInputFocused: Bool
    
    var body: some View {
        Menu {
            Button {
                withAnimation {
                    isChatActive = true
                    // Delay focus slightly to ensure the text field is rendered
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isChatInputFocused = true
                    }
                }
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
