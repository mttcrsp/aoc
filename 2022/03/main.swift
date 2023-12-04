import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case invalidCharacter
  case invalidIntersection
}

extension Character {
  func priority() throws -> Int {
    let base: (value: Int, character: Character) =
      isLowercase ? (1, "a") : (27, "A")
    guard let asciiValue, let baseAsciiValue = base.character.asciiValue
    else { throw UnexpectedError.invalidCharacter }
    return Int(asciiValue)-Int(baseAsciiValue)+base.value
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var prioritiesSum = 0
  for try await line in file.bytes.lines {
    let compartment1 = Set(line.prefix(line.count/2))
    let compartment2 = Set(line.suffix(line.count/2))
    let intersection = compartment1.intersection(compartment2)
    guard let item = intersection.first, intersection.count == 1
    else { throw UnexpectedError.invalidIntersection }
    prioritiesSum += try item.priority()
  }

  return prioritiesSum
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var groups: [Int: Set<Character>] = [:]
  var index = 0
  for try await line in file.bytes.lines {
    defer { index += 1 }

    let items = Set(line)
    let groupIndex = index/3
    if let group = groups[groupIndex] {
      groups[groupIndex] = group.intersection(items)
    } else {
      groups[groupIndex] = items
    }
  }

  var prioritiesSum = 0
  for group in groups.values {
    guard let item = group.first, group.count == 1
    else { throw UnexpectedError.invalidIntersection }
    prioritiesSum += try item.priority()
  }

  return prioritiesSum
}
