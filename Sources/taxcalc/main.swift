import ArgumentParser
import DataSource
import Foundation

struct TaxCalculator: ParsableCommand {
  @Argument(help: "Directory of Stock & Shares records")
  var recordsContainer: URL

  func run() throws {
    let records = try RecorderLoader.default.load(from: recordsContainer)
    print(records.count)
  }
}

TaxCalculator.main()
