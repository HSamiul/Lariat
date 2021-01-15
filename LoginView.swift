//
//  LoginView.swift
//  LariatUI
//
//  Created by Samiul Hoque on 1/14/21.
//

import SwiftUI

//  NSTextField is a class
extension NSTextField {
    //  Use open to access variable in an imported module *classes*. It's equivalent to public, used everywhere else.
    //  I'm ovveriding the original definition of focusRingType
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
    

}

//  NSViewRepresentable is a protocol that this custom View I'm making conforms to
struct OpaqueWindow: NSViewRepresentable {
    //  Creates and returns an NSView object. Configure the object properties inside.
    //  makeNSView is blueprinted in NSViewRepresentable, which I'm implementing in my custom View!
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

//  View is a protocol. My struct (Login) must conform to the variables and methods defined in its protocol. E.g., body is a variable somewhere in View.
struct ContentView: View {
    var screen = NSScreen.main?.visibleFrame
    let lightGreyColor = Color(red: 255, green: 255, blue: 255, opacity: 0.05)

    @State private var login = ""
    //  some View is a specific structure that is compatible with the contents of the body. I don't know what that structure is, but the compiler will.
    
    //  Furthermore, below I'm declaring the type of the body, not setting it equal to anything. That type will be determined by what I've commented above.
    var body: some View {
        //  View protocol has an HStack blueprint which I'm implementing (defining) below.
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 250, height: 135)
            HStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.gray)
                
                SecureField("•••••••••••••••••••••••••", text: $login)
                    .frame(width: 150, height: nil)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(PlainTextFieldStyle()) // love you
                    .font(Font.system(size: 15, weight: .light, design: .default))
                
            }
            .frame(width: 300, height: 50)
            .background(lightGreyColor)
            .cornerRadius(5.0)
        }
        .frame(width: screen!.width / 3, height: screen!.height / 3)
        .offset(y:-25)
        .background(OpaqueWindow())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

