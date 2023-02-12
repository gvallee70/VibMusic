//
//  AmbianceView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbianceView: View {
    @Binding var ambiance: Ambiance
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .frame(height: 100)
                .foregroundColor(Color(hue: Double(ambiance.lightHue)/360, saturation: Double(ambiance.lightSaturation)/100, brightness: Double(ambiance.lightBrightness)/100, opacity: 1.0))
            VStack {
                Text(ambiance.name)
                    .font(.title)
                    .padding(2)
                HStack {
                    Image(systemName: ambiance.lightBrightness < 50 ? "light.min" : "light.max")
                    Text("\(ambiance.lightBrightness)%")
                }
            }
        }
    }
}
