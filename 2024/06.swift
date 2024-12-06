import Foundation

guard let input = try? String(contentsOfFile: "06.in", encoding: .utf8)
else { fatalError("input not found") }

enum Direction: Hashable {
  case u, d, l, r

  var next: Direction {
    switch self {
    case .u: .r
    case .d: .l
    case .l: .u
    case .r: .d
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
    switch direction {
    case .u: .init(row-1, col)
    case .d: .init(row+1, col)
    case .l: .init(row, col-1)
    case .r: .init(row, col+1)
    }
  }
}

struct State: Hashable {
  var point: Point
  var direction: Direction
}

typealias Grid = [[Character]]

extension Grid {
  subscript(_ point: Point) -> Character {
    get { self[point.row][point.col] }
    set { self[point.row][point.col] = newValue }
  }

  func contains(_ point: Point) -> Bool {
    point.row >= 0 && point.row < count &&
      point.col >= 0 && point.col < self[point.row].count
  }
}

var grid = input.components(separatedBy: "\n").map(Array.init)

var start: Point?
loop: for row in grid.indices {
  for col in grid[row].indices {
    let point = Point(row, col)
    if grid[point] == "^" {
      start = point
      break
    }
  }
}

guard let start
else { fatalError("start not found") }

func visit(from start: Point) -> Set<Point>? {
  var states: Set<State> = []
  var path: Set<Point> = []
  var state = State(point: start, direction: .u)

  while grid.contains(state.point) {
    let (inserted, _) = states.insert(state)
    guard inserted else { return nil }
    path.insert(state.point)

    var next: Point { state.point.next(in: state.direction) }
    while grid.contains(next), grid[next] == "#" {
      state.direction = state.direction.next
    }

    state.point = next
  }

  return path
}

guard let path = visit(from: start)
else { fatalError("invalid initial path") }

print(path.count)

var loopingObstructions = 0
for point in path.subtracting([start]) {
  grid[point] = "#"
  if visit(from: start) == nil { loopingObstructions += 1 }
  grid[point] = "."
}

print(loopingObstructions)
