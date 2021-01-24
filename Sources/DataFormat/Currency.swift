import Foundation

public struct Currency {
  public let amount: Decimal
  public let unit: Unit
  public let time: Date

  public init(amount: Decimal, unit: Unit, time: Date? = nil) {
    self.amount = amount
    self.unit = unit
    self.time = time ?? Date()
  }
}

public extension Currency {
  enum Unit {
    case GBP
    case USD
  }
}

public extension Currency {
  init?(amount: String, unit: Unit, time: Date? = nil) {
    guard let decimalAmount = Decimal(string: amount) else {
      return nil
    }
    self = .init(amount: decimalAmount, unit: unit, time: time)
  }
}

extension Currency: CustomStringConvertible {
  public var description: String {
    unit.numberFormatter.string(for: amount) ?? ""
  }
}

private extension Currency.Unit {
  static let gbpNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = .init(identifier: "en_GB")
    return formatter
  }()

  static let usdNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = .init(identifier: "en_US")
    return formatter
  }()

  var numberFormatter: NumberFormatter {
    switch self {
    case .GBP:
      return Self.gbpNumberFormatter
    case .USD:
      return Self.usdNumberFormatter
    }
  }
}
