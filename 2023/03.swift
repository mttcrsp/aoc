import Foundation

struct Location: Hashable {
  let x: Int
  let y: Int

  func adjacentLocations(forValueOfLength length: Int) -> [Location] {
    let adjacencyRange = x-1 ... x+length
    var adjacentLocations: [Location] = []
    adjacentLocations += adjacencyRange.map { .init(x: $0, y: y-1) }
    adjacentLocations += adjacencyRange.map { .init(x: $0, y: y+1) }
    adjacentLocations += [.init(x: adjacencyRange.lowerBound, y: y)]
    adjacentLocations += [.init(x: adjacencyRange.upperBound, y: y)]
    return adjacentLocations
  }
}

extension Int {
  var numberOfDigits: Int {
    self == 0 ? 1 : Int(log10(Double(self)))+1
  }
}

guard let file = FileHandle(forReadingAtPath: "03.in")
else { fatalError("input not found") }

var symbolLocations: [Location: Character] = [:]
var numberLocations: [Location: Int] = [:]

var row = 0
for try await line in file.bytes.lines {
  defer { row += 1 }

  let scanner = Scanner(string: line)
  scanner.charactersToBeSkipped = CharacterSet(charactersIn: ".")

  while !scanner.isAtEnd {
    if let rawNumber = scanner.scanCharacters(from: .decimalDigits) {
      guard let number = Int(rawNumber)
      else { fatalError("integer convertion failed for value '\(rawNumber)'") }
      let column = scanner.scanLocation-rawNumber.count
      numberLocations[.init(x: column, y: row)] = number
    } else if let character = scanner.scanCharacter() {
      let column = scanner.scanLocation-1
      symbolLocations[.init(x: column, y: row)] = character
    }
  }
}

var partNumbersSum = 0
for (location, number) in numberLocations {
  let adjacentLocations = location.adjacentLocations(
    forValueOfLength: number.numberOfDigits
  )
  let isAdjacentToSymbol = adjacentLocations.contains { location in
    symbolLocations[location] != nil
  }
  if isAdjacentToSymbol {
    partNumbersSum += number
  }
}

var groups: [Location: Set<Location>] = [:]
for (numberLocation, number) in numberLocations {
  let adjacentLocations = numberLocation.adjacentLocations(
    forValueOfLength: number.numberOfDigits
  )
  for adjecentLocation in adjacentLocations {
    if let symbol = symbolLocations[adjecentLocation], symbol == "*" {
      groups[adjecentLocation, default: []].insert(numberLocation)
    }
  }
}

var gearRatiosSum = 0
for (_, locations) in groups where locations.count == 2 {
  let gear = Array(locations)
  guard let number1 = numberLocations[gear[0]]
  else { fatalError("location not found for gear \(gear[0])") }
  guard let number2 = numberLocations[gear[1]]
  else { fatalError("location not found for gear \(gear[1])") }
  gearRatiosSum += number1*number2
}

print(partNumbersSum)
print(gearRatiosSum)
