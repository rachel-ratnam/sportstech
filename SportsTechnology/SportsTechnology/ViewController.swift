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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up AR scene
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        self.view.addSubview(sceneView)

        let scene = SCNScene()
        sceneView.scene = scene

        // Add a blank canvas (a simple white plane)
        let plane = SCNPlane(width: 0.2, height: 0.2) // Adjust dimensions as needed
        plane.firstMaterial?.diffuse.contents = UIColor.white
        let planeNode = SCNNode(geometry: plane)
        scene.rootNode.addChildNode(planeNode)
        
//        // Set the view's delegate
//        sceneView.delegate = self
//        
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//        
//        // Create a new scene
//        let scene = SCNScene()
//        
//        // Set the scene to the view
//        sceneView.scene = scene
//        let plane = SCNPlane(width: 5, height: 5) // Adjust dimensions as needed
//        plane.firstMaterial?.diffuse.contents = UIColor.black
//        let planeNode = SCNNode(geometry: plane)
//        scene.rootNode.addChildNode(planeNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

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
}
