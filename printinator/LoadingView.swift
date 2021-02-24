//
//  LoadingView.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/24/21.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false
 
    var body: some View {
        ProgressView()
            .padding(.top, 5)
            .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
            .frame(width: 50, height: 50, alignment: .center)
    }
}
