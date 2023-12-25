import Foundation

guard let file = FileHandle(forReadingAtPath: "25.in")
else { fatalError("input not found") }

var components: Set<String> = []
var connections: [(String, String)] = []
for try await line in file.bytes.lines {
  let elements = line.components(separatedBy: ": ")
  guard elements.count == 2
  else { fatalError("malformed components definition") }

  let connector = elements[0]
  for connected in Set(elements[1].components(separatedBy: " ")) {
    components.insert(connector)
    components.insert(connected)
    connections.append((connector, connected))
  }
}

var subsets: [Set<String>] = []
while true {
  subsets = components.map { Set([$0]) }

  while subsets.count > 2 {
    guard
      let (connector, connected) = connections.randomElement(),
      let i = subsets.firstIndex(where: { $0.contains(connector) }),
      let j = subsets.firstIndex(where: { $0.contains(connected) })
    else { fatalError("failed to keep track of subsets") }
    if i != j {
      subsets.append(subsets[i].union(subsets[j]))
      subsets.remove(at: i > j ? i : j)
      subsets.remove(at: i > j ? j : i)
    }
  }

  let brokenConnectionsCount = connections.reduce(0) { total, connection in
    let (connector, connected) = connection
    let i = subsets.firstIndex(where: { $0.contains(connector) })
    let j = subsets.firstIndex(where: { $0.contains(connected) })
    return total+(i != j ? 1 : 0)
  }
  if brokenConnectionsCount <= 3 {
    break
  }
}

print(subsets.map(\.count).reduce(1, *))
