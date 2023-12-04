import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case invalidFileComponents
  case missingMoveCount
  case missingMoveFrom
  case missingMoveTo
  case invalidCranesDefinition
  case malformedCranesDefinition
}

struct Move {
  let count: Int
  let from: Int
  let to: Int

  init(rawValue: String) throws {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = .whitespacesAndNewlines

    _ = scanner.scanString("move")
    guard let count = scanner.scanInt()
    else { throw UnexpectedError.missingMoveCount }
    self.count = count

    _ = scanner.scanString("from")
    guard let from = scanner.scanInt()
    else { throw UnexpectedError.missingMoveFrom }
    self.from = from

    _ = scanner.scanString("to")
    guard let to = scanner.scanInt()
    else { throw UnexpectedError.missingMoveTo }
    self.to = to
  }
}

struct Level {
  var crates: [Character?]

  init(rawValue: String) throws {
    crates = []

    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = CharacterSet()

    while !scanner.isAtEnd {
      defer { _ = scanner.scanString(" ") }

      if scanner.scanString("   ") != nil {
        crates.append(nil)
        continue
      }

      _ = scanner.scanString("[")
      guard let crate = scanner.scanCharacter()
      else { throw UnexpectedError.invalidCranesDefinition }
      _ = scanner.scanString("]")
      crates.append(crate)
    }
  }
}

struct Ship {
  var stacks: [[Character]]

  init(levels: [Level]) {
    let count = levels.first?.crates.count ?? 0
    stacks = [[Character]](repeating: [], count: count)

    for level in levels.reversed() {
      for (index, crate) in level.crates.enumerated() {
        if let crate = crate {
          stacks[index].append(crate)
        }
      }
    }
  }

  mutating func performCrateMover9000(_ move: Move) throws {
    for _ in 0 ..< move.count {
      let (from, to) = (move.from-1, move.to-1)
      let crate = stacks[from].removeLast()
      stacks[to].append(crate)
    }
  }

  mutating func performCrateMover9001(_ move: Move) throws {
    let (from, to) = (move.from-1, move.to-1)
    let crates = Array(stacks[from].suffix(move.count))
    stacks[from].removeLast(move.count)
    stacks[to].append(contentsOf: crates)
  }

  var topCrates: [Character] {
    stacks.map { stack in
      stack.last ?? " "
    }
  }
}

struct Configuration {
  let levels: [Level]
  let moves: [Move]

  init(rawValue: String) throws {
    let lines = rawValue.components(separatedBy: "\n")
    let components = lines.split(separator: "")
    guard components.count == 2
    else { throw UnexpectedError.invalidFileComponents }

    levels = try components[0].dropLast().map { line in
      try Level(rawValue: String(line))
    }

    moves = try components[1].map { line in
      try Move(rawValue: String(line))
    }
  }
}

func part1() throws -> String {
  let string = try String(contentsOfFile: "input/1.txt")
  let config = try Configuration(rawValue: string)
  var ship = Ship(levels: config.levels)
  for move in config.moves {
    try ship.performCrateMover9000(move)
  }
  return String(ship.topCrates)
}

func part2() throws -> String {
  let string = try String(contentsOfFile: "input/2.txt")
  let config = try Configuration(rawValue: string)
  var ship = Ship(levels: config.levels)
  for move in config.moves {
    try ship.performCrateMover9001(move)
  }
  return String(ship.topCrates)
}
