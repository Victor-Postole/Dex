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
    
    @FetchRequest<Pokemon>(sortDescriptors: [], animation: .default) private var allPokemon
    
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
        
        if allPokemon.isEmpty {
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
                        
                        ForEach(pokeIndex) { pokemon in
                            PokemonRowDetails(filterByFavorites: $filterByFavorites)
                                .environmentObject(pokemon)
                        }
                        
                    }footer: {
                        if allPokemon.isEmpty {
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
                    PokemonDetails().environmentObject(pokemon)
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
                getPokemon(from: pokeIndex.count + 1)
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
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
                    pokemon.sprite = try await URLSession.shared.data(from: fetchedPokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: fetchedPokemon.shinyURL).0
                    
            
        
                    try viewContext.save()
                }catch {
                    print(error)
                }
            }
            
            storeSprites()
        }
    }
    
    private func storeSprites() {
        Task {
            do {
                for pokemon in allPokemon {
                    
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    
                    try viewContext.save()
                }
            } catch {
                print(error)
            }
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
