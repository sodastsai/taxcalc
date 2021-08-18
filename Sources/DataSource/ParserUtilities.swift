//

import CodableCSV
import DataFormat
import Foundation

// MARK: - Error

enum DecodingError: Error {
  case invalidContent
  case invalidDateString(String)
  case invalidDecimalString(String)
}

// MARK: - Decoder

extension KeyedDecodingContainer {
  func decode(_: Currency.Type, forKey key: Key, unit: Currency.Unit = .USD, at time: Date) throws -> Currency {
    let decimal = try decode(Decimal.self, forKey: key)
    return Currency(amount: decimal, unit: unit, time: time)
  }

  func decodeIfPresent(_: Currency.Type,
                       forKey key: Key, unit: Currency.Unit = .USD, at time: Date) throws -> Currency? {
    guard let decimal = try decodeIfPresent(Decimal.self, forKey: key) else {
      return nil
    }
    return Currency(amount: decimal, unit: unit, time: time)
  }

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
}

// MARK: - Date Formatters

extension DateFormatter {
  convenience init(dateFormat: String) {
    self.init()
    self.dateFormat = dateFormat
    timeZone = TimeZone(abbreviation: "UTC")
  }
}

extension Strategy.DateDecoding {
  private static var cachedDateFormatters = [String: DateFormatter]()

  private static func dateFormatter(using dateFormat: String) -> DateFormatter {
    if let cachedFormatter = cachedDateFormatters[dateFormat] {
      return cachedFormatter
    }
    let formatter = DateFormatter(dateFormat: dateFormat)
    cachedDateFormatters[dateFormat] = formatter
    return formatter
  }

  static func by(formats: String...) -> Self {
    .custom { decoder in
      let dateString = try String(from: decoder)
      for format in formats {
        if let date = dateFormatter(using: format).date(from: dateString) {
          return date
        }
      }
      throw DecodingError.invalidDateString(dateString)
    }
  }
}

// MARK: - Decimal

extension Strategy.DecimalDecoding {
  struct Option: OptionSet {
    let rawValue: Int
    static let emptyAsZero = Option(rawValue: 1 << 0)
    static let replaceDollarSign = Option(rawValue: 1 << 1)
  }

  static func with(options: Option) -> Self {
    .custom { decoder in
      var string = try String(from: decoder)
      if string.isEmpty, options.contains(.emptyAsZero) {
        return 0
      }
      if options.contains(.replaceDollarSign) {
        string = string.replacingOccurrences(of: "$", with: "")
      }
      guard let decimal = Decimal(string: string) else {
        throw DecodingError.invalidDecimalString(string)
      }
      return decimal
    }
  }
}

// MARK: - Misc

extension String {
  var rangeOfFullString: NSRange {
    NSRange(startIndex ..< endIndex, in: self)
  }

  func substring(matching result: NSTextCheckingResult) -> Substring? {
    guard let range = Range(result.range, in: self) else {
      return nil
    }
    return self[range]
  }
}
