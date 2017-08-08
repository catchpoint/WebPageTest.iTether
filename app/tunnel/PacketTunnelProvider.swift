//
//  PacketTunnelProvider.swift
//  tunnel
//
//  Created by Patrick Meenan on 8/7/17.
//  Copyright © 2017 WebPageTest LLC. All rights reserved.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
  override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
    // Add code here to start the process of connecting the tunnel.
    print("startTunnel")
    completionHandler(nil)
  }
    
  override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
    // Add code here to start the process of stopping the tunnel.
    print("stopTunnel")
    completionHandler()
  }
    
  override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
    // Add code here to handle the message.
    print("handleAppMessage")
    if let handler = completionHandler {
      handler(messageData)
    }
  }
    
  override func sleep(completionHandler: @escaping () -> Void) {
    // Add code here to get ready to sleep.
    print("sleep")
    completionHandler()
  }
    
  override func wake() {
    print("wake")
    // Add code here to wake up.
  }
}
