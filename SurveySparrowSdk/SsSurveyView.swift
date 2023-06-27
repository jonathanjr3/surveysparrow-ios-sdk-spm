//
//  SsSurveyView.swift
//  SurveySparrowSdk
//
//  Created by Ajay Sivan on 05/06/20.
//  Copyright © 2020 SurveySparrow. All rights reserved.
//

import UIKit
import WebKit

@IBDesignable public class SsSurveyView: UIView, WKScriptMessageHandler, WKNavigationDelegate {
  // MARK: Properties
  private var ssWebView: WKWebView = WKWebView()
  private let surveyResponseHandler = WKUserContentController()
  private let loader: UIActivityIndicatorView = UIActivityIndicatorView()
  private var surveyLoaded: String = "surveyLoadStarted"
  private var surveyCompleted: String = "surveyCompleted"
  
  public var params: [String: String] = [:]
  public var surveyType: SurveySparrow.SurveyType = .CLASSIC
  public var getSurveyLoadedResponse: Bool = false
  
  @IBInspectable public var domain: String?
  @IBInspectable public var token: String?
  
  public var surveyDelegate: SsSurveyDelegate!
  
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
    let config = WKWebViewConfiguration()
    config.userContentController = surveyResponseHandler
    
    ssWebView = WKWebView(frame: bounds, configuration: config)
    surveyResponseHandler.add(self, name: "surveyResponse")
    
    ssWebView.backgroundColor = .gray
    ssWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(ssWebView)
    
    ssWebView.addSubview(loader)
    ssWebView.navigationDelegate = self
    loader.translatesAutoresizingMaskIntoConstraints = false
    loader.centerXAnchor.constraint(equalTo: ssWebView.centerXAnchor).isActive = true
    loader.centerYAnchor.constraint(equalTo: ssWebView.centerYAnchor).isActive = true
    loader.hidesWhenStopped = true
  }
  
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    loader.stopAnimating()
  }
  
  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    loader.stopAnimating()
  }
  
 public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if surveyDelegate != nil {
      let response = message.body as! [String: AnyObject]
      let responseType = response["type"] as! String
      if(responseType == surveyLoaded){
        surveyDelegate.handleSurveyLoaded(response: response)
      }
      if(responseType == surveyCompleted){
        surveyDelegate.handleSurveyResponse(response: response)
      }
    }
  }

  public func loadFullscreenSurvey(parent: UIViewController,delegate:SsSurveyDelegate, domain: String? = nil, token: String? = nil, params: [String: String]? = [:]) {
    let ssSurveyViewController = SsSurveyViewController()
    ssSurveyViewController.domain = domain
    ssSurveyViewController.token = token
    if(params != nil){
        ssSurveyViewController.params = params ?? [:]
    }
    ssSurveyViewController.getSurveyLoadedResponse = true
    if domain != nil && token != nil {
      ssSurveyViewController.surveyDelegate = delegate
      var isActive: Bool = false
      var reason: String = ""
      let group = DispatchGroup()
      group.enter()
      let completion: ([String: Any]) -> Void = { result in
          if let active = result["active"] as? Bool {
            isActive = active
        }
         if let reasonData = result["reason"] as? String {
            reason = reasonData
        }
      }
      validateSurvey(domain:domain,token:token,group: group,completion:completion);
      group.wait()
     if  isActive == true {
          parent.present(ssSurveyViewController, animated: true)
      } else {
          ssSurveyViewController.surveyDelegate.handleSurveyValidation(response: [
            "active": String(isActive),
            "reason": reason,
          ] as  [String: AnyObject])
      }
    }
  }
  
  // MARK: Public method
  public func loadSurvey(domain: String? = nil, token: String? = nil) {
    self.domain = domain != nil ? domain! : self.domain
    self.token = token != nil ? token! : self.token
    if self.domain != nil && self.token != nil {
      var isActive: Bool = false
      var reason: String = ""
      let group = DispatchGroup()
      group.enter()
      let completion: ([String: Any]) -> Void = { result in
          if let active = result["active"] as? Bool {
            isActive = active
        }
         if let reasonData = result["reason"] as? String {
            reason = reasonData
        }
      }
      validateSurvey(domain:domain,token:token,group: group,completion:completion);
      group.wait()
      if  isActive == true {
          loader.startAnimating()
          var urlComponent = URLComponents()
          urlComponent.scheme = "http"
          urlComponent.host = self.domain!.trimmingCharacters(in: CharacterSet.whitespaces)
          urlComponent.path = "/\(surveyType == .NPS ? "n" : "s")/ios/\(self.token!.trimmingCharacters(in: CharacterSet.whitespaces))"
          if(getSurveyLoadedResponse){
            params["isSurveyLoaded"] = "true"
          }
          urlComponent.queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
          }
          if let url = urlComponent.url {
            let request = URLRequest(url: url)
            ssWebView.load(request)
          }
      } else {
          self.handleSurveyValidation(response: [
            "active": String(isActive),
            "reason": reason,
          ] as  [String: AnyObject])
      }
    } else {
      print("Error: Domain or token is nil")
    }
  }

  func handleSurveyValidation(response: [String : AnyObject]) {
    print(response)
  }
}
