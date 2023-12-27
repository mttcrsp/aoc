import Foundation

struct Outcome {
  var r = 0
  var g = 0
  var b = 0

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: " ,")

    while !scanner.isAtEnd {
      guard let count = scanner.scanInt()
      else { fatalError("cubes count not found in '\(rawValue)'") }

      switch scanner.scanCharacters(from: .lowercaseLetters) {
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

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)

    guard 
      let _ = scanner.scanString("Game "),
      let id = scanner.scanInt(),
      let _ = scanner.scanString(": ")
    else { fatalError("id not found in '\(rawValue)'") }
    self.id = id

    outcomes = scanner.string[scanner.currentIndex...]
      .components(separatedBy: "; ")
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

guard let file = FileHandle(forReadingAtPath: "02.in")
else { fatalError("input not found") }

var possibleGamesIDsSum = 0
var gamesPowerSum = 0
for try await line in file.bytes.lines {
  let game = Game(rawValue: line)
  gamesPowerSum += game.power
  if game.isPossible {
    possibleGamesIDsSum += game.id
  }
}

print(possibleGamesIDsSum)
print(gamesPowerSum)
