//
//  Network.swift
//  AR
//
//  Created by Junjie Li on 12/15/21.
//

import Foundation
import MultipeerConnectivity
import RealityKit

extension CheckBoardARView: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: self.mcSession!, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            if self.role == .host{
                self.mcAdvertiser?.startAdvertisingPeer()
            }
            print("notconnected \(peerID.displayName)")
        case .connecting:
            print("connecting \(peerID.displayName)")
        case .connected:
            print("connected \(peerID.displayName)")
            if self.role == .host{
                self.mcAdvertiser?.stopAdvertisingPeer()
            }
//            self.mcAdvertiser?.stopAdvertisingPeer()
//            self.mcBrowser?.stopBrowsingForPeers()
        default:
            print("default")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.mcSession)
    }
    
    //tell nearby peers that your app is willing to join sessions of a specified type
    func startAdvertiser(){
        let advitiser = MCNearbyServiceAdvertiser(peer: self.devicePeerID, discoveryInfo: [:], serviceType: "ljj-ar")
        advitiser.delegate = self
        self.mcAdvertiser = advitiser
        
        advitiser.startAdvertisingPeer()
    }
    
    func startBrowser(){
        let browser = MCNearbyServiceBrowser(peer: self.devicePeerID, serviceType: "ljj-ar")
        browser.delegate = self
        self.mcBrowser = browser
        
        browser.startBrowsingForPeers()
    }
    
    func setupSyncService(){
        self.mcSession = MCSession(peer: self.devicePeerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession?.delegate = self
        
        if self.role == .host{
            startAdvertiser()
        }
        else{
            startBrowser()
        }
        self.scene.synchronizationService = try? MultipeerConnectivityService(session: self.mcSession!)
    }
}
