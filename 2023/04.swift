import Foundation

struct Card {
  var cardNumbers: Set<Int>
  var winningNumbers: Set<Int>

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    _ = scanner.scanString("Card")
    _ = scanner.scanInt()
    _ = scanner.scanString(":")
    winningNumbers = []
    while let number = scanner.scanInt() {
      winningNumbers.insert(number)
    }

    _ = scanner.scanString("|")
    cardNumbers = []
    while let number = scanner.scanInt() {
      cardNumbers.insert(number)
    }
  }

  var matchedNumbers: Set<Int> {
    winningNumbers.intersection(cardNumbers)
  }

  var score: Int {
    var score = 0
    for _ in matchedNumbers {
      if score == 0 {
        score = 1
      } else {
        score *= 2
      }
    }
    return score
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "04.in")
  else { fatalError("input not found") }

  var points = 0
  for try await line in file.bytes.lines {
    let card = Card(rawValue: line)
    points += card.score
  }

  return points
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "04.in")
  else { fatalError("input not found") }

  var cards: [Card] = []
  for try await line in file.bytes.lines {
    cards.append(Card(rawValue: line))
  }

  var counts = [Int](repeating: 1, count: cards.count)
  for (cardIndex, card) in cards.enumerated() {
    for offset in 0 ..< card.matchedNumbers.count {
      counts[cardIndex+(offset+1)] += counts[cardIndex]
    }
  }

  return counts.reduce(0, +)
}

try await print(part1())
try await print(part2())
