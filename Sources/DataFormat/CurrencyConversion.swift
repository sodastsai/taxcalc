import Foundation
import HMRCExchangeRate

public extension Currency {
  enum ConversionError: Error {
    case unsupportedConversion
    case failedToQuery(Unit)
  }

  func converting(to anotherUnit: Unit) throws -> Currency {
    let rate = try getRate(from: unit, to: anotherUnit)
    return Currency(amount: amount * rate, unit: anotherUnit, time: time)
  }
}

extension Currency {
  func getRate(from currentUnit: Unit, to anotherUnit: Unit) throws -> Decimal {
    guard currentUnit != anotherUnit else {
      return 1
    }
    switch (currentUnit, anotherUnit) {
    case let (.GBP, queryingRate), let (queryingRate, .GBP):
      guard let rate = RateSource.directHMRC.rate(of: queryingRate.rawValue, at: time)?.first?.rate else {
        throw ConversionError.failedToQuery(queryingRate)
      }
      return currentUnit == .GBP ? rate : 1 / rate
    case (_, _):
      throw ConversionError.unsupportedConversion
    }
  }
}
