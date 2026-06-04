//
//  NusaLensTests.swift
//  NusaLensTests
//
//  Created by student on 22/05/26.
//

import Testing
import CoreLocation
@testable import NusaLens

struct NusaLensTests {

    // MARK: - Budaya Tests
    @Test("Verify Budaya coordinate mapping")
    func budayaCoordinate() {
        // Arrange: Setup the data
        let budaya = Budaya(
            id: "test1",
            name: "Test Budaya",
            description: "Desc",
            category: .pakaianAdat,
            province: "Test",
            region: "Test",
            imageUrl: "url",
            latitude: -6.2088,
            longitude: 106.8456
        )
        
        // Act: Extract the coordinate
        let coordinate = budaya.coordinate
        
        // Assert: Verify it matches the input
        #expect(coordinate.latitude == -6.2088, "Latitude mismatch")
        #expect(coordinate.longitude == 106.8456, "Longitude mismatch")
    }

    // MARK: - Museum Tests
    @Test("Verify Museum coordinate mapping")
    func museumCoordinate() {
        let museum = Museum(
            id: "m1",
            name: "Museum Nasional",
            description: "Desc",
            province: "Jakarta",
            region: "Jawa",
            address: "Jl. Merdeka",
            imageUrl: "url",
            latitude: -6.1761,
            longitude: 106.8216,
            budayaIds: []
        )
        
        let coordinate = museum.coordinate
        
        #expect(coordinate.latitude == -6.1761, "Latitude mismatch")
        #expect(coordinate.longitude == 106.8216, "Longitude mismatch")
    }

    // MARK: - Trivia Tests
    @Test("Verify Trivia isQuiz returns true for complete quiz data")
    func triviaIsQuizTrue() {
        // Arrange
        let trivia = Trivia(
            id: "test",
            fact: "A fact",
            question: "Is this a question?",
            options: ["Yes", "No"],
            correctOptionIndex: 0,
            explanation: "Explanation"
        )
        
        // Act & Assert
        #expect(trivia.isQuiz == true, "Trivia with question and options should be considered a quiz")
    }
    
    @Test("Verify Trivia isQuiz returns false for pure facts")
    func triviaIsQuizFalse() {
        // Arrange
        let trivia = Trivia(
            id: "test",
            fact: "Just a pure fact without questions.",
            question: nil,
            options: nil,
            correctOptionIndex: nil,
            explanation: nil
        )
        
        // Act & Assert
        #expect(trivia.isQuiz == false, "Trivia without question data should NOT be considered a quiz")
    }

    // MARK: - Cultural Category Tests
    @Test("Verify CulturalCategory UI Icon Mappings")
    func culturalCategoryIconMappings() {
        // Assert: Ensure the hardcoded UI icons haven't accidentally changed
        #expect(CulturalCategory.pakaianAdat.iconName == "tshirt")
        #expect(CulturalCategory.alatMusik.iconName == "music.note")
        #expect(CulturalCategory.kuliner.iconName == "fork.knife")
        #expect(CulturalCategory.seniPertunjukan.iconName == "theatermasks")
        #expect(CulturalCategory.rumahAdat.iconName == "house")
        #expect(CulturalCategory.upacaraAdat.iconName == "sparkles")
    }

    // MARK: - Province Location Tests
    @Test("Verify total number of provinces in Indonesia")
    func provinceLocationCount() {
        // Arrange & Act
        let provinces = ProvinceLocation.allProvinces
        
        // Assert
        #expect(provinces.count == 38, "Indonesia currently has exactly 38 provinces. The array count must match.")
    }
    
    @Test("Verify provinces are perfectly sorted alphabetically")
    func provinceLocationAlphabeticalSorting() {
        // Arrange & Act
        let provinces = ProvinceLocation.allProvinces
        
        // Assert: Verify that every province is alphabetically before or equal to the next one
        for i in 0..<(provinces.count - 1) {
            let current = provinces[i].name
            let next = provinces[i + 1].name
            #expect(current <= next, "Provinces must be sorted alphabetically. Failed at \(current) and \(next)")
        }
    }
}
