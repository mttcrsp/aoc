import Foundation

guard let file = FileHandle(forReadingAtPath: "02.in")
else { fatalError("input not found") }

enum Direction: String {
  case forward, down, up
}

struct Command {
  var direction: Direction
  var units: Int
}

var commands: [Command] = []
for try await line in file.bytes.lines {
  let components = line.components(separatedBy: " ")
  guard 
    components.count == 2,
    let direction = Direction(rawValue: components[0]),
    let units = Int(components[1])
  else { fatalError("malformed line '\(line)'") }
  commands.append(Command(direction: direction, units: units))
}

var horizontalPosition = 0
var depth = 0
for command in commands {
  switch command.direction {
  case .forward: horizontalPosition += command.units
  case .down: depth += command.units
  case .up: depth -= command.units
  }
}

print(horizontalPosition*depth)

horizontalPosition = 0
depth = 0

var aim = 0
for command in commands {
  switch command.direction {
  case .forward:
    horizontalPosition += command.units
    depth += aim*command.units
  case .down:
    aim += command.units
  case .up:
    aim -= command.units
  }
}

print(horizontalPosition*depth)
