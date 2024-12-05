import Foundation

let args = ProcessInfo.processInfo.arguments
let file = args.contains("ex") ? "ex" : "in"
let path = "Sources/Resources/\(file)"

guard let input = try? String(contentsOfFile: path, encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
print(lines)
