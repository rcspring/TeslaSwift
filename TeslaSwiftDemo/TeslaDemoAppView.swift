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
    @StateObject var model = TeslaModel.shared
    
    
    var body: some View {
        Text(model.token?.isValid ?? false ? "Logged In" : "Logged Out")
            .sheet(isPresented: $showingThing, onDismiss: nil) {
                model.authenticateWeb()
        }
    }
}

struct TeslaDemoAppView_Previews: PreviewProvider {
    static var previews: some View {
        TeslaDemoAppView()
    }
}
