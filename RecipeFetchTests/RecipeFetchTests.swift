//
//  RecipeFetchTests.swift
//  RecipeFetchTests
//
//  Created by Thomas DiZoglio on 3/11/25.
//

import SwiftUI
import XCTest
@testable import RecipeFetch

class RecipeFetchTests: XCTestCase {

    // Sample JSON for testing
    let validJSON = """
    {
        "cuisine": "Italian",
        "name": "Spaghetti Carbonara",
        "photo_url_large": "https://example.com/large.jpg",
        "photo_url_small": "https://example.com/small.jpg",
        "source_url": "https://example.com/recipe",
        "uuid": "123e4567-e89b-12d3-a456-426614174000",
        "youtube_url": "https://www.youtube.com/watch?v=example"
    }
    """.data(using: .utf8)!
    
    let missingOptionalJSON = """
    {
        "cuisine": "Japanese",
        "name": "Sushi",
        "photo_url_large": "https://example.com/large.jpg",
        "photo_url_small": "https://example.com/small.jpg",
        "uuid": "321e4567-e89b-12d3-a456-426614174999"
    }
    """.data(using: .utf8)!
    
    let invalidJSON = """
    {
        "cuisine": "French",
        "name": "Crepe",
        "photo_url_large": 123,  // Invalid type (should be String)
        "photo_url_small": "https://example.com/small.jpg",
        "uuid": "987e4567-e89b-12d3-a456-426614174111"
    }
    """.data(using: .utf8)!

    // Test decoding a valid Recipe JSON
    func testDecodeValidRecipe() throws {
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(Recipe.self, from: validJSON)
        
        XCTAssertEqual(recipe.cuisine, "Italian")
        XCTAssertEqual(recipe.name, "Spaghetti Carbonara")
        XCTAssertEqual(recipe.photoURLLarge, "https://example.com/large.jpg")
        XCTAssertEqual(recipe.photoURLSmall, "https://example.com/small.jpg")
        XCTAssertEqual(recipe.sourceURL, "https://example.com/recipe")
        XCTAssertEqual(recipe.uuid, "123e4567-e89b-12d3-a456-426614174000")
        XCTAssertEqual(recipe.youtubeURL, "https://www.youtube.com/watch?v=example")
    }

    // Test decoding JSON where optional fields are missing
    func testDecodeRecipeWithMissingOptionalFields() throws {
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(Recipe.self, from: missingOptionalJSON)
        
        XCTAssertEqual(recipe.cuisine, "Japanese")
        XCTAssertEqual(recipe.name, "Sushi")
        XCTAssertEqual(recipe.photoURLLarge, "https://example.com/large.jpg")
        XCTAssertEqual(recipe.photoURLSmall, "https://example.com/small.jpg")
        XCTAssertEqual(recipe.uuid, "321e4567-e89b-12d3-a456-426614174999")
        
        // Optional fields should be nil
        XCTAssertNil(recipe.sourceURL)
        XCTAssertNil(recipe.youtubeURL)
    }
    
    // Test decoding an invalid JSON format (should throw an error)
    func testDecodeInvalidRecipe() {
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(try decoder.decode(Recipe.self, from: invalidJSON)) { error in
            print("Expected decoding error: \(error)")
        }
    }
    
    // Test encoding a Recipe back to JSON
    func testEncodeRecipe() throws {
        let recipe = Recipe(
            cuisine: "Mexican",
            name: "Tacos",
            photoURLLarge: "https://example.com/tacos-large.jpg",
            photoURLSmall: "https://example.com/tacos-small.jpg",
            sourceURL: "https://example.com/tacos",
            uuid: "555e4567-e89b-12d3-a456-426614174222",
            youtubeURL: nil
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(recipe)
        
        XCTAssertNotNil(jsonData, "JSON encoding should produce data")
        
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertTrue(jsonString?.contains("\"cuisine\" : \"Mexican\"") ?? false)
        XCTAssertTrue(jsonString?.contains("\"name\" : \"Tacos\"") ?? false)
        XCTAssertTrue(jsonString?.contains("\"uuid\" : \"555e4567-e89b-12d3-a456-426614174222\"") ?? false)
    }
    
    // Test decoding an entire RecipeResponse JSON
    func testDecodeRecipeResponse() throws {
        let jsonResponse = """
        {
            "recipes": [
                {
                    "cuisine": "Indian",
                    "name": "Butter Chicken",
                    "photo_url_large": "https://example.com/butterchicken-large.jpg",
                    "photo_url_small": "https://example.com/butterchicken-small.jpg",
                    "source_url": "https://example.com/butterchicken",
                    "uuid": "777e4567-e89b-12d3-a456-426614174333",
                    "youtube_url": "https://www.youtube.com/watch?v=butterchicken"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let recipeResponse = try decoder.decode(RecipeResponse.self, from: jsonResponse)
        
        XCTAssertEqual(recipeResponse.recipes.count, 1)
        XCTAssertEqual(recipeResponse.recipes.first?.name, "Butter Chicken")
        XCTAssertEqual(recipeResponse.recipes.first?.cuisine, "Indian")
    }
}
