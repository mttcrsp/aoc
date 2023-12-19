import Foundation

extension CharacterSet {
  static let part = CharacterSet(charactersIn: "{},=")
    .union(.whitespacesAndNewlines)
    .union(.letters)
}

struct Part {
  let x: Int, m: Int, a: Int, s: Int

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = .part
    guard
      let x = scanner.scanInt(),
      let m = scanner.scanInt(),
      let a = scanner.scanInt(),
      let s = scanner.scanInt()
    else { fatalError("malformed part '\(rawValue)'") }
    self.x = x
    self.m = m
    self.a = a
    self.s = s
  }

  var rating: Int {
    x+m+a+s
  }
}

struct Workflow {
  let name: String
  let rules: [Rule]
  let fallback: Outcome

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    guard
      let name = scanner.scanUpToString("{"),
      let _ = scanner.scanString("{")
    else { fatalError("malformed workflow '\(rawValue)'") }
    self.name = name

    guard let rulesRaw = scanner.scanUpToString("}")
    else { fatalError("malformed workflow '\(rawValue)'") }
    let rulesComponents = rulesRaw.components(separatedBy: ",")
    guard let lastRulesComponent = rulesComponents.last
    else { fatalError("no rule found in workflow '\(rawValue)'") }

    rules = rulesComponents.dropLast().map(Rule.init)
    fallback = Outcome(rawValue: lastRulesComponent)
  }

  func outcome(for part: Part) -> Outcome {
    for rule in rules {
      if let outcome = rule.outcome(for: part) {
        return outcome
      }
    }
    return fallback
  }
}

struct Rule {
  let category: String
  let comparisonOperator: ComparisonOperator
  let rightOperand: Int
  let outcome: Outcome

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    guard
      let category = scanner.scanCharacters(from: .init(charactersIn: "xmas")),
      let comparisonOperatorRaw = scanner.scanCharacter(),
      let comparisonOperator = ComparisonOperator(rawValue: comparisonOperatorRaw),
      let rightOperand = scanner.scanInt(),
      let _ = scanner.scanString(":")
    else { fatalError("malformed rule '\(rawValue)'") }
    self.category = category
    self.comparisonOperator = comparisonOperator
    self.rightOperand = rightOperand

    let outcomeRaw = String(rawValue[scanner.currentIndex...])
    outcome = Outcome(rawValue: outcomeRaw)
  }

  func outcome(for part: Part) -> Outcome? {
    let `operator`: (Int, Int) -> Bool = switch comparisonOperator {
    case .greaterThan: (>)
    case .lessThan: (<)
    }

    let leftOperand = switch category {
    case "x": part.x
    case "m": part.m
    case "a": part.a
    case "s": part.s
    default: fatalError("unknown category '\(category)'")
    }

    return `operator`(leftOperand, rightOperand) ? outcome : nil
  }

  func applied(to range: ClosedRange<Int>, valid: Bool) -> ClosedRange<Int>? {
    var lowerBound = range.lowerBound
    var upperBound = range.upperBound
    switch (comparisonOperator, valid) {
    case (.lessThan, true): upperBound = min(upperBound, rightOperand-1)
    case (.lessThan, false): lowerBound = max(lowerBound, rightOperand)
    case (.greaterThan, true): lowerBound = max(lowerBound, rightOperand+1)
    case (.greaterThan, false): upperBound = min(upperBound, rightOperand)
    }
    return lowerBound <= upperBound ? lowerBound ... upperBound : nil
  }
}

enum ComparisonOperator: Character {
  case lessThan = "<"
  case greaterThan = ">"
}

enum Outcome: Equatable {
  case accepted
  case rejected
  case workflow(String)

  init(rawValue: String) {
    switch rawValue {
    case "A": self = .accepted
    case "R": self = .rejected
    case let name where name.allSatisfy(\.isLetter):
      self = .workflow(name)
    default:
      fatalError("malformed outcome '\(rawValue)'")
    }
  }
}

let string = try String(contentsOfFile: "19.in")
let components = string.components(separatedBy: "\n\n")
guard components.count == 2 else { fatalError("malformed input") }

var workflows: [String: Workflow] = [:]
for rawValue in components[0].components(separatedBy: "\n") {
  let workflow = Workflow(rawValue: rawValue)
  workflows[workflow.name] = workflow
}

guard let initialWorkflow = workflows["in"]
else { fatalError("initial workflow 'in' not found") }

var totalRating = 0
for rawValue in components[1].components(separatedBy: "\n") {
  let part = Part(rawValue: rawValue)
  var workflow = initialWorkflow
  loop: while true {
    switch workflow.outcome(for: part) {
    case let .workflow(name):
      guard let nextWorkflow = workflows[name]
      else { fatalError("workflow '\(name)' not found") }
      workflow = nextWorkflow
    case .accepted:
      totalRating += part.rating
      break loop
    case .rejected:
      break loop
    }
  }
}

let defaultRange = 1 ... 4000
var combinationsCount = 0
var queue: [(Workflow, [String: ClosedRange<Int>])] = [(initialWorkflow, [:])]
while var (workflow, categoryRanges) = queue.popLast() {
  let outcomes = workflow.rules.map(\.outcome)
    + [workflow.fallback]

  for (index, outcome) in outcomes.enumerated() {
    for rule in workflow.rules[0 ..< index] {
      let oldRange = categoryRanges[rule.category, default: defaultRange]
      let newRange = rule.applied(to: oldRange, valid: false)
      categoryRanges[rule.category] = newRange
    }

    if index < workflow.rules.endIndex {
      let rule = workflow.rules[index]
      let oldRange = categoryRanges[rule.category, default: defaultRange]
      let newRange = rule.applied(to: oldRange, valid: true)
      categoryRanges[rule.category] = newRange
    }

    switch outcome {
    case let .workflow(name):
      guard let newWorkflow = workflows[name]
      else { fatalError("workflow '\(name)' not found") }
      queue.append((newWorkflow, categoryRanges))
    case .accepted:
      combinationsCount += ["x", "m", "a", "s"].reduce(1) { total, category in
        total*categoryRanges[category, default: defaultRange].count
      }
    case .rejected:
      continue
    }
  }
}

print(totalRating)
print(combinationsCount)
