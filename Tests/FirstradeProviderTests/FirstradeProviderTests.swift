import DataFormat
@testable import FirstradeProvider
import Foundation

import XCTest

func makeDate(day: Int, month: Int, year: Int) -> Date {
  let dateComponents = DateComponents(calendar: .current, year: year, month: month, day: day)
  guard let date = Calendar.current.date(from: dateComponents) else {
    fatalError()
  }
  return date
}

func makeDecimal(_ string: String) -> Decimal {
  guard let decimal = Decimal(string: string) else {
    fatalError()
  }
  return decimal
}

class FirstradeProviderTests: XCTestCase {
  // swiftlint:disable function_body_length
  func testReadingFromCSVFile() {
    guard
      let csvURL = Bundle.module.url(forResource: "firstrade-example", withExtension: "csv"),
      let records = try? FirstradeRecord.from(contentsOf: csvURL)
    else {
      XCTFail("Cannot load example CSV")
      return
    }
    XCTAssertEqual(records.count, 5)

    XCTAssertEqual(records[0].symbol, nil)
    XCTAssertEqual(records[0].quantity, 0)
    XCTAssertEqual(records[0].price, Currency(amount: 0, unit: .USD, time: records[0].tradeDate))
    XCTAssertEqual(records[0].action, .other)
    XCTAssertEqual(records[0].description, "Wire Funds Received")
    XCTAssertEqual(records[0].tradeDate, makeDate(day: 29, month: 10, year: 2018))
    XCTAssertEqual(records[0].settledDate, makeDate(day: 29, month: 10, year: 2018))
    XCTAssertEqual(records[0].interest, Currency(amount: 0, unit: .USD, time: records[0].tradeDate))
    XCTAssertEqual(records[0].amount, Currency(amount: 2000, unit: .USD, time: records[0].tradeDate))
    XCTAssertEqual(records[0].commission, Currency(amount: 0, unit: .USD, time: records[0].tradeDate))
    XCTAssertEqual(records[0].fee, Currency(amount: 0, unit: .USD, time: records[0].tradeDate))
    XCTAssertEqual(records[0].cusip, nil)
    XCTAssertEqual(records[0].recordType, .financial)

    XCTAssertEqual(records[1].symbol, "QQQ")
    XCTAssertEqual(records[1].quantity, -1)
    XCTAssertEqual(records[1].price, Currency(amount: "164.21001", unit: .USD, time: records[1].tradeDate))
    XCTAssertEqual(records[1].action, .sell)
    XCTAssertEqual(
      records[1].description,
      // swiftlint:disable line_length
      "INVESCO QQQ TR                 UNIT SER 1                     INTERNET ORDER                 UNSOLICITED                    SHORT."
      // swiftlint:enable line_length
    )
    XCTAssertEqual(records[1].tradeDate, makeDate(day: 30, month: 10, year: 2018))
    XCTAssertEqual(records[1].settledDate, makeDate(day: 1, month: 11, year: 2018))
    XCTAssertEqual(records[1].interest, Currency(amount: 0, unit: .USD, time: records[1].tradeDate))
    XCTAssertEqual(records[1].amount, Currency(amount: "164.2", unit: .USD, time: records[1].tradeDate))
    XCTAssertEqual(records[1].commission, Currency(amount: 0, unit: .USD, time: records[1].tradeDate))
    XCTAssertEqual(records[1].fee, Currency(amount: "0.01", unit: .USD, time: records[1].tradeDate))
    XCTAssertEqual(records[1].cusip, "12345566")
    XCTAssertEqual(records[1].recordType, .trade)

    XCTAssertEqual(records[2].symbol, "AAPL")
    XCTAssertEqual(records[2].quantity, 1)
    XCTAssertEqual(records[2].price, Currency(amount: 218, unit: .USD, time: records[2].tradeDate))
    XCTAssertEqual(records[2].action, .buy)
    XCTAssertEqual(records[2].description, "APPLE INC                      INTERNET ORDER                 UNSOLICITED")
    XCTAssertEqual(records[2].tradeDate, makeDate(day: 1, month: 11, year: 2018))
    XCTAssertEqual(records[2].settledDate, makeDate(day: 5, month: 11, year: 2018))
    XCTAssertEqual(records[2].interest, Currency(amount: 0, unit: .USD, time: records[2].tradeDate))
    XCTAssertEqual(records[2].amount, Currency(amount: -218, unit: .USD, time: records[2].tradeDate))
    XCTAssertEqual(records[2].commission, Currency(amount: 0, unit: .USD, time: records[2].tradeDate))
    XCTAssertEqual(records[2].fee, Currency(amount: 0, unit: .USD, time: records[2].tradeDate))
    XCTAssertEqual(records[2].cusip, "37923121")
    XCTAssertEqual(records[2].recordType, .trade)

    XCTAssertEqual(records[3].symbol, "AAPL")
    XCTAssertEqual(records[3].quantity, 0)
    XCTAssertEqual(records[3].price, Currency(amount: 0, unit: .USD, time: records[3].tradeDate))
    XCTAssertEqual(records[3].action, .dividend)
    XCTAssertEqual(
      records[3].description,
      // swiftlint:disable line_length
      "APPLE INC                      CASH DIV  ON       2 SHS       REC 12/12/18 PAY 11/30/18      NON-RES TAX WITHHELD"
      // swiftlint:enable line_length
    )
    XCTAssertEqual(records[3].tradeDate, makeDate(day: 31, month: 03, year: 2020))
    XCTAssertEqual(records[3].settledDate, makeDate(day: 15, month: 04, year: 2020))
    XCTAssertEqual(records[3].interest, Currency(amount: 0, unit: .USD, time: records[3].tradeDate))
    XCTAssertEqual(records[3].amount, Currency(amount: 1.8623, unit: .USD, time: records[3].tradeDate))
    XCTAssertEqual(records[3].commission, Currency(amount: 1.32, unit: .USD, time: records[3].tradeDate))
    XCTAssertEqual(records[3].fee, Currency(amount: 0, unit: .USD, time: records[3].tradeDate))
    XCTAssertEqual(records[3].cusip, "94832582")
    XCTAssertEqual(records[3].recordType, .financial)

    XCTAssertEqual(records[4].symbol, nil)
    XCTAssertEqual(records[4].quantity, 0)
    XCTAssertEqual(records[4].price, Currency(amount: 0, unit: .USD, time: records[4].tradeDate))
    XCTAssertEqual(records[4].action, .interest)
    XCTAssertEqual(records[4].description, "INTEREST ON CREDIT BALANCE     AT  0.065  10/41 THRU 11/24")
    XCTAssertEqual(records[4].tradeDate, makeDate(day: 16, month: 11, year: 2018))
    XCTAssertEqual(records[4].settledDate, makeDate(day: 16, month: 11, year: 2018))
    XCTAssertEqual(records[4].interest, Currency(amount: 0, unit: .USD, time: records[4].tradeDate))
    XCTAssertEqual(records[4].amount, Currency(amount: "0.03", unit: .USD, time: records[4].tradeDate))
    XCTAssertEqual(records[4].commission, Currency(amount: 0, unit: .USD, time: records[4].tradeDate))
    XCTAssertEqual(records[4].fee, Currency(amount: 0, unit: .USD, time: records[4].tradeDate))
    XCTAssertEqual(records[4].cusip, "00099A109")
    XCTAssertEqual(records[4].recordType, .financial)
  }

  // swiftlint:enable function_body_length
}
