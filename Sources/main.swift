import Foundation

guard let file = FileHandle(forReadingAtPath: "Sources/Resources/ex")
else { fatalError("input not found") }

for try await line in file.bytes.lines {
  print(line)
}
