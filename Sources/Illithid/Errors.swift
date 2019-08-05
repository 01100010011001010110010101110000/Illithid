//
//  File.swift
//  
//
//  Created by Tyler Gregory on 7/9/19.
//

import Foundation

public extension RedditClientBroker {
  struct NotFound: LocalizedError {
    let lookingFor: String
  }
}
