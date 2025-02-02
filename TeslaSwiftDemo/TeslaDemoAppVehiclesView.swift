//
//  TeslaDemoAppVehiclesView.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 7/6/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import SwiftUI

struct TeslaDemoAppVehiclesView: View {
    @StateObject var model = TeslaDemoAppVehiclesViewModel()
    
    var body: some View {
        List(model.vehicles) { vehicle in
            NavigationLink(vehicle.displayName ?? "none") {
                TeslaVehicleView(id: vehicle.idInt ?? -1)
            }
        }
        .navigationTitle("Vehicles")
    }
}

extension Vehicle: Identifiable {
    
}

//struct TeslaDemoAppVehiclesView_Previews: PreviewProvider {
//    static var previews: some View {
//        TeslaDemoAppVehiclesView()
//    }
//}
