//
//  ContentView.swift
//  Dex
//
//  Created by diseso software on 24.04.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)], animation: .default)
    private var pokeIndex: FetchedResults<Pokemon>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(pokeIndex){ pokemon in
                    NavigationLink{
                        Text(pokemon.name!)
                    }label: {
                        Text(pokemon.name!)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add item", systemImage: "plus"){
                        
                    }
                }
            }
            Text("Select an item")
        }
    }

    
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
