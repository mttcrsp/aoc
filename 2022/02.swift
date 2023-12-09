import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case missingPlayerMove
  case missingOpponentMove
  case missingOutcome
  case unknownPlayerMove
  case unknownOpponentMove
  case unknownOutcome
}

enum Move {
  case rock, paper, scissors

  init(opponentRawValue: Character) throws {
    switch opponentRawValue {
    case "A": self = .rock
    case "B": self = .paper
    case "C": self = .scissors
    default: throw UnexpectedError.unknownOpponentMove
    }
  }

  init(rawValue: Character) throws {
    switch rawValue {
    case "X": self = .rock
    case "Y": self = .paper
    case "Z": self = .scissors
    default: throw UnexpectedError.unknownPlayerMove
    }
  }

  var defeats: Move {
    switch self {
    case .rock: .scissors
    case .paper: .rock
    case .scissors: .paper
    }
  }

  var defeatedBy: Move {
    switch self {
    case .rock: .paper
    case .paper: .scissors
    case .scissors: .rock
    }
  }

  func outcome(against other: Move) -> Outcome {
    if self == other {
      .draw
    } else if defeatedBy == other {
      .loss
    } else {
      .win
    }
  }

  var score: Int {
    switch self {
    case .rock: 1
    case .paper: 2
    case .scissors: 3
    }
  }
}

enum Outcome {
  case win, loss, draw

  var score: Int {
    switch self {
    case .loss: 0
    case .draw: 3
    case .win: 6
    }
  }

  init(rawValue: Character) throws {
    switch rawValue {
    case "X": self = .loss
    case "Y": self = .draw
    case "Z": self = .win
    default: throw UnexpectedError.unknownOutcome
    }
  }
}

struct Game1 {
  let opponentMove: Move
  let playerMove: Move

  init(rawValue: String) throws {
    let scanner = Scanner(string: rawValue)

    guard let opponentRawValue = scanner.scanCharacter()
    else { throw UnexpectedError.missingOpponentMove }
    opponentMove = try Move(opponentRawValue: opponentRawValue)

    _ = scanner.scanString(" ")

    guard let playerRawValue = scanner.scanCharacter()
    else { throw UnexpectedError.missingPlayerMove }
    playerMove = try Move(rawValue: playerRawValue)
  }

  var outcome: Outcome {
    playerMove.outcome(against: opponentMove)
  }

  var score: Int {
    playerMove.score+outcome.score
  }
}

struct Game2 {
  let opponentMove: Move
  let outcome: Outcome

  init(rawValue: String) throws {
    let scanner = Scanner(string: rawValue)

    guard let opponentRawValue = scanner.scanCharacter()
    else { throw UnexpectedError.missingOpponentMove }
    opponentMove = try Move(opponentRawValue: opponentRawValue)

    _ = scanner.scanString(" ")

    guard let outcomeRawValue = scanner.scanCharacter()
    else { throw UnexpectedError.missingOutcome }
    outcome = try Outcome(rawValue: outcomeRawValue)
  }

  var playerMove: Move {
    switch outcome {
    case .win: opponentMove.defeatedBy
    case .draw: opponentMove
    case .loss: opponentMove.defeats
    }
  }

  var score: Int {
    playerMove.score+outcome.score
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "02.in")
  else { throw UnexpectedError.inputNotFound }

  var totalScore = 0
  for try await line in file.bytes.lines {
    let game = try Game1(rawValue: line)
    totalScore += game.score
  }

  return totalScore
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "02.in")
  else { throw UnexpectedError.inputNotFound }

  var totalScore = 0
  for try await line in file.bytes.lines {
    let game = try Game2(rawValue: line)
    totalScore += game.score
  }

  return totalScore
}
