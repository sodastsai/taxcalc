// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "taxcalc",
  platforms: [
    .macOS(.v11),
  ],
  products: [
    .executable(name: "taxcalc", targets: ["taxcalc"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sodastsai/hmrc-fx.git", from: "0.4.0"),
    .package(url: "https://github.com/dehesa/CodableCSV.git", from: "0.6.0"),
  ],
  targets: [
    .target(name: "taxcalc",
            dependencies: [
              .target(name: "DataFormat"),
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
