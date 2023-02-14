//
//  RoomView.swift
//  VibMusic
//
//  Created by Gwendal on 14/02/2023.
//

import SwiftUI
import HomeKit

struct RoomView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStore

    @State var room: HMRoom
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(maxWidth: 130, maxHeight: 130)
                .opacity(0.9)
                .overlay {
                    if self.homeStoreViewModel.currentStoredRooms.contains(self.room) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 5)
                    }
                }
            
            VStack {
                Image(systemName: "house.circle")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .padding(.bottom, 2)
                
                Text(self.room.name)
                    .bold()
                    .font(.headline)
                    .frame(maxWidth: 110)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            if self.homeStoreViewModel.currentStoredRooms.contains(self.room) {
                Text("Active")
                    .font(.system(size: 14))
                    .padding(5)
                    .background(.green)
                    .clipShape(Capsule())
            }
        }
    }
}
