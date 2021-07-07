//
//  TeslaDemoAppViewModel.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 7/6/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import Foundation

final class TeslaDemoAppVehiclesViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    
    init() {
        async {
            do {
                vehicles = try await base.request(.vehicles)
            } catch {
                print("Have Error \(error.localizedDescription)")
                vehicles = []
            }
        }
    }
    
    private let base = TeslaBase.shared
}
