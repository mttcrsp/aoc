import Foundation

struct Play {
  let bid: Int
  let cards: String

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = .whitespaces

    guard
      let cards = scanner.scanCharacters(from: .alphanumerics),
      let bid = scanner.scanInt()
    else { fatalError("malformed play '\(rawValue)'") }
    self.bid = bid
    self.cards = cards
  }

  func beats(_ other: Play, consideringJokers: Bool = false) -> Bool {
    let lhs = cards
    let rhs = other.cards

    let handTypeInit = consideringJokers
      ? HandType.init(handWithJokers:)
      : HandType.init(hand:)
    let lhsHandType = handTypeInit(lhs)
    let rhsHandType = handTypeInit(rhs)
    guard lhsHandType == rhsHandType
    else { return lhsHandType < rhsHandType }

    let cardValuesReference = consideringJokers
      ? "J23456789TQKA"
      : "23456789TJQKA"
    for (lhsCard, rhsCard) in zip(lhs, rhs) {
      guard 
        let lhsCardValue = cardValuesReference.firstIndex(of: lhsCard),
        let rhsCardValue = cardValuesReference.firstIndex(of: rhsCard)
      else { fatalError("missing value mapping for card '\(lhsCard)' or '\(rhsCard)'") }
      guard lhsCardValue == rhsCardValue
      else { return lhsCardValue < rhsCardValue }
    }

    return false
  }
}

enum HandType: Int, Comparable {
  case highCard
  case onePair
  case twoPair
  case threeOfAKind
  case fullHouse
  case fourOfAKind
  case fiveOfAKind

  init(hand: String) {
    var occurrences: [Character: Int] = [:]
    for card in hand {
      occurrences[card, default: 0] += 1
    }

    switch occurrences.values.sorted(by: >) {
    case [5]: self = .fiveOfAKind
    case [4, 1]: self = .fourOfAKind
    case [3, 2]: self = .fullHouse
    case [3, 1, 1]: self = .threeOfAKind
    case [2, 2, 1]: self = .twoPair
    case [2, 1, 1, 1]: self = .onePair
    case [1, 1, 1, 1, 1]: self = .highCard
    default: fatalError("unexpected hand definition \(hand)")
    }
  }

  init(handWithJokers hand: String) {
    var jokersCount = 0
    var occurrences: [Character: Int] = [:]
    for card in hand {
      if card == "J" {
        jokersCount += 1
      } else {
        occurrences[card, default: 0] += 1
      }
    }

    switch (jokersCount, occurrences.values.sorted(by: >)) {
    case (0, _): self = .init(hand: hand)
    case (1, [4]): self = .fiveOfAKind
    case (1, [3, 1]): self = .fourOfAKind
    case (1, [2, 2]): self = .fullHouse
    case (1, [2, 1, 1]): self = .threeOfAKind
    case (1, _): self = .onePair
    case (2, [3]): self = .fiveOfAKind
    case (2, [2, 1]): self = .fourOfAKind
    case (2, _): self = .threeOfAKind
    case (3, [2]): self = .fiveOfAKind
    case (3, _): self = .fourOfAKind
    case (4, _), (5, _): self = .fiveOfAKind
    default: fatalError("unexpected hand definition \(hand)")
    }
  }

  static func < (lhs: HandType, rhs: HandType) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

guard let file = FileHandle(forReadingAtPath: "07.in")
else { fatalError("input not found") }

var plays: [Play] = []
for try await line in file.bytes.lines {
  plays.append(Play(rawValue: line))
}

let totalWinnings = plays
  .sorted(by: { $0.beats($1) })
  .enumerated().reduce(0) { $0+($1.offset+1)*$1.element.bid }
print(totalWinnings)

let totalWinningsConsideringJokers = plays
  .sorted(by: { $0.beats($1, consideringJokers: true) })
  .enumerated().reduce(0) { $0+($1.offset+1)*$1.element.bid }
print(totalWinningsConsideringJokers)
