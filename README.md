<div style="font-size:40px;text-align:center;">MultiAR</div>
<div style="font-size:32px;text-align:center;">指导教师：沈莹</div>
<div style="font-size:32px;text-align:center;">1850668 李俊杰</div>



[TOC]



## Introduction

#### Brief Introduction

MultiAR is an augmented reality board game on Apple devices (iPhone, iPad). The application uses both SwiftUI and UIKit frameworks to build a graphical interface, uses Apple's latest AR framework Reality Kit to build AR scenes, and uses MultipeerConnectivityService to provide Two-person senseless online service.

The application provides two options, one is man-machine battle, and the other is two-player online battle (users do not need any additional configuration). During the battle, the top of the app will provide real-time guidance, such as which side to play chess, who wins, etc. At the same time, real sound feedback is provided in the process of playing chess to further enhance the user's experience. Considering that the position of the chessboard may not be suitable for the user during the two-player online process, it also allows the user to adjust the chessboard using familiar gestures, such as rotating, zooming, moving, etc.

#### Structure

The code structure is shown below, and the role of each folder or file is explained in comments.

```sh
.
├── AR
│   ├── Assets.xcassets #Project resource folders, such as App icons and pictures used in the project.
│   │   ├── AccentColor.colorset
│   │   ├── AppIcon.appiconset
│   │   └── backg.imageset
│   ├── CheckBoard #AR scene construction (main logic) and online services.
│   ├── Experience.rcproject #Reality Composer, an AR model modeling application from which app can call and manipulate models through code.
│   │   ├── Library
│   │   │   └── ProjectLibrary
│   │   └── SceneThumbnails
│   │       ├── A19524D5-6183-4F6E-ADBF-6174B51587E3.thumbnails
│   │       ├── E0272227-6594-44C2-87D5-C83A0F26F634.thumbnails
│   │       └── F9610871-0955-494F-A5C3-51D1A281BAB3.thumbnails
│   ├── ModelEntity #The components and entities of the AR scene, the details will be introduced later
│   └── Preview Content #Live Preview provided by Xcode
│   │   └── Preview Assets.xcassets
│   ├── AppDelegate.swift #Application initialization
│   ├── Info.plist #App Service Configuration
│   ├── ContentView.swift #Application Home
└── AR.xcodeproj #Project startup file and project configuration
    ├── project.xcworkspace
    │   ├── xcshareddata
    │   │   └── swiftpm
    │   └── xcuserdata
    │       └── junjieli.xcuserdatad
    ├── xcshareddata
    │   └── xcschemes
    └── xcuserdata
        └── junjieli.xcuserdatad
            ├── xcdebugger
            └── xcschemes
```

#### Module

As shown in the figure below, RealityKit renders the model according to the entity component system shown in the figure below. The AR view contains an AR scene, and the AR scene contains multiple anchor entities (similar to the origin of the spatial coordinate system). Further, the anchor entities can contain various other entities. The entities and entities are organized in a tree structure. Different entities contain different components and thus have different characteristics. Therefore, the modules of the project are also divided according to this.

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj7wku71j20mg0gumxk.jpg" alt="Block diagram showing how entity hierarchies, composed of different kinds" style="zoom:50%;" />

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj7xeftrj213g0rs76d.jpg" alt="Diagram showing the components present in the base entity class, as well" style="zoom:50%;" />

The logical structure of the project is shown in the figure below. The AR scene includes a Pure Anchor, whose role is to avoid anchor drift when the entity changes ownership (in other words, the ownership of the entity always belongs to the host). Further, Pure Anchor includes Checkboard, which is composed of many Blocks. And each Block further contains a Piece.

![Modules](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj84t7t2j20h60cwmxd.jpg)

Different entities contain different components, giving them different characteristics. All entities inherit from the class Entity, so they all have Synchronization Component and Transform Component, which are used to provide online services and change the physical position of the entity, such as translation and rotation. Pure Anchor has Anchoring Component, which is used to determine the coordinate origin of AR Scene. Checkboard has a Collision Component that accepts finger touches and gestures. It also has a custom Checkboard Component for storing chessboard data. Piece and Block have Model Component and Collision Component for rendering physical shapes and detecting collisions (gestures, touches, etc.), respectively. Piece also has custom Piece Component for storing chess piece data. The graphical relationship of entities and components is shown below.

![MyECS](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8amfjrj20yi0clmz3.jpg)

Regarding network communication, as long as the component implements the Codable protocol, the component can be automatically transmitted on the network.

In summary, the project uses RealityKit to render AR View, and MultiPeerConnectivity provides communication services.

|                           AR View                            |                        Communication                         |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| <img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8evqmnj20wf0kxgmf.jpg" alt="img" style="zoom:50%;" /> | ![image-20220616235125706](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8hmf70j20iy0a0aa9.jpg) |

When communicating, entity ownership is involved. Ownership can be requested if the entity does not belong to the current user.

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8kjgghj20r20eowf6.jpg" alt="image-20220616235315786" style="zoom:50%;" />

Combining the above statements, the architecture of the project is shown in the following diagram.

![image-20220617000026628](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8oggydj21qu0u0n10.jpg)

![image-20220617000046344](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8rvk1rj21js0u042t.jpg)

![image-20220617000111384](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8tww7fj21m90u0q6e.jpg)

## Implemented Requirements

#### Application Homepage

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8v0c8zj20mk1cmwhn.jpg" alt="image-20220616154958163" style="zoom:50%;" />

On the homepage of the application, users can choose the human-machine battle option, or choose to create a game or join a game in a two-player online game.

```swift
if isStartGame{
            ARViewContainer(role: $role, isSelfPlay: $isSelfPlay, quitClosure: {
                self.isStartGame = false
            })
                .edgesIgnoringSafeArea(.all)
        }
        else{
            ZStack{
                Image("backg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                    
                VStack(alignment: .center, spacing: 20){
                    HStack{
                        Image(systemName: "checkerboard.rectangle")
                        Text("Welcome to Gobang")
                    }
                    .font(Font.largeTitle)
                    
                    Button(action: {
                        isStartGame = true
                        role = .host
                        isSelfPlay = true
                    })
                  ...
                }
            }
        }
```

#### Play Chess

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj8z5xmuj20mk1cmgp4.jpg" alt="image-20220616183024980" style="zoom:50%;" />

Playing chess as a basic operation involves many complex considerations. Whether it is single player or online, program must ensure that you can only play chess once when you come to your own side to play chess. Subsequent clicks are invalid, and you can start playing chess only after the opponent has played chess.

```swift
    @objc func tapAction(_ sender: UITapGestureRecognizer? = nil){
        if self.isQuitGame!{
            //quit
            self.quitClosure!()
            self.removeFromSuperview()
        }
        
        if self.isComplete!{
            self.isQuitGame = true
            return
        }
        
        self.textView!.text = self.whoTurn
        if !self.isCompleteCoaching{
            print("not complete coaching")
            return
        }
        
        if mutex < 1{
            print("mutex")
            return
        }
        mutex -= 1//==0
        //may addCheckBoard
        if self.role == .host && !self.isAddCheckBboard{
            guard let result = self.raycast(from: (sender?.location(in: self))!, allowing: .existingPlaneGeometry, alignment: .horizontal).first else{
                mutex += 1
                return
            }
            self.addCheckBoard(transform: result.worldTransform)
            self.isAddCheckBboard = true
            mutex += 1
            self.textView!.text = self.whoTurn
            return
        }

        //debug
        print("tapped")
        if !isTurn{
            print("It's not my turn")
            mutex += 1
            return
        }
        
        guard let touchPosition = sender?.location(in: self) else{
            mutex += 1
            return
        }
        //debug
//        print(self.scene.anchors)
        // tap piece !
        for touchEntity in self.entities(at: touchPosition){
            if let touchEntity = touchEntity as? Piece{
                if !isTurn{
                    print("It's not my turn")
                    mutex += 1
                    return
                }
                //debug
                print(touchEntity)
                //check is whether been placed
                if checkWhetherBeenPlaced(position: touchEntity.piece!.positionInMemory){
                    print("It has been placed!")
                    mutex += 1
                    return
                }
                //request ownership of checkboard as needed
                if (self.checkBoard?.isOwner)!{
                    print("checkboard ownership is self")
                    self.touchEntity(piece: touchEntity)
                }
                else{
                    self.checkBoard?.requestOwnership {result in
                        if result == .granted{
                            print("checkboard ownership authorized")
                            self.touchEntity(piece: touchEntity)
                        }
                        else{
                            print("checkboard ownership unauthorized")
                        }
                    }
                }
            }
        }
        mutex += 1
    }
```

#### Man-Machine Battle

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj93ipbtj20mk1cmq62.jpg" alt="image-20220616155342419" style="zoom:50%;" />

The machine adopts a strategy of playing chess randomly. At the start, the user has priority. Players place pieces by tapping on the board position on the phone screen.

```swift
//self Play
    if self.isSelfPlay!{
      //play in 2s
      Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: self.AIplayChess)
    }
```

#### User Guidance

| ![image-20220616162049228](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj98973oj206q02sjr8.jpg) | ![image-20220616162128474](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9azwt5j207k02ga9y.jpg) | ![image-20220616162144002](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9ed89lj204802e0sj.jpg) | ![image-20220616162157021](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9gjflaj203q02adfm.jpg) | ![image-20220616162212888](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9jr27vj206202aa9w.jpg) | ![image-20220616162228095](https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9lvqrfj209k0200sm.jpg) |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |

In the process of playing chess, there are corresponding guides at the top of the screen to inform the user of the current status, such as who to play chess, whether the AR scan is ready, who wins, click to exit, etc.

```swift
//update textView in certainInterval
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: self.updateUITextView)
		
    func updateUITextView(timer: Timer){
        self.textView!.text = self.whoTurn
    }
```

#### Sound Feedback

When the user places the pieces on the chessboard, there will be real sound feedback to provide the user with a real experience.

```swift
  guard let path = Bundle.main.path(forResource: "music", ofType: "mp3")
  else{
    print("no path")
    return
  }
  print(path)
  let url = URL(fileURLWithPath: path)
  let audioFile = try? AudioFileResource.load(contentsOf: url, withName: "", inputMode: .spatial, loadingStrategy: .preload, shouldLoop: false)
  touchEntity.playAudio(audioFile!)
```

#### Online Chess for Two

Both users can complete the connection as long as they are in a local area network. One party chooses to create the game and the other party chooses to join the game. Both parties can go online without any additional configuration, thanks to the cooperation of the entity component system and the MultipeerConnectivityService.

|                            iPhone                            |                             iPad                             |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| <img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9pqw81j20mk1cmdjn.jpg" alt="image-20220616164720825" style="zoom:50%;" /> | <img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9slpobj21420u0djw.jpg" alt="image-20220616164812001" style="zoom:50%;" /> |

```swift
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

		func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.mcSession)
    }

		func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: self.mcSession!, withContext: nil, timeout: 10)
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

		func touchEntity(piece: Piece){
        if piece.isOwner{
            print("piece owner is self")
            touchPiece(touchEntity: piece, player: self.player)
            changeTurn()
            self.textView!.text = self.whoTurn
            //self Play
            if self.isSelfPlay!{
                //play in 2s
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: self.AIplayChess)
            }
        }
        else{
            piece.requestOwnership(){result in
                if result == .granted{
                    print("piece authorized")
                    self.touchPiece(touchEntity: piece, player: self.player)
                    self.changeTurn()
                    self.textView!.text = self.whoTurn
                    //这里必然不是selfplay
                }
                else{
                    print("piece unauthorized, retry please")
                }
            }
        }
    }
```

#### Gesture Control

|                            Before                            |                            After                             |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| <img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aj9wlac9j20mk1cmdii.jpg" alt="image-20220616170248848" style="zoom:50%;" /> | <img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aja55nqlj20mk1cmadf.jpg" alt="image-20220616170307940" style="zoom:50%;" /> |

Whether it is online or stand-alone, it may happen that the position of the chessboard is not suitable. The app allows users to manipulate the board through gestures, such as pinch to zoom, rotate, and move the board.

```swift
		self.installGestures(.all, for: checkBoard!)
```

## Advantages & Disadvantages

#### Advantages

Use Apple's **latest AR framework RealityKit** to achieve AR rendering, and use **MultipeerConnectivity** to achieve online. The framework documentation is not perfect, such as the network communication part, which is explored by reading the source code. At the same time, there will be more and more official improvements and support for the framework, and later enhancements and improvements will be easier. For example, in WWDC2022 a few days ago, Object Capture technology was launched in the framework to help programmers quickly model complex AR model.

**The underlying communication mechanism is transparent to the upper layer**. The upper layer only needs to define the data structure of the transmission and business logic. For the upper layer, it only needs to switch the ownership to operate the entity and its data.

**Pluggable entity and component design**. You can use custom components to: (1) extend existing components (2) define data belonging to entities. Taking network transmission as an example, the data of entities, such as the chessboard matrix and the position of chess pieces, are transmitted through custom components, and these components comply with the protocol Codeable. Similarly, more features can be added to existing entities through custom components without changing existing code.

**Integrate UIKit and SwiftUI**, Apple's two UI frameworks based on the Swift language. Since SwiftUI is not perfect, UI components provided by the UIKit framework are often used, such as ARView in this project. In order for the two to communicate, the project uses the UIViewRepresentable protocol to encapsulate UIKit components. As a result, more components are available.

**Using functional programming**, when returning from the ARView to the home page, the switch is completed using the escape closure that the home page passed to it when the ARView was initialized. The closure refers to the variables of the homepage, so when returning to the home page, calling this closure can take advantage the MVVM mechanism of SwiftUI to return the interface.

**Computed attributes are used to optimize network transmission**. Although the CPU and GPU of IOS devices provide strong support for AR, the network bandwidth is still the bottleneck of the application. Therefore, using computed attributes as much as possible to reduce data transmission is beneficial for improving user experience. 

**Online matches require no additional configuration by the user**, and will detect users within the same local area network and connect automatically. At the same time, the entire application process is complete.

#### Disadvantages

Since the RealityKit framework is relatively new, its **coordination with the MultipeerConnectivity framework is not perfect**. Under the two-player option, the app sometimes crashes. This is improved when connecting to a device's hotspot.

**The modeling of the AR model is not very beautiful**. As mentioned in the project structure, the model provided by the model design tool Reality Composer does not meet the project requirements, and the personal design ability is not very good. Therefore, this project adopts the programming method to build models like Blcok, Piece, etc. Therefore, the aesthetics of the model is not very good.

**Application fault tolerance is not very good**. For example, when the AR scan loses context, it is difficult to restore the previous scene again. Sometimes there will be no AR Coach, which requires the user to manually exit the application and then enter, and the user experience is not good.

If multiple users are in the same LAN, **users cannot choose their opponents**.

## Improvement

For multiple devices in the same local area network, **all discovered devices should be displayed to the user in a pop-up window** so that the user can choose to match.

For situations like AR context disappearing and AR Coach not appearing, I need to know more about class ARSession. Detailed guidance on the Session lifecycle and **resuming sessions from interruptions** is provided in the [Apple documentation](https://sdeveloper.apple.com/documentation/arkit/managing_session_life_cycle_and_tracking_quality).

![Sequence diagram with normal tracking state before the session is interrupted, then, after the interruption, proceeding from notAvailable to limited (initializing) to limited (relocalizing) to normal.](https://tva1.sinaimg.cn/large/e6c9d24egy1h3ajabziyzj20u203kglw.jpg)

For the problem that the model is not beautiful: (1) The latest **[Object Capture](https://developer.apple.com/documentation/realitykit/capturing-photographs-for-realitykit-object-capture) technology** of WWDC2022 can be used to scan the real chessboard and chess pieces to obtain a more realistic model. (2) I can use modeling tools such as **Blender** to build a real model, and then convert it into **USDZ** format and import it into Reality Composer. Finally according to the [documentation](https://developer.apple.com/documentation/realitykit/manipulating-reality-composer-scenes-from-code), I can manipulate Reality Composer scenes from Code.

<img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h3aja9o1c5j20sx0o8770.jpg" alt="An illustration of a robot, showing the overlapping field of view for two cameras next to each other. The overlap is labeled “Ideal overlap: 70%”." style="zoom:50%;" />

At the same time, **more complete logic and interfaces can be added to the application**, such as score tables, various pieces, and various chessboards, and more board games can be introduced. At the same time, since robots currently play chess with random strategies, Apple's **[Core ML](https://developer.apple.com/documentation/coreml) technology** can also be used to improve chess strategies to provide users with experiences of different difficulty levels.