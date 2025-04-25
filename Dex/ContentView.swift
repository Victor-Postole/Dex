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
    
    @FetchRequest<Pokemon>(sortDescriptors: [SortDescriptor( \.id)], animation: .default) private var pokeIndex

    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        //search predicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        //filter by vaforite preidcate
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        //combine predicates
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    var body: some View {
        
        if pokeIndex.isEmpty {
            ContentUnavailableView{
                Label("No Pokemon", image: .nopokemon)
            }description: {
                Text("There aren't any pokemon yet.\nFetch some Pokemon to get started!")
            }actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1)
                }.buttonStyle(.borderedProminent)
            }
        }else{
            NavigationStack {
                List {
                    
                    Section {
                        
                        ForEach(pokeIndex){ pokemon in
                            NavigationLink(value: pokemon){
                                AsyncImage(url: pokemon.sprite) { image in
                                    
                                    image.resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name!.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow )
                                        }
                                    }
                                    
                                    HStack {
                                        ForEach(pokemon.types!, id: \.self) { type in
                                            Text(type.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(Color(type.capitalized))
                                                .clipShape(.capsule)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }footer: {
                        if pokeIndex.count < 151 {
                            ContentUnavailableView{
                                Label("Missing pokemon", image: .nopokemon)
                            }description: {
                                Text("The fetch was interrupted!\nFetch the rest of the pokemon.")
                            }actions: {
                                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokeIndex.count + 1)
                                }.buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .navigationTitle("PokeDex")
                .searchable(text: $searchText, prompt: "Find a pokemon:")
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    pokeIndex.nsPredicate = dynamicPredicate
                }
                .onChange(of: filterByFavorites){
                    pokeIndex.nsPredicate = dynamicPredicate
                }
                .navigationDestination(for: Pokemon.self){pokemon in
                    Text(pokemon.name ?? "no name")
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button{
                            filterByFavorites.toggle()
                        }label: {
                            Label("Filter by favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }.task {
                getPokemon()
            }
        }
    }

    private func getPokemon(from id: Int){
        Task {
            for i in id..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
                    let pokemon = Pokemon(context: viewContext)
                    
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    
                    if pokemon.id % 2 == 0 {
                        pokemon.favorite = true
                    }
                    
                    try viewContext.save()
                }catch {
                    print(error)
                }
            }
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
