import SwiftUI

/// 앱 전체가 공유하는 상태입니다.
@MainActor
@Observable
class AppModel {
    /// 몰입 공간을 여닫을 때 쓰는 이름입니다. 앱 안에서만 쓰는 값이라 아무 문자열이나 괜찮지만,
    /// 여는 쪽과 정의하는 쪽이 같아야 합니다.
    let immersiveSpaceID = "SolarSystem"

    /// 여는 중에 버튼을 또 누르는 일을 막기 위해 '전환 중' 상태를 따로 둡니다.
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed
}
