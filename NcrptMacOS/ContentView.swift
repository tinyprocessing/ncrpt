//
//  ContentView.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: NcrptMacOSDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(NcrptMacOSDocument()))
    }
}
