import Foundation

guard let input = try? String(contentsOfFile: "03.in", encoding: .utf8)
else { fatalError("input not found") }

enum CommandType {
  case mul(Int, Int)
  case `do`
  case dont
}

struct Command {
  var range: Range<String.Index>
  var type: CommandType
}

var commands: [Command] = []
for match in input.matches(of: /mul\((\d+),(\d+)\)/) {
  let (_, lhsString, rhsString) = match.output
  let lhs = Int(lhsString)!
  let rhs = Int(rhsString)!
  commands.append(.init(range: match.range, type: .mul(lhs, rhs)))
}

for match in input.matches(of: /do\(\)/) {
  commands.append(.init(range: match.range, type: .do))
}

for match in input.matches(of: /don't\(\)/) {
  commands.append(.init(range: match.range, type: .dont))
}

commands.sort { $0.range.lowerBound < $1.range.lowerBound }

var part1 = 0
var part2 = 0
var isMulEnabled = true
for command in commands {
  switch command.type {
  case .do:
    isMulEnabled = true
  case .dont:
    isMulEnabled = false
  case let .mul(lhs, rhs):
    let result = lhs*rhs
    part1 += result
    if isMulEnabled {
      part2 += result
    }
  }
}

print(part1)
print(part2)
