//
//  ViewController.swift
//  DeviceInfo
//
//  Created by krishan kumar sharma on 01/03/24.
//

import UIKit
import AVFoundation

//import DeviceKit
import Metal

class ViewController: UIViewController {
    
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var iOSVersionLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var storageLabel: UILabel!
    @IBOutlet weak var batteryHealthLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var processorLabel: UILabel!
    @IBOutlet weak var gpuLabel: UILabel!
    @IBOutlet weak var imeiLabel: UILabel!
    @IBOutlet weak var cameraMegaPixelLabel: UILabel!
    @IBOutlet weak var cameraApertureLable: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDeviceInformation()
    }
    
    func fetchDeviceInformation() {
        let device = UIDevice.current
        
        // Model Name & Model Number
        let modelName = device.model
        let modelNumber = device.localizedModel
        
        // iOS Version
        let iOSVersion = device.systemVersion
        
        // Device’s Serial Number
        let serialNumber = getSerialNumber()
        
        // Storage
        let storage = getStorageSpace()
        
        // Battery Health (Maximum Capacity)
        let batteryHealth = getBatteryHealth()
        
        // Battery Level (Current charging level)
        let batteryLevel = getBatteryLevel()
        
        // Processor (CPU) Information
        let processorInfo = getProcessorInfo()
        
        // GPU Information
        let gpuInfo = getGPUInfo()
        
        // IMEI (Note: IMEI is not accessible on iOS due to privacy restrictions)
        let imei = getDeviceIdentifier()
        
        // Update UI
        modelLabel.text = "Model: \(modelName) (\(modelNumber))"
        iOSVersionLabel.text = "iOS Version: \(iOSVersion)"
        serialNumberLabel.text = "Serial Number: \(serialNumber)"
        storageLabel.text = "Storage: \(storage)"
        batteryHealthLabel.text = "Battery Health: \(batteryHealth)%"
        batteryLevelLabel.text = "Battery Level: \(batteryLevel)%"
        processorLabel.text = "Processor: \(processorInfo)"
        gpuLabel.text = "GPU: \(gpuInfo)"
        imeiLabel.text = "IMEI: \(imei)" + "   ------You can get the UDID, but can not get the IMEI.Apple does not allow this."
        cameraMegaPixelLabel.text = getCameraMegaPixel()
        cameraApertureLable.text = getCameraInfo()
    }
    
    // Helper functions to get additional information
    
    func getSerialNumber() -> String {
        if let serialNumber = UIDevice.current.identifierForVendor?.uuidString {
            return serialNumber
        } else {
            return "Not Available"
        }
    }
    
    func getStorageSpace() -> String {
        do {
            let fileAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let totalSize = fileAttributes[FileAttributeKey.systemSize] as? Int64 {
                return "\(totalSize / (1024 * 1024 * 1024)) GB"
            }
        } catch {
            print("Error getting storage space: \(error.localizedDescription)")
        }
        return "Not Available"
    }
    
    func getBatteryHealth() -> Int {
        let batteryHealth = UIDevice.current.batteryState == .unplugged ? UIDevice.current.batteryLevel * 100 : 100
        return Int(batteryHealth)
    }
    
    func getBatteryLevel() -> Int {
        let batteryLevel = UIDevice.current.batteryLevel * 100
        return Int(batteryLevel)
    }
    
    func getProcessorInfo() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
   
    func getGPUInfo() -> String {
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            return "GPU: Not Available"
        }

        return "GPU: \(metalDevice.name)"
    }

  
    func getDeviceIdentifier() -> String {
        if let identifier = UIDevice.current.identifierForVendor?.uuidString {
            return identifier
        } else {
            return "Not Available"
        }
    }

    
    func getCameraMegaPixel() -> String {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .unspecified)

        for device in discoverySession.devices {
            print("Device: \(device.localizedName)")
            print("Position: \(device.position.rawValue)")
            
            if let formats = device.formats.first {
                let dimensions = CMVideoFormatDescriptionGetDimensions(formats.formatDescription)
                let megapixels = Double(dimensions.width * dimensions.height) / 1_000_000.0
                print("Megapixels: \(megapixels) MP")
                return "Megapixels: \(megapixels) MP"
            }
        }
        return "Not Accessible"
    }
    

    func getCameraInfo() -> String {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                    mediaType: .video,
                                                                    position: .unspecified)
    for device in discoverySession.devices {
                print("Device: \(device.localizedName)")
                print("Position: \(device.position.rawValue)")
                
                if let formats = device.formats.first {
                    print("Max ISO: \(formats.maxISO)")
                    return "Max ISO: \(formats.maxISO)"
                }
            }
        return "Not Accessible"
        }
}
