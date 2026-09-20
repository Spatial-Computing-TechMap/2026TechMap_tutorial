import ARKit
import QuartzCore

/// 지금 머리가 어디에 있고 어느 쪽을 보고 있는지 알려 줍니다.
@MainActor
final class HeadTracker {
    private var session = ARKitSession()
    private var worldTracking = WorldTrackingProvider()

    /// 추적을 시작합니다. 몰입 공간이 열릴 때 부르세요.
    /// ARKit 정보는 몰입 공간이 열려 있는 동안에만 받을 수 있습니다.
    func start() async {
        // 한 번 멈춘 것은 다시 쓸 수 없어서, 시작할 때마다 새로 만듭니다.
        session = ARKitSession()
        worldTracking = WorldTrackingProvider()

        guard WorldTrackingProvider.isSupported else { return }
        do {
            try await session.run([worldTracking])
        } catch {
            print("월드 트래킹을 시작하지 못했습니다: \(error)")
        }
    }

    func stop() {
        session.stop()
    }

    /// 지금 머리의 위치와 방향입니다. 아직 준비되지 않았으면 `nil`입니다.
    func headTransform() -> simd_float4x4? {
        guard worldTracking.state == .running,
              let anchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        else { return nil }

        return anchor.originFromAnchorTransform
    }
}
