import SwiftUI

/// 앱 전체가 공유하는 상태입니다.
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "SolarSystem"

    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed

    // MARK: - 태양

    /// 태양이 놓이는 자리입니다. 나중에 모든 행성이 이 점을 중심으로 돕니다.
    /// 값은 미터 단위이고, z가 음수면 사람의 앞쪽입니다.
    let solarSunPosition: SIMD3<Float> = [0, 1.0, -9]

    /// 태양 모델을 몇 배로 키울지 정합니다.
    let solarSunScale: Float = 2.0
}
