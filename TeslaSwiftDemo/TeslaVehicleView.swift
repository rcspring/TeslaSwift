//
//  TeslaVehicleView.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 7/7/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import SwiftUI

enum NavigationDestination: CaseIterable {
    case charge
    case vehicle
    case status
}

extension NavigationDestination {
    func label() -> some View {
        switch self {
        case .charge: return Text("Charge")
        case .vehicle: return Text("Vehicle")
        case .status: return Text("Status")
        }
    }
    
    func destination() -> some View {
        switch self {
        case .charge: return Text("Charge View")
        case .vehicle: return Text("Vehicle View")
        case .status: return Text("Status View")
        }
    }
}


struct TeslaVehicleView: View {
    let id: Int64
    
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    let buttons = ["Wake Up", "Charging", "Data"]
        
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 30) {
            ForEach(NavigationDestination.allCases, id: \.self) { item in
                NavigationLink(destination: item.destination()) {
                    item.label()
                }
            }
        }
    }
}

struct TeslaVehicleView_Previews: PreviewProvider {
    static var previews: some View {
        TeslaVehicleView(id: 1234)
    }
}
