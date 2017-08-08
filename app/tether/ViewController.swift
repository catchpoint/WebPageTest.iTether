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
  var vpn: NETunnelProviderManager?
 
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var button: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureVpnEntry()
  }
  
  @IBAction func buttonClicked(_ sender: Any) {
    self.status.text = "Connecting"
    self.button.setTitle("Connecting", for: UIControlState.normal)
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
            print("Error Loading Preferences")
            print (error!)
          } else {
            print("Loaded Preferences")
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
              print("Error Saving Preferences")
              print (error!)
            } else {
              print("Saved Preferences")
            }
          }
        }
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

