import Foundation

guard let file = FileHandle(forReadingAtPath: "10.in")
else { fatalError("input not found") }

enum Instruction {
  case noop
  case addx(Int)

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    let command = scanner.scanCharacters(from: .lowercaseLetters)
    switch command {
    case "noop":
      self = .noop
    case "addx":
      guard let value = scanner.scanInt()
      else { fatalError("malformed addx command '\(rawValue)'") }
      self = .addx(value)
    default:
      fatalError("unexpected command '\(command ?? "")'")
    }
  }
}

var x = 1
var cycles: [Int] = []

for try await line in file.bytes.lines {
  let instruction = Instruction(rawValue: line)
  switch instruction {
  case .noop:
    cycles.append(x)
  case let .addx(value):
    cycles.append(x)
    cycles.append(x)
    x += value
  }
}

var part1 = 0
for index in [20, 60, 100, 140, 180, 220] {
  let cycle = index
  let value = cycles[cycle-1]
  part1 += cycle*value
}

print(part1)

let screenWidth = 40
let screenHeight = 6
let crtRow = [Character](repeating: ".", count: screenWidth)
var crt = [[Character]](repeating: crtRow, count: screenHeight)
for row in crt.indices {
  for col in crt[row].indices {
    let spritePosition = cycles[row*screenWidth+col]
    let spriteRange = spritePosition-1 ... spritePosition+1
    if spriteRange.contains(col) {
      crt[row][col] = "#"
    }
  }
}

let part2 = crt
  .map { row in String(row) }
  .joined(separator: "\n")
print(part2)
