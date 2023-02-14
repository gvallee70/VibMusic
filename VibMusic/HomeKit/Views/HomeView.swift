//
//  PlusCircleView.swift
//  VibMusic
//
//  Created by Gwendal on 13/02/2023.
//

import SwiftUI
import HomeKit

struct HomeView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStoreViewModel

    @State var home: HMHome
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 130, height: 130)
                .opacity(0.9)
                .overlay {
                    if self.homeStoreViewModel.currentStoredHome == self.home {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 5)
                    }
                }
            
            VStack {
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .padding(.bottom, 2)
                
                Text(self.home.name)
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: 110)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            if self.homeStoreViewModel.currentStoredHome == self.home {
                Text("Active")
                    .font(.system(size: 14))
                    .padding(5)
                    .background(.green)
                    .clipShape(Capsule())
            }
        }
    }
}
