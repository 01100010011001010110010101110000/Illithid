public extension Array {
  func chunks(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min(count, size + $0)])
    }
  }
}
