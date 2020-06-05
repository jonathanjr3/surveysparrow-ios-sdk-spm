//
//  SsSurveyView.swift
//  SurveySparrowSdk
//
//  Created by Ajay Sivan on 05/06/20.
//  Copyright © 2020 SurveySparrow. All rights reserved.
//

import UIKit
import WebKit
import os.log

@IBDesignable class SsSurveyView: UIView, WKScriptMessageHandler {
  // MARK: Properties
  private var ssWebView: WKWebView?
  private let surveyResponseHandler = WKUserContentController()
  
  var params: [String: String] = [:]
  
  @IBInspectable var domain: String?
  @IBInspectable var token: String?
  
  var surveyDelegate: SsSurveyDelegate!
  
  // MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    addFeedbackView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    addFeedbackView()
  }
  
  // MARK: Private methods
  private func addFeedbackView() {
    backgroundColor = backgroundColor != nil ? backgroundColor : .gray;
    
    let config = WKWebViewConfiguration()
    config.userContentController = surveyResponseHandler
    
    ssWebView = WKWebView(frame: bounds, configuration: config)
    surveyResponseHandler.add(self, name: "surveyResponse")
    
    ssWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(ssWebView!)
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if surveyDelegate != nil {
      let response = message.body as! [String: Any]
      surveyDelegate.handleSurveyResponse(response: response)
    }
  }
  
  // MARK: Public method
  func loadSurvey(domain: String? = nil, token: String? = nil) {
    self.domain = domain != nil ? domain! : self.domain
    self.token = token != nil ? token! : self.token
    if self.domain != nil && self.token != nil {
      var urlComponent = URLComponents()
      urlComponent.scheme = "http"
      urlComponent.host = self.domain!.trimmingCharacters(in: CharacterSet.whitespaces)
      urlComponent.path = "/s/ios/\(self.token!.trimmingCharacters(in: CharacterSet.whitespaces))"
      urlComponent.queryItems = params.map {
        URLQueryItem(name: $0.key, value: $0.value)
      }
      
      if let url = urlComponent.url {
        let request = URLRequest(url: url)
        ssWebView?.load(request)
      }
    } else {
      os_log("Domain or token is nil", type: .debug)
    }
  }
}
