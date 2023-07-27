// swift-tools-version: 5.5

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hubtel Checkout",
    products: [
        .library(
            name: "Hubtel Checkout",
            targets: ["Hubtel Checkout"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Hubtel Checkout",
            dependencies: [],
            resources: [
                .process("Resources/NunitoSans-Regular.ttf"),
                .process("Resources/NunitoSans-ExtraBold.ttf")
               
            ]
        ),
        .testTarget(
            name: "Hubtel CheckoutTests",
            dependencies: ["Hubtel Checkout"]),
    ]
)
