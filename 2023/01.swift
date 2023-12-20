import Foundation

guard let file = FileHandle(forReadingAtPath: "01.in")
else { fatalError("input not found") }

let mapping: [String: Int] = [
  "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
  "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
]

var calibrationValue = 0
var calibrationValueSpelled = 0
for try await line in file.bytes.lines {
  guard
    let firstDigitChar = line.first(where: \.isNumber),
    let lastDigitChar = line.last(where: \.isNumber),
    let firstDigit = Int(String(firstDigitChar)),
    let lastDigit = Int(String(lastDigitChar))
  else { fatalError("no digit found in '\(line)'") }
  calibrationValue += firstDigit*10
  calibrationValue += lastDigit

  var firstDigitSpelled: Int?
  loop: for index in line.indices {
    for (digit, value) in mapping {
      if line[index...].hasPrefix(digit) {
        firstDigitSpelled = value
        break loop
      }
    }
  }

  var lastDigitSpelled: Int?
  loop: for index in line.indices.reversed() {
    for (digit, value) in mapping {
      if line[index...].hasPrefix(digit) {
        lastDigitSpelled = value
        break loop
      }
    }
  }

  guard let firstDigitSpelled, let lastDigitSpelled
  else { fatalError("no digit found in \(line)") }

  calibrationValueSpelled += firstDigitSpelled*10
  calibrationValueSpelled += lastDigitSpelled
}

print(calibrationValue)
print(calibrationValueSpelled)
