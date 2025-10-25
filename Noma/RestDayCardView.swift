//
//  RestDayCardView.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct RestDayCardView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Rest Day")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Recovery is part of the plan")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RestDayCardView()
        .padding()
}

