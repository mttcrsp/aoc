import Foundation

guard
  let fileURL = Bundle.module.url(forResource: "ex", withExtension: nil),
  let file = try? FileHandle(forReadingFrom: fileURL)
else { fatalError("input not found") }

for try await line in file.bytes.lines {
  print(line)
}
