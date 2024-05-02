import Foundation
import CoreImage
import Vision

func getField(from image: CIImage) -> (maskedImage: CIImage, centerPoint: (x: Double, y: Double)) {
    // Convert image to HSV color space
    let hsv = image.converted(to: .HSV)
    
    // Define range of green color in HSV
    let lowerGreen = CIColor(red: 30/255, green: 40/255, blue: 40/255)
    let upperGreen = CIColor(red: 80/255, green: 1, blue: 1)
    
    // Threshold the HSV image to get only green colors
    let mask = hsv.applyingFilter("CIColorInvert")
                   .applyingFilter("CIColorThreshold", parameters: [
                       "inputColor": lowerGreen,
                       "inputMaxColor": upperGreen
                   ])
    
    // Find the center of the field
    let fieldPixels = mask.pixelBuffer()
    let fieldPixelCount = fieldPixels.count
    var totalX: Double = 0, totalY: Double = 0
    for i in 0..<fieldPixelCount {
        totalX += Double(i % mask.extent.width)
        totalY += Double(i / mask.extent.width)
    }
    let centerX = totalX / Double(fieldPixelCount)
    let centerY = totalY / Double(fieldPixelCount)
    
    // Apply the mask to the original image
    let maskedImage = image.applyingFilter("CIColorInvert")
                          .applyingFilter("CIColorThreshold", parameters: [
                              "inputColor": lowerGreen,
                              "inputMaxColor": upperGreen
                          ])
    
    return (maskedImage, (centerX, centerY))
}

if __name__ == "__main__" {
    let image = CIImage(contentsOf: URL(fileURLWithPath: "img7.png"))!
    let (maskedImage, centerPoint) = getField(from: image)
    
    print("x, y: \(centerPoint.x), \(centerPoint.y)")
    
    // Display commands - remove for API
    let context = CIContext()
    if let cgImage = context.createCGImage(maskedImage, from: maskedImage.extent) {
        let uiImage = UIImage(cgImage: cgImage)
        // Display the masked image
    }
}

