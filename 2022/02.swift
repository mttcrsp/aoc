import Foundation

enum Move {
  case rock, paper, scissors

  init(opponentRawValue: Character) {
    switch opponentRawValue {
    case "A": self = .rock
    case "B": self = .paper
    case "C": self = .scissors
    default: fatalError("unknown opponent move '\(opponentRawValue)'")
    }
  }

  init(playerRawValue: Character) {
    switch playerRawValue {
    case "X": self = .rock
    case "Y": self = .paper
    case "Z": self = .scissors
    default: fatalError("unknown player move '\(playerRawValue)'")
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

  init(rawValue: Character) {
    switch rawValue {
    case "X": self = .loss
    case "Y": self = .draw
    case "Z": self = .win
    default: fatalError("unknown outcome type '\(rawValue)'")
    }
  }
}

struct Game1 {
  let opponentMove: Move
  let playerMove: Move

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)

    guard let opponentRawValue = scanner.scanCharacter()
    else { fatalError("missing opponent move in '\(rawValue)'") }
    opponentMove = Move(opponentRawValue: opponentRawValue)

    _ = scanner.scanString(" ")

    guard let playerRawValue = scanner.scanCharacter()
    else { fatalError("missing player move in '\(rawValue)'") }
    playerMove = Move(playerRawValue: playerRawValue)
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

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)

    guard let opponentRawValue = scanner.scanCharacter()
    else { fatalError("opponent move not found in '\(rawValue)'") }
    opponentMove = Move(opponentRawValue: opponentRawValue)

    _ = scanner.scanString(" ")

    guard let outcomeRawValue = scanner.scanCharacter()
    else { fatalError("outcome not found in '\(rawValue)'") }
    outcome = Outcome(rawValue: outcomeRawValue)
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
  else { fatalError("input not found") }

  var totalScore = 0
  for try await line in file.bytes.lines {
    let game = Game1(rawValue: line)
    totalScore += game.score
  }

  return totalScore
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "02.in")
  else { fatalError("input not found") }

  var totalScore = 0
  for try await line in file.bytes.lines {
    let game = Game2(rawValue: line)
    totalScore += game.score
  }

  return totalScore
}

try await print(part1())
try await print(part2())
