import Foundation

class Monkey {
  var items: [Int]
  var operation: (Int) -> Int
  var divisor: Int
  var ifDivisible: Int
  var ifNotDivisible: Int
  var inspectedItemsCount: Int = 0
  init(items: [Int], operation: @escaping (Int) -> Int, divisor: Int, ifDivisible: Int, ifNotDivisible: Int) {
    self.items = items
    self.operation = operation
    self.divisor = divisor
    self.ifDivisible = ifDivisible
    self.ifNotDivisible = ifNotDivisible
  }
}

extension Monkey {
  func test(_ worryLevel: Int) -> Int {
    return worryLevel%divisor == 0 ? ifDivisible : ifNotDivisible
  }
}

struct Configuration {
  var monkeys: [Monkey]
  var rounds: Int
  var worryLevelDivisor: Int = 1
}

func greatestCommonDivisor(_ x: Int, _ y: Int) -> Int {
  var a = 0
  var b = max(x, y)
  var r = min(x, y)
  while r != 0 {
    a = b
    b = r
    r = a%b
  }
  return b
}

func leastCommonMultiple(_ x: Int, _ y: Int) -> Int {
  return x/greatestCommonDivisor(x, y)*y
}

func monkeyBusiness(for configuration: Configuration) -> Int {
  let monkeys = configuration.monkeys

  let leastCommonMultiple = monkeys
    .map(\.divisor)
    .reduce(1, leastCommonMultiple)

  for _ in 1 ... configuration.rounds {
    for (oldMonkeyIndex, monkey) in monkeys.enumerated() {
      for oldWorryLevel in monkey.items {
        var newWorryLevel = monkey.operation(oldWorryLevel)
        newWorryLevel /= configuration.worryLevelDivisor
        newWorryLevel %= leastCommonMultiple
        let newMonkeyIndex = monkey.test(newWorryLevel)
        monkeys[oldMonkeyIndex].inspectedItemsCount += 1
        monkeys[oldMonkeyIndex].items.removeFirst()
        monkeys[newMonkeyIndex].items.append(newWorryLevel)
      }
    }
  }

  return monkeys
    .map(\.inspectedItemsCount)
    .sorted()
    .suffix(2)
    .reduce(1, *)
}

extension [Monkey] {
  static var example: Self {
    [
      .init(items: [79, 98], operation: { $0*19 }, divisor: 23, ifDivisible: 2, ifNotDivisible: 3),
      .init(items: [54, 65, 75, 74], operation: { $0+6 }, divisor: 19, ifDivisible: 2, ifNotDivisible: 0),
      .init(items: [79, 60, 97], operation: { $0*$0 }, divisor: 13, ifDivisible: 1, ifNotDivisible: 3),
      .init(items: [74], operation: { $0+3 }, divisor: 17, ifDivisible: 0, ifNotDivisible: 1),
    ]
  }

  static var input: Self {
    [
      .init(items: [66, 71, 94], operation: { $0*5 }, divisor: 3, ifDivisible: 7, ifNotDivisible: 4),
      .init(items: [70], operation: { $0+6 }, divisor: 17, ifDivisible: 3, ifNotDivisible: 0),
      .init(items: [62, 68, 56, 65, 94, 78], operation: { $0+5 }, divisor: 2, ifDivisible: 3, ifNotDivisible: 1),
      .init(items: [89, 94, 94, 67], operation: { $0+2 }, divisor: 19, ifDivisible: 7, ifNotDivisible: 0),
      .init(items: [71, 61, 73, 65, 98, 98, 63], operation: { $0*7 }, divisor: 11, ifDivisible: 5, ifNotDivisible: 6),
      .init(items: [55, 62, 68, 61, 60], operation: { $0+7 }, divisor: 5, ifDivisible: 2, ifNotDivisible: 1),
      .init(items: [93, 91, 69, 64, 72, 89, 50, 71], operation: { $0+1 }, divisor: 13, ifDivisible: 5, ifNotDivisible: 2),
      .init(items: [76, 50], operation: { $0*$0 }, divisor: 7, ifDivisible: 4, ifNotDivisible: 6),
    ]
  }
}

func part1() -> Int {
  monkeyBusiness(for: .init(monkeys: .monkeys(), rounds: 20, worryLevelDivisor: 3))
}

func part2() -> Int {
  monkeyBusiness(for: .init(monkeys: .monkeys(), rounds: 10000))
}

print(part2() == 15_117_269_860)
