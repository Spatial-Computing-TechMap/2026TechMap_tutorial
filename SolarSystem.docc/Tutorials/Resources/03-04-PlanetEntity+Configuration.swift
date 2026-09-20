import SwiftUI

extension PlanetEntity {
    /// 행성 하나를 어떻게 그리고 어떻게 움직일지 담는 값입니다.
    struct Configuration {
        var id: PlanetID

        /// 모델을 찾지 못했을 때 대신 그릴 구의 색입니다.
        var placeholderColor: Color

        /// 태양에서 떨어진 거리입니다. 단위는 미터입니다.
        var orbitRadius: Float
        /// 궤도 위의 출발 각도입니다. 행성들이 한 줄로 늘어서지 않게 합니다.
        var initialOrbitAngle: Angle = .zero

        /// 행성의 반지름입니다.
        var visualRadius: Float = 0.2

        /// 자전축이 기울어진 정도입니다.
        var axialTilt: Angle = .zero
        /// 자전 속도입니다. 음수면 반대 방향으로 돕니다.
        var rotationSpeed: Float = 0
        /// 공전 속도입니다.
        var revolutionSpeed: Float = 0

        /// 태양계 전체의 중심입니다. 모든 행성이 같은 값을 씁니다.
        var sceneCenter: SIMD3<Float> = .zero
        /// 궤도면을 기울여 태양계를 위에서 내려다보는 각도로 보여 줍니다.
        var presentationTilt: simd_quatf = .init(angle: 0, axis: [0, 1, 0])
    }
}

extension PlanetEntity.Configuration {
    // 지구를 기준으로 다른 행성의 속도를 정합니다.
    // 바깥 행성은 실제 비율대로 하면 멈춘 것처럼 보여서, 차이를 줄여 두었습니다.
    private static let earthRotationSpeed: Float = 0.045
    private static let earthRevolutionSpeed: Float = 0.05

    // 궤도 간격은 이웃한 두 행성이 스쳐 지나가도 닿지 않도록 잡습니다.
    // (안쪽 행성의 반지름 + 여유 0.15 + 바깥 행성의 반지름)보다 넓게 둡니다.

    static var mercury: Self {
        .init(
            id: .mercury,
            placeholderColor: Color(red: 0.61, green: 0.61, blue: 0.58),
            orbitRadius: 1.2,
            initialOrbitAngle: .degrees(20),
            visualRadius: 0.15,
            axialTilt: .degrees(0.03),
            rotationSpeed: earthRotationSpeed * 0.017,
            revolutionSpeed: earthRevolutionSpeed * 1.65)
    }

    static var venus: Self {
        .init(
            id: .venus,
            placeholderColor: Color(red: 0.91, green: 0.80, blue: 0.64),
            orbitRadius: 1.75,
            initialOrbitAngle: .degrees(95),
            visualRadius: 0.22,
            axialTilt: .degrees(177.4),
            rotationSpeed: -earthRotationSpeed * 0.0041,
            revolutionSpeed: earthRevolutionSpeed * 1.19)
    }

    static var earth: Self {
        .init(
            id: .earth,
            placeholderColor: Color(red: 0.24, green: 0.46, blue: 0.72),
            orbitRadius: 2.65,
            initialOrbitAngle: .degrees(160),
            visualRadius: 0.35,
            axialTilt: .degrees(23.5),
            rotationSpeed: earthRotationSpeed,
            revolutionSpeed: earthRevolutionSpeed)
    }

    static var mars: Self {
        .init(
            id: .mars,
            placeholderColor: Color(red: 0.76, green: 0.35, blue: 0.24),
            orbitRadius: 3.5,
            initialOrbitAngle: .degrees(210),
            visualRadius: 0.17,
            axialTilt: .degrees(25.2),
            rotationSpeed: earthRotationSpeed * 0.972,
            revolutionSpeed: earthRevolutionSpeed * 0.80)
    }

    static var jupiter: Self {
        .init(
            id: .jupiter,
            placeholderColor: Color(red: 0.79, green: 0.64, blue: 0.42),
            orbitRadius: 4.25,
            initialOrbitAngle: .degrees(30),
            visualRadius: 0.42,
            axialTilt: .degrees(3.1),
            rotationSpeed: earthRotationSpeed * 2.41,
            revolutionSpeed: earthRevolutionSpeed * 0.42)
    }

    static var saturn: Self {
        .init(
            id: .saturn,
            placeholderColor: Color(red: 0.86, green: 0.78, blue: 0.57),
            orbitRadius: 5.75,
            initialOrbitAngle: .degrees(275),
            visualRadius: 0.38,
            axialTilt: .degrees(26.7),
            rotationSpeed: earthRotationSpeed * 2.24,
            revolutionSpeed: earthRevolutionSpeed * 0.31)
    }

    static var uranus: Self {
        .init(
            id: .uranus,
            placeholderColor: Color(red: 0.62, green: 0.84, blue: 0.87),
            orbitRadius: 7.1,
            initialOrbitAngle: .degrees(120),
            visualRadius: 0.27,
            axialTilt: .degrees(97.8),
            rotationSpeed: -earthRotationSpeed * 1.39,
            revolutionSpeed: earthRevolutionSpeed * 0.21)
    }

    static var neptune: Self {
        .init(
            id: .neptune,
            placeholderColor: Color(red: 0.24, green: 0.37, blue: 0.80),
            orbitRadius: 7.8,
            initialOrbitAngle: .degrees(340),
            visualRadius: 0.26,
            axialTilt: .degrees(28.3),
            rotationSpeed: earthRotationSpeed * 1.49,
            revolutionSpeed: earthRevolutionSpeed * 0.17)
    }
}
