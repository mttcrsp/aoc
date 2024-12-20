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

extension [[Character]] {
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

guard let input = try? String(contentsOfFile: "20.in", encoding: .utf8)
else { fatalError("input not found") }

let grid = input.components(separatedBy: "\n").map(Array.init)

var start: Point?
var path: Set<Point> = []
for row in grid.rowsIndices {
  for col in grid.colsIndices {
    let point = Point(row, col)
    let value = grid[point]
    if value != "#" {
      path.insert(point)
    }
    if value == "S" {
      start = point
    }
  }
}

guard let start else { fatalError("start not found") }

var distances: [Point: Int] = [start: 0]
var stack: [Point] = [start]
while let point = stack.popLast() {
  for direction in Direction.allCases {
    let next = point.next(in: direction)
    if path.contains(next), distances[next] == nil {
      distances[next] = distances[point]!+1
      stack.append(next)
    }
  }
}

var part1 = 0
var part2 = 0
for (point1, distance1) in distances {
  for (point2, distance2) in distances {
    let distance = abs(point1.row-point2.row)+abs(point1.col-point2.col)
    if distance == 2, distance2-distance1-distance >= 100 {
      part1 += 1
    }
    if distance < 21, distance2-distance1-distance >= 100 {
      part2 += 1
    }
  }
}

print(part1)
print(part2)
