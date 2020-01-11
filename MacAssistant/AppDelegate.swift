//
//  AppDelegate.swift
//  MacAssistant
//
//  Created by Vansh Gandhi on 7/25/18.
//  Copyright © 2018 Vansh Gandhi. All rights reserved.
//

import Cocoa
import AudioKit
import SwiftGRPC
import Log
import AudioKit
import SwiftyUserDefaults
import Preferences
import Magnet

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, LoginSuccessDelegate {

    let Log = Logger()
    let assistant = Assistant()
    var audioEngine: AudioEngine!
    var streamCall: AssistCall!
    let authenticator = Authenticator.instance
    
    let sb = NSStoryboard(name: "Main", bundle: nil)
    let assitantWindowControllerID = "AssistantWindowControllerID"
    let loginWindowControllerID = "LoginWindowControllerID"
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    lazy var awc = sb.instantiateController(withIdentifier: assitantWindowControllerID) as! AssistantWindowController
    lazy var lwc = sb.instantiateController(withIdentifier: loginWindowControllerID) as! LoginWindowController
    
    lazy var preferencesWindowController = PreferencesWindowController(viewControllers: [
            GeneralPreferenceViewController(),
            AppearancePreferenceViewController(),
            AudioPreferenceViewController(),
            AccountPreferenceViewController()
    ])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = #imageLiteral(resourceName: "statusIcon")
        statusItem.action = #selector(toggleWindow)
        showAppropriateWindow()
        preferencesWindowController.showWindow()

        // register hotkey
        if let keyCombo = KeyCombo(doubledCocoaModifiers: .command) {
            let hotKey = HotKey(identifier: "CommandDoubleTap", keyCombo: keyCombo, target: self, action: #selector(doubleCommandHotKey))
           HotKeyCenter.shared.register(with: hotKey)

        }
    }

    @objc func doubleCommandHotKey() {
        // for some reason, this only works when appdidFinishlaunching, while prefernce window open. then when you close no longer calls
        Log.debug("double command key hit")
        showAppropriateWindow()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    @objc func toggleWindow() {
        if awc.window?.isVisible ?? false || lwc.window?.isVisible ?? false {
            hideAppropriateWindow()
        } else {
            showAppropriateWindow()
        }
    }
    
    func showAppropriateWindow() {
        if Defaults[.isLoggedIn] {
            showAssistant()
        } else {
            showLogin()
        }
    }
    
    func hideAppropriateWindow() {
        if awc.window?.isVisible ?? false {
            awc.close()
        }
        
        if lwc.window?.isVisible ?? false {
            lwc.close()
        }
    }
    
    func showAssistant() {
        awc.showWindow(nil)
    }
    
    func showLogin() {
        let lvc = lwc.contentViewController as! LoginViewController
        lvc.loginSuccessDelegate = self
        lwc.showWindow(nil)
    }
    
    func onLoginSuccess() {
        Log.debug("login success")
        showAppropriateWindow()
    }
    
    func logout() {
        self.Log.info("Logging out")
        authenticator.logout()
    }
}
