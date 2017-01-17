/*
 Swift implementation of https://github.com/imgly/rembrandt
 */
import UIKit

class ImageDiff {
    private var imageA: UIImage
    private var imageB: UIImage
    
    private var dataImageA: CFData?
    private var dataImageB: CFData?
    
    private var maxDelta:CGFloat = 0.5
    private var maxOffset: CGFloat = 0
    
    init(imageA: UIImage, imageB: UIImage){
        self.imageA = imageA
        self.imageB = imageB
        prepareImages(imageA: imageA, imageB: imageB)
        
        dataImageA = imageA.cgImage!.dataProvider!.data
        dataImageB = imageB.cgImage!.dataProvider!.data
    }
    
    func compare() -> UIImage? {
        let width = min(imageA.size.width, imageB.size.width)
        let height = min(imageA.size.height, imageB.size.height)
        
        let size = CGSize(width: imageA.size.width, height: imageA.size.height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        imageA.draw(in: CGRect(x: 0, y: 0, width: imageA.size.width, height: imageA.size.height))
        
        let t1 = Int64(Date().timeIntervalSince1970 * 1000)
        for x in 0...Int(width){
            for y in 0...Int(height){
                let result = comparePosition(pos: CGPoint(x: x, y: y))
                if !result {
                    context?.setFillColor(UIColor.red.cgColor)
                    context?.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
        let t2 = Int64(Date().timeIntervalSince1970 * 1000)
        print("compare time: \(t2-t1)")
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func comparePosition(pos: CGPoint) -> Bool {
        let colorA = self.getPixelColor(imageData: self.dataImageA, pos: pos)
        let colorB = self.getPixelColor(imageData: self.dataImageB, pos: pos)

        // Default delta check
        let delta = self.calculateColorDelta(colorA: colorA, colorB: colorB)
        if (delta < maxDelta) {
            return true
        }
        
        // Check surrounding pixels
        if (maxOffset == 0) {
            return false
        }
        
        let width = self.imageA.size.width
        let height = self.imageA.size.height
        
        let lowestX  = Int(max(0, pos.x - maxOffset))
        let highestX = Int(min(width - 1, pos.x + maxOffset))
        let lowestY  = Int(max(0, pos.y - maxOffset))
        let highestY = Int(min(height - 1, pos.y + maxOffset))
        for currentX in lowestX..<highestX {
            for currentY in lowestY..<highestY {
                if currentX == Int(pos.x)  || currentY == Int(pos.y) {
                    continue
                }
                
                let newColorA =  self.getPixelColor(imageData: self.dataImageA, pos: CGPoint(x: currentX, y: currentY))
                let newDeltaA =  self.calculateColorDelta(colorA: colorA, colorB: newColorA)
                
                let newColorB = self.getPixelColor(imageData: self.dataImageB, pos: CGPoint(x: currentX, y: currentY))
                let newDeltaB =  self.calculateColorDelta(colorA: colorA, colorB: newColorB)
                
                if ((abs(newDeltaB - newDeltaA) < maxDelta) && (newDeltaA > maxDelta)) {
                    return true
                }
                
                
            }
        }
        return false
    }
    
    /**
     * Makes sure the two images have the same dimensions
     */
    private func prepareImages (imageA: UIImage, imageB: UIImage) {
        let maxWidth = max(imageA.size.width, imageB.size.width)
        let maxHeight = max(imageB.size.height, imageB.size.height)
        
        self.imageA = self.ensureImageDimensions(image: imageA, width: maxWidth, height: maxHeight)
        self.imageB = self.ensureImageDimensions(image: imageB, width: maxWidth, height: maxHeight)
    }
    
    /**
     * Makes sure the given image has the given dimensions. If it does,
     * it returns the same image. If not, it returns a new image with
     * the correct dimensions
     */
    func ensureImageDimensions (image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        if (image.size.width == width && image.size.height == image.size.height) {
            return image
        }
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    /**
     * Calculates the distance between the given colors
     */
    private func calculateColorDelta (colorA: UIColor, colorB: UIColor) -> CGFloat {
        var total:CGFloat = 0
        let ciColorA =  CoreImage.CIColor(color: colorA)
        let ciColorB =  CoreImage.CIColor(color: colorB)
       
        total += pow(ciColorA.red - ciColorB.red, 2)
        total += pow(ciColorA.green - ciColorB.green, 2)
        total += pow(ciColorA.blue - ciColorB.blue, 2)
        total += pow(ciColorA.alpha - ciColorB.alpha, 2)
        return sqrt(total * 255)
    }
    
    private func getPixelColor(imageData: CFData?, pos: CGPoint) -> UIColor {
        let data : UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
        let pixelInfo: Int = ((Int(imageB.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    
}

extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}
