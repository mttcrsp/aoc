import Foundation

func greatestCommonDivisor(_ x: Int, _ y: Int) -> Int {
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

func leastCommonMultiple(_ x: Int, _ y: Int) -> Int {
  x/greatestCommonDivisor(x, y)*y
}

guard let file = FileHandle(forReadingAtPath: "08.in")
else { fatalError("input not found") }

var instructions: String = ""
var map: [String: (lhs: String, rhs: String)] = [:]

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
  else { fatalError("malformed map entry '\(line)'") }
  map[location] = (lhs, rhs)
}

func steps(from location: String, to predicate: (String) -> Bool) -> Int {
  var steps = 0
  var location = location
  var index = instructions.startIndex
  while !predicate(location) {
    guard let (lhs, rhs) = map[location]
    else { fatalError("no destinations found for location '\(location)'") }

    let instruction = instructions[index]
    switch instruction {
    case "L": location = lhs
    case "R": location = rhs
    default: fatalError("invalid instruction '\(instruction)'")
    }

    steps += 1
    index = instructions.index(after: index)
    if index == instructions.endIndex {
      index = instructions.startIndex
    }
  }

  return steps
}

let fromAAAtoZZZ = steps(from: "AAA") { $0 == "ZZZ" }
print(fromAAAtoZZZ)

let from__Ato__Z = map.keys
  .filter { location in location.hasSuffix("A") }
  .map { location in steps(from: location, to: { location in location.hasSuffix("Z") }) }
  .reduce(1, leastCommonMultiple)
print(from__Ato__Z)
