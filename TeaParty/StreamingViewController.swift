/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import OpenTok
import Foundation

final class StreamingViewController: UIViewController {
  private let apiKey = "47232544"
  private let sessionId = "2_MX40NzIzMjU0NH5-MTYyMTM1MDA1OTEyMn53b0dWM0w0ZVdJRlJzajN6b01UODJRUTh-fg"
  // swiftlint:disable:next line_length
  private let token = "T1==cGFydG5lcl9pZD00NzIzMjU0NCZzaWc9MzExY2UwMmM2YTJhMmU2OTQ2ZGU2Mzg0ZDhhM2YyNGI0MjFmNmUxYzpzZXNzaW9uX2lkPTJfTVg0ME56SXpNalUwTkg1LU1UWXlNVE0xTURBMU9URXlNbjUzYjBkV00wdzBaVmRKUmxKemFqTjZiMDFVT0RKUlVUaC1mZyZjcmVhdGVfdGltZT0xNjIxMzUyMTE4Jm5vbmNlPTAuNTQ2MzcwNzgzOTMwODE4MyZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjIzOTQ0MTE3JmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
  
  private var subscriberView: UIView?
  
  private var session: OTSession?
  
  @IBOutlet private var leaveButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    leaveButton.layer.cornerRadius = leaveButton.frame.size.height / 2
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    
    connectToSession()
  }

  @IBAction private func leave() {
    navigationController?.popViewController(animated: true)
  }
  
  private func connectToSession() {
    // 1
    session = OTSession(
      apiKey: apiKey,
      sessionId: sessionId,
      delegate: self
    )

    // 2
    var error: OTError?
    session?.connect(withToken: token, error: &error)

    // 3
    if let error = error {
      print("An error occurred connecting to the session", error)
    }
  }
  
  private func publishCamera() {
    // 1
    guard let publisher = OTPublisher(delegate: nil) else {
      return
    }

    // 2
    var error: OTError?
    session?.publish(publisher, error: &error)

    // 3
    if let error = error {
      print("An error occurred when trying to publish", error)
      return
    }

    // 4
    guard let publisherView = publisher.view else {
      return
    }

    // 5
    let screenBounds = UIScreen.main.bounds
    let viewWidth: CGFloat = 150
    let viewHeight: CGFloat = 267
    let margin: CGFloat = 20

    publisherView.frame = CGRect(
      x: screenBounds.width - viewWidth - margin,
      y: screenBounds.height - viewHeight - margin,
      width: viewWidth,
      height: viewHeight
    )
    view.addSubview(publisherView)
  }
  
  private func subscribe(to stream: OTStream) {
    // 1
    guard let subscriber = OTSubscriber(stream: stream, delegate: nil) else {
      return
    }

    // 2
    var error: OTError?
    session?.subscribe(subscriber, error: &error)

    // 3
    if let error = error {
      print("An error occurred when subscribing to the stream", error)
      return
    }

    // 4
    guard let subscriberView = subscriber.view else {
      return
    }

    // 5
    self.subscriberView = subscriberView
    subscriberView.frame = UIScreen.main.bounds
    view.insertSubview(subscriberView, at: 0)
  }
}

// MARK: - OTSessionDelegate
extension StreamingViewController: OTSessionDelegate {
  // 1
  func sessionDidConnect(_ session: OTSession) {
    print("The client connected to the session.")
    
    publishCamera()
  }

  // 2
  func sessionDidDisconnect(_ session: OTSession) {
    print("The client disconnected from the session.")
  }

  // 3
  func session(_ session: OTSession, didFailWithError error: OTError) {
    print("The client failed to connect to the session: \(error).")
  }

  // 4
  func session(_ session: OTSession, streamCreated stream: OTStream) {
    print("A stream was created in the session.")
    
    subscribe(to: stream)
  }

  // 5
  func session(_ session: OTSession, streamDestroyed stream: OTStream) {
    print("A stream was destroyed in the session.")
  }
}
