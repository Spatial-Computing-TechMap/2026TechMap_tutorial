// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "WorldAssets",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        // The library product the SolarSystem app target links against.
        // Its name is what `import WorldAssets` resolves to.
        .library(
            name: "WorldAssets",
            targets: ["WorldAssets"])
    ],
    targets: [
        .target(
            name: "WorldAssets"
        )
    ]
)
