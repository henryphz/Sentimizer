//
//  SettingsView.swift
//  Sentimizer
//
//  Created by Samuel Ginsberg on 17.05.22.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(K.userNickname) private var userNickname = ""
    @State private var nicknameText = UserDefaults.standard.string(forKey: K.userNickname) ?? ""
    @State private var nicknameTextFieldEditing = false
    @FocusState private var nicknameTextFieldFocused: Bool
    
    @State private var colorScheme: K.AppColorScheme = Settings.getColorScheme()
    @AppStorage(K.appHasToBeUnlocked) private var appHasToBeUnlocked = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "person.fill")
                        .standardSentiSettingsIcon(foregroundColor: .white, backgroundColor: .brandColor2Light)
                    ZStack {
                        SentiTextField(placeholder: "Your nickname", text: $nicknameText, textFieldEditing: $nicknameTextFieldEditing, done: .constant(false), textFieldFocus: _nicknameTextFieldFocused)
                            .padding(.vertical, -10)
                            .onChange(of: nicknameTextFieldEditing) { _ in
                                userNickname = nicknameText
                            }
                        HStack {
                            Spacer()
                            
                            if !nicknameTextFieldFocused {
                                Button {
                                    withAnimation {
                                        nicknameTextFieldFocused = true
                                    }
                                } label: {
                                    Image(systemName: "pencil")
                                        .standardIcon()
                                        .frame(height: 20)
                                        .padding(13)
                                        .standardBackground()
                                        .padding(.trailing)
                                }
                            }
                        }
                    }
                    
                }
            }
            
            Section {
                NavigationLink {
                    ZStack {
                        Color.bgColor.ignoresSafeArea()
                        ActivityChooserView(activity: .constant(""), icon: .constant(""), redirectToEdit: true)
                            .padding(.top, -30)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.crop.rectangle.stack")
                            .standardSentiSettingsIcon(foregroundColor: .white, backgroundColor: .brandColor2)
                        Text("Edit Activity Categories")
                            .minimumScaleFactor(0.8)
                    }
                }
            }
            
            Section(header: Text("Color Scheme").foregroundColor(.gray)) {
                Button {
                    Settings.saveColorScheme(.light)
                    colorScheme = Settings.getColorScheme()
                } label: {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .standardSentiSettingsIcon(foregroundColor: .gray, backgroundColor: .brandColor4)
                        Text("Light")
                        Spacer()
                        if(colorScheme == .light) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                Button {
                    Settings.saveColorScheme(.dark)
                    colorScheme = Settings.getColorScheme()
                } label: {
                    HStack {
                        Image(systemName: "moon.stars")
                            .standardSentiSettingsIcon(foregroundColor: .gray, backgroundColor: .brandColor4)
                        Text("Dark")
                        Spacer()
                        if(colorScheme == .dark) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                Button {
                    Settings.saveColorScheme(.auto)
                    colorScheme = Settings.getColorScheme()
                } label: {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .standardSentiSettingsIcon(foregroundColor: .gray, backgroundColor: .brandColor4)
                        Text("Auto")
                        Spacer()
                        if(colorScheme == .auto) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section(header: Text("Use Face ID / Touch ID to restrict access").foregroundColor(.gray)) {
                Button {
                    appHasToBeUnlocked.toggle()
                    UserDefaults.standard.set(appHasToBeUnlocked, forKey: K.appHasToBeUnlocked)
                } label: {
                    HStack {
                        Image(systemName: "lock.fill")
                            .standardSentiSettingsIcon(foregroundColor: .white, backgroundColor: .brandColor1)
                        Text("Lock Sentimizer")
                        Spacer()
                        if(appHasToBeUnlocked) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "text.bubble")
                            .standardSentiSettingsIcon(foregroundColor: .white, backgroundColor: .brandColor2)
                        Text("App Language")
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .font(.senti(size: 20))
        .padding(.top, 5)
        .onAppear {
            UITableView.appearance().backgroundColor = .clear // tableview background
        }
        .foregroundColor(.textColor)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
