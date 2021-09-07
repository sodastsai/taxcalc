//

import ArgumentParser
import CGTCalcCore
import DataSource
import Foundation

struct TaxCalculator: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "A utility for calculating UK CGT.",
    subcommands: [Calculator.self, RecordConverter.self]
  )
}

@main
enum App {
  static func main() async throws {
    try await TaxCalculator.main()
  }
}
