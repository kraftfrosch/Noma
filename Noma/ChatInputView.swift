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
        isChatActive = false
        chatMessage = ""
        isChatInputFocused = false
    }
    
    var body: some View {
        Group {
            // Availability-gated glass container with a fallback for earlier iOS versions
            if #available(iOS 26.0, *) {
                GlassEffectContainer {
                    HStack {
                        if isChatActive {
                            TextField("Ask your coach...", text: $chatMessage)
                                .glassEffect()
                                .focused($isChatInputFocused)
                                .submitLabel(.send)
                                .onSubmit {
                                    sendMessage()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            Image(systemName: "paperplane.fill")
                                .glassEffect()
                                .foregroundStyle(chatMessage.isEmpty ? Color.secondary : Color.blue)
                                .onTapGesture {
                                    withAnimation {
                                        sendMessage()
                                    }
                                }
                                .disabled(chatMessage.isEmpty)
                                .padding()
                            Image(systemName: "xmark.circle.fill")
                                .glassEffect()
                                .foregroundStyle(.secondary)
                                .onTapGesture {
                                    withAnimation {
                                        isChatActive = false
                                        chatMessage = ""
                                    }
                                }
                                .padding()
                        }
                    }.padding()
                }
            } else {
                // Fallback: a material-backed container that mimics a glass effect
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .bottom)
                    HStack {
                        TextField("Ask your coach...", text: $chatMessage)
                            .textFieldStyle(.plain)
                            .focused($isChatInputFocused)
                            .submitLabel(.send)
                            .onSubmit {
                                sendMessage()
                            }
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(chatMessage.isEmpty ? Color.secondary : Color.blue)
                        }
                        .disabled(chatMessage.isEmpty)
                        Button(action: {
                            isChatActive = false
                            chatMessage = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

