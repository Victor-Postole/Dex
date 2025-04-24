//
//  FetchedPokemon.swift
//  Dex
//
//  Created by diseso software on 24.04.2025.
//

import Foundation

struct FetchedPokemon: Decodable {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialDefense: Int16
    let speed: Int16
    let sprite: URL
    let shiny: URL
    
       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           
           id = try container.decode(Int16.self, forKey: .id)
           name = try container.decode(String.self, forKey: .name)
           types = try container.decode([String].self, forKey: .types)
           hp = try container.decode(Int16.self, forKey: .hp)
           attack = try container.decode(Int16.self, forKey: .attack)
           defense = try container.decode(Int16.self, forKey: .defense)
           specialAttack = try container.decode(Int16.self, forKey: .specialAttack)
           specialDefense = try container.decode(Int16.self, forKey: .specialDefense)
           speed = try container.decode(Int16.self, forKey: .speed)
           sprite = try container.decode(URL.self, forKey: .sprite)
           shiny = try container.decode(URL.self, forKey: .shiny)
       }

       // Define the coding keys that map the properties to the JSON keys
       enum CodingKeys: String, CodingKey {
           case id
           case name
           case types
           case hp
           case attack
           case defense
           case specialAttack = "special_attack"
           case specialDefense = "special_defense"
           case speed
           case sprite
           case shiny
           
           enum TypeDictionaryKeys: CodingKey {
               case type
               
               enum TypeKyes: CodingKey {
                   case name
               }
           }
           
           enum StatDictionaryKeys: CodingKey {
               case baseStat
           }
           
           enum SpriteKeys: String, CodingKey {
               case sprite = "frontDefault"
               case shiny = "fontShiny"
               
           }
       }
}
