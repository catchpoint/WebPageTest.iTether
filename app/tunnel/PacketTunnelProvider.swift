//
//  PacketTunnelProvider.swift
//  tunnel
//
//  Created by Patrick Meenan on 8/7/17.
//  Copyright © 2017 WebPageTest LLC. All rights reserved.
//

import NetworkExtension
import Foundation

class PacketTunnelProvider: NEPacketTunnelProvider {
  
  enum ConnectError: Error {
    case socketError
  }

  // Completion handlers for NetworkExtension connection management
  var pendingStartCompletion: ((Error?) -> Void)?
  var pendingStopCompletion: (() -> Void)?
  
  // Socket server
  var listenSocket: Int32 = -1
  var connectedSocket: Int32 = -1
  let semaphore = DispatchSemaphore(value: 1)

  func log(_ message: String) {
    NSLog("iTether (tunnel): \(message)")
  }

  override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
    // Add code here to start the process of connecting the tunnel.
    self.log("startTunnel")
    var error: Error?
    pendingStartCompletion = completionHandler
    listenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    if listenSocket != -1 {
      var flag: Int32 = 1
      setsockopt(listenSocket, SOL_SOCKET, SO_REUSEADDR, &flag, socklen_t(MemoryLayout<Int32>.size))

      var addrIn = sockaddr_in(
        sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
        sin_family: sa_family_t(AF_INET),
        sin_port: in_port_t(CFSwapInt16HostToBig(9333)),
        sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")),
        sin_zero: (0,0,0,0,0,0,0,0)
      )
      var err = withUnsafePointer(to: &addrIn) { addrInPtr in
        addrInPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
          bind(listenSocket, addrPtr, socklen_t(MemoryLayout<sockaddr_in>.stride))
        }
      }
      if err >= 0 {
        err = listen(listenSocket, 4)
        if err >= 0 {
          let src = DispatchSource.makeReadSource(fileDescriptor: listenSocket)
          src.setEventHandler(handler: acceptClient)
          self.log("Waiting for client to connect")
          src.resume()
        } else {
          self.log("Error listening")
          error = ConnectError.socketError
          close(listenSocket)
        }
      } else {
        self.log("Error binding to port 9333")
        error = ConnectError.socketError
        close(listenSocket)
      }
    } else {
      self.log("Error creating socket")
      error = ConnectError.socketError
    }
    
    if error != nil {
      pendingStartCompletion = nil
      completionHandler(error)
    }
  }
  
  func acceptClient() {
    self.log("acceptClient")
    if pendingStartCompletion != nil {
      pendingStartCompletion!(nil)
      pendingStartCompletion = nil
    }
  }
  
  override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
    // Add code here to start the process of stopping the tunnel.
    self.log("stopTunnel")
    completionHandler()
  }
    
  override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
    // Add code here to handle the message.
    self.log("handleAppMessage")
    if let handler = completionHandler {
      handler(messageData)
    }
  }
    
  override func sleep(completionHandler: @escaping () -> Void) {
    // Add code here to get ready to sleep.
    self.log("sleep")
    completionHandler()
  }
    
  override func wake() {
    self.log("wake")
    // Add code here to wake up.
  }
}
