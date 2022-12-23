//
//  AmbianceView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbianceView: View {
    var ambiance: Ambiance
    
    var body: some View {
        Text(ambiance.name)
    }
}

struct AmbianceView_Previews: PreviewProvider {
    static var previews: some View {
        AmbianceView(ambiance: Ambiance(name: "Jazz", lightHue: 50, lightSaturation: 20, lightBrightness: 40))
    }
}
