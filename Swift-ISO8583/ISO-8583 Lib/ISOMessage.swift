//
//  ISOMessage.swift
//  Swift-ISO8583
//
//  Created by Jorge Tapia on 3/14/15.
//  Copyright (c) 2015 Jorge Tapia. All rights reserved.
//

import Foundation

class ISOMessage {
    // MARK: Properties
    
    private(set) var mti: String?
    var bitmap: ISOBitmap?
    private(set) var hasSecondaryBitmap: Bool
    private(set) var usesCustomConfiguration: Bool
    
    var dataElements: NSMutableDictionary?
    
    private var dataElementsScheme: NSDictionary
    private var validMTIs: NSArray
    
    // MARK: Initializers
    
    init() {
        let pathToConfigFile = Bundle.main.path(forResource: "isoconfig", ofType: "plist")
        dataElementsScheme = NSMutableDictionary(contentsOfFile: pathToConfigFile!)!
        dataElements = NSMutableDictionary(capacity: dataElementsScheme.count)
        
        let pathToMTIConfigFile = Bundle.main.path(forResource: "isoMTI", ofType: "plist")
        validMTIs = NSArray(contentsOfFile: pathToMTIConfigFile!)!
        
        usesCustomConfiguration = false
        hasSecondaryBitmap = false
    }
    
    convenience init?(isoMessage: String?) {
        self.init()
        
        if isoMessage == nil {
            print("The isoMessage parameter cannot be nil.")
            return nil
        }
        
        let isoMessageStr = (isoMessage! as NSString)
        
//        let isoHeaderPresent = isoMessageStr.substring(to: 3) == "ISO"
        let isoHeaderPresent = isoMessage!.hasPrefix("ISO")
//        let isoHeaderPresent = isoMessage!.substringToIndex(advance(isoMessage!.startIndex, 3)) == "ISO"
        
        if !isoHeaderPresent {
            // Sets MTI
            let startIndex = isoMessage!.index(isoMessage!.startIndex, offsetBy: 3)
            let endIndex = isoMessage!.index(startIndex, offsetBy: 3)
            let mti = String(isoMessage![startIndex...endIndex])
//            setMTI(isoMessage!.substringToIndex(advance(isoMessage!.startIndex, 4)))
            let _ = setMTI(mti: mti)
            
            let startBitmapFirstBitIndex = isoMessage!.index(endIndex, offsetBy: 3)
//            advance(isoMessage!.startIndex, 4)
//            let endBitmapFirstBitIndex = advance(startBitmapFirstBitIndex, 1)
            let endBitmapFirstBitIndex = isoMessage!.index(startBitmapFirstBitIndex, offsetBy: 0)
//            let bitmapFirstBit = isoMessage!.substringWithRange(Range(start: startBitmapFirstBitIndex, end: endBitmapFirstBitIndex))
            let bitmapFirstBit = String(isoMessage![startBitmapFirstBitIndex...endBitmapFirstBitIndex])
            
            // Sets bitmap
            hasSecondaryBitmap = bitmapFirstBit == "8" || bitmapFirstBit == "9" || bitmapFirstBit == "A" || bitmapFirstBit == "B" || bitmapFirstBit == "C" || bitmapFirstBit == "D" || bitmapFirstBit == "E" || bitmapFirstBit == "F"
            
            let endBitmapIndex = hasSecondaryBitmap ? isoMessage!.index(startBitmapFirstBitIndex, offsetBy: 31) : isoMessage!.index(startBitmapFirstBitIndex, offsetBy: 15)
//            let endBitmapIndex = hasSecondaryBitmap ? advance(startBitmapFirstBitIndex, 32) : advance(startBitmapFirstBitIndex, 16)
//            let bitmapRange = Range(start: startBitmapFirstBitIndex, end: endBitmapIndex)
//            let bitmapHexString = isoMessage!.substringWithRange(bitmapRange)
            let bitmapHexString = String(isoMessage![startBitmapFirstBitIndex...endBitmapIndex])
            
            bitmap = ISOBitmap(hexString: bitmapHexString)
            
            // Extract and set values for data elements
//            let dataElementValues = isoMessageStr.substringFromIndex(endBitmapIndex)
            let dataElementValues = String(isoMessage![endBitmapIndex...])
//            let theValues = extractDataElementValues(isoMessageDataElementValues: dataElementValues, dataElements: bitmap?.dataElementsInBitmap())
            
            print("MTI: \(self.mti!)")
            print("Bitmap: \(bitmap!.rawValue ?? "nil")")
            print("Data: \(dataElementValues)")
        } else {
            // TODO: with iso header
        }
    }
    
    // MARK: Methods
    
    func setMTI(mti: String) -> Bool {
        if (isValidMTI(mti: mti)) {
            self.mti = mti
            return true
        } else {
            print("The MTI is not valid. Please set a valid MTI like the ones described in the isoMTI.plist or your custom MTI configuration file.")
            return false
        }
    }
    
    func addDataElement(elementName: String?, value: String?) -> Bool {
        return addDataElement(elementName: elementName, value: value, customConfigFileName: nil)
    }
    
    func addDataElement(elementName: String?, value: String?, customConfigFileName: String?) -> Bool {
        return false
    }
    
    func useCustomConfigurationFiles(customConfigurationFileName: String?, customMTIFileName: String?) -> Bool {
        if customConfigurationFileName == nil {
            print("The customConfigurationFileName cannot be nil.")
            return false
        }
        
        if customMTIFileName == nil {
            print("The customMTIFileName cannot be nil.")
            return false
        }
        
        let pathToConfigFile = Bundle.main.path(forResource: customConfigurationFileName, ofType: "plist")
        dataElementsScheme = NSDictionary(contentsOfFile: pathToConfigFile!)!
        dataElements = NSMutableDictionary()
        
        let pathToMTIConfigFile = Bundle.main.path(forResource: customMTIFileName, ofType: "plist")
        validMTIs = NSArray(contentsOfFile: pathToMTIConfigFile!)!
        
        usesCustomConfiguration = true
        
        return true
    }
    
    func getHexBitmap1() -> String? {
        let hexBitmapString = (bitmap?.bitmapAsHexString())!
        let endindex = hexBitmapString.index(hexBitmapString.startIndex, offsetBy: 15)
        return String(hexBitmapString[...endindex])
//        return hexBitmapString.substringToIndex(advance(hexBitmapString.startIndex, 16))
    }
    
    func getBinaryBitmap1() -> String? {
        let binaryBitmapString = ISOHelper.hexToBinaryAsString(hexString: bitmap?.bitmapAsHexString())!
        let endindex = binaryBitmapString.index(binaryBitmapString.startIndex, offsetBy: 63)
        return String(binaryBitmapString[...endindex])
//        return binaryBitmapString.substringToIndex(advance(binaryBitmapString.startIndex, 64))
    }
    
    func getHexBitmap2() -> String? {
        let isBinary = bitmap!.isBinary
//        let length = countElements(bitmap!.rawValue!)
        let length = bitmap!.rawValue!.count
        
        if isBinary && length != 128 {
            print("This bitmap does not have a secondary bitmap.")
            return nil
        } else if !isBinary && length != 32 {
            print("This bitmap does not have a secondary bitmap.")
            return nil
        } else if isBinary && length == 128 {
            let endindex = bitmap!.rawValue!.index(bitmap!.rawValue!.startIndex, offsetBy: 63)
            return ISOHelper.binaryToHexAsString(binaryString: String(bitmap!.rawValue![...endindex]))
        } else if isBinary && length == 32 {
            let endindex = bitmap!.rawValue!.index(bitmap!.rawValue!.startIndex, offsetBy: 15)
            return ISOHelper.binaryToHexAsString(binaryString: String(bitmap!.rawValue![...endindex]))
        }
        
        return nil
    }
    
    // MARK: Private methods
    
    private func isValidMTI(mti: String) -> Bool {
        return validMTIs.index(of: mti) > -1
    }
    
    private func extractDataElementValues(isoMessageDataElementValues: String?, dataElements: [String]?) -> [String]? {
        var dataElementCount = 0
        var fromIndex = -1
        var toIndex = -1
        var values = [String]()
        
        for dataElement in dataElements! {
            if dataElement == "DE01" {
                continue
            }
            
            let length = dataElementsScheme.value(forKeyPath: "\(dataElement).Length") as! NSString
            
            // fixed length values
            if length.range(of: ".").location == NSNotFound {
                let trueLength = Int(length as String)
                
                if dataElementCount == 0 {
                    fromIndex = 0
                    toIndex = trueLength!
                    
                    let valuesAsNSString = isoMessageDataElementValues! as NSString
                    let value = (valuesAsNSString.substring(from: fromIndex) as NSString).substring(to: toIndex)
                    values.append(value)
                    fromIndex = trueLength!
                } else {
                    toIndex = trueLength!
                    let valuesAsNSString = isoMessageDataElementValues! as NSString
                    let value = (valuesAsNSString.substring(from: fromIndex) as NSString).substring(to: toIndex)
                    values.append(value)
                    fromIndex += trueLength!
                }
            } else {
                // variable length values
                var trueLength = -1
                var numberOfLengthDigits = 0
                let valuesAsNSString = isoMessageDataElementValues! as NSString
                
                if (length as String).count == 2 {
                    numberOfLengthDigits = 1
                } else if (length as String).count == 4 {
                    numberOfLengthDigits = 2
                } else if (length as String).count == 6 {
                    numberOfLengthDigits = 3
                }
                
                if dataElementCount == 0 {
                    trueLength = Int((valuesAsNSString.substring(from: fromIndex) as NSString).substring(to: toIndex))! + numberOfLengthDigits
//                    trueLength = Int((isoMessageDataElementValues![fromIndex...])[...toIndex])! + numberOfLengthDigits
                    fromIndex = 0 + numberOfLengthDigits
                    toIndex = trueLength - numberOfLengthDigits
                    let value = (valuesAsNSString.substring(from: fromIndex) as NSString).substring(to: toIndex)
                    values.append(value)
                    fromIndex = trueLength;
                } else {
                    trueLength = Int((valuesAsNSString.substring(from: fromIndex) as NSString).substring(to: numberOfLengthDigits))! + numberOfLengthDigits
//                    trueLength = Int((isoMessageDataElementValues![fromIndex...])[...numberOfLengthDigits])! + numberOfLengthDigits
                    toIndex = trueLength
                    let value = (valuesAsNSString.substring(to: fromIndex + numberOfLengthDigits) as NSString).substring(to: toIndex - numberOfLengthDigits)
                    values.append(value)
                    fromIndex += trueLength
                }
            }
            
            dataElementCount+=1;
        }
        
        return values
    }
}
