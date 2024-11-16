import Foundation

guard let file = FileHandle(forReadingAtPath: "12.in")
else { fatalError("input not found") }

var smallCaves: Set<String> = []
var graph: [String: Set<String>] = [:]
for try await line in file.bytes.lines {
  let components = line.components(separatedBy: "-")
  let src = components[0]
  let dst = components[1]
  graph[src, default: []].insert(dst)
  graph[dst, default: []].insert(src)
  if src.allSatisfy(\.isLowercase) { smallCaves.insert(src) }
  if dst.allSatisfy(\.isLowercase) { smallCaves.insert(dst) }
}

@MainActor func paths(withDuplicateCave duplicateCave: String? = nil) -> [String] {
  var paths: [String] = []
  var path = ["start"]
  var visits = ["start": 1]
  var backtrack: ((String) -> Void)!
  backtrack = { cave in
    guard cave != "end" else {
      paths.append(path.joined(separator: ","))
      return
    }

    for dst in graph[cave, default: []] {
      let isSmallCave = smallCaves.contains(dst)
      if isSmallCave, visits[dst, default: 0] > (dst == duplicateCave ? 1 : 0) { continue }

      if isSmallCave { visits[dst, default: 0] += 1 }
      path.append(dst)
      backtrack(dst)
      path.removeLast()
      if isSmallCave { visits[dst, default: 0] -= 1 }
    }
  }

  backtrack("start")
  return paths
}

print(paths().count)

var pathsWithDuplicateVisits: Set<String> = []
for cave in smallCaves.subtracting(["start", "end"]) {
  pathsWithDuplicateVisits.formUnion(paths(withDuplicateCave: cave))
}

print(pathsWithDuplicateVisits.count)
