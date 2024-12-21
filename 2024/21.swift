import Foundation

guard let input = try? String(contentsOfFile: "21.in", encoding: .utf8)
else { fatalError("input not found") }

struct Point: Equatable {
  var row, col: Int
  init(_ row: Int, _ col: Int) {
    self.row = row
    self.col = col
  }
}

typealias Pad = [Character: Point]

let numPad: Pad = [
  "7": .init(0, 0), "8": .init(0, 1), "9": .init(0, 2),
  "4": .init(1, 0), "5": .init(1, 1), "6": .init(1, 2),
  "1": .init(2, 0), "2": .init(2, 1), "3": .init(2, 2),
  /*             */ "0": .init(3, 1), "A": .init(3, 2),
]

let dPad: Pad = [
  /*             */ "^": .init(0, 1), "A": .init(0, 2),
  "<": .init(1, 0), "v": .init(1, 1), ">": .init(1, 2),
]

func moves(from start: Character, to end: Character, in pad: Pad) -> [Character] {
  guard let start = pad[start], let end = pad[end]
  else { fatalError("button not found") }

  let delta = (
    row: end.row-start.row,
    col: end.col-start.col
  )

  let colMoves: [Character] = delta.col < 0
    ? .init(repeating: "<", count: abs(delta.col))
    : .init(repeating: ">", count: abs(delta.col))
  let rowMoves: [Character] = delta.row < 0
    ? .init(repeating: "^", count: abs(delta.row))
    : .init(repeating: "v", count: abs(delta.row))

  return if delta.col > 0, pad.values.contains(.init(end.row, start.col)) {
    rowMoves+colMoves+["A"]
  } else if pad.values.contains(.init(start.row, end.col)) {
    colMoves+rowMoves+["A"]
  } else {
    rowMoves+colMoves+["A"]
  }
}

func movesList(for sequence: [Character], in pad: Pad) -> [Character] {
  var result: [Character] = []
  for index in sequence.indices {
    let prev = index == 0 ? "A" : sequence[index-1]
    let curr = sequence[index]
    result += moves(from: prev, to: curr, in: pad)
  }

  return result
}

func movesCounts(for sequence: [Character], in pad: Pad) -> [[Character]: Int] {
  var result: [[Character]: Int] = [:]
  for index in sequence.indices {
    let prev = index == 0 ? "A" : sequence[index-1]
    let curr = sequence[index]
    result[moves(from: prev, to: curr, in: pad), default: 0] += 1
  }

  return result
}

var part1 = 0
var part2 = 0
for code in input.components(separatedBy: "\n").map(Array.init) {
  guard let number = Int(String(code.dropLast())) else { fatalError("invalid code") }

  let numMoves = movesList(for: code, in: numPad)
  var dMoves = numMoves
  dMoves = movesList(for: dMoves, in: dPad)
  dMoves = movesList(for: dMoves, in: dPad)
  part1 += dMoves.count*number

  var dMovesCounts = [numMoves: 1]
  for _ in 1 ... 25 {
    var nextCounts: [[Character]: Int] = [:]
    defer { dMovesCounts = nextCounts }

    for (move1, moveCount1) in dMovesCounts {
      for (move2, moveCount2) in movesCounts(for: move1, in: dPad) {
        nextCounts[move2, default: 0] += moveCount2*moveCount1
      }
    }
  }

  var total = 0
  for (move, count) in dMovesCounts {
    total += move.count*count
  }

  part2 += total*number
}

print(part1)
print(part2)
