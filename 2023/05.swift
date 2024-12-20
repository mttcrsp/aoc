import Foundation

struct RangeConverter {
  let srcLowerBound: Int
  let dstLowerBound: Int
  let count: Int

  init(rawValue: String) {
    let components = rawValue.components(separatedBy: " ")
    guard
      components.count == 3,
      let dstLowerBound = Int(components[0]),
      let srcLowerBound = Int(components[1]),
      let count = Int(components[2])
    else { fatalError("malformed range converter definition '\(rawValue)'") }
    self.srcLowerBound = srcLowerBound
    self.dstLowerBound = dstLowerBound
    self.count = count
  }

  func convert(_ value: Int) -> Int? {
    let range = (srcLowerBound ... srcLowerBound+count-1)
    return range.contains(value) ? value-srcLowerBound+dstLowerBound : nil
  }
}

struct Converter {
  let converters: [RangeConverter]

  init(block: String) {
    converters = block
      .components(separatedBy: "\n")
      .dropFirst()
      .map(RangeConverter.init)
  }

  func convert(_ value: Int) -> Int {
    for converter in converters {
      if let converted = converter.convert(value) {
        return converted
      }
    }
    return value
  }

  func convert(_ ranges: [Range<Int>]) -> [Range<Int>] {
    var ranges = ranges
    var convertedRanges: [Range<Int>] = []
    for converter in converters {
      let srcLowerbound = converter.srcLowerBound
      let srcUpperbound = converter.srcLowerBound+converter.count
      var newRanges: [Range<Int>] = []
      while !ranges.isEmpty {
        let range = ranges.removeFirst()

        let intersectionLowerBound = max(range.lowerBound, srcLowerbound)
        let intersectionUpperBound = min(range.upperBound, srcUpperbound)
        if intersectionLowerBound < intersectionUpperBound {
          convertedRanges.append(
            converter.convert(intersectionLowerBound)!
              ..< converter.convert(intersectionUpperBound-1)!
          )
        }

        let lhsLowerBound = range.lowerBound
        let lhsUpperBound = min(range.upperBound, srcLowerbound)
        if lhsLowerBound < lhsUpperBound {
          newRanges.append(lhsLowerBound ..< lhsUpperBound)
        }

        let rhsLowerBound = max(range.lowerBound, srcUpperbound)
        let rhsUpperBound = range.upperBound
        if rhsLowerBound < rhsUpperBound {
          newRanges.append(rhsLowerBound ..< rhsUpperBound)
        }
      }
      ranges = newRanges
    }
    return convertedRanges+ranges
  }
}

struct CompositeConverter {
  let converters: [Converter]

  init(blocks: [String]) {
    converters = blocks.map(Converter.init)
  }

  func convert(_ value: Int) -> Int {
    var value = value
    for converter in converters {
      value = converter.convert(value)
    }
    return value
  }

  func convert(_ ranges: [Range<Int>]) -> [Range<Int>] {
    var ranges = ranges
    for converter in converters {
      ranges = converter.convert(ranges)
    }
    return ranges
  }
}

let string = try String(contentsOfFile: "05.in", encoding: .utf8)
let blocks = string.components(separatedBy: "\n\n")
let seeds = blocks[0].components(separatedBy: " ").compactMap(Int.init)
let converter = CompositeConverter(blocks: Array(blocks[1...]))

guard let lowestLocationNumber1 = seeds.map(converter.convert).min()
else { fatalError() }
print(lowestLocationNumber1)

let seedRanges = stride(from: 0, to: seeds.count, by: 2)
  .map { i in seeds[i] ..< seeds[i]+seeds[i+1] }

guard let lowestLocationNumber2 = converter.convert(seedRanges).map(\.lowerBound).min()
else { fatalError() }
print(lowestLocationNumber2)
