import Algorithms
import Foundation

guard let input = try? String(contentsOfFile: "23.in", encoding: .utf8)
else { fatalError("input not found") }

var groups: [String: Set<String>] = [:]
for line in input.components(separatedBy: "\n") {
  let components = line.components(separatedBy: "-")
  let computer1 = components[0]
  let computer2 = components[1]
  groups[computer1, default: []].insert(computer2)
  groups[computer2, default: []].insert(computer1)
}

var networksOf3: Set<Set<String>> = []
for (computer, neighbors) in groups {
  for combination in neighbors.combinations(ofCount: 2) {
    guard
      groups[combination[0], default: []].contains(combination[1]),
      groups[combination[1], default: []].contains(combination[0])
    else { continue }
    networksOf3.insert(Set([computer]+combination))
  }
}

print(
  networksOf3.count { network in
    network.contains { computer in
      computer.starts(with: "t")
    }
  }
)

var largestNetwork: Set<String> = []
for (computer, others) in groups {
  var network: Set<String> = [computer]
  for other in others {
    if !network.contains(other) {
      if network.allSatisfy({ groups[other, default: []].contains($0) }) {
        network.insert(other)
      }
    }
  }

  if largestNetwork.count < network.count {
    largestNetwork = Set(network)
  }
}

print(largestNetwork.sorted().joined(separator: ","))
