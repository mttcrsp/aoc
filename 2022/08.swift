import Foundation

enum Direction: CaseIterable {
  case n, s, w, e
}

struct Location {
  let row: Int
  let col: Int
  init(_ row: Int, _ col: Int) {
    self.row = row
    self.col = col
  }

  func adjacent(in direction: Direction) -> Location {
    switch direction {
    case .n: return .init(row-1, col)
    case .s: return .init(row+1, col)
    case .w: return .init(row, col-1)
    case .e: return .init(row, col+1)
    }
  }
}

struct Forest {
  var heights: [[Int]]
  var rows: Int { heights.count }
  var cols: Int { heights.first?.count ?? 0 }
  var treesCount: Int { rows*cols }

  init() async throws {
    guard let file = FileHandle(forReadingAtPath: "08.in")
    else { fatalError("input not found") }

    heights = []
    for try await line in file.bytes.lines {
      var row: [Int] = []
      for character in line {
        guard let height = Int(String(character))
        else { fatalError("invalid character in '\(character)'") }
        row.append(height)
      }
      heights.append(row)
    }
  }

  func height(at location: Location) -> Int {
    heights[location.row][location.col]
  }

  func adjacent(to location: Location, in direction: Direction) -> Location? {
    let adjacent = location.adjacent(in: direction)
    guard adjacent.row >= 0, adjacent.row < rows else { return nil }
    guard adjacent.col >= 0, adjacent.col < cols else { return nil }
    return adjacent
  }

  func isTreeVisible(at location: Location, from direction: Direction) -> Bool {
    var current = location
    while let adjacent = adjacent(to: current, in: direction) {
      defer { current = adjacent }
      if height(at: adjacent) >= height(at: location) {
        return false
      }
    }

    return true
  }

  func isTreeVisible(at location: Location) -> Bool {
    for direction in Direction.allCases {
      if isTreeVisible(at: location, from: direction) {
        return true
      }
    }

    return false
  }

  func scenicScore(for location: Location, in direction: Direction) -> Int {
    var score = 0
    var current = location
    while let adjacent = adjacent(to: current, in: direction) {
      defer { current = adjacent }
      score += 1
      if height(at: adjacent) >= height(at: location) {
        break
      }
    }

    return score
  }

  func scenicScore(for location: Location) -> Int {
    var score = 1
    for direction in Direction.allCases {
      score *= scenicScore(for: location, in: direction)
    }

    return score
  }
}

func part1() async throws -> Int {
  let forest = try await Forest()

  var nonVisibleTreesCount = 0
  for row in 1 ..< forest.rows-1 {
    for col in 1 ..< forest.cols-1 {
      let location = Location(row, col)
      let isVisible = forest.isTreeVisible(at: location)
      if !isVisible {
        nonVisibleTreesCount += 1
      }
    }
  }

  return forest.treesCount-nonVisibleTreesCount
}

func part2() async throws -> Int {
  let forest = try await Forest()

  var maximumScenicScore = 0
  for row in 1 ..< forest.rows-1 {
    for col in 1 ..< forest.cols-1 {
      let location = Location(row, col)
      let score = forest.scenicScore(for: location)
      maximumScenicScore = max(maximumScenicScore, score)
    }
  }

  return maximumScenicScore
}

try await print(part1())
try await print(part2())
