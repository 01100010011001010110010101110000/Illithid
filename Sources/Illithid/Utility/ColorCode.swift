//
// ColorCode.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 7/26/20
//

import Foundation

#if canImport(SwiftUI)
  import SwiftUI
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
func parseWebColor(hex: String) -> Color? {
  let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
  var int: UInt64 = 0
  Scanner(string: hex).scanHexInt64(&int)

  let a, r, g, b: UInt64
  switch hex.count {
  case 3: // RGB (12-bit)
    (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
  case 6: // RGB (24-bit)
    (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
  case 8: // ARGB (32-bit)
    (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
  default:
    (a, r, g, b) = (1, 1, 1, 0)
  }

  return Color(
    .sRGB,
    red: Double(r) / 255,
    green: Double(g) / 255,
    blue: Double(b) / 255,
    opacity: Double(a) / 255
  )
}
