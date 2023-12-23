import Foundation

enum Direction: Character, CaseIterable, Equatable {
  case up = "^"
  case right = ">"
  case down = "v"
  case left = "<"
}

enum Location: Equatable {
  case forest
  case path
  case slope(Direction)
  init?(rawValue: Character) {
    if rawValue == "#" {
      self = .forest
    } else if rawValue == "." {
      self = .path
    } else if let direction = Direction(rawValue: rawValue) {
      self = .slope(direction)
    } else {
      return nil
    }
  }
}

struct Coordinate: Hashable {
  var x: Int
  var y: Int
  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  func neighbour(in direction: Direction) -> Coordinate {
    switch direction {
    case .up: .init(x, y-1)
    case .down: .init(x, y+1)
    case .left: .init(x-1, y)
    case .right: .init(x+1, y)
    }
  }
}

typealias Map = [[Location]]

extension Map {
  func canWalk(at coordinate: Coordinate) -> Bool {
    indices.contains(coordinate.y)
      && self[coordinate.y].indices ~= coordinate.x
      && self[coordinate.y][coordinate.x] != .forest
  }
}

struct Path {
  var destination: Coordinate
  var stepsCount = 0
}

guard let file = FileHandle(forReadingAtPath: "23.in")
else { fatalError("input not found") }

var map: [[Location]] = []
for try await line in file.bytes.lines {
  map.append(line.compactMap(Location.init))
}

var entrance: Coordinate?
for (x, location) in (map.first ?? []).enumerated() {
  if case .path = location {
    entrance = .init(x, 0)
  }
}

var exit: Coordinate?
for (x, location) in (map.last ?? []).enumerated() {
  if case .path = location {
    exit = .init(x, map.count-1)
  }
}

guard let entrance, let exit
else { fatalError("entrance/exit not found") }

var crossroads: Set<Coordinate> = [entrance, exit]
for y in map.indices {
  for x in map[y].indices {
    let coordinate = Coordinate(x, y)
    guard map.canWalk(at: coordinate) else { continue }

    var paths = 0
    for direction in Direction.allCases {
      let neighbour = coordinate.neighbour(in: direction)
      if map.canWalk(at: neighbour) {
        paths += 1
      }
    }

    guard paths > 2 else { continue }
    crossroads.insert(coordinate)
  }
}

func maxStepsCount(ignoringSlides: Bool = false) -> Int {
  var paths: [Coordinate: [Path]] = [:]
  for crossroad in crossroads {
    var visited: Set<Coordinate> = []
    var frontier = [(crossroad, 0)]
    while let (coordinate, stepsCount) = frontier.popLast() {
      guard !visited.contains(coordinate) else { continue }
      visited.insert(coordinate)

      if crossroads.contains(coordinate), coordinate != crossroad {
        paths[crossroad, default: []].append(
          Path(destination: coordinate, stepsCount: stepsCount)
        )
      } else {
        let location = map[coordinate.y][coordinate.x]
        var directions = Direction.allCases
        if !ignoringSlides, case let .slope(direction) = location {
          directions = [direction]
        }

        for direction in directions {
          let neighbour = coordinate.neighbour(in: direction)
          if map.canWalk(at: neighbour) {
            frontier.append((neighbour, stepsCount+1))
          }
        }
      }
    }
  }

  var maxStepsCount = 0
  var visited: Set<Coordinate> = []
  func visit(_ coordinate: Coordinate, _ stepsCount: Int) {
    guard !visited.contains(coordinate) else { return }
    visited.insert(coordinate)
    defer { visited.remove(coordinate) }

    for edge in paths[coordinate, default: []] {
      visit(edge.destination, stepsCount+edge.stepsCount)
    }
    if coordinate == exit {
      maxStepsCount = max(maxStepsCount, stepsCount)
    }
  }

  visit(entrance, 0)
  return maxStepsCount
}

print(maxStepsCount())
print(maxStepsCount(ignoringSlides: true))
