//
// OrderedSet.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 3/21/20
//

/// A data structure which guarantees unique membership and preserves lement ordering
public struct OrderedSet<E: Hashable>: RandomAccessCollection, Equatable, Hashable {
  public typealias Element = E
  public typealias Index = Int
  public typealias Indices = Range<Int>

  private var set: Set<Element>
  private var array: [Element]

  public init() {
    set = .init()
    array = []
  }

  public init(minimumCapacity: Int) {
    set = .init(minimumCapacity: minimumCapacity)
    array = []
    array.reserveCapacity(minimumCapacity)
  }

  public init(_ array: [Element]) {
    self.init(minimumCapacity: array.count)
    for element in array { append(element) }
  }

  // MARK: Working with OrderedSet

  /// The number of elements in the ordered set
  public var count: Int {
    array.count
  }

  /// Whether the oredered set is empty
  public var isEmpty: Bool {
    array.isEmpty
  }

  /// A copy of the contents of the ordered set as an array
  public var contents: [Element] { array }

  /// Checks whether the ordered set contains a given element
  /// - Parameter member: The element to test for membership
  /// - Complexity: `O(1)`
  /// - Returns: `true` if the elemenr is a member, `false` otherwise
  public func contains(_ member: Element) -> Bool {
    set.contains(member)
  }

  /// Append a new element to the ordered set
  /// - Parameter newElement: The element to insert
  /// - Complexity: `Theta(1)` (constant on average)
  /// - Returns: `true` if the element was inserted, `false` otherwise
  @discardableResult
  public mutating func append(_ newElement: Element) -> Bool {
    let didInsert = set.insert(newElement).inserted
    if didInsert { array.append(newElement) }
    return didInsert
  }

  /// Removes the given `element` from the ordered set
  /// - Parameter element: The element to remove
  /// - Complexity: `O(n)`
  /// - Returns: A tuple with the first element being the element removed and the second element being its index, or nil if the element did not belong to the ordered set
  @discardableResult
  public mutating func remove(_ element: Element) -> (Element, Index)? {
    guard let element = set.remove(element) else {
      return nil
    }
    let index = array.firstIndex(of: element)!
    array.remove(at: index)
    return (element, index)
  }

  /// Removes the element at a given `index`
  /// - Parameter index: The position of the element to remove
  /// - Complexity: `O(1)`
  /// - Returns: The element that was removed at the specified `index`
  public mutating func remove(at index: Index) -> Element {
    let element = array.remove(at: index)
    set.remove(element)
    return element
  }

  /// Remove the first element in the ordered set
  public mutating func removeFirst() -> Element {
    let first = array.removeFirst()
    set.remove(first)
    return first
  }

  /// Remove the last element in the ordered set
  public mutating func removeLast() -> Element {
    let last = array.removeLast()
    set.remove(last)
    return last
  }

  /// Remove all elements from the ordered set
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    array.removeAll(keepingCapacity: keepCapacity)
    set.removeAll(keepingCapacity: keepCapacity)
  }

  // MARK: RandomAccessCollection compliance

  public var startIndex: Int { array.startIndex }
  public var endIndex: Int { array.endIndex }
  public subscript(position: Int) -> Element {
    array[position]
  }
}

extension OrderedSet: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
