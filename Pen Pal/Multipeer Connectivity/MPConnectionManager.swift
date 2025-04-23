////
////  MultipeerConnectionManager.swift
////  Pen Pal
////
////  Created by jacob brown on 1/1/25.
////
//
//import Foundation
//import MultipeerConnectivity
//
//extension String {
//    static var serviceName = "PenPal"
//}
//
//@Observable
//class MPConnectionManager: NSObject {
//    @ObservationIgnored private let serviceType = String.serviceName
//    @ObservationIgnored private let session: MCSession
//    @ObservationIgnored private let peerID: MCPeerID
//    @ObservationIgnored private let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
//    @ObservationIgnored private let nearbyServiceBrowser: MCNearbyServiceBrowser
//    
//    var availablePeers = [MCPeerID]()
//    var receivedInvite: Bool = false
//    var receivedInviteFrom: MCPeerID?
//    var invitationHandler: ((Bool, MCSession?) -> Void)?
//    var isPaired: Bool = false
//    
//    var isAvailableToPlay: Bool = false {
//        didSet {
//            if isAvailableToPlay {
//                startAdvertising()
//            } else {
//                stopAdvertising()
//            }
//        }
//    }
//    
//    init(yourName: String) {
//        peerID = MCPeerID(displayName: yourName)
//        session = MCSession(peer: peerID)
//        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
//        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
//        
//        super.init()
//        
//        nearbyServiceAdvertiser.delegate = self
//        nearbyServiceBrowser.delegate = self
//        session.delegate = self
//    }
//    
//    deinit {
//        stopAdvertising()
//        stopBrowsing()
//    }
//    
//    func startAdvertising() {
//        nearbyServiceAdvertiser.startAdvertisingPeer()
//    }
//    
//    func stopAdvertising() {
//        nearbyServiceAdvertiser.stopAdvertisingPeer()
//    }
//    
//    func startBrowsing() {
//        nearbyServiceBrowser.startBrowsingForPeers()
//    }
//    
//    func stopBrowsing() {
//        nearbyServiceBrowser.stopBrowsingForPeers()
//        availablePeers.removeAll()
//    }
//    
//    func send(document: Document) {
//        
//    }
//}
//
//extension MPConnectionManager: MCNearbyServiceAdvertiserDelegate {
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        self.receivedInvite = true
//        self.receivedInviteFrom = peerID
//        self.invitationHandler = invitationHandler
//    }
//}
//
//extension MPConnectionManager: MCNearbyServiceBrowserDelegate {
//    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
//        DispatchQueue.main.async {
//            if !self.availablePeers.contains(peerID) {
//                self.availablePeers.append(peerID)
//            }
//        }
//    }
//    
//    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        guard let index = availablePeers.firstIndex(of: peerID) else { return }
//        
//        DispatchQueue.main.async {
//            self.availablePeers.remove(at: index)
//        }
//    }
//}
//
//extension MPConnectionManager: MCSessionDelegate {
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        switch state {
//        case .notConnected:
//            DispatchQueue.main.async {
//                self.isPaired = false
//                self.isAvailableToPlay = true
//            }
//        case .connected:
//            DispatchQueue.main.async {
//                self.isPaired = true
//                self.isAvailableToPlay = true
//            }
//        default:
//            DispatchQueue.main.async {
//                self.isPaired = false
//                self.isAvailableToPlay = true
//            }
//        }
//    }
//    
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        //
//    }
//    
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        //
//    }
//    
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//        //
//    }
//    
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
//        //
//    }
//}
