//
//  AccessoryView.swift
//  VibMusic
//
//  Created by Gwendal on 14/02/2023.
//

import SwiftUI
import HomeKit

struct AccessoryView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStoreViewModel

    @State var accessory: HMAccessory
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 130, height: 130)
                .opacity(0.9)
                .overlay {
                    if self.homeStoreViewModel.currentStoredAccessories.contains(self.accessory) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 5)
                    }
                }
            
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
        .overlay(alignment: .topTrailing) {
            if self.homeStoreViewModel.currentStoredAccessories.contains(self.accessory) {
                Text("Active")
                    .font(.system(size: 14))
                    .padding(5)
                    .background(.green)
                    .clipShape(Capsule())
            }
        }
    }
}
