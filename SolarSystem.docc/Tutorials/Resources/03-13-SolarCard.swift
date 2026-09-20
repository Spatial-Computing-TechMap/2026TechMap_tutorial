/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A detail view that presents information about different module types.
*/

// Mixed Immersive에서 보이는 카드
import SwiftUI

/// A detail view that presents information about different module types.
struct SolarCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openWindow) private var openWindow
    var module: Module

    var body: some View {
        @Bindable var model = model

        GeometryReader { proxy in
            let textWidth = min(max(proxy.size.width * 0.4, 300), 500)
            let imageWidth = min(max(proxy.size.width - textWidth, 300), 700)
            ZStack {
                // 텍스트와 module.detailView 둘 다 깊이(depth)가 없는 평면
                // 콘텐츠라, depthAlignment(.center)를 줘도 정렬할 깊이 차이 자체가
                // 없어서 겉모습/동작은 그대로다. HStack 대신 HStackLayout을 써야
                // depthAlignment를 걸 수 있다.
                HStackLayout(spacing: 60).depthAlignment(.center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(module.heading)
                            .font(.system(size: 50, weight: .bold))
                            .padding(.bottom, 15)
                            .accessibilitySortPriority(4)

                        Text(module.overview)
                            .padding(.bottom, 24)
                            .accessibilitySortPriority(3)
                        
                        ToggleImmersiveSpaceButton()
                    }
                    .frame(width: textWidth, alignment: .leading)

                    module.detailView
                        .frame(width: imageWidth, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding([.leading, .trailing], 70)
        .padding(.bottom, 24)
        .background {
            if module == .solar {
                Image("SolarBackground")
                    .resizable()
                    .scaledToFill()
                    .accessibility(hidden: true)
            }
        }

        // A settings button in an ornament,
        // visible only when `showDebugSettings` is true.
//        .settingsButton(module: module)
   }
}

extension Module {
    @ViewBuilder
    fileprivate var detailView: some View {
        SolarSystemModule()
    }
}

#Preview("Solar System") {
    NavigationStack {
        SolarCard(module: .solar)
            .environment(AppModel())
    }
}
