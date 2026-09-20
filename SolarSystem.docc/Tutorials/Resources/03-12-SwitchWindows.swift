//
//  SwitchWindows.swift
//  SolarSystem
//
//  Created by Saerom on 8/14/26.
//

import SwiftUI

struct SwitchWindows: View {
    @Environment(AppModel.self) private var model
    
    var body: some View {
        // SolarSystemControls와 SolarCard는 완전히 같은 자리에서 opacity로만
        // 크로스페이드되는, 정확히 SpatialContainer가 의도하는 "같은 3D 공간에
        // 여러 뷰를 겹쳐두는" 상황이라 ZStack 대신 사용했다. alignment: .center는
        // ZStack의 기본 정렬과 동일해서 동작/외형은 그대로 유지된다.
        SpatialContainer(alignment: .center) {
            SolarSystemControls() /// full
                .opacity(model.isShowingSolar ? 1 : 0)

            SolarCard(module: .solar) /// mixed
                // @Main에서 windowStyle(.plain)을 적용하지 않으면 시스템 glass 배경이 적용됨
                // 시스템 glass 배경은 opacity 적용 대상이 아니라 안없어졌던 것임
                .glassBackgroundEffect()
                .opacity(model.isShowingSolar ? 0 : 1)
        }
        .animation(.default, value: model.isShowingSolar)
    }
}

#Preview {
    SwitchWindows()
}
