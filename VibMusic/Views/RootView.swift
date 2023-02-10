//
//  RootView.swift
//  VibMusic
//
//  Created by Gwendal on 10/02/2023.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var homeStoreViewModel: HomeStore
    @EnvironmentObject var audioKitViewModel: TunerConductor
    
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: self.$path) {
            VStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(deviceToUse: self.audioKitViewModel.initialDevice)) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
