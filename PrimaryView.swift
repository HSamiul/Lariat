//
//  PrimaryView.swift
//  LariatUI
//
//  Created by Samiul Hoque on 1/15/21.
//

import SwiftUI

struct PrimaryView: View {
    let whiteGrey = Color(red: 255, green: 255, blue: 255, opacity: 0.2)
    let lightGrey = Color(red: 255, green: 255, blue: 255, opacity: 0.05)

    //  Don't know how this works. https://stackoverflow.com/questions/62577208/collapse-sidebar-in-swiftui-xcode-12
    func toggleSidebar() -> Void {
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    @State private var text = ""
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: Text("Listing View")) {
                    HStack {
                        Image(systemName: "rectangle.stack")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Listings")
                            .font(Font.system(size: 15, design: .default))
                    }
                }
                .padding(5)


                NavigationLink(destination: Text("Orders View")) {
                    HStack {
                        Image(systemName: "shippingbox")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Orders")
                            .font(Font.system(size: 15, design: .default))
                    }
                }
                .padding(5)


                NavigationLink(destination: Text("Text Editor View")) {
                    HStack {
                        Image(systemName: "terminal")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Editor")
                            .font(Font.system(size: 15, design: .default))
                    }
                }
                .padding(5)


                NavigationLink(destination: Text("Preferences View")) {
                    HStack {
                        Image(systemName: "paintbrush")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Preferences")
                            .font(Font.system(size: 15, design: .default))
                    }
                }
                .padding(5)
            }
            .frame(minWidth: 250, idealWidth: 250, maxWidth: .infinity)
            
            Text("Content")
        }
        .toolbar(content: {
            
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
            
            ToolbarItemGroup() {
                Button(action: {
                    print("Compose")
                }) { Image(systemName: "square.and.pencil") }
                
                Button(action: {
                    print("envelope")
                }) { Image(systemName: "envelope") }
                
                Button(action: {
                    print("chart.bar.xaxis")
                }) { Image(systemName: "chart.bar.xaxis") }
                
                Button(action: {
                    print("dollarsign.circle")
                }) { Image(systemName: "dollarsign.circle") }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 10)
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .frame(width: 150, height: 30)
                .background(lightGrey)
                .cornerRadius(5.0)
            }
        })

    }
}

struct PrimaryView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryView()
    }
}
