import Foundation

struct Position: Hashable {
  let x: Int
  let y: Int
  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  static let validPipesForDirection: [Direction: Set<Character>] = [
    .u: ["S", "|", "┌", "┐"],
    .d: ["S", "|", "┘", "└"],
    .l: ["S", "-", "└", "┌"],
    .r: ["S", "-", "┐", "┘"],
  ]

  static let validDirectionsForPipe: [Character: Set<Direction>] = [
    "S": [.u, .d, .l, .r],
    "|": [.u, .d],
    "-": [.l, .r],
    "┌": [.d, .r],
    "┐": [.d, .l],
    "└": [.u, .r],
    "┘": [.u, .l],
  ]

  func isValid(for direction: Direction) -> Bool {
    guard y >= 0, y < characters.count
    else { return false }
    guard x >= 0, x < characters[0].count
    else { return false }
    return Self.validPipesForDirection[direction]!
      .contains(characters[y][x])
  }

  func next(in direction: Direction) -> Position {
    switch direction {
    case .u: return .init(x, y-1)
    case .d: return .init(x, y+1)
    case .l: return .init(x-1, y)
    case .r: return .init(x+1, y)
    }
  }

  var next: [Position] {
    var result: [Position] = []
    for direction in Self.validDirectionsForPipe[characters[y][x]]! {
      let position = next(in: direction)
      if position.isValid(for: direction) {
        result.append(position)
      }
    }
    return result
  }
}

struct Path {
  var values: [Position]
  var visited: Set<Position>

  mutating func append(_ position: Position) {
    values.append(position)
    visited.formUnion([position])
  }

  func appending(_ position: Position) -> Path {
    var path = self
    path.append(position)
    return path
  }
}

enum Direction: CaseIterable {
  case u, d, l, r
}

func findLoop(from startingPosition: Position) -> Path? {
  var paths = [Path(values: [startingPosition], visited: [startingPosition])]
  var step = 0
  while !paths.isEmpty {
    defer { step += 1 }
    var newPaths: [Path] = []
    for path in paths {
      let nextPositions = path.values.last!.next
      for nextPosition in nextPositions {
        if nextPosition == startingPosition, path.values.count > 2 {
          return path.appending(startingPosition)
        } else if !path.visited.contains(nextPosition) {
          let newPath = path.appending(nextPosition)
          newPaths.append(newPath)
        }
      }
    }
    paths = newPaths
  }
  return nil
}

guard let file = FileHandle(forReadingAtPath: "10.in")
else { fatalError("input not found") }

var characters: [[Character]] = []
for try await line in file.bytes.lines {
  characters.append(Array(line))
}

var startingPosition: Position?
for y in 0 ..< characters.count {
  for x in 0 ..< characters[y].count {
    let symbol = characters[y][x]
    switch symbol {
    case "S": startingPosition = .init(x, y)
    case "L": characters[y][x] = "└"
    case "J": characters[y][x] = "┘"
    case "7": characters[y][x] = "┐"
    case "F": characters[y][x] = "┌"
    case "|", "-", ".": continue
    default: fatalError("unknown symbol: \(symbol)")
    }
  }
}

guard let startingPosition else {
  fatalError("starting position not found")
}

guard let loop = findLoop(from: startingPosition) else {
  fatalError("no loop found")
}

let part1 = loop.values.count/2
print(part1)

let pipeTiles: [Character: [[Character]]] = [
  "|": [
    [".", "x", "."],
    [".", "x", "."],
    [".", "x", "."],
  ],
  "-": [
    [".", ".", "."],
    ["x", "x", "x"],
    [".", ".", "."],
  ],
  "┌": [
    [".", ".", "."],
    [".", "x", "x"],
    [".", "x", "."],
  ],
  "┐": [
    [".", ".", "."],
    ["x", "x", "."],
    [".", "x", "."],
  ],
  "└": [
    [".", "x", "."],
    [".", "x", "x"],
    [".", ".", "."],
  ],
  "┘": [
    [".", "x", "."],
    ["x", "x", "."],
    [".", ".", "."],
  ],
  "S": [
    ["x", "x", "x"],
    ["x", "x", "x"],
    ["x", "x", "x"],
  ],
]

let emptyZoomedTile: [[Character]] = [
  [".", ".", "."],
  [".", ".", "."],
  [".", ".", "."],
]

var tiles: [[Character]] = []
for y in 0 ..< characters.count {
  tiles.append([])
  tiles.append([])
  tiles.append([])
  for x in 0 ..< characters[y].count {
    let value = characters[y][x]
    let isOnPath = loop.values.contains(.init(x, y))
    let tileRow1: [Character]
    let tileRow2: [Character]
    let tileRow3: [Character]
    if isOnPath, let tile = pipeTiles[value] {
      tileRow1 = tile[0]
      tileRow2 = tile[1]
      tileRow3 = tile[2]
    } else {
      tileRow1 = emptyZoomedTile[0]
      tileRow2 = emptyZoomedTile[1]
      tileRow3 = emptyZoomedTile[2]
    }
    tiles[(y*3)+0].append(contentsOf: tileRow1)
    tiles[(y*3)+1].append(contentsOf: tileRow2)
    tiles[(y*3)+2].append(contentsOf: tileRow3)
  }
}

var visited: Set<Position> = []
var queue: Set<Position> = [.init(0, 0)]
while !queue.isEmpty {
  let position = queue.removeFirst()
  visited.insert(position)

  var neighbors: [Position] = []
  if position.y > 0 {
    neighbors.append(.init(position.x, position.y-1))
  }
  if position.y < tiles.count-1 {
    neighbors.append(.init(position.x, position.y+1))
  }
  if position.x > 0 {
    neighbors.append(.init(position.x-1, position.y))
  }
  if position.x < tiles[0].count-1 {
    neighbors.append(.init(position.x+1, position.y))
  }

  for neighbor in neighbors {
    let value = tiles[neighbor.y][neighbor.x]
    if value == ".", !visited.contains(neighbor) {
      queue.insert(neighbor)
    }
  }
}

for y in 0 ..< tiles.count {
  for x in 0 ..< tiles[y].count {
    if visited.contains(.init(x, y)) {
      tiles[y][x] = " "
    }
  }
}

var part2 = 0
for y in 0 ..< tiles.count where y%3 == 1 {
  for x in 0 ..< tiles[y].count where x%3 == 1 {
    if tiles[y][x] == ".", !visited.contains(.init(x, y)) {
      part2 += 1
    }
  }
}

print(part2)
