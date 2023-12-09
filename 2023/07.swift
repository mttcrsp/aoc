import Foundation

enum HandType: Int, Comparable {
  case highCard
  case onePair
  case twoPair
  case threeOfAKind
  case fullHouse
  case fourOfAKind
  case fiveOfAKind

  static func < (lhs: HandType, rhs: HandType) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

struct Hand {
  let cards: String

  init(rawValue: String) {
    cards = rawValue
  }

  var handType: HandType {
    var occurrences: [Character: Int] = [:]
    for card in cards {
      occurrences[card, default: 0] += 1
    }

    let sortedOccurences = occurrences.values.sorted(by: >)
    switch sortedOccurences {
    case [5]:
      return .fiveOfAKind
    case [4, 1]:
      return .fourOfAKind
    case [3, 2]:
      return .fullHouse
    case [3, 1, 1]:
      return .threeOfAKind
    case [2, 2, 1]:
      return .twoPair
    case [2, 1, 1, 1]:
      return .onePair
    default:
      return .highCard
    }
  }

  var alternateHandType: HandType {
    var alternateCards = ""
    for card in cards where card != "J" {
      alternateCards.append(card)
    }

    var alternateOccurrences: [Character: Int] = [:]
    for card in alternateCards {
      alternateOccurrences[card, default: 0] += 1
    }

    let sortedOccurences = alternateOccurrences.values.sorted(by: >)
    let jokersCount = cards.count-alternateCards.count
    switch (jokersCount, sortedOccurences) {
    case (0, _):
      return handType
    case (1, [4]):
      return .fiveOfAKind
    case (1, [3, 1]):
      return .fourOfAKind
    case (1, [2, 2]):
      return .fullHouse
    case (1, [2, 1, 1]):
      return .threeOfAKind
    case (1, _):
      return .onePair
    case (2, [3]):
      return .fiveOfAKind
    case (2, [2, 1]):
      return .fourOfAKind
    case (2, _):
      return .threeOfAKind
    case (3, [2]):
      return .fiveOfAKind
    case (3, _):
      return .fourOfAKind
    default:
      return .fiveOfAKind
    }
  }

  func beats(_ other: Hand) -> Bool {
    guard handType == other.handType else {
      return handType < other.handType
    }

    for (lhsCard, rhsCard) in zip(cards, other.cards) {
      if lhsCard != rhsCard {
        return originalValues[lhsCard]! < originalValues[rhsCard]!
      }
    }

    return false
  }

  func alternateBeats(_ other: Hand) -> Bool {
    let alternateHandType = self.alternateHandType
    let otherAlternateHandType = other.alternateHandType
    guard alternateHandType == otherAlternateHandType else {
      return alternateHandType < otherAlternateHandType
    }

    for (lhsCard, rhsCard) in zip(cards, other.cards) {
      if lhsCard != rhsCard {
        return alternateValues[lhsCard]! < alternateValues[rhsCard]!
      }
    }

    return false
  }
}

struct Entry {
  var hand: Hand
  var bid: Int

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    guard let hand = scanner.scanCharacters(from: cardCharacterSet)
    else { fatalError("hand definition not found in '\(rawValue)'") }
    guard let bid = scanner.scanInt()
    else { fatalError("bid not found in '\(rawValue)'") }
    self.hand = Hand(rawValue: hand)
    self.bid = bid
  }

  func winning(forRank rank: Int) -> Int {
    bid*rank
  }
}

let cards = "23456789TJQKA"

var originalValues: [Character: Int] = [:]
for (index, card) in cards.enumerated() {
  originalValues[card] = index
}

var alternateValues: [Character: Int] = [:]
for (index, card) in "J23456789TQKA".enumerated() {
  alternateValues[card] = index
}

let cardCharacterSet = CharacterSet(charactersIn: cards)

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "07.in")
  else { fatalError("input not found") }

  var entries: [Entry] = []
  for try await line in file.bytes.lines {
    let entry = Entry(rawValue: line)
    entries.append(entry)
  }

  entries.sort { $0.hand.beats($1.hand) }

  var result = 0
  for (index, entry) in entries.enumerated() {
    let rank = index+1
    result += entry.winning(forRank: rank)
  }

  return result
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "07.in")
  else { fatalError("input not found") }

  var entries: [Entry] = []
  for try await line in file.bytes.lines {
    let entry = Entry(rawValue: line)
    entries.append(entry)
  }

  entries.sort { $0.hand.alternateBeats($1.hand) }

  var result = 0
  for (index, entry) in entries.enumerated() {
    let rank = index+1
    let winning = entry.winning(forRank: rank)
    result += winning
  }

  return result
}

try await print(part1())
try await print(part2())
