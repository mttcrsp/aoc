import Foundation

guard let file = FileHandle(forReadingAtPath: "01.in")
else { fatalError("input not found") }

var list1: [Int] = []
var list2: [Int] = []
for try await line in file.bytes.lines {
  let numbers = line
    .components(separatedBy: "   ")
    .compactMap(Int.init)
  list1.append(numbers[0])
  list2.append(numbers[1])
}

list1.sort()
list2.sort()

var totalDistance = 0
for (lhs, rhs) in zip(list1, list2) {
  totalDistance += abs(lhs-rhs)
}

var countIn2: [Int: Int] = [:]
for num in list2 {
  countIn2[num, default: 0] += 1
}

var similarityScore = 0
for num in list1 {
  similarityScore += (num*countIn2[num, default: 0])
}

print(totalDistance)
print(similarityScore)
