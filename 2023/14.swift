import Foundation

enum Rock: Character {
  case empty = "."
  case round = "O"
  case cube = "#"
}

extension Rock: CustomStringConvertible {
  var description: String { String(rawValue) }
}

enum Direction: CaseIterable {
  case north, west, south, east

  var isHorizontal: Bool {
    switch self {
    case .north, .south: false
    case .east, .west: true
    }
  }

  var isForward: Bool {
    switch self {
    case .north, .west: false
    case .south, .east: true
    }
  }
}

typealias Grid = [[Rock]]

extension Grid {
  var totalLoad: Int {
    var sum = 0
    for rowIndex in indices {
      for rock in self[rowIndex] {
        if case .round = rock {
          sum += count-rowIndex
        }
      }
    }
    return sum
  }

  mutating func tilt(_ direction: Direction) {
    guard let first else { return }

    var outerIndices = first.indices
    var innerIndices = indices
    if direction.isHorizontal { swap(&outerIndices, &innerIndices) }

    for outerIndex in outerIndices {
      var innerIndices = innerIndices.map { $0 }
      if direction.isForward { innerIndices.reverse() }
      var tiltedColumn: [Rock] = []
      var roundCount = 0
      var emptyCount = 0
      for innerIndex in innerIndices {
        var rowIndex = innerIndex
        var colIndex = outerIndex
        if direction.isHorizontal { swap(&rowIndex, &colIndex) }
        let rock = self[rowIndex][colIndex]
        switch rock {
        case .empty: emptyCount += 1
        case .round: roundCount += 1
        case .cube:
          tiltedColumn += [Rock](repeating: .round, count: roundCount)
          tiltedColumn += [Rock](repeating: .empty, count: emptyCount)
          tiltedColumn += [.cube]
          roundCount = 0
          emptyCount = 0
        }
      }

      tiltedColumn += [Rock](repeating: .round, count: roundCount)
      tiltedColumn += [Rock](repeating: .empty, count: emptyCount)
      if direction.isForward { tiltedColumn.reverse() }

      for innerIndex in innerIndices {
        var rowIndex = innerIndex
        var colIndex = outerIndex
        if direction.isHorizontal { swap(&rowIndex, &colIndex) }
        self[rowIndex][colIndex] = tiltedColumn[innerIndex]
      }
    }
  }
}

guard let file = FileHandle(forReadingAtPath: "14.in")
else { fatalError("input not found") }

var grid: Grid = []
for try await line in file.bytes.lines {
  let scanner = Scanner(string: line)

  grid.append([])
  while let character = scanner.scanCharacter() {
    if let rock = Rock(rawValue: character) {
      grid[grid.count-1].append(rock)
    } else {
      fatalError("unexpected character '\(character)'")
    }
  }
}

var grids: [Grid: [Int]] = [:]
let iterationsCount = 1_000_000_000
var iteration = 0
while iteration < iterationsCount {
  iteration += 1

  for direction in Direction.allCases {
    grid.tilt(direction)
    if direction == .north, iteration == 1 {
      print(grid.totalLoad)
    }
  }

  if let previousIterations = grids[grid] {
    let cycleLength = iteration-previousIterations.last!
    let remainingIterations = (iterationsCount-iteration)/cycleLength
    iteration += remainingIterations*cycleLength
  } else {
    grids[grid, default: []].append(iteration)
  }
}

print(grid.totalLoad)
