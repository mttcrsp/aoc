import Collections
import Foundation

enum Direction: Hashable, CaseIterable {
  case u, d, l, r

  var clockwise: Direction {
    switch self {
    case .u: .r
    case .d: .l
    case .l: .u
    case .r: .d
    }
  }

  var counterClockwise: Direction {
    switch self {
    case .u: .l
    case .d: .r
    case .l: .d
    case .r: .u
    }
  }

  var opposite: Direction {
    switch self {
    case .u: .d
    case .d: .u
    case .l: .r
    case .r: .l
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

typealias Grid = [[Character]]

extension Grid {
  var rows: Int { count }
  var cols: Int { self[0].count }

  subscript(_ point: Point) -> Character {
    get { self[point.row][point.col] }
    set { self[point.row][point.col] = newValue }
  }
}

struct State: Hashable {
  var point: Point
  var direction: Direction
}

struct StateWithScore: Comparable {
  var state: State
  var score: Int = 0
  static func < (_ lhs: Self, _ rhs: Self) -> Bool {
    lhs.score < rhs.score
  }
}

guard let input = try? String(contentsOfFile: "16.in", encoding: .utf8)
else { fatalError("input not found") }

var grid = input.components(separatedBy: "\n").map(Array.init)

var start: Point?
var end: Point?
for row in 0 ..< grid.rows {
  for col in 0 ..< grid.cols {
    let point = Point(row, col)
    switch grid[point] {
    case "S":
      start = point
      grid[point] = "."
    case "E":
      end = point
      grid[point] = "."
    default:
      continue
    }
  }
}

guard let start else { fatalError("start not found") }
guard let end else { fatalError("end not found") }

@MainActor func visit(from starts: [State], end: Point? = nil, reversed: Bool = false) -> (best: Int?, scores: [State: Int]) {
  var queue: Heap<StateWithScore> = []
  for state in starts {
    queue.insert(.init(state: state))
  }

  var scores: [State: Int] = [:]
  var visited: Set<State> = []
  while let item = queue.popMin() {
    if scores[item.state] == nil {
      scores[item.state] = item.score
    }

    if item.state.point == end {
      return (item.score, scores)
    }

    guard !visited.contains(item.state) else { continue }
    visited.insert(item.state)

    let direction = item.state.direction

    var nextClockwise = item
    nextClockwise.state.direction = direction.clockwise
    nextClockwise.score += 1000
    queue.insert(nextClockwise)

    var nextCounterClockwise = item
    nextCounterClockwise.state.direction = direction.counterClockwise
    nextCounterClockwise.score += 1000
    queue.insert(nextCounterClockwise)

    let nextDirection = reversed ? item.state.direction.opposite : item.state.direction
    let next = item.state.point.next(in: nextDirection)
    if grid[next] != "#" {
      var nextForward = item
      nextForward.state.point = next
      nextForward.score += 1
      queue.insert(nextForward)
    }
  }

  return (nil, scores)
}

let starts: [State] = [.init(point: start, direction: .r)]
let (best, scores) = visit(from: starts, end: end)
guard let best else { fatalError("path not found") }
print(best)

let reverseStarts: [State] = Direction.allCases.map { .init(point: end, direction: $0) }
let (_, reverseScores) = visit(from: reverseStarts, reversed: true)

var seats: Set<Point> = []
for row in 0 ..< grid.rows {
  for col in 0 ..< grid.cols {
    for direction in Direction.allCases {
      let score = scores[.init(point: .init(row, col), direction: direction)]
      let reverseScore = reverseScores[.init(point: .init(row, col), direction: direction)]
      if let score, let reverseScore, score+reverseScore == best {
        seats.insert(.init(row, col))
      }
    }
  }
}

print(seats.count)
