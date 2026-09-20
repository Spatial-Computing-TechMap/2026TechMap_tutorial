import SwiftUI

/// 모듈 하나를 소개하는 카드입니다. 왼쪽에 글, 오른쪽에 미리보기가 옵니다.
struct SolarCard: View {
    var module: Module

    var body: some View {
        // `depthAlignment`는 뷰가 아니라 `Layout` 프로토콜을 따르는 값에만
        // 걸 수 있어서 `HStackLayout`을 씁니다. 가로로 늘어놓되 앞뒤(깊이)
        // 기준은 가운데로 맞춥니다.
        HStackLayout(spacing: 60).depthAlignment(.center) {
            VStack(alignment: .leading, spacing: 20) {
                Text(module.heading)
                    .font(.system(size: 50, weight: .bold))

                Text(module.overview)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 400, alignment: .leading)

            // 두께가 있는 3D 미리보기입니다. 위의 `depthAlignment`가
            // 이 콘텐츠와 왼쪽 글의 앞뒤 기준을 맞춰 줍니다.
            module.detailView
                .frame(width: 400, height: 400)
        }
        .padding(60)
    }
}

extension Module {
    /// 모듈마다 오른쪽에 보여줄 미리보기입니다. 이 파일 안에서만 쓰므로
    /// `fileprivate`로 둡니다.
    @ViewBuilder
    fileprivate var detailView: some View {
        SolarSystemModule()
    }
}
