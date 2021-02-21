import ArgumentParser
import Foundation

extension URL: ExpressibleByArgument {
  public init?(argument: String) {
    self = URL(fileURLWithPath: argument)
  }
}
