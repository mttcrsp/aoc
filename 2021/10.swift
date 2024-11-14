import Foundation

guard let file = try? FileHandle(forReadingAtPath: "10.in")
else { fatalError("input not found") }

var lines: [String] = []
for try await line in file.bytes.lines {
  lines.append(line)
}

let open: [Character: Character] = ["(": ")", "[": "]", "{": "}", "<": ">"]
let points1: [Character: Int] = [")": 3, "]": 57, "}": 1197, ">": 25137]
let points2: [Character: Int] = [")": 1, "]": 2, "}": 3, ">": 4]

var incomplete: [String] = []
var syntaxErrorsScore = 0
var autocompleteScores: [Int] = []
loop: for line in lines {
  var stack: [Character] = []
  for character in line {
    if let close = open[character] {
      stack.append(close)
    } else if stack.last == character {
      stack.removeLast()
    } else {
      syntaxErrorsScore += points1[character, default: 0]
      continue loop
    }
  }

  var points = 0
  if !stack.isEmpty {
    for character in stack.reversed() {
      points *= 5
      points += points2[character, default: 0]
    }
  }

  autocompleteScores.append(points)
}

print(syntaxErrorsScore)
print(autocompleteScores.sorted()[autocompleteScores.count/2])
