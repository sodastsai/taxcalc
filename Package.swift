// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "taxcalc",
  platforms: [
    .macOS(.v12),
  ],
  products: [
    .executable(name: "taxcalc", targets: ["taxcalc"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sodastsai/hmrc-fx.git", from: "0.5.2"),
    .package(url: "https://github.com/dehesa/CodableCSV.git", from: "0.6.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
    .package(url: "https://github.com/sodastsai/cgtcalc.git", .branch("main")),
    .package(url: "https://github.com/sindresorhus/Regex.git", from: "0.1.1"),
    .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit.git", from: "0.1.0"),
  ],
  targets: [
    .executableTarget(name: "taxcalc",
                      dependencies: [
                        .target(name: "DataSource"),
                        .product(name: "ArgumentParser", package: "swift-argument-parser"),
                        .product(name: "CGTCalcCore", package: "cgtcalc"),
                        .product(name: "CollectionConcurrencyKit", package: "CollectionConcurrencyKit"),
                      ]),
    .target(name: "DataFormat",
            dependencies: [
              .product(name: "HMRCExchangeRate", package: "hmrc-fx"),
            ]),
    .testTarget(name: "DataFormatTests",
                dependencies: [
                  .target(name: "DataFormat"),
                ]),
    .target(name: "DataSource",
            dependencies: [
              .target(name: "DataFormat"),
              .product(name: "CodableCSV", package: "CodableCSV"),
              .product(name: "CGTCalcCore", package: "cgtcalc"),
              .product(name: "Regex", package: "Regex"),
            ]),
    .testTarget(name: "DataSourceTests",
                dependencies: [
                  .target(name: "DataFormat"),
                  .target(name: "DataSource"),
                ],
                resources: [
                  .process("Resources"),
                ]),
  ],
  swiftLanguageVersions: [.v5]
)
