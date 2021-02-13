// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "cgtcalc",
  platforms: [
    .macOS(.v11),
  ],
  products: [
    .executable(name: "cgtcalc", targets: ["cgtcalc"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sodastsai/hmrc-fx.git", from: "0.4.0"),
    .package(url: "https://github.com/dehesa/CodableCSV.git", from: "0.6.0"),
  ],
  targets: [
    .target(name: "cgtcalc",
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
    .target(name: "FirstradeProvider",
            dependencies: [
              .target(name: "DataFormat"),
              .product(name: "CodableCSV", package: "CodableCSV"),
            ]),
    .testTarget(name: "FirstradeProviderTests",
                dependencies: [
                  .target(name: "FirstradeProvider"),
                  .target(name: "DataFormat"),
                ],
                resources: [
                  .process("Resources"),
                ]),
    .target(name: "SchwabProvider",
            dependencies: [
              .target(name: "DataFormat"),
              .product(name: "CodableCSV", package: "CodableCSV"),
            ]),
  ],
  swiftLanguageVersions: [.v5]
)
