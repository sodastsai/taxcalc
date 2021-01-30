import Foundation
import HMRCExchangeRate

public extension Currency {
  enum ConversionError: Error {
    case unsupportedConversion(Unit, Unit)
    case failedToQuery(Unit)
  }

  func converting(to anotherUnit: Unit, via source: RateSource = .directHMRC) throws -> Currency {
    let conversion = try getConversion(from: unit, to: anotherUnit, via: source)
    return Currency(amount: conversion(amount), unit: anotherUnit, time: time)
  }
}

extension Currency {
  typealias AmountConverter = (Decimal) -> Decimal

  func getConversion(from currentUnit: Unit, to anotherUnit: Unit,
                     via source: RateSource) throws -> AmountConverter {
    guard currentUnit != anotherUnit else {
      return { $0 }
    }
    switch (currentUnit, anotherUnit) {
    case let (.GBP, queryingUnit), let (queryingUnit, .GBP):
      guard let rate = source.rate(of: queryingUnit.rawValue, at: time)?.first?.rate else {
        throw ConversionError.failedToQuery(queryingUnit)
      }
      if currentUnit == .GBP {
        return { $0 * rate }
      } else {
        return { $0 / rate }
      }
    case (_, _):
      throw ConversionError.unsupportedConversion(currentUnit, anotherUnit)
    }
  }
}
