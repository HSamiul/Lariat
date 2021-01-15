//
//  ContentView.swift
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
    
    //open override func removeCursorRect(_ rect: NSRect, cursor object: NSCursor) {
        
    //}
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
    @State private var text = ""

    //  some View is a specific structure that is compatible with the contents of the body. I don't know what that structure is, but the compiler will.
    
    //  Furthermore, below I'm declaring the type of the body, not setting it equal to anything. That type will be determined by what I've commented above.
    var body: some View {
        //  View protocol has an HStack blueprint which I'm implementing (defining) below.
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 256, height: 135)
            
            HStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.gray)
                
                SecureField("Enter your key", text: $text)
                    .frame(width: 150, height: nil)
                    .controlSize(.large)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(Font.system(size: 15, weight: .light, design: .default))
                    .multilineTextAlignment(TextAlignment.center)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: screen!.width / 3, height: screen!.height / 3)
        .background(OpaqueWindow())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


