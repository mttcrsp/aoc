import Foundation

enum UnexpectedError: Error {
  case inputNotFound
}

enum PredictionType {
  case prev
  case next
}

func prediction(of mode: PredictionType) async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var prevResult = 0
  var nextResult = 0

  for try await line in file.bytes.lines {
    let scanner = Scanner(string: line)
    var numbers: [Int] = []
    while let number = scanner.scanInt() {
      numbers.append(number)
    }

    var history: [[Int]] = [numbers]
    while let prev = history.last, !prev.allSatisfy({ $0 == 0 }) {
      var next: [Int] = []
      for i in prev.indices.dropFirst() {
        next.append(prev[i]-prev[i-1])
      }
      history.append(next)
    }

    var prevPrediction = 0
    var nextPrediction = 0
    for entry in history.reversed().dropFirst() {
      let prev = entry[0]
      let next = entry[entry.count-1]
      prevPrediction = prev-prevPrediction
      nextPrediction = next+nextPrediction
    }
    prevResult += prevPrediction
    nextResult += nextPrediction
  }

  switch mode {
  case .prev: return prevResult
  case .next: return nextResult
  }
}

func part1() async throws -> Int {
  try await prediction(of: .next)
}

func part2() async throws -> Int {
  try await prediction(of: .prev)
}
