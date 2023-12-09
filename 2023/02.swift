import Foundation

struct Outcome {
  var r = 0
  var g = 0
  var b = 0

  init(rawValue: String) {
    for component in rawValue.components(separatedBy: ", ") {
      let scanner = Scanner(string: component)

      guard let count = scanner.scanInt()
      else { fatalError("cubes count not found in '\(rawValue)'") }

      _ = scanner.scanString(" ")

      switch scanner.scanCharacters(from: .alphanumerics) {
      case "red": r = count
      case "green": g = count
      case "blue": b = count
      default: fatalError("unknown color '\(rawValue)'")
      }
    }
  }

  var isPossible: Bool {
    r <= 12 && g <= 13 && b <= 14
  }
}

struct Game {
  var id: Int
  var outcomes: [Outcome]

  static let outcomesCharacterSet =
    CharacterSet(charactersIn: " ,;")
      .union(.alphanumerics)

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    _ = scanner.scanString("Game ")

    guard let id = scanner.scanInt()
    else { fatalError("id not found in '\(rawValue)'") }
    self.id = id

    _ = scanner.scanString(": ")

    guard let rawOutcomes = scanner.scanCharacters(from: Self.outcomesCharacterSet)
    else { fatalError("outcomes not found in '\(rawValue)'") }

    outcomes = rawOutcomes.components(separatedBy: "; ")
      .map(Outcome.init)
  }

  var isPossible: Bool {
    outcomes.allSatisfy(\.isPossible)
  }

  var power: Int {
    var maxR = 0
    var maxG = 0
    var maxB = 0
    for outcome in outcomes {
      maxR = max(maxR, outcome.r)
      maxG = max(maxG, outcome.g)
      maxB = max(maxB, outcome.b)
    }
    return maxR*maxG*maxB
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "02.in")
  else { fatalError("input not found") }

  var possibleGamesIDsSum = 0
  for try await line in file.bytes.lines {
    let game = Game(rawValue: line)
    if game.isPossible {
      possibleGamesIDsSum += game.id
    }
  }

  return possibleGamesIDsSum
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "02.in")
  else { fatalError("input not found") }

  var gamesPowerSum = 0
  for try await line in file.bytes.lines {
    let game = Game(rawValue: line)
    gamesPowerSum += game.power
  }

  return gamesPowerSum
}

try await print(part1())
try await print(part2())
