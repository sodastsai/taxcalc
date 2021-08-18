//

@testable import DataSource
import Foundation

import XCTest

struct Book {
  let title: String
  let author: String
  let price: Int
}

class UtilsTests: XCTestCase {
  func testSortingByKeypath() {
    let books = [
      Book(title: "A", author: "Peter", price: 1),
      Book(title: "C", author: "Peter", price: 3),
      Book(title: "B", author: "Peter", price: 2),
    ]
    XCTAssertEqual(books.sorted(by: \.price).map(\.title), ["A", "B", "C"])
  }
}
