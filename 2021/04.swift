import Foundation

guard let file = FileHandle(forReadingAtPath: "04.in")
else { fatalError("input not found") }

var lines: [String] = []
for try await line in file.bytes.lines {
  lines.append(line)
}

let drawnNumbers = lines[0]
  .components(separatedBy: ",")
  .compactMap(Int.init)

struct Board: CustomDebugStringConvertible {
  static let size = 5

  var numbers: [Int: [Int]] = [:]
  var marked: Set<[Int]> = []
  var rows = [Int](repeating: 0, count: Self.size)
  var cols = [Int](repeating: 0, count: Self.size)
  var lines: [String]

  var score: Int {
    var result = 0
    for (number, position) in numbers {
      if !marked.contains(position) {
        result += number
      }
    }

    return result
  }

  init(lines: [String]) {
    self.lines = lines
    for (row, line) in lines.enumerated() {
      let lineNumbers = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        .compactMap(Int.init)
      for (col, number) in lineNumbers.enumerated() {
        numbers[number] = [row, col]
      }
    }
  }

  mutating func mark(_ number: Int) -> Bool {
    guard let location = numbers[number] else { return false }
    let row = location[0]
    let col = location[1]
    rows[row] += 1
    cols[col] += 1
    marked.insert(location)
    return rows[row] == Self.size || cols[col] == Self.size
  }

  var debugDescription: String {
    lines.joined(separator: "\n")
  }
}

var boards: [Board] = []
var pendingLines: [String] = []
for line in lines.dropFirst() {
  pendingLines.append(line)
  if pendingLines.count == Board.size {
    let board = Board(lines: pendingLines)
    boards.append(board)
    pendingLines = []
  }
}

var markedBoards = boards
loop: for number in drawnNumbers {
  for index in markedBoards.indices {
    if markedBoards[index].mark(number) {
      print(markedBoards[index].score*number)
      break loop
    }
  }
}

markedBoards = boards
secondLoop: for number in drawnNumbers {
  for index in markedBoards.indices.reversed() {
    if markedBoards[index].mark(number) {
      if markedBoards.count == 1 {
        print(markedBoards[index].score*number)
        break secondLoop
      }

      markedBoards.remove(at: index)
    }
  }
}
