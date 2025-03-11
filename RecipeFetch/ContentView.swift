//
//  ContentView.swift
//  RecipeFetch
//
//  Created by Thomas DiZoglio on 3/11/25.
//

import SwiftUI

struct Recipe: Codable {
    let cuisine: String
    let name: String
    let photoURLLarge: String
    let photoURLSmall: String
    let sourceURL: String?
    let uuid: String
    let youtubeURL: String?
    
    /// Custom CodingKeys to match JSON keys
    enum CodingKeys: String, CodingKey {
        case cuisine, name, uuid
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
}

/// Struct to represent the top-level JSON object
struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

struct ContentView: View {
    
    @State var allRecipes: [Recipe] = [Recipe]()
    
    var colums = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init () {
        URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
    }

    var body: some View {
        Text("Recipes")
            .font(.title)
            .padding(10)

        NavigationView {
            ScrollView {
                LazyVGrid(columns: colums, spacing: 10) {
                    ForEach(0..<allRecipes.count, id: \.self) { index in
                        
                        RecipeMainView(recipe: $allRecipes[index])
                        
                    }.padding(.all, 10)
                }
            }
            .task {
                do {
                    try await getRecipes()
                } catch {
                    print("Error", error)
                }
            }
        }
    }
    
    func getRecipes() async throws {
        guard let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json") else { fatalError("Missing URL")
        }

        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else
        {
            fatalError("Error while fetching data")
        }
        
        let decodedData = try JSONDecoder().decode(RecipeResponse.self, from: data)
        allRecipes = decodedData.recipes
        
        print(allRecipes)
    }
}

struct RecipeMainView: View {

    @State private var isTapped = false
    @Binding var recipe: Recipe

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
            ZStack {
                AsyncImage(url: URL(string: recipe.photoURLSmall))
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .clipped()
                
                VStack(alignment: .center) {
                    Text(recipe.name)
                        .font(.subheadline)
                        .foregroundColor(.black)

                    Text(recipe.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct RecipeDetailView: View {

    var recipe: Recipe

    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: recipe.photoURLLarge))
                .clipped()
            
            VStack(alignment: .center) {
                Text(recipe.name)
                    .font(.headline)
                
                Text(recipe.cuisine)
                    .font(.headline)
            }
        }
    }
}

#Preview {
    ContentView()
}
