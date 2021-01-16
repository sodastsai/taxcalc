@testable import DataFormat

import XCTest

class CurrencyTests: XCTestCase {
  func testStringRepresentationOfPound() {
    let gbp3_20 = Currency(amount: Decimal(string: "3.20")!, unit: .GBP)
    XCTAssertEqual("\(gbp3_20)", "£3.20")
    let gbp1024_32 = Currency(amount: Decimal(string: "-1024.32")!, unit: .GBP)
    XCTAssertEqual("\(gbp1024_32)", "-£1,024.32")
  }

  func testStringRepresentationOfDollar() {
    let usd3_20 = Currency(amount: Decimal(string: "3.20")!, unit: .USD)
    XCTAssertEqual("\(usd3_20)", "$3.20")
    let usd1024_32 = Currency(amount: Decimal(string: "-1024.32")!, unit: .USD)
    XCTAssertEqual("\(usd1024_32)", "-$1,024.32")
  }
}
