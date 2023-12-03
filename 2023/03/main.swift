import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case invalidNumber
  case invalidNumberLocation
}

extension CharacterSet {
  static let dot = CharacterSet(charactersIn: ".")
}

extension BinaryInteger {
  var numberOfDigits: Int {
    self == 0 ? 1 : Int(log10(Double(self)))+1
  }
}

struct Location: Hashable {
  let x, y: Int
  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  func adjacentLocations(forValueOfLength length: Int) -> [Location] {
    let adjacencyRange = x-1 ... x+length
    var adjacentLocations: [Location] = []
    adjacentLocations += adjacencyRange.map { .init($0, y-1) }
    adjacentLocations += adjacencyRange.map { .init($0, y+1) }
    adjacentLocations += [.init(adjacencyRange.lowerBound, y)]
    adjacentLocations += [.init(adjacencyRange.upperBound, y)]
    return adjacentLocations
  }
}

struct Engine {
  var symbolLocations: [Location: Character]
  var numberLocations: [Location: Int]

  init(file: FileHandle) async throws {
    symbolLocations = [:]
    numberLocations = [:]

    var row = 0
    for try await line in file.bytes.lines {
      defer { row += 1 }

      let scanner = Scanner(string: line)
      scanner.charactersToBeSkipped = .dot

      while !scanner.isAtEnd {
        if let rawNumber = scanner.scanCharacters(from: .decimalDigits) {
          guard let number = Int(rawNumber)
          else { throw UnexpectedError.invalidNumber }
          let column = scanner.scanLocation-rawNumber.count
          numberLocations[.init(column, row)] = number
        } else if let character = scanner.scanCharacter() {
          let column = scanner.scanLocation-1
          symbolLocations[.init(column, row)] = character
        }
      }
    }
  }

  func partNumbersSum() -> Int {
    var sum = 0
    for (location, number) in numberLocations {
      let adjacentLocations = location.adjacentLocations(
        forValueOfLength: number.numberOfDigits
      )
      let isAdjacentToSymbol = adjacentLocations.contains { location in
        symbolLocations[location] != nil
      }
      if isAdjacentToSymbol {
        sum += number
      }
    }
    return sum
  }

  func gearRatiosSum() throws -> Int {
    var groups: [Location: Set<Location>] = [:]
    for (numberLocation, number) in numberLocations {
      let adjacentLocations = numberLocation.adjacentLocations(
        forValueOfLength: number.numberOfDigits
      )
      for location in adjacentLocations {
        if let symbol = symbolLocations[location], symbol == "*" {
          groups[location, default: []].insert(numberLocation)
        }
      }
    }

    var sum = 0
    for (_, locations) in groups where locations.count == 2 {
      let gear = Array(locations)
      guard
        let number1 = numberLocations[gear[0]],
        let number2 = numberLocations[gear[1]]
      else { throw UnexpectedError.invalidNumberLocation }
      sum += number1*number2
    }

    return sum
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input/1.txt")
  else { throw UnexpectedError.inputNotFound }

  let engine = try await Engine(file: file)
  return engine.partNumbersSum()
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input/2.txt")
  else { throw UnexpectedError.inputNotFound }

  let engine = try await Engine(file: file)
  return try engine.gearRatiosSum()
}
