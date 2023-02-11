//
//  AmbianceView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbianceView: View {
    var ambiance: Ambiance
    @ObservedObject var viewModel: AmbiancesViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Text(ambiance.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.viewModel.delete(ambiance)
                        self.dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }

                }
            }
    }
}
