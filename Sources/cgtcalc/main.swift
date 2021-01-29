import DataFormat

func case1() {
  let priceInGBP = Currency(amount: 1, unit: .GBP)
  if let priceInUSD = try? priceInGBP.converting(to: .USD) {
    print("\(priceInGBP) == \(priceInUSD)")
  } else {
    print("case1 QQ")
  }
}

func case2() {
  let priceInUSD = Currency(amount: 2.70, unit: .USD)
  if let priceInGBP = try? priceInUSD.converting(to: .GBP) {
    print("\(priceInUSD) == \(priceInGBP)")
  } else {
    print("case2 QQ")
  }
}

case1()
case2()
