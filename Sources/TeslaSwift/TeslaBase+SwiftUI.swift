//
//  TeslaBase+SwiftUI.swift
//  TeslaBase+SwiftUI
//
//  Created by Ryan Spring on 7/22/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import Foundation
import SwiftUI

struct TeslaBaseKey: EnvironmentKey {
    static let defaultValue = TeslaBase.shared
}

extension EnvironmentValues {
    public var teslaBase: TeslaBase {
        get { self[TeslaBaseKey.self] }
        set { self[TeslaBaseKey.self] = newValue }
    }
}
