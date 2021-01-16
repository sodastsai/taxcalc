@testable import DataFormat

import XCTest

class CurrencyTests: XCTestCase {
  func testStringRepresentationOfPound() {
    let gbp1 = Currency(amount: Decimal(string: "3.20")!, unit: .GBP)
    XCTAssertEqual("\(gbp1)", "£3.20")
    let gbp2 = Currency(amount: Decimal(string: "-1024.32")!, unit: .GBP)
    XCTAssertEqual("\(gbp2)", "-£1,024.32")
  }

  func testStringRepresentationOfDollar() {
    let usd1 = Currency(amount: Decimal(string: "3.20")!, unit: .USD)
    XCTAssertEqual("\(usd1)", "$3.20")
    let usd2 = Currency(amount: Decimal(string: "-1024.32")!, unit: .USD)
    XCTAssertEqual("\(usd2)", "-$1,024.32")
  }
}
