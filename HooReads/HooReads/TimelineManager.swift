//
//  TimelineManager.swift
//  HooReads
//
//  Created by Maraki Fanuil on 5/2/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI


struct DBTimeline: Hashable {
    let id: String?
    let friendId: String?
    let timestamp: Date?
    let activityDetails: [String: String]?
    
}

enum ActivityType: String {
    case reviewed
    case rated
}

final class TimelineManager {
    static let shared = TimelineManager()
    private init(){}
    
    func createTimeLine(userId: String, friendId: String, activityType: String, bookId: String ) async throws {
        let id = UUID().uuidString
        
        var TimelineData: [String:Any] = [
            "id": id,
            "friendId" : friendId,
            "timestamp" : Timestamp(),
            "activityDetails": [activityType: bookId],
        ]

        try await Firestore.firestore().collection("users/\(userId)/timeline").document("\(id)").setData(TimelineData, merge: false)
        
    }
    
    func getActivities(userId: String) async throws -> [DBTimeline] {
        let snapshot = try await Firestore.firestore().collection("users/\(userId)/timeline").getDocuments()
        
        var activities: [DBTimeline] = []
     
        for document in snapshot.documents {
            let data = try document.data()
            print("data: \(data)")
            let id = data["id"] as? String
            let friendId = data["friendId"] as? String
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
            print("data timestap: \(data["timestamp"])")
            print("timestamp: \(timestamp)")
            let activityDetails = data["activityDetails"] as? [String: String]

            
            print("activityDetails[]: \(data["activityDetails"])")
            print("activityDetails: \(activityDetails)")
            let activity = DBTimeline(id: id, friendId: friendId, timestamp: timestamp, activityDetails: activityDetails)
            activities.append(activity)
        }
  
        return activities
        
        
    }
}
