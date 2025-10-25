//
//  ChatInputView.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct ChatInputView: View {
    @Binding var chatMessage: String
    @Binding var isChatActive: Bool
    @FocusState.Binding var isChatInputFocused: Bool
    
    private func sendMessage() {
        print("Sending message: \(chatMessage)")
        isChatInputFocused = false
        chatMessage = ""
        isChatActive = false
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                HStack {
                    if isChatActive {
                        TextField("Ask your coach...", text: $chatMessage)
                            .focused($isChatInputFocused)
                            .padding()
                            .glassEffect(.regular.interactive())
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                            .padding()
                            .glassEffect(.regular.interactive())
                            .disabled(chatMessage.isEmpty)
                        }
                        Button(action: {
                            chatMessage = ""
                            isChatInputFocused = false
                            isChatActive = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                            .padding()
                            .glassEffect(.regular.interactive())
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)

            }
        } else {
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                .padding()
            }.padding()
        }
    }
}

