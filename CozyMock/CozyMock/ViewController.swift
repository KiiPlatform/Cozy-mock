//
//  ViewController.swift
//  CozyMock
//
//  Created by syahRiza on 12/1/15.
//  Copyright © 2015 cozy. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBPeripheralDelegate,CBPeripheralManagerDelegate {

    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var advertisingSwitch: UISwitch!
    
    private var peripheralManager: CBPeripheralManager?
    private var transferCharacteristic: CBMutableCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start up the CBPeripheralManager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Don't keep it going while we're not showing.
        peripheralManager?.stopAdvertising()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** Start advertising
     */
    @IBAction func switchChanged(sender: UISwitch) {
        if advertisingSwitch.on {
            // All we advertise is our service's UUID
            peripheralManager!.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey : [transferServiceUUID]
                ])
        } else {
            peripheralManager?.stopAdvertising()
        }
    }
    
    /** Required protocol method.  A full app should take care of all the possible states,
     *  but we're just waiting for  to know when the CBPeripheralManager is ready
     */
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        // Opt out from any other state
        if (peripheral.state != CBPeripheralManagerState.PoweredOn) {
            return
        }
        
        // We're in CBPeripheralManagerStatePoweredOn state...
        print("self.peripheralManager powered on.")
        
        // ... so build our service.
        
        // Start with the CBMutableCharacteristic
        transferCharacteristic = CBMutableCharacteristic(
            type: transferCharacteristicUUID,
            properties: CBCharacteristicProperties.Write,
            value: nil,
            permissions: CBAttributePermissions.Writeable
        )
        
        // Then the service
        let transferService = CBMutableService(
            type: transferServiceUUID,
            primary: true
        )
        
        // Add the characteristic to the service
        transferService.characteristics = [transferCharacteristic!]
        
        // And add it to the peripheral manager
        peripheralManager!.addService(transferService)
    }

    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?){
        
    }
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        let request = requests[0]
        if let request_data = request.value {
            let str = String(data: request_data, encoding: NSUTF8StringEncoding)
            print(str)
            self.textView.text = str
            
        }
        
    }
}

