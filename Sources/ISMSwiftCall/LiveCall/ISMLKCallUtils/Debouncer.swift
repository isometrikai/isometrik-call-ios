//
//  File.swift
//  
//
//  Created by Ajay Thakur on 20/06/24.
//

import Foundation
class Debouncer {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
