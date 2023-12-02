import Foundation

enum UnexpectedError: Error {
  case inputNotFound
}

enum ParseError: Error {
  case missingGameID
  case missingOutcomes
  case missingCubesCount
  case unknownColor
}

struct Outcome {
  var r = 0
  var g = 0
  var b = 0
}

struct Game {
  var id: Int
  var outcomes: [Outcome]
}

extension Game {
  static let outcomesCharacterSet =
    CharacterSet(charactersIn: " ,;")
      .union(.alphanumerics)

  init(rawValue: String) throws {
    let scanner = Scanner(string: rawValue)
    _ = scanner.scanString("Game ")

    guard let id = scanner.scanInt()
    else { throw ParseError.missingGameID }
    self.id = id

    _ = scanner.scanString(": ")

    guard let rawOutcomes = scanner.scanCharacters(from: Self.outcomesCharacterSet)
    else { throw ParseError.missingOutcomes }

    outcomes = try rawOutcomes.components(separatedBy: "; ")
      .map(Outcome.init)
  }
}

extension Outcome {
  init(rawValue: String) throws {
    for component in rawValue.components(separatedBy: ", ") {
      let scanner = Scanner(string: component)

      guard let count = scanner.scanInt()
      else { throw ParseError.missingCubesCount }

      _ = scanner.scanString(" ")

      switch scanner.scanCharacters(from: .alphanumerics) {
      case "red": r = count
      case "green": g = count
      case "blue": b = count
      default: throw ParseError.unknownColor
      }
    }
  }
}

extension Game {
  var isPossible: Bool {
    outcomes.allSatisfy(\.isPossible)
  }
}

extension Outcome {
  var isPossible: Bool {
    r <= 12 && g <= 13 && b <= 14
  }
}

extension Game {
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
  guard let file = FileHandle(forReadingAtPath: "input/1.txt")
  else { throw UnexpectedError.inputNotFound }

  var possibleGamesIDsSum = 0
  for try await line in file.bytes.lines {
    let game = try Game(rawValue: line)
    if game.isPossible {
      possibleGamesIDsSum += game.id
    }
  }

  return possibleGamesIDsSum
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input/2.txt")
  else { throw UnexpectedError.inputNotFound }

  var gamesPowerSum = 0
  for try await line in file.bytes.lines {
    let game = try Game(rawValue: line)
    gamesPowerSum += game.power
  }

  return gamesPowerSum
}
