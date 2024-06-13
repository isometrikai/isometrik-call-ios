//
//  File.swift
//  
//
//  Created by Ajay Thakur on 13/06/24.
//

import Foundation

public class ISMCallHangupTimer {
    private var timer: DispatchSourceTimer?
    private let timeInterval: TimeInterval
    private let queue: DispatchQueue
    private let hangupHandler: () -> Void

    public init(timeInterval: TimeInterval = 60.0, queue: DispatchQueue = .main, hangupHandler: @escaping () -> Void) {
        self.timeInterval = timeInterval
        self.queue = queue
        self.hangupHandler = hangupHandler
    }

    public func start() {
        timer?.cancel() // cancel previous timer if any

        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now() + timeInterval)
        timer?.setEventHandler { [weak self] in
            self?.hangupHandler()
            self?.timer?.cancel()
            self?.timer = nil
        }
        timer?.resume()
    }

    public func cancel() {
        timer?.cancel()
        timer = nil
    }
}
