//
//  PreviewView.swift
//  heypimbl
//
//  Created by Macbook Pro on 11/11/25.
//

import SwiftUI

struct PreviewView: View {
    let image: UIImage
    var onSend: () -> Void
    var onCancel: () -> Void
    var isSending: Bool = false
    var showSuccess: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Image preview
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .top)

                // Action buttons
                if !showSuccess && !isSending {
                    HStack(spacing: 60) {
                        // Cancel button (Red X)
                        Button(action: onCancel) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                        }

                        // Send button (Green Arrow)
                        Button(action: {
                            onSend()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color(.systemBackground))
                } else {
                    // Empty space when buttons are hidden
                    Spacer()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color(.systemBackground))
                }
            }

            // Warning banner or Sending banner
            if !showSuccess {
                VStack {
                    Spacer()
                        .frame(maxHeight: .infinity, alignment: .top)

                    HStack {
                        Spacer()

                        if isSending {
                            // Sending banner - yellow-green
                            VStack(spacing: 8) {
                                ProgressView()
                                    .tint(.black)

                                Text("Submitting...")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: 180)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .background(Color(red: 0.9, green: 0.95, blue: 0.7))
                            .cornerRadius(16)
                            .shadow(radius: 8)
                        } else {
                            // Warning banner
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)

                                Text("You're parked in\nmy bike lane!")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: 180)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .background(Color.yellow)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                        }

                        Spacer()
                    }

                    Spacer()
                        .frame(maxHeight: .infinity)
                }
                .frame(maxHeight: .infinity)
            }

            // Success message - marquee style
            if showSuccess {
                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.green)

                            Text("Submitted to 311")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)

                            Text("😊")
                                .font(.system(size: 32))
                        }
                        .frame(maxWidth: 200)
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(16)
                        .shadow(radius: 8)

                        Spacer()
                    }

                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

#if DEBUG
struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleImage = UIImage(systemName: "photo.fill") ?? UIImage()
        PreviewView(image: sampleImage, onSend: {}, onCancel: {})
    }
}
#endif
