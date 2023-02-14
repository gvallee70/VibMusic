//
//  AmplitudeFooter.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI
import AudioKitUI

struct AmplitudeSectionView: View {
    @ObservedObject var audioKitViewModel: AudioKitViewModel
    
    var body: some View {
        Section(header: HStack {
            Text("Informations")
        }) {
            VStack {
                HStack {
                    Text("Amplitude du son capté")
                    Spacer()
                    Text("\(audioKitViewModel.data.amplitude, specifier: "%0.1f")")
                }
                NodeOutputView(audioKitViewModel.tappableNodeB)
                    .clipped()
                    .frame(height: 50)
                    .padding(.horizontal, -20)
                    .clipShape(Capsule())
            }
        }
    }
}

struct AmplitudeFooter_Previews: PreviewProvider {
    static var previews: some View {
        AmplitudeSectionView(audioKitViewModel: AudioKitViewModel())
    }
}
