import Foundation

enum UnexpectedError: Error {
  case inputNotFound
}

enum ParsingError: Error {
  case missingGameID
  case missingOutcomes
  case missingCubesCount
  case unknownColor
}

struct Outcome {
  var r = 0
  var g = 0
  var b = 0

  init(rawValue: String) throws {
    for component in rawValue.components(separatedBy: ", ") {
      let scanner = Scanner(string: component)

      guard let count = scanner.scanInt()
      else { throw ParsingError.missingCubesCount }

      _ = scanner.scanString(" ")

      switch scanner.scanCharacters(from: .alphanumerics) {
      case "red": r = count
      case "green": g = count
      case "blue": b = count
      default: throw ParsingError.unknownColor
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

  init(rawValue: String) throws {
    let scanner = Scanner(string: rawValue)
    _ = scanner.scanString("Game ")

    guard let id = scanner.scanInt()
    else { throw ParsingError.missingGameID }
    self.id = id

    _ = scanner.scanString(": ")

    guard let rawOutcomes = scanner.scanCharacters(from: Self.outcomesCharacterSet)
    else { throw ParsingError.missingOutcomes }

    outcomes = try rawOutcomes.components(separatedBy: "; ")
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
  guard let file = FileHandle(forReadingAtPath: "input.txt")
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
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var gamesPowerSum = 0
  for try await line in file.bytes.lines {
    let game = try Game(rawValue: line)
    gamesPowerSum += game.power
  }

  return gamesPowerSum
}
