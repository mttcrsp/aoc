import Foundation

guard let input = try? String(contentsOfFile: "10.in", encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
let grid = lines.map { line in
  var result: [Int] = []
  for character in line {
    if let digit = Int(String(character)) {
      result.append(digit)
    }
  }
  return result
}

let rows = grid.count
let cols = grid[0].count

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

  var neighbors: [Point] {
    var result: [Point] = []
    for direction in Direction.allCases {
      let next = next(in: direction)
      if grid.contains(next) {
        result.append(next)
      }
    }
    return result
  }
}

typealias Grid = [[Int]]

extension Grid {
  subscript(_ point: Point) -> Int {
    get { self[point.row][point.col] }
    set { self[point.row][point.col] = newValue }
  }

  func contains(_ point: Point) -> Bool {
    point.row >= 0 && point.row < rows &&
      point.col >= 0 && point.col < cols
  }
}

var trailheads: [Point] = []
for row in 0 ..< rows {
  for col in 0 ..< cols {
    if grid[row][col] == 0 {
      trailheads.append(.init(row, col))
    }
  }
}

var part1 = 0
var part2 = 0
for trailhead in trailheads {
  var ends: Set<[Point]> = []
  var paths: Set<[Point]> = []
  var stack: [(path: [Point], Point)] = [([trailhead], trailhead)]
  while let (path, point) = stack.popLast() {
    let value = grid[point]
    for neighbor in point.neighbors {
      let neighborValue = grid[neighbor]
      if value+1 == neighborValue {
        if neighborValue == 9 {
          ends.insert([path.first!, neighbor])
          paths.insert(path+[neighbor])
        } else {
          stack.append((path+[neighbor], neighbor))
        }
      }
    }
  }
  part1 += ends.count
  part2 += paths.count
}

print(part1)
print(part2)
