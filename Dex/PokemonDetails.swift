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
                    Image(pokemon.background)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black, radius: 6)
                 
                    if pokemon.sprite == nil || pokemon.shiny == nil {
                        
                        AsyncImage(url: showShiny ? pokemon.shinyURL  : pokemon.spriteURL) { image in
                            image
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .padding(.top, 50)
                                .shadow(color: .black, radius: 6)
                                .frame(width: 300, height:300)
                        }placeholder: {
                            ProgressView()
                        }
                    }else {
                        (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 50)
                            .shadow(color: .black, radius: 6)
                            .frame(width: 300, height:300)
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
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            
            Stats(pokemon: pokemon)
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShiny.toggle()
                } label : {
                    Image(systemName: showShiny ? "want.and.stars" : "wand.and.stars.inverse")
                        .tint(showShiny ? .yellow : .primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetails().environmentObject(PersistenceController.previewPokemon)
    }
}
