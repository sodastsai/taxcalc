import CodableCSV
import DataFormat
import Foundation

public struct FirstradeRecord {
  public enum Action: String, Decodable {
    case buy = "BUY"
    case sell = "SELL"
    case dividend = "Dividend"
    case interest = "Interest"
    case other = "Other"
  }

  public enum RecordType: String, Decodable {
    case financial = "Financial"
    case trade = "Trade"
  }

  public let symbol: String?
  public let quantity: Decimal
  public let price: Currency
  public let action: Action
  public let description: String
  public let tradeDate: Date
  public let settledDate: Date
  public let interest: Currency
  public let amount: Currency
  public let commission: Currency
  public let fee: Currency
  public let cusip: String?
  public let recordType: RecordType

  init(symbol: String?,
       quantity: Decimal,
       price: Currency,
       action: Action,
       description: String,
       tradeDate: Date,
       settledDate: Date,
       interest: Currency,
       amount: Currency,
       commission: Currency,
       fee: Currency,
       cusip: String?,
       recordType: RecordType) {
    self.symbol = symbol
    self.quantity = quantity
    self.price = price
    self.action = action
    self.description = description
    self.tradeDate = tradeDate
    self.settledDate = settledDate
    self.interest = interest
    self.amount = amount
    self.commission = commission
    self.fee = fee
    self.cusip = cusip
    self.recordType = recordType
  }
}

extension FirstradeRecord: CustomStringConvertible, Equatable {}

extension FirstradeRecord: Decodable {
  public enum DecodingError: Error {
    case noneDecimalString(String)
  }

  private enum CodingKey: String, Swift.CodingKey {
    case symbol = "Symbol"
    case quantity = "Quantity"
    case price = "Price"
    case action = "Action"
    case description = "Description"
    case tradeDate = "TradeDate"
    case settledDate = "SettledDate"
    case interest = "Interest"
    case amount = "Amount"
    case commission = "Commission"
    case fee = "Fee"
    case cusip = "CUSIP"
    case recordType = "RecordType"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    symbol = try container.decode(String.self, forKey: .symbol, option: .emptyAsNil)
    quantity = try container.decode(Decimal.self, forKey: .quantity)
    action = try container.decode(Action.self, forKey: .action)
    description = try container.decode(String.self, forKey: .description)
    tradeDate = try container.decode(Date.self, forKey: .tradeDate)
    settledDate = try container.decode(Date.self, forKey: .settledDate)
    cusip = try container.decode(String.self, forKey: .cusip, option: .emptyAsNil)
    recordType = try container.decode(RecordType.self, forKey: .recordType)
    price = try container.decode(Currency.self, forKey: .price, at: tradeDate)
    interest = try container.decode(Currency.self, forKey: .interest, at: tradeDate)
    amount = try container.decode(Currency.self, forKey: .amount, at: tradeDate)
    commission = try container.decode(Currency.self, forKey: .commission, at: tradeDate)
    fee = try container.decode(Currency.self, forKey: .fee, at: tradeDate)
  }
}

public extension FirstradeRecord {
  static func from(contentsOf url: URL) throws -> [Self] {
    let decoder = CSVDecoder {
      $0.headerStrategy = .firstLine
      $0.dateStrategy = .formatted(makeDateFormatter())
      $0.decimalStrategy = .custom(parse(decimal:))
      $0.trimStrategy = .whitespaces
    }
    return try decoder.decode([Self].self, from: url)
  }
}

private func parse(decimal decoder: Decoder) throws -> Decimal {
  let string = try String(from: decoder)
  guard !string.isEmpty else {
    return 0
  }
  guard let decimal = Decimal(string: string) else {
    throw FirstradeRecord.DecodingError.noneDecimalString(string)
  }
  return decimal
}

private func makeDateFormatter() -> DateFormatter {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter
}

private extension KeyedDecodingContainer {
  enum StringDecodingOption {
    case `default`
    case emptyAsNil
  }

  func decode(_ type: String.Type, forKey key: Key, option: StringDecodingOption) throws -> String? {
    let string = try decode(type, forKey: key)
    switch option {
    case .default:
      return string
    case .emptyAsNil:
      return string.isEmpty ? nil : string
    }
  }

  func decode(_: Currency.Type, forKey key: Key, at tradeDate: Date) throws -> Currency {
    let decimal = try decode(Decimal.self, forKey: key)
    return Currency(amount: decimal, unit: .USD, time: tradeDate)
  }
}
