@testable import DataFormat
import Foundation
import HMRCExchangeRate

import XCTest

class TestRateFetcher: RateFetcher {
  var rates = [Month: [Rate.CurrencyCode: [Rate]]]()

  func fetchRate(of month: Month) async throws -> [Rate.CurrencyCode: [Rate]] {
    guard let rate = rates[month] else {
      throw RateFetcherError.fetchingError
    }
    return rate
  }
}

func makeDate(day: Int = 1, month: Int, year: Int) -> Date {
  let components = DateComponents(calendar: .current, year: year, month: month, day: day)
  guard let date = Calendar.current.date(from: components) else {
    fatalError("Cannot create Date representing \(day)/\(month)/\(year)")
  }
  return date
}

func makeRate(_ value: String, currencyCode: String) -> Rate {
  Rate(
    country: Rate.Country(name: "Testing Country", code: "TES"),
    currency: Rate.Currency(name: "Testing Currency", code: currencyCode),
    rate: makeDecimal(value)
  )
}

func makeDecimal(_ value: String) -> Decimal {
  guard let decimal = Decimal(string: value) else {
    fatalError()
  }
  return decimal
}

class CurrencyConversionTests: XCTestCase {
  let rateFetcher = TestRateFetcher()
  lazy var rateSource = RateSource(rateFetcher: rateFetcher)

  override func tearDown() {
    rateFetcher.rates.removeAll()
    super.tearDown()
  }

  func testConvertingToSameCurrencyType() async throws {
    let originalCurrency = Currency(amount: 1.2, unit: .USD, time: makeDate(month: 10, year: 2019))
    let convertedCurrency = try await originalCurrency.converting(to: .USD, via: rateSource)
    XCTAssertEqual(convertedCurrency.amount, 1.2)
    XCTAssertEqual(convertedCurrency.unit, .USD)
    XCTAssertEqual(convertedCurrency.time, originalCurrency.time)
  }

  func testConvertingToACurrencyThatRateSourceNotSupporting() async {
    let originalCurrency = Currency(amount: 1.2, unit: .GBP, time: makeDate(month: 10, year: 2019))
    do {
      _ = try await originalCurrency.converting(to: .USD, via: rateSource)
      XCTFail("Error not throw")
    } catch RateFetcherError.fetchingError {
      // pass
    } catch {
      XCTFail("Raised wrong error: \(error)")
    }
  }

  func testConvertingToACurrencyThatRateSourceIsEmpty() async {
    let originalCurrency = Currency(amount: 1.2, unit: .GBP, time: makeDate(month: 10, year: 2019))
    rateFetcher.rates[Month(.oct, in: 2019)] = [
      "USD": [],
    ]
    do {
      _ = try await originalCurrency.converting(to: .USD, via: rateSource)
      XCTFail("Error not throw")
    } catch let Currency.ConversionError.failedToQuery(unit) {
      XCTAssertEqual(unit, .USD)
    } catch {
      XCTFail("Raised wrong error: \(error)")
    }
  }

  func testConvertingBetweenTwoNonGBPCurrencies() async {
    let originalCurrency = Currency(amount: 1.2, unit: .TWD, time: makeDate(month: 10, year: 2019))
    do {
      _ = try await originalCurrency.converting(to: .USD, via: rateSource)
      XCTFail("Error not throw")
    } catch let Currency.ConversionError.unsupportedConversion(unit1, unit2) {
      XCTAssertEqual(unit1, .TWD)
      XCTAssertEqual(unit2, .USD)
    } catch {
      XCTFail("Raised wrong error: \(error)")
    }
  }

  func testConvertingFromGBPToOtherCurrency() async throws {
    rateFetcher.rates[Month(.oct, in: 2019)] = [
      "USD": [
        makeRate("1.3", currencyCode: "USD"),
      ],
    ]
    let originalCurrency = Currency(amount: makeDecimal("1.2"), unit: .GBP, time: makeDate(month: 10, year: 2019))
    let usdCurrency = try await originalCurrency.converting(to: .USD, via: rateSource)
    XCTAssertEqual(usdCurrency.amount, makeDecimal("1.56"))
    XCTAssertEqual(usdCurrency.unit, .USD)
    XCTAssertEqual(usdCurrency.time, originalCurrency.time)
  }

  func testConvertingFromOtherCurrencyToGBP() async throws {
    rateFetcher.rates[Month(.oct, in: 2020)] = [
      "TWD": [
        makeRate("38.20", currencyCode: "UWD"),
      ],
    ]
    let originalCurrency = Currency(amount: makeDecimal("76.40"), unit: .TWD, time: makeDate(month: 10, year: 2020))
    let gbpCurrency = try await originalCurrency.converting(to: .GBP, via: rateSource)
    XCTAssertEqual(gbpCurrency.amount, makeDecimal("2"))
    XCTAssertEqual(gbpCurrency.unit, .GBP)
    XCTAssertEqual(gbpCurrency.time, originalCurrency.time)
  }
}
