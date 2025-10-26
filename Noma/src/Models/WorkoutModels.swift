//
//  WorkoutModels.swift
//  Noma
//
//  Created by Joshua Kraft on 24.10.25.
//

import Foundation

// MARK: - Workout Models

struct Workout: Codable, Identifiable {
    let id: String
    let date: String // ISO 8601 date string
    let timeSlot: TimeSlot
    let title: String
    let category: Category
    let duration: Int // minutes
    let completed: Bool
    let exerciseRounds: [ExerciseRound]
    let explanation: String
}

struct ExerciseRound: Codable, Identifiable {
    let id: String
    let order: Int
    let rounds: Int
    let restBetweenRounds: Int // seconds
    let exercises: [Exercise]
    let explanation: String
}

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let order: Int
    let volume: Volume
    let intensity: Intensity
    let rest: Int? // seconds
    let explanation: String?
}

// MARK: - Supporting Types

enum TimeSlot: String, Codable, CaseIterable {
    case morning = "morning"
    case daytime = "daytime"
    case evening = "evening"
}

enum Category: Codable {
    case gym(GymSubcategory)
    case run(RunSubcategory)
    case bike(BikeSubcategory)
    case swim(SwimSubcategory)
    case hiit(HIITSubcategory)
    
    enum CodingKeys: String, CodingKey {
        case type
        case subcategory
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let subcategory = try container.decode(String.self, forKey: .subcategory)
        
        switch type {
        case "gym":
            guard let gymSub = GymSubcategory(rawValue: subcategory) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid gym subcategory: \(subcategory)")
                )
            }
            self = .gym(gymSub)
        case "run":
            guard let runSub = RunSubcategory(rawValue: subcategory) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid run subcategory: \(subcategory)")
                )
            }
            self = .run(runSub)
        case "bike":
            guard let bikeSub = BikeSubcategory(rawValue: subcategory) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid bike subcategory: \(subcategory)")
                )
            }
            self = .bike(bikeSub)
        case "swim":
            guard let swimSub = SwimSubcategory(rawValue: subcategory) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid swim subcategory: \(subcategory)")
                )
            }
            self = .swim(swimSub)
        case "hiit":
            guard let hiitSub = HIITSubcategory(rawValue: subcategory) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid hiit subcategory: \(subcategory)")
                )
            }
            self = .hiit(hiitSub)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown category type: \(type)")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .gym(let subcategory):
            try container.encode("gym", forKey: .type)
            try container.encode(subcategory.rawValue, forKey: .subcategory)
        case .run(let subcategory):
            try container.encode("run", forKey: .type)
            try container.encode(subcategory.rawValue, forKey: .subcategory)
        case .bike(let subcategory):
            try container.encode("bike", forKey: .type)
            try container.encode(subcategory.rawValue, forKey: .subcategory)
        case .swim(let subcategory):
            try container.encode("swim", forKey: .type)
            try container.encode(subcategory.rawValue, forKey: .subcategory)
        case .hiit(let subcategory):
            try container.encode("hiit", forKey: .type)
            try container.encode(subcategory.rawValue, forKey: .subcategory)
        }
    }
}

// MARK: - Category Subcategories

enum GymSubcategory: String, Codable, CaseIterable {
    case volumePush = "volume_push"
    case volumePull = "volume_pull"
    case volumeLegs = "volume_legs"
    case volumeCore = "volume_core"
    case volumeFullBody = "volume_full_body"
    case maxStrengthPush = "max_strength_push"
    case maxStrengthPull = "max_strength_pull"
    case maxStrengthLegs = "max_strength_legs"
    case maxStrengthCore = "max_strength_core"
    case maxStrengthFullBody = "max_strength_full_body"
}

enum RunSubcategory: String, Codable, CaseIterable {
    case baseZ2 = "base_z2"
    case intervalsZ4Z5 = "intervals_z4_z5"
}

enum BikeSubcategory: String, Codable, CaseIterable {
    case baseZ2 = "base_z2"
    case intervalsZ4Z5 = "intervals_z4_z5"
}

enum SwimSubcategory: String, Codable, CaseIterable {
    case baseZ2 = "base_z2"
    case intervalsZ4Z5 = "intervals_z4_z5"
}

enum HIITSubcategory: String, Codable, CaseIterable {
    case cardio = "cardio"
    case strengthCardio = "strength_cardio"
}

// MARK: - Volume Types

enum Volume: Codable {
    case reps(repetitions: Int)
    case duration(seconds: Int)
    case distance(kilometers: Double)
    
    enum CodingKeys: String, CodingKey {
        case type
        case repetitions
        case seconds
        case kilometers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "reps":
            let repetitions = try container.decode(Int.self, forKey: .repetitions)
            self = .reps(repetitions: repetitions)
        case "duration":
            let seconds = try container.decode(Int.self, forKey: .seconds)
            self = .duration(seconds: seconds)
        case "distance":
            let kilometers = try container.decode(Double.self, forKey: .kilometers)
            self = .distance(kilometers: kilometers)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown volume type: \(type)")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .reps(let repetitions):
            try container.encode("reps", forKey: .type)
            try container.encode(repetitions, forKey: .repetitions)
        case .duration(let seconds):
            try container.encode("duration", forKey: .type)
            try container.encode(seconds, forKey: .seconds)
        case .distance(let kilometers):
            try container.encode("distance", forKey: .type)
            try container.encode(kilometers, forKey: .kilometers)
        }
    }
}

// MARK: - Intensity Types

enum Intensity: Codable {
    case weight(kilogramms: Double)
    case heartRate(targetBpm: Int)
    
    enum CodingKeys: String, CodingKey {
        case type
        case kilogramms
        case targetBpm
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "weight":
            let kilogramms = try container.decode(Double.self, forKey: .kilogramms)
            self = .weight(kilogramms: kilogramms)
        case "heart_rate":
            let targetBpm = try container.decode(Int.self, forKey: .targetBpm)
            self = .heartRate(targetBpm: targetBpm)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown intensity type: \(type)")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .weight(let kilogramms):
            try container.encode("weight", forKey: .type)
            try container.encode(kilogramms, forKey: .kilogramms)
        case .heartRate(let targetBpm):
            try container.encode("heart_rate", forKey: .type)
            try container.encode(targetBpm, forKey: .targetBpm)
        }
    }
}
