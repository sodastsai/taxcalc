@testable import DataFormat

import XCTest

class CurrencyTests: XCTestCase {
  func testStringRepresentationOfPound() {
    guard let gbp1 = Currency(amount: "3.20", unit: .GBP) else {
      XCTFail("Failed to instantiate a Currency instance")
      return
    }
    XCTAssertEqual("\(gbp1)", "£3.20")
    guard let gbp2 = Currency(amount: "-1024.32", unit: .GBP) else {
      XCTFail("Failed to instantiate a Currency instance")
      return
    }
    XCTAssertEqual("\(gbp2)", "-£1,024.32")
  }

  func testStringRepresentationOfDollar() {
    guard let usd1 = Currency(amount: "3.20", unit: .USD) else {
      XCTFail("Failed to instantiate a Currency instance")
      return
    }
    XCTAssertEqual("\(usd1)", "$3.20")
    guard let usd2 = Currency(amount: "-1024.32", unit: .USD) else {
      XCTFail("Failed to instantiate a Currency instance")
      return
    }
    XCTAssertEqual("\(usd2)", "-$1,024.32")
  }
}
