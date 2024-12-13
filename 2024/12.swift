import Foundation

guard let input = try? String(contentsOfFile: "12.in", encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
let grid = lines.map(Array.init)
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

var part1 = 0
var part2 = 0
var visited: Set<Point> = []
for row in 0 ..< rows {
  for col in 0 ..< cols {
    let start = Point(row, col)
    guard !visited.contains(start) else { continue }

    var area = 0
    var perimeter = 0
    var perimeterPoints: [Direction: Set<Point>] = [:]
    var stack: [Point] = [start]
    while let point = stack.popLast() {
      guard !visited.contains(point) else { continue }
      visited.insert(point)
      area += 1

      for direction in Direction.allCases {
        let neighbor = point.next(in: direction)
        if grid.contains(neighbor), grid[neighbor] == grid[point] {
          stack.append(neighbor)
        } else {
          perimeter += 1
          perimeterPoints[direction, default: []].insert(point)
        }
      }
    }

    part1 += area*perimeter

    var sides = 0
    for (_, points) in perimeterPoints {
      var visited: Set<Point> = []
      for start in points {
        guard !visited.contains(start) else { continue }
        sides += 1

        var stack: [Point] = [start]
        while let point = stack.popLast() {
          guard !visited.contains(point) else { continue }
          visited.insert(point)

          for direction in Direction.allCases {
            let neighbor = point.next(in: direction)
            if points.contains(neighbor) {
              stack.append(neighbor)
            }
          }
        }
      }
    }

    part2 += area*sides
  }
}

print(part1)
print(part2)
