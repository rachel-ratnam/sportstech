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
        button.addTarget(self, action: #selector(showFixtures), for: .touchUpInside)
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
    
    @objc func showFixtures() {
        // Implement navigation to the next page
        print("Navigating to next page...")
        // Remove the button from the canvas node
        if let buttonNode = sceneView.scene.rootNode.childNode(withName: "buttonNode", recursively: true) {
            buttonNode.removeFromParentNode()
        }
        //addTeams()
        Task {
            print("Beginning Task...")
            do {
                print("Fetching data...")
                let data = try await NetworkService.fetchAllGamesByDate(from: "2024-04-15", to: "2024-04-15")
                //addFixtureNodes(data: data)
                print("Received data from server!")
                DispatchQueue.main.async {
                    self.displayFixtureViews(leagueInfo: data)
                }
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }
    
    private func displayFixtureViews(leagueInfo: LeagueInfo) {
        for fixture in leagueInfo.fixtures {
            // Create a SwiftUI view with the fixture information
            let fixtureView = FixtureCardView(
                homeTeamName: fixture.teams["home"]?.name ?? "Home Team",
                awayTeamName: fixture.teams["away"]?.name ?? "Away Team",
                homeTeamFlag: Image("englandflag"),//fixture.teams["home"]?.logoURL ?? "",
                awayTeamFlag: Image("iranflag"),//fixture.teams["away"]?.logoURL ?? "",
                matchDate: fixture.date,
                matchTime: fixture.timezone,
                matchVenue: fixture.venue
            )

            // Create a UIHostingController with the SwiftUI view
            let hostingController = UIHostingController(rootView: fixtureView)

            // Present or add the hosting controller's view to your interface
            present(hostingController, animated: true)
            // If you want to add it to the AR scene, you'd create a SCNNode with the view as a texture
        }
    }
    
    func addFixtureNodes(data: LeagueInfo) {
        for game in data.fixtures {
            let fixtureNode = createFixtureNode(game: game)
            sceneView.scene.rootNode.addChildNode(fixtureNode)
        }
    }

    func createFixtureNode(game: Fixture) -> SCNNode {
        let fixtureTexture = createFixtureTexture(game: game)
        let plane = SCNPlane(width: FIELD_WIDTH ?? 0.6, height: FIELD_HEIGHT ?? 1.0)
        plane.firstMaterial?.diffuse.contents = fixtureTexture
        let fixtureNode = SCNNode(geometry: plane)
        // Use the camera transform to place the node in front of the camera
        if let currentFrame = self.sceneView.session.currentFrame {
                // Use the camera's current transform
                let cameraTransform = currentFrame.camera.transform
                var translationMatrix = matrix_identity_float4x4
                // Define how far away from the camera you want to place the node (e.g., 0.5 meters in front)
                translationMatrix.columns.3.z = -0.5
                // Combine the camera and translation matrices
                let modifiedTransform = simd_mul(cameraTransform, translationMatrix)
                fixtureNode.simdTransform = modifiedTransform
            }

        return fixtureNode
    }
    
    func createFixtureTexture(game: Fixture) -> UIImage {
        // Define the size of the image you want to create.
        let imageSize = CGSize(width: 600, height: 100) // Example size, you'll want to scale this appropriately.
        
        // Begin image context
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        // Draw background
        let backgroundColor = UIColor.white
        backgroundColor.set()
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        // Set up the attributes for drawing text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        
        // Draw the home team name
        if let homeTeamInfo = game.teams["home"],
           let awayTeamInfo = game.teams["away"] {
            
            // Extract the team names from the nested dictionaries
            let homeTeamName = homeTeamInfo.name
            let awayTeamName = awayTeamInfo.name
            
            let homeTeamRect = CGRect(x: 10, y: 15, width: imageSize.width / 2 - 10, height: 20)
            homeTeamName.draw(in: homeTeamRect, withAttributes: attributes)
            
            let awayTeamRect = CGRect(x: imageSize.width / 2, y: 15, width: imageSize.width / 2 - 10, height: 20)
            awayTeamName.draw(in: awayTeamRect, withAttributes: attributes)
        }
            // Draw the match time
        let matchTimeString = game.date as String
            let matchTimeRect = CGRect(x: 10, y: 40, width: imageSize.width - 20, height: 20)
            matchTimeString.draw(in: matchTimeRect, withAttributes: attributes)
            
            // Draw the goals
            if let homeGoals = game.goals["home"], let awayGoals = game.goals["away"] {
                let goalsString = "\(homeGoals) - \(awayGoals)"
                let goalsRect = CGRect(x: 10, y: 65, width: imageSize.width - 20, height: 20)
                goalsString.draw(in: goalsRect, withAttributes: attributes)
            }
            
            // End the graphics context and return the image
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image ?? UIImage()
    }
    
    func createTeam(x: CGFloat, y: CGFloat, z: CGFloat, color: UIColor) -> SCNNode {
        let plane = SCNPlane(width: (FIELD_WIDTH ?? 0.6), height: (FIELD_HEIGHT ?? 1.0)/2) // Adjust dimensions as needed
        plane.firstMaterial?.diffuse.contents = color
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(x, y, z)
        return planeNode
    }
    
    func addTeams() {
        // Find the canvas node
        guard let canvasNode = sceneView.scene.rootNode.childNode(withName: "canvasNode", recursively: true) else {
            print("Canvas node not found.")
            return
        }

        // Create a new node to hold both teams
        let teamsNode = SCNNode()
        teamsNode.addChildNode(createTeam(x: 0, y: -(FIELD_HEIGHT ?? 1.0)/4, z: 0.06, color: UIColor.red))
        teamsNode.addChildNode(createTeam(x: 0, y: (FIELD_HEIGHT ?? 1.0)/4, z: 0.06, color: UIColor.blue))
        
        // Add the planes node to the canvas node
        canvasNode.addChildNode(teamsNode)
    }
}

