import Foundation

guard let input = try? String(contentsOfFile: "Sources/Resources/ex", encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
print(lines)
