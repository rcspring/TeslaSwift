//
//  TeslaDemoAppView.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 6/22/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import SwiftUI

struct TeslaDemoAppView: View {
    @State var showingThing = true
    @StateObject var model = TeslaBase.shared
    
    var body: some View {
        if model.isAuthenticated {
            TeslaDemoAppVehiclesView()
        } else {
            Text(model.isAuthenticated ? "Logged In" : "Logged Out")
                .sheet(isPresented: $showingThing, onDismiss: nil) {
                    model.authenticateWeb()
                }
        }
    }
}

struct TeslaDemoAppView_Previews: PreviewProvider {
    static var previews: some View {
        TeslaDemoAppView()
    }
}
