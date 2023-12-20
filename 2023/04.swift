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

  var points: Int {
    var points = 0
    for _ in matchedNumbers {
      if points == 0 {
        points = 1
      } else {
        points *= 2
      }
    }
    return points
  }
}

guard let file = FileHandle(forReadingAtPath: "04.in")
else { fatalError("input not found") }

for try await line in file.bytes.lines {
  let card = Card(rawValue: line)
  cards.append(Card(rawValue: line))
}

var totalPoints = 0
var scratchcardsCounts = [Int](repeating: 1, count: cards.count)
for (cardIndex, card) in cards.enumerated() {
  totalPoints += card.points
  for offset in 0 ..< card.matchedNumbers.count {
    scratchcardsCounts[cardIndex+(offset+1)] += scratchcardsCounts[cardIndex]
  }
}

let totalScratchCartsCount = scratchcardsCounts.reduce(0, +)
print(totalPoints)
print(totalScratchCartsCount)
