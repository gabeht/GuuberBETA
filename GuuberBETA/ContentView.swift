//
//  ContentView.swift
//  GuuberBETA
//
//  Created by Gabe Holte on 2/24/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        HStack{
            Image(systemName: "car.fill")
                .imageScale(.large)
                .foregroundColor(Color.green)
            Text("Guuber")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .multilineTextAlignment(.center)
            Text("BETA")
                .foregroundColor(Color.green)
            
            
        }
    }
}
