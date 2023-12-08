import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case malformedMapEntry
  case missingMapEntry
  case invalidInstruction
}

struct Input {
  var instructions: String
  var map: [String: (lhs: String, rhs: String)]

  init() async throws {
    guard let file = FileHandle(forReadingAtPath: "input.txt")
    else { throw UnexpectedError.inputNotFound }

    instructions = ""
    map = [:]
    for try await line in file.bytes.lines {
      if instructions.isEmpty {
        instructions = line
        continue
      }

      let scanner = Scanner(string: line)
      scanner.charactersToBeSkipped = CharacterSet(charactersIn: " =(),")
      guard
        let location = scanner.scanCharacters(from: .uppercaseLetters),
        let lhs = scanner.scanCharacters(from: .uppercaseLetters),
        let rhs = scanner.scanCharacters(from: .uppercaseLetters)
      else { throw UnexpectedError.malformedMapEntry }
      map[location] = (lhs, rhs)
    }
  }

  func steps(from location: String, to predicate: (String) -> Bool) throws -> Int {
    var steps = 0
    var location = location
    var index = instructions.startIndex
    while !predicate(location) {
      guard let (lhs, rhs) = map[location]
      else { throw UnexpectedError.missingMapEntry }

      switch instructions[index] {
      case "L": location = lhs
      case "R": location = rhs
      default: throw UnexpectedError.invalidInstruction
      }

      steps += 1
      index = instructions.index(after: index)
      if index == instructions.endIndex {
        index = instructions.startIndex
      }
    }

    return steps
  }
}

func gcd(_ x: Int, _ y: Int) -> Int {
  var a = 0
  var b = max(x, y)
  var r = min(x, y)
  while r != 0 {
    a = b
    b = r
    r = a%b
  }
  return b
}

func lcm(_ x: Int, _ y: Int) -> Int {
  return x/gcd(x, y)*y
}

func part1() async throws -> Int {
  let input = try await Input()
  return try input.steps(from: "AAA") { $0 == "ZZZ" }
}

func part2() async throws -> Int {
  let input = try await Input()
  return try input.map.keys
    .filter { location in location.hasSuffix("A") }
    .map { location in try input.steps(from: location, to: { location in location.hasSuffix("Z") }) }
    .reduce(1, lcm)
}
