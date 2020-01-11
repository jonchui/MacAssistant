//
//  LoginViewController.swift
//  MacAssistant
//
//  Created by Vansh Gandhi on 8/2/18.
//  Copyright © 2018 Vansh Gandhi. All rights reserved.
//

import Cocoa
import WebKit
import Log
import SwiftyUserDefaults

class LoginViewController: NSViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    private let Log = Logger()
    private let authenticator = Authenticator.instance
    var loginSuccessDelegate: LoginSuccessDelegate?
    
    override func viewDidLoad() {
        webView.navigationDelegate = self
        loadLoginUrl()
    }


    fileprivate func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    fileprivate func getCodeFromUrl(url : String)  -> String? {
        return getQueryStringParameter(url: url, param: "code")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString {
            if url.hasPrefix("http://localhost") { // TODO: Un-hardcode this
                decisionHandler(.cancel)
                if let code = getCodeFromUrl(url: url) {
                    authenticator.authenticate(code: code) { err in
                        if let err = err {
                            self.Log.error("Error: \(err)")
                        } else {
                            self.loadNextScreen()
                        }
                    }
                return
                }
            }
        } else {
            Log.debug("invalid login url")
        }
        decisionHandler(.allow)
    }
    
    func loadLoginUrl() {
        if let url = URL(string: authenticator.loginUrl) {
            webView.load(URLRequest(url: url))
        } else {
            Log.debug("invalid loginUrl: \(authenticator.loginUrl)")
        }
    }
    
    func loadNextScreen() {
        view.window?.close()
        loginSuccessDelegate?.onLoginSuccess()
    }
}
