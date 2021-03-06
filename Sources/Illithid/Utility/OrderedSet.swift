// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

// MARK: - OrderedSet

/// A data structure which guarantees unique membership and preserves lement ordering
public struct OrderedSet<E: Hashable>: RandomAccessCollection, Equatable, Hashable {
  // MARK: Lifecycle

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

  // MARK: Public

  public typealias Element = E
  public typealias Index = Int
  public typealias Indices = Range<Int>

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

  // MARK: RandomAccessCollection compliance

  public var startIndex: Int { array.startIndex }
  public var endIndex: Int { array.endIndex }

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

  public subscript(position: Int) -> Element {
    array[position]
  }

  // MARK: Private

  private var set: Set<Element>
  private var array: [Element]
}

// MARK: ExpressibleByArrayLiteral

extension OrderedSet: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
