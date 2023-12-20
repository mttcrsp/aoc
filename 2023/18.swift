import Foundation

enum Direction: CaseIterable {
  case up, down, left, right

  init?(alphabeticalCode: Character) {
    switch alphabeticalCode {
    case "R": self = .right
    case "D": self = .down
    case "L": self = .left
    case "U": self = .up
    default: return nil
    }
  }

  init?(colorCode: Character) {
    switch colorCode {
    case "0": self = .right
    case "1": self = .down
    case "2": self = .left
    case "3": self = .up
    default: return nil
    }
  }
}

struct Entry {
  let mainCommand: Command
  let colorCommand: Command

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    guard
      let directionAlphabeticalCode = scanner.scanCharacter(),
      let direction = Direction(alphabeticalCode: directionAlphabeticalCode)
    else { fatalError("direction not found in command '\(rawValue)'") }

    guard let steps = scanner.scanInt()
    else { fatalError("steps not found in command '\(rawValue)'") }
    mainCommand = .init(direction: direction, steps: steps)

    guard 
      let _ = scanner.scanString("(#"),
      let color = scanner.scanCharacters(from: .alphanumerics),
      let _ = scanner.scanString(")")
    else { fatalError("color not found in command '\(rawValue)'") }

    guard let colorDirectionCode = color.last
    else { fatalError("malformed color in command '\(rawValue)'") }

    guard let colorDirection = Direction(colorCode: colorDirectionCode)
    else { fatalError("unexpected color direction code '\(colorDirectionCode)' in command '\(rawValue)'") }

    guard let colorSteps = Int(String(color.dropLast()), radix: 16)
    else { fatalError("invalid color steps \(color.dropLast()) in command '\(rawValue)'") }
    colorCommand = .init(direction: colorDirection, steps: colorSteps)
  }
}

struct Command {
  let direction: Direction
  let steps: Int
}

func cubicMeters(for commands: [Command]) -> Int {
  var points: [(x: Int, y: Int)] = [(0, 0)]
  var boundaryPointsCount = 0
  for command in commands {
    var newPoint = points.last!
    switch command.direction {
    case .up: newPoint.y -= command.steps
    case .down: newPoint.y += command.steps
    case .left: newPoint.x -= command.steps
    case .right: newPoint.x += command.steps
    }

    points.append(newPoint)
    boundaryPointsCount += command.steps
  }

  var underestimatedArea = 0
  for (i, point) in points.enumerated() {
    let prevPoint = points[(i-1+points.count)%points.count]
    let nextPoint = points[(i+1)%points.count]
    underestimatedArea += point.x*(prevPoint.y-nextPoint.y)
  }
  underestimatedArea = abs(underestimatedArea)/2

  let interiorPointsCount = underestimatedArea-boundaryPointsCount/2+1
  return interiorPointsCount+boundaryPointsCount
}

guard let file = FileHandle(forReadingAtPath: "18.in")
else { fatalError("input not found") }

var entries: [Entry] = []
for try await line in file.bytes.lines {
  entries.append(Entry(rawValue: line))
}

print(cubicMeters(for: entries.map(\.mainCommand)))
print(cubicMeters(for: entries.map(\.colorCommand)))
