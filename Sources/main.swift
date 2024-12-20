import Algorithms
import Collections
import Foundation

enum Direction: CaseIterable {
  case up, down, left, right
  var delta: (row: Int, col: Int) {
    switch self {
    case .up: (-1, 0)
    case .down: (+1, 0)
    case .left: (0, -1)
    case .right: (0, +1)
    }
  }
}

struct Point: Hashable {
  var row, col: Int
  init(_ row: Int, _ col: Int) {
    self.row = row
    self.col = col
  }

  func next(in direction: Direction) -> Point {
    var next = self
    next.row += direction.delta.row
    next.col += direction.delta.col
    return next
  }
}

extension Point: CustomDebugStringConvertible {
  var debugDescription: String {
    "(\(row),\(col))"
  }
}

extension Point: Comparable {
  static func < (_ lhs: Self, _ rhs: Self) -> Bool {
    guard lhs.row == rhs.row else { return lhs.row < rhs.row }
    return lhs.col < rhs.col
  }
}

extension [[Character]] {
  var rowsCount: Int { count }
  var colsCount: Int { self[0].count }
  var rowsIndices: Range<Int> { indices }
  var colsIndices: Range<Int> { self[0].indices }
  func contains(_ point: Point) -> Bool {
    rowsIndices ~= point.row && colsIndices ~= point.col
  }

  subscript(_ point: Point) -> Character {
    get { self[point.row][point.col] }
    set { self[point.row][point.col] = newValue }
  }
}

let args = ProcessInfo.processInfo.arguments
let file = args.contains("ex") ? "ex" : "in"

guard let input = try? String(contentsOfFile: file, encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
print(lines)
