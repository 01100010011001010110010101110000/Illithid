//
//  File.swift
//
//
//  Created by Tyler Gregory on 11/10/19.
//

import SwiftUI

internal extension View {
  func eraseToAnyView() -> AnyView {
    AnyView(self)
  }
}
