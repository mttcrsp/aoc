import Foundation

enum Direction: CaseIterable {
  case up, down, left, right
}

enum Location: Character {
  case garden = "."
  case rock = "#"
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
  var rowsCount: Int { count }
  var colsCount: Int { self[0].count }
  subscript(_ coordinate: Coordinate) -> Location {
    let loopingX = (coordinate.x+(abs(coordinate.x/colsCount)+1)*colsCount)%colsCount
    let loopingY = (coordinate.y+(abs(coordinate.y/rowsCount)+1)*rowsCount)%rowsCount
    return self[loopingY][loopingX]
  }
}

func interpolate(a: Int, b: Int, c: Int, target t: Int) -> Int {
  ((a*t*t)-(3*a*t)+(2*a)-(2*b*t*t)+(4*b*t)+(c*t*t)-(c*t))/2
}

guard let file = FileHandle(forReadingAtPath: "21.in")
else { fatalError("input not found") }

var start: Coordinate?
var map: Map = []
for try await line in file.bytes.lines {
  map.append(
    line.enumerated().map { index, character in
      if let location = Location(rawValue: character) {
        return location
      } else if character == "S" {
        start = .init(index, map.count)
        return .garden
      } else {
        fatalError("unexpected character '\(character)'")
      }
    }
  )
}

guard let start = start
else { fatalError("start not found") }

let targetStepsCount1 = 64
let targetStepsCount2 = 26_501_365
let stepsCountA = start.y
let stepsCountB = start.y+map.rowsCount
let stepsCountC = start.y+map.rowsCount*2
var pathsCountA: Int?
var pathsCountB: Int?
var pathsCountC: Int?

var coordinatesSet = Set<Coordinate>([start])
for stepsCount in 1 ... stepsCountC {
  var newCoordinatesSet = Set<Coordinate>()
  for coordinate in coordinatesSet {
    for direction in Direction.allCases {
      let neighbour = coordinate.neighbour(in: direction)
      if case .garden = map[neighbour] {
        newCoordinatesSet.insert(neighbour)
      }
    }
  }

  switch stepsCount {
  case targetStepsCount1: print(newCoordinatesSet.count)
  case stepsCountA: pathsCountA = newCoordinatesSet.count
  case stepsCountB: pathsCountB = newCoordinatesSet.count
  case stepsCountC: pathsCountC = newCoordinatesSet.count
  default: break
  }

  coordinatesSet = newCoordinatesSet
}

guard let pathsCountA, let pathsCountB, let pathsCountC
else { fatalError("failed to record paths counts") }

let target = targetStepsCount2/map.rowsCount
print(interpolate(a: pathsCountA, b: pathsCountB, c: pathsCountC, target: target))
