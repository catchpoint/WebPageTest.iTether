//
//  ViewController.swift
//  tether
//
//  Created by Patrick Meenan on 8/7/17.
//  Copyright © 2017 WebPageTest LLC. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {
  var vpn:NETunnelProviderManager?
  var currentStatus = ""
  var notificationObserver:NSObjectProtocol?
 
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var button: UIButton!
  
  func log(_ message: String) {
    NSLog("iTether: \(message)")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureVpnEntry()
    notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil, queue: nil) {
      notification in
      self.log("received NEVPNStatusDidChangeNotification")
      self.updateStatus()
    }
  }
  
  @IBAction func buttonClicked(_ sender: Any) {
    updateStatus()
    if currentStatus == "Connected" {
      disconnect()
    } else if currentStatus == "Disconnected" {
      connect()
    } else {
      cancel()
    }
    updateStatus()
  }
  
  func connect() {
    if vpn != nil {
      do {
        self.log("Connecting")
        try vpn!.connection.startVPNTunnel()
      } catch _ {
      }
    }
  }
  
  func disconnect() {
    if vpn != nil {
      self.log("Disconnecting")
      vpn!.connection.stopVPNTunnel()
    }
  }
  
  func cancel() {
    disconnect()
  }
  
  func configureVpnEntry() {
    NETunnelProviderManager.loadAllFromPreferences() { loadedManagers, error in
      if let vpnEntries = loadedManagers {
        for entry in vpnEntries {
          if self.vpn == nil {
            self.vpn = entry
          } else {
            entry.removeFromPreferences() { error in }
          }
        }
      }
      if self.vpn == nil {
        self.vpn = NETunnelProviderManager()
      }
      if self.vpn != nil {
        self.vpn!.loadFromPreferences() { error in
          if error != nil {
            self.log ("Error Loading Preferences: \(error!.localizedDescription)")
          } else {
            self.log("Loaded Preferences")
          }
          self.vpn!.localizedDescription = "Reverse Tether"
          let provider = NETunnelProviderProtocol()
          provider.serverAddress = "USB"
          provider.disconnectOnSleep = true
          provider.providerBundleIdentifier = "org.webpagetest.tether.tunnel"
          self.vpn!.protocolConfiguration = provider
          self.vpn!.isEnabled = true
          self.vpn!.isOnDemandEnabled = true
          self.vpn!.saveToPreferences() { error in
            if error != nil {
              self.log("Error Saving Preferences")
              print (error!)
            } else {
              self.log("Saved Preferences")
            }
            self.updateStatus()
          }
        }
      }
    }
  }
  
  func updateStatus() {
    var statusText = "Unknown"
    if vpn != nil {
      switch vpn!.connection.status {
      case NEVPNStatus.connected: statusText = "Connected"
      case NEVPNStatus.connecting: statusText = "Connecting"
      case NEVPNStatus.disconnected: statusText = "Disconnected"
      case NEVPNStatus.disconnecting: statusText = "Disconnecting"
      default: statusText = "Unknown"
      }
    }
    
    if (currentStatus != statusText) {
      currentStatus = statusText
      status.text = statusText
      self.log("VPN status changed to \(statusText)")
      if statusText == "Connected" {
        button.setTitle("Disconnect", for: UIControlState.normal)
      } else if statusText == "Disconnected" {
        button.setTitle("Connect", for: UIControlState.normal)
      } else {
        button.setTitle("Cancel", for: UIControlState.normal)
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

