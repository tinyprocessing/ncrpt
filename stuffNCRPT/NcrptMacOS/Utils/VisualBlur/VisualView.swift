//
//  VisualView.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode
    private let isEmphasized: Bool
    
    init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        emphasized: Bool) {
        self.material = material
        self.blendingMode = blendingMode
        self.isEmphasized = emphasized
    }
    
    func makeNSView(context: Context) -> NonVibrancyBackground {
        let view = NonVibrancyBackground()
        
        // Not certain how necessary this is
        view.autoresizingMask = [.width, .height]
        
        return view
    }
    

    func updateNSView(_ nsView: NonVibrancyBackground, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = isEmphasized
        nsView.state = .active
        
    }
}

class NonVibrancyBackground: NSVisualEffectView {
    override var allowsVibrancy: Bool {
        return false
    }
}

func configureIcon(_ name: String, size: CGFloat, isSF: Bool = false, color: Color = .secondary) -> AnyView {
    AnyView(
        VStack{
            if isSF {
                Image(systemName: name)
                    .font(.system(size: size))
                    .foregroundColor(color)
            }else{
                Image(nsImage: NSImage(named: name)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size, alignment: .center)
            }
        }
    )
}
