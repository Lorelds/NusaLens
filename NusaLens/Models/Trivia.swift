//
//  Trivia.swift
//  NusaLens
//

import Foundation

struct Trivia: Identifiable, Codable {
    var id: String
    var fact: String
    var question: String?
    var options: [String]?
    var correctOptionIndex: Int?
    var explanation: String?
    
    var isQuiz: Bool {
        question != nil && options != nil && correctOptionIndex != nil
    }
}
