import Foundation

struct Move {
  let count: Int
  let from: Int
  let to: Int

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = .whitespacesAndNewlines

    _ = scanner.scanString("move")
    guard let count = scanner.scanInt()
    else { fatalError("move count not found in '\(rawValue)'") }
    self.count = count

    _ = scanner.scanString("from")
    guard let from = scanner.scanInt()
    else { fatalError("from component not found in '\(rawValue)'") }
    self.from = from

    _ = scanner.scanString("to")
    guard let to = scanner.scanInt()
    else { fatalError("to component not found in '\(rawValue)'") }
    self.to = to
  }
}

struct Level {
  var crates: [Character?]

  init(rawValue: String) {
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
      else { fatalError("invalid crates definition '\(rawValue)'") }
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

  mutating func performCrateMover9000(_ move: Move) {
    for _ in 0 ..< move.count {
      let (from, to) = (move.from-1, move.to-1)
      let crate = stacks[from].removeLast()
      stacks[to].append(crate)
    }
  }

  mutating func performCrateMover9001(_ move: Move) {
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
  init(rawValue: String) {
    let lines = rawValue.components(separatedBy: "\n")
    let components = lines.split(separator: "")
    guard components.count == 2
    else { fatalError("unable to split input in levels and moves component: \(components.count) components found") }
    levels = components[0].dropLast().map { Level(rawValue: String($0)) }
    moves = components[1].map { Move(rawValue: String($0)) }
  }
}

func part1() throws -> String {
  let string = try String(contentsOfFile: "05.in", encoding: .utf8)
  let config = Configuration(rawValue: string)
  var ship = Ship(levels: config.levels)
  for move in config.moves {
    ship.performCrateMover9000(move)
  }
  return String(ship.topCrates)
}

func part2() throws -> String {
  let string = try String(contentsOfFile: "05.in", encoding: .utf8)
  let config = Configuration(rawValue: string)
  var ship = Ship(levels: config.levels)
  for move in config.moves {
    ship.performCrateMover9001(move)
  }
  return String(ship.topCrates)
}

try print(part1())
try print(part2())
