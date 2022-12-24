//
//  AmbiancesView.swift
//  VibMusic
//
//  Created by Gwendal on 23/12/2022.
//

import SwiftUI

struct AmbiancesListView: View {
    @State private var showAddAmbianceSheet = false

    @ObservedObject var viewModel: AmbiancesViewModel

    var body: some View {
        List {
            Section {
                Button {
                    self.showAddAmbianceSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Ajouter une ambiance")
                    }
                }
                .sheet(isPresented: $showAddAmbianceSheet) {
                    List {
                        AddAmbianceSheetView(viewModel: self.viewModel)
                    }
                }
                
                Button(role: .destructive) {
                    //self.showAddAmbianceSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Modifier")
                    }
                }
            }
    
           LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
               ForEach(self.viewModel.ambiances, id: \.id) { ambiance in
                   ZStack {
                       RoundedRectangle(cornerRadius: 12)
                           .frame(height: 100)
                           .foregroundColor(Color(hue: Double(ambiance.lightHue), saturation: Double(ambiance.lightSaturation), brightness: Double(ambiance.lightBrightness)))
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
                   .padding(10)
               }
            }
            .padding(-10)
            .listRowBackground(Color.clear)
            .navigationTitle("Mes ambiances")
        }
    }
}

struct AmbiancesView_Previews: PreviewProvider {
    static var previews: some View {
        Text("toto")
        //AmbiancesListView()
    }
}
