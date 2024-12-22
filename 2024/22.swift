import Collections
import Foundation

guard let input = try? String(contentsOfFile: "22.in", encoding: .utf8)
else { fatalError("input not found") }

func computeSecret(fromSecret secret: Int) -> Int {
  var secret = secret
  secret = (secret*64 ^ secret)%16_777_216
  secret = (secret/32 ^ secret)%16_777_216
  secret = (secret*2048 ^ secret)%16_777_216
  return secret
}

var secretsSum = 0
var combinedPrices: [Deque<Int>: Int] = [:]
for line in input.components(separatedBy: "\n") {
  var secret = Int(line)!
  var firstPriceForVariation: [Deque<Int>: Int] = [:]
  var latestVariations: Deque<Int> = []
  var previousPrice = secret%10
  for _ in 0 ..< 2000 {
    secret = computeSecret(fromSecret: secret)

    let price = secret%10
    latestVariations.append(price-previousPrice)
    latestVariations.removeFirst(max(0, latestVariations.count-4))
    if firstPriceForVariation[latestVariations] == nil {
      firstPriceForVariation[latestVariations] = price
    }

    previousPrice = price
  }

  secretsSum += secret
  for (buffer, price) in firstPriceForVariation {
    combinedPrices[buffer, default: 0] += price
  }
}

print(secretsSum)
print(combinedPrices.values.max()!)
