import Foundation

guard let input = try? String(contentsOfFile: "15.in", encoding: .utf8)
else { fatalError("input not found") }

enum Direction: Character, Hashable, CaseIterable {
  case u = "^", d = "v", l = "<", r = ">"
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

typealias Grid = [[Character]]

extension Grid {
  var rows: Int { count }
  var cols: Int { self[0].count }

  subscript(_ point: Point) -> Character {
    get { self[point.row][point.col] }
    set { self[point.row][point.col] = newValue }
  }
}

let movable: Set<Character> = ["O", "[", "]"]
let components = input.components(separatedBy: "\n\n")
let moves = components[1].replacingOccurrences(of: "\n", with: "").compactMap(Direction.init)
let smallGrid = components[0].components(separatedBy: "\n").map(Array.init)
let largeGrid = smallGrid.map { row in
  row.flatMap { character -> [Character] in
    switch character {
    case "#": ["#", "#"]
    case "O": ["[", "]"]
    case ".": [".", "."]
    case "@": ["@", "."]
    case let character:
      preconditionFailure("unexpected grid character '\(character)' found")
    }
  }
}

func gpsCoordinatesSum(for target: Character, in grid: Grid) -> Int {
  var start: Point?
  loop: for row in 0 ..< grid.rows {
    for col in 0 ..< grid.cols {
      if grid[row][col] == "@" {
        start = .init(row, col)
        break loop
      }
    }
  }

  guard let start else { fatalError("start not found") }

  var grid = grid
  var curr = start
  nextMove: for direction in moves {
    var visited: Set<Point> = []
    var stack: [Point] = [curr]
    while let point = stack.popLast() {
      guard !visited.contains(point) else { continue }
      visited.insert(point)

      if grid[point] == "[" {
        stack.append(point.next(in: .r))
      } else if grid[point] == "]" {
        stack.append(point.next(in: .l))
      }

      let next = point.next(in: direction)
      switch grid[next] {
      case let character where movable.contains(character):
        stack.append(next)
      case "#":
        continue nextMove // can not move anything as something is blocked
      default:
        continue
      }
    }

    var newGrid = grid
    for point in visited {
      newGrid[point] = "."
    }
    for point in visited {
      newGrid[point.next(in: direction)] = grid[point]
    }
    grid = newGrid
    curr = curr.next(in: direction)
  }

  var sum = 0
  for row in 0 ..< grid.rows {
    for col in 0 ..< grid.cols {
      if grid[row][col] == target {
        sum += 100*row+col
      }
    }
  }

  return sum
}

print(gpsCoordinatesSum(for: "O", in: smallGrid))
print(gpsCoordinatesSum(for: "[", in: largeGrid))
