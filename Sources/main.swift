import Foundation

let args = ProcessInfo.processInfo.arguments
let file = args.contains("ex") ? "ex" : "in"

guard let input = try? String(contentsOfFile: file, encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
print(lines)
