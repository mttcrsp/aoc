import Algorithms
import Collections
import Foundation

let rows = 71, cols = 71, steps = 1024

enum Direction: Hashable, CaseIterable {
  case u, d, l, r
}

struct Point: Hashable {
  var row, col: Int

  init(_ row: Int, _ col: Int) {
    self.row = row
    self.col = col
  }

  func next(in direction: Direction) -> Point {
    switch direction {
    case .u: .init(row-1, col)
    case .d: .init(row+1, col)
    case .l: .init(row, col-1)
    case .r: .init(row, col+1)
    }
  }
}

extension Point: CustomStringConvertible {
  var description: String { "\(col),\(row)" }
}

typealias Grid = [[Character]]

extension Grid {
  subscript(_ point: Point) -> Character {
    get { self[point.row][point.col] }
    set { self[point.row][point.col] = newValue }
  }

  func contains(_ point: Point) -> Bool {
    point.row >= 0 && point.row < rows &&
      point.col >= 0 && point.col < cols
  }
}

guard let input = try? String(contentsOfFile: "18.in", encoding: .utf8)
else { fatalError("input not found") }

let points = input
  .components(separatedBy: "\n")
  .map { line in
    let components = line.components(separatedBy: ",")
    let col = Int(components[0])!
    let row = Int(components[1])!
    return Point(row, col)
  }

let gridRow = [Character](repeating: ".", count: cols)
var grid = [[Character]](repeating: gridRow, count: rows)

func shortestDistance() -> Int? {
  var queue: Deque<(Point, Int)> = [(Point(0, 0), 0)]
  var visited: Set<Point> = []
  while let (point, distance) = queue.popFirst() {
    guard !visited.contains(point) else { continue }
    visited.insert(point)

    if point == .init(rows-1, cols-1) {
      return distance
    }

    for direction in Direction.allCases {
      let next = point.next(in: direction)
      if grid.contains(next), grid[next] != "#" {
        queue.append((next, distance+1))
      }
    }
  }

  return nil
}

for point in points.prefix(1024) {
  grid[point.row][point.col] = "#"
}

print(shortestDistance()!)

for point in points.dropFirst(1024) {
  grid[point.row][point.col] = "#"

  if shortestDistance() == nil {
    print(point)
    break
  }
}
