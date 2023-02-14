//
//  AccessoryView.swift
//  VibMusic
//
//  Created by Gwendal on 14/02/2023.
//

import SwiftUI
import HomeKit

struct AccessoryView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStore

    @State var accessory: HMAccessory
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 130, height: 130)
                .opacity(0.9)
            
            VStack {
                Image(systemName: "lightbulb.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 55)
                    .padding(.bottom, 2)
                
                Text(self.accessory.name)
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: 110)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
