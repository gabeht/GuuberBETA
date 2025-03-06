//
//  ContentView.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 2/24/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        NavigationView { // Move NavigationView to the top level
            VStack {
                NavigationLink(destination: CreateAccountScreen()) {
                    Text("Click to go to")
                        .frame(width: 200, height: 50, alignment: .center)
                }
                
                HStack {
                    Image(systemName: "car.fill")
                        .imageScale(.large)
                        .foregroundColor(Color.green)
                    Text("GÜHBER")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .multilineTextAlignment(.center)
                    Text("BETA")
                        .foregroundColor(Color.green)
                }
                .padding() // Add padding to the HStack to prevent bleeding
            }
        }
    }
}
#Preview {
    MainView()
        .modelContainer(for: Item.self, inMemory: true)
}

