import Foundation

guard let file = FileHandle(forReadingAtPath: "03.in")
else { fatalError("input not found") }

var numbers: [[Character]] = []
for try await line in file.bytes.lines {
  numbers.append(Array(line))
}

var onesCounts = [Int](repeating: 0, count: numbers[0].count)
for number in numbers {
  for (index, character) in number.enumerated() {
    if character == "1" {
      onesCounts[index] += 1
    }
  }
}

var gammaRate = 0
var epsilonRate = 0
for count in onesCounts {
  let isOneMostCommon = count >= numbers.count/2
  gammaRate = gammaRate << 1
  gammaRate |= isOneMostCommon ? 1 : 0
  epsilonRate = epsilonRate << 1
  epsilonRate |= isOneMostCommon ? 0 : 1
}

print(gammaRate*epsilonRate)

var remainingOnesCount = onesCounts
var remaining = numbers
var bitIndex = 0
while remaining.count > 1 {
  let isOneMostCommon = Double(remainingOnesCount[bitIndex]) >= Double(remaining.count)/2
  let target: Character = isOneMostCommon ? "1" : "0"

  for index in remaining.indices.reversed() {
    guard remaining[index][bitIndex] != target else { continue }

    let number = remaining.remove(at: index)
    for (index, character) in number.enumerated() {
      if character == "1" {
        remainingOnesCount[index] -= 1
      }
    }
  }

  bitIndex += 1
}

let oxygenGeneratorRating = Int(String(remaining[0]), radix: 2)!

remainingOnesCount = onesCounts
remaining = numbers
bitIndex = 0
while remaining.count > 1 {
  let isOneMostCommon = Double(remainingOnesCount[bitIndex]) >= Double(remaining.count)/2
  let target: Character = isOneMostCommon ? "0" : "1"

  for index in remaining.indices.reversed() {
    guard remaining[index][bitIndex] != target else { continue }

    let number = remaining.remove(at: index)
    for (index, character) in number.enumerated() {
      if character == "1" {
        remainingOnesCount[index] -= 1
      }
    }
  }

  bitIndex += 1
}

let co2ScrubberRating = Int(String(remaining[0]), radix: 2)!
print(oxygenGeneratorRating*co2ScrubberRating)
