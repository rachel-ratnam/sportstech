//
//  ViewController.swift
//  SportsTechnology
//
//  Created by Rachel Ratnam on 3/11/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        translation.columns.3.z = -0.5 // Canvas will be half a meter in front of the camera
        return simd_mul(currentFrame.camera.transform, translation)
    }
    
    func setupCanvas(transform: simd_float4x4) -> SCNNode {
        // Add a blank canvas (simple white plane)
        let plane = SCNPlane(width: 0.4, height: 0.4) // Adjust dimensions as needed
        plane.firstMaterial?.diffuse.contents = UIColor.white
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
        button.addTarget(self, action: #selector(showTeams), for: .touchUpInside)
        return button
    }
    
    func setupField() {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let transform = getTransform(currentFrame: currentFrame)
        
        // Create a new node for the canvas
        let scene = SCNScene()
        
        // Create a button
        let button = createButton()
        
        // Attach button to scene
        let buttonNode = SCNNode() // Adjust button size
        buttonNode.geometry = SCNPlane(width: 0.1, height: 0.05)
        buttonNode.geometry?.firstMaterial?.diffuse.contents = button
        buttonNode.position = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        buttonNode.position.z += 0.06 // Make sure the button is positioned in front of the canvas
        buttonNode.name = "buttonNode"
        scene.rootNode.addChildNode(buttonNode)
        
        
        scene.rootNode.addChildNode(setupCanvas(transform: transform))
        
        // Add the canvas node to the scene's root node
        sceneView.scene = scene
    }
    
    @objc func showTeams() {
        // Implement navigation to the next page
        print("Navigating to next page...")
        // Remove the button from the canvas node
        if let buttonNode = sceneView.scene.rootNode.childNode(withName: "buttonNode", recursively: true) {
            buttonNode.removeFromParentNode()
        }
        
        addTeams()
    }
    
    func createTeam(x: CGFloat, y: CGFloat, z: CGFloat, color: UIColor) -> SCNNode {
        let bluePlane = SCNPlane(width: 0.4, height: 0.2) // Adjust dimensions as needed
        bluePlane.firstMaterial?.diffuse.contents = color
        let bluePlaneNode = SCNNode(geometry: bluePlane)
        bluePlaneNode.position = SCNVector3(x, y, z) // Slightly below the red plane
        return bluePlaneNode
    }
    
    func addTeams() {
        // Find the canvas node
        guard let canvasNode = sceneView.scene.rootNode.childNode(withName: "canvasNode", recursively: true) else {
            print("Canvas node not found.")
            return
        }

        // Create a new node to hold both teams
        let teamsNode = SCNNode()
        teamsNode.addChildNode(createTeam(x: 0, y: -0.1, z: 0.06, color: UIColor.red))
        teamsNode.addChildNode(createTeam(x: 0, y: 0.1, z: 0.06, color: UIColor.blue))
        
        // Add the planes node to the canvas node
        canvasNode.addChildNode(teamsNode)
    }
}

