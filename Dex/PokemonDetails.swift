//
//  PokemonDetails.swift
//  Dex
//
//  Created by diseso software on 25.04.2025.
//

import SwiftUI

struct PokemonDetails: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var pokemon: Pokemon
    
    @State private var showShiny = false
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    Image(.normalgrasselectricpoisonfairy)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black, radius: 6)
                    
                    AsyncImage(url: pokemon.sprite) { image in
                        image
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 50)
                            .shadow(color: .black, radius: 6)
                    }placeholder: {
                        ProgressView()
                    }
                    
                    
                }
                
                HStack {
                    ForEach(pokemon.types!, id:  \.self) {type in
                        Text(type.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .shadow(color: .white, radius: 1)
                            .padding(.vertical, 7)
                            .padding(.horizontal)
                            .background(Color(type.capitalized))
                            .clipShape(.capsule)
                    }
                    
                    Spacer()
                    
                    Button {
                        pokemon.favorite.toggle()
                        
                        do {
                            try viewContext.save()
                        }catch{
                            print(error)
                        }
                    }label: {
                        Image(systemName: pokemon.favorite ? "star.fill" : "star")
                            .font(.largeTitle)
                            .tint(.yellow)
                    }
                }    .padding(.vertical, 7)
                    .padding(.horizontal)
            }
        }
        .navigationTitle(pokemon.name!.capitalized)
    }
}

#Preview {
    NavigationStack {
        PokemonDetails().environmentObject(PersistenceController.previewPokemon)
    }
}
