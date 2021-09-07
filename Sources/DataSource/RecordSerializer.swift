//

import CGTCalcCore
import Foundation

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "dd/MM/yyyy"
  return formatter
}()

private let priceFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.minimumFractionDigits = 3
  return formatter
}()

private func format(price: Decimal) -> String {
  priceFormatter.string(from: NSDecimalNumber(decimal: price)) ?? "\(price)"
}

private extension Transaction {
  var serializedString: String {
    let kind = kind.serializedString
    let date = dateFormatter.string(from: date)
    let price = format(price: price)
    let expenses = format(price: expenses)
    return "\(kind) \(date) \(asset) \(amount) \(price) \(expenses)"
  }
}

private extension Transaction.Kind {
  var serializedString: String {
    switch self {
    case .Buy:
      return "BUY"
    case .Sell:
      return "SELL"
    }
  }
}

private extension AssetEvent {
  var serializedString: String {
    let date = dateFormatter.string(from: date)
    switch kind {
    case let .CapitalReturn(amount, value):
      return "CAPRETURN \(date) \(asset) \(amount) \(value)"
    case let .Dividend(amount, value):
      return "DIVIDEND \(date) \(asset) \(amount) \(value)"
    case let .Split(multiplier):
      return "SPLIT \(date) \(asset) \(multiplier)"
    case let .Unsplit(multiplier):
      return "SPLIT \(date) \(asset) \(multiplier)"
    }
  }
}

public func serialize(transactions: [Transaction], assetEvents: [AssetEvent]) -> String {
  (transactions.map(\.serializedString) + assetEvents.map(\.serializedString)).joined(separator: "\n")
}
