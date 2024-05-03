//
//  ViewController.swift
//  SportsTechnology
//
//  Created by Rachel Ratnam on 3/11/24.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var tapGestureRecognizer: UITapGestureRecognizer?
    var FIELD_WIDTH: CGFloat? // meters
    var FIELD_HEIGHT: CGFloat? //meters
    var selectedFixtures: LeagueInfo?
    var chosenTeams: [Lineup]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIELD_WIDTH = 0.6
        FIELD_HEIGHT = 1.0
        
        // Set up the view
        sceneView.frame = self.view.frame
        sceneView.delegate = self
        self.view.addSubview(sceneView)
        
        // Set up a tap gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wakeUp))
        sceneView.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc func wakeUp(sender: UITapGestureRecognizer) {
        // Check if the canvas has already been set up to avoid doing it multiple times
        if sender.state == .ended {
            setupField() 
            // Remove the tap gesture recognizer after the canvas is added
            sceneView.removeGestureRecognizer(tapGestureRecognizer!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical] // Enable both horizontal and vertical plane detection
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func getTransform(currentFrame: ARFrame) -> simd_float4x4 {
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0 // Canvas will be half a meter in front of the camera
        return simd_mul(currentFrame.camera.transform, translation)
    }
    
    func setupCanvas(transform: simd_float4x4) -> SCNNode {
        // Add a blank canvas (simple white plane)
        let plane = SCNPlane(width: FIELD_WIDTH ?? 0.6, height: FIELD_HEIGHT ?? 1.0) // Adjust dimensions as needed
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        let canvasNode = SCNNode(geometry: plane)
        canvasNode.simdTransform = transform // Adjust position of node based on camera transform
        canvasNode.name = "canvasNode"
        return canvasNode
    }
    
    func createButton() -> UIButton {
        // Create a button
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 50) // Adjust button size and position
        button.backgroundColor = UIColor.blue // Making the button blue for visibility
        button.setTitleColor(UIColor.white, for: .normal) // Set the title color to white
        button.setTitle("Next Page", for: .normal)
        button.addTarget(self, action: #selector(showFixtures), for: .touchUpInside)
        //button.addTarget(self, action: #selector(showTeamLineups), for: .touchUpInside)
        return button
    }
    
    func attachButton(transform: simd_float4x4) -> SCNNode {
        // Attach button to scene
        let button = createButton()
        let buttonNode = SCNNode() // Adjust button size
        buttonNode.geometry = SCNPlane(width: 0.1, height: 0.05)
        buttonNode.geometry?.firstMaterial?.diffuse.contents = button
        buttonNode.position = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        buttonNode.position.z += 0.06 // Make sure the button is positioned in front of the canvas
        buttonNode.name = "buttonNode"
        return buttonNode
    }
    
    func setupField() {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let transform = getTransform(currentFrame: currentFrame)
        
        // Create a new node for the canvas
        let scene = SCNScene()
        
        // Create a button and attach to scene
        let button = attachButton(transform: transform)
        
        
        scene.rootNode.addChildNode(button)
        
        
        scene.rootNode.addChildNode(setupCanvas(transform: transform))
        
        // Add the canvas node to the scene's root node
        sceneView.scene = scene
    }
    
    @objc func showTeamLineups() {
        // display new canvas vertically
        // Define the horizontal plane geometry

        let plane = SCNPlane(width: 0.1, height: 0.1) // Adjust size as needed
        plane.firstMaterial?.diffuse.contents = UIColor.red

        // Create a node for the plane

        let planeNode = SCNNode(geometry: plane)
        //planeNode.rotation = SCNVector4Make(0, 0, 1, .pi/2)

        
        //plane.firstMaterial?.diffuse.contents = UIImage(named: "gridTexture")  // Assuming you have a grid texture image


        // Place the node in the scene at a specific location
        if let currentFrame = sceneView.session.currentFrame {
            // Place the node 0.5 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5 // Adjust distance as needed
            let transform = simd_mul(currentFrame.camera.transform, translation)
            planeNode.simdTransform = transform
            
            // Add the node to the scene
            sceneView.scene.rootNode.addChildNode(planeNode)
        }
    }
    
    @objc func showFixtures() {
        // Implement navigation to the next page
        print("Navigating to next page...")
        // Remove the button from the canvas node
        if let buttonNode = sceneView.scene.rootNode.childNode(withName: "buttonNode", recursively: true) {
            buttonNode.removeFromParentNode()
        }
        Task {
            print("Beginning Task...")
            do {
                print("Fetching data...")
                let data = try await NetworkService.fetchAllGamesByDate(from: "2024-04-13", to: "2024-04-13")
                //addFixtureNodes(data: data)
                print("Received data from server: \(String(describing: data.fixtures[0].teams["home"]?.name))")
                DispatchQueue.main.async {
                    print("creating images for AR...")
                    self.renderImageAR(fixtures: data.fixtures)
                    print("Created images!")
                }
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }
    
    @objc func showLineups(fixtureId: Int) {
        Task {
            print("Beginning Task...")
            do {
                print("Fetching data...")
                let data = try await NetworkService.fetchTeamLineups(fixtureId: fixtureId) as? [Lineup]
                print("Received data from server: \(String(describing: data))")
                DispatchQueue.main.async {
                    self.displayLineups(lineupInfo: (data as [Lineup]?)!)
                }
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }
    
    @objc func showPlayerStats(fixtureId: Int, playerId: Int) {
        Task {
            print("Beginning Task...")
            do {
                print("Fetching data...")
                let data = try await NetworkService.fetchPlayerStats(fixtureId: fixtureId, playerId: playerId)
                //addFixtureNodes(data: data)
                print("Received data from server: \(String(describing: data))")
                DispatchQueue.main.async {
                    //self.createImageForAR(fixtures: data.fixtures)
                    self.displayPlayerStats(data: data)
                }
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }
    
    func displayFixtures(fixtures: [Fixture]) {
        let fixtureView = GamesInfo(fixtures: fixtures) { fixtureId in
            self.showLineups(fixtureId: fixtureId)
        }
        .padding()

        // Create a UIHostingController with the SwiftUI view
        let hostingController = UIHostingController(rootView: fixtureView)
        
        // Present or add the hosting controller's view to your interface
        present(hostingController, animated: true)
    }
    
    func displayLineups(lineupInfo: [Lineup]) {
        print("Removing other nodes...")
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
        }
        
        print("Display the lineup...")
        
        let node = SCNNode()

        let plane = SCNPlane(width: 200,
                             height: 200)
        
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position.z -= 200
        createHostingControllerForLineups(for: planeNode, lineupInfo: lineupInfo)
        
        node.addChildNode(planeNode)
        sceneView.scene.rootNode.addChildNode(node)
        //self.showPlayerStats(fixtureId: 592872, playerId: 617)
    }
    
    func createHostingControllerForLineups(for node: SCNNode, lineupInfo: [Lineup]) {
            // create a hosting controller with SwiftUI view
            let arVC = UIHostingController(rootView: MatchView(homeLineup: lineupInfo[0], awayLineup: lineupInfo[1]))
            
            // Do this on the main thread
            DispatchQueue.main.async {
                arVC.willMove(toParent: self)
                // make the hosting VC a child to the main view controller
                self.addChild(arVC)
                arVC.view.frame = CGRect(x: 0, y: 0, width: 800, height: 400) // Landscape dimensions

                // set the pixel size of the Card View
                //arVC.view.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
                
                // add the ar card view as a subview to the main view
                self.view.addSubview(arVC.view)
                
                // render the view on the plane geometry as a material
                self.showLineupsAR(hostingVC: arVC, on: node)
            }
    }
    func showLineupsAR(hostingVC: UIHostingController<MatchView>, on node: SCNNode) {
        // create a new material
        let material = SCNMaterial()
        
        // this allows the card to render transparent parts the right way
        hostingVC.view.isOpaque = false
        
        // set the diffuse of the material to the view of the Hosting View Controller
        material.diffuse.contents = hostingVC.view
        
        // Set the material to the geometry of the node (plane geometry)
        node.geometry?.materials = [material]
        
        hostingVC.view.backgroundColor = UIColor.clear
    }
    
    func displayPlayerStats(data: Any) {
        print("Display player stats")
    }
    
    func renderImageAR(fixtures: [Fixture]) {
            let node = SCNNode()
            
            // Cast the found anchor as image anchor
            
            // get the name of the image from the anchor
    
            let plane = SCNPlane(width: 200,
                                 height: 200)
            
            
            let planeNode = SCNNode(geometry: plane)
            // When a plane geometry is created, by default it is oriented vertically
            // so we have to rotate it on X-axis by -90 degrees to
            // make it flat to the image detected
            //planeNode.eulerAngles.x = -.pi / 2
            planeNode.position.z -= 200

            createHostingController(for: planeNode, fixtures: fixtures)
            
            node.addChildNode(planeNode)
            sceneView.scene.rootNode.addChildNode(node)
        }
    
    func createHostingController(for node: SCNNode, fixtures: [Fixture]) {
            // create a hosting controller with SwiftUI view
            let arVC = UIHostingController(rootView: GamesInfo(fixtures: fixtures) { fixtureId in
                self.showLineups(fixtureId: fixtureId)
            })
            
            // Do this on the main thread
            DispatchQueue.main.async {
                arVC.willMove(toParent: self)
                // make the hosting VC a child to the main view controller
                self.addChild(arVC)
                
                // set the pixel size of the Card View
                arVC.view.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
                
                // add the ar card view as a subview to the main view
                self.view.addSubview(arVC.view)
                
                // render the view on the plane geometry as a material
                self.show(hostingVC: arVC, on: node)
            }
        }
        
        func show(hostingVC: UIHostingController<GamesInfo>, on node: SCNNode) {
            // create a new material
            let material = SCNMaterial()
            
            // this allows the card to render transparent parts the right way
            hostingVC.view.isOpaque = false
            
            // set the diffuse of the material to the view of the Hosting View Controller
            material.diffuse.contents = hostingVC.view
            
            // Set the material to the geometry of the node (plane geometry)
            node.geometry?.materials = [material]
            
            hostingVC.view.backgroundColor = UIColor.clear
        }
    
    func createImageForAR(fixtures: [Fixture]) {
        // Create the SwiftUI view you want to render
//        let fixtureListView = GamesInfo(fixtures: fixtures, onTap: { fixtureID in
//            if fixtureID != fixtureID {
//                print("Selected Fixture ID: \(fixtureID)")
//            } else {
//                print("No fixture ID available")
//            }
//        })
//        // Convert the SwiftUI view to a UIImage
//        let hostingController = UIHostingController(rootView: fixtureListView)
//        guard let fixtureListView = hostingController.view else { return }
//        print(fixtures)
        
        let controller = UIHostingController(rootView: GamesInfo(fixtures: fixtures) { fixtureId in
            self.showLineups(fixtureId: fixtureId)
        })
            
        // Define the size of the view and a renderer
        let size = CGSize(width: 300, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        }
        print(image)
//        let fixtureListView = GamesInfo(fixtures: fixtures)
//        // Convert the SwiftUI view to a UIImage
//        let hostingController = UIHostingController(rootView: fixtureListView)
//        guard let fixtureListView = hostingController.view else { return }
        let plane = SCNPlane(width: 0.3, height: 0.6) // Size in meters
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided = true
        
        let node = SCNNode(geometry: plane)
        if let currentFrame = sceneView.session.currentFrame {
            // Place the node 0.5 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5 // Adjust distance as needed
            let transform = simd_mul(currentFrame.camera.transform, translation)
            node.simdTransform = transform
            
            // Add the node to the scene
            sceneView.scene.rootNode.addChildNode(node)
        }
        
        // Assume the SwiftUI view's frame for now, you might need to adjust this
        //hostingController.view.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
//        fixtureListView.frame = CGRect(x: 0, y: 0, width: FIELD_WIDTH ?? 0.6, height: FIELD_HEIGHT ?? 1.0)
//        
//        //fixtureListView.backgroundColor = .clear
//        // Render the view to an image
//        guard let image = renderViewToImage(view: fixtureListView)else {
//            print("Image rendering failed")
//            return
//        }
//        
//        DispatchQueue.main.async {
//            print("adding images to AR Scene...")
//            self.addImageToARScene(image: image)
//            print("Added images!")
//        }
    }
    
    func renderViewToImage(view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    
    func addImageToARScene(image: UIImage) {
        // Find the canvas node
        guard let canvasNode = sceneView.scene.rootNode.childNode(withName: "canvasNode", recursively: true) else {
            print("Canvas node not found.")
            return
        }

        let planeGeometry = SCNPlane(width: FIELD_WIDTH ?? 0.6, height: FIELD_HEIGHT ?? 1.0)
        planeGeometry.firstMaterial?.diffuse.contents = image
        planeGeometry.firstMaterial?.isDoubleSided = true

        let planeNode = SCNNode(geometry: planeGeometry)
        //planeNode.position = SCNVector3(0, 0, 0.06)
        planeNode.position = canvasNode.position
        planeNode.position.z += 0.06
        if let currentFrame = self.sceneView.session.currentFrame {
            // Use the camera's current transform
            let cameraTransform = currentFrame.camera.transform
            var translationMatrix = matrix_identity_float4x4
            // Define how far away from the camera you want to place the node (e.g., 0.5 meters in front)
            translationMatrix.columns.3.z = +0.1
            // Combine the camera and translation matrices
            let modifiedTransform = simd_mul(cameraTransform, translationMatrix)
            planeNode.simdTransform = modifiedTransform
            print("Plane node position: \(planeNode.position)")
        }
        //canvasNode.addChildNode(planeNode)
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
}

