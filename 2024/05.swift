import Foundation

guard let input = try? String(contentsOfFile: "05.in", encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
let components = lines.split(separator: "")
let rules = components[0].map { $0.components(separatedBy: "|") }
let updates = components[1].map { $0.components(separatedBy: ",") }

var graph: [String: Set<String>] = [:]
var inverseGraph: [String: Set<String>] = [:]
for rule in rules {
  graph[rule[0], default: []].insert(rule[1])
  inverseGraph[rule[1], default: []].insert(rule[0])
}

var cachedPredecessors: [String: Set<String>] = [:]
func predecessors(_ page: String) -> Set<String> {
  if let cached = cachedPredecessors[page] { return cached }

  var result: Set<String> = []
  var stack = [page]
  while let current = stack.popLast(), !result.contains(current) {
    let predecessors = inverseGraph[current, default: []]
    result.formUnion(predecessors)
    stack.append(contentsOf: predecessors)
  }

  cachedPredecessors[page] = result
  return result
}

var cachedSuccessors: [String: Set<String>] = [:]
func successors(_ page: String) -> Set<String> {
  if let cached = cachedSuccessors[page] { return cached }

  var result: Set<String> = []
  var stack = [page]
  while let current = stack.popLast(), !result.contains(current) {
    let successors = graph[current, default: []]
    result.formUnion(successors)
    stack.append(contentsOf: successors)
  }

  cachedSuccessors[page] = result
  return result
}

func ordered(_ update: [String]) -> [String] {
  update.sorted { lhs, rhs in
    if predecessors(lhs).contains(rhs) { return false }
    if predecessors(rhs).contains(lhs) { return true }
    if successors(lhs).contains(rhs) { return true }
    if successors(rhs).contains(lhs) { return false }
    return true
  }
}

func midPage(_ update: [String]) -> Int {
  Int(update[update.count/2])!
}

var part1 = 0
var part2 = 0
loop: for original in updates {
  let ordered = ordered(original)
  if original == ordered {
    part1 += midPage(original)
  } else {
    part2 += midPage(ordered)
  }
}

print(part1)
print(part2)
