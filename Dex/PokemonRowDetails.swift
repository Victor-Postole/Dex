//
//  PokemonRowDetails.swift
//  Dex
//
//  Created by diseso software on 25.04.2025.
//

import SwiftUI

struct PokemonRowDetails: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var pokemon: Pokemon
    @Binding var filterByFavorites: Bool

    var body: some View {
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
        .swipeActions(edge: .leading){
            Button(pokemon.favorite ? "Remove from Favorites": "Add to favorties", systemImage: filterByFavorites ? "star.fill" : "star") {
                pokemon.favorite.toggle()
                
                do {
                    try viewContext.save()
                }catch {
                    print(error)
                }
            }.tint(pokemon.favorite ? .gray : .yellow)
        }
    }
}


#Preview {
    PokemonRowDetails(filterByFavorites: .constant(true))
        .environmentObject(PersistenceController.previewPokemon)
}
