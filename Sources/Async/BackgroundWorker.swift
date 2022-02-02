//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/11/21.
//

import Foundation

private final class BlockWrapper: NSObject {
  let block: () -> Void
  
  init(block: @escaping () -> Void) {
    self.block = block
  }
}

final class BackgroundWorker: NSObject {
  public var name: String?
  lazy private var thread: WorkerThread = {
    let threadName = String(describing: self).components(separatedBy: .punctuationCharacters)[1]
    let name = "\(threadName)-\(UUID().uuidString)-\(self.name ?? "generic")"
    let thread = WorkerThread(name)
    thread.start()
    return thread
  }()
  
  func async(_ block: @escaping () -> Void) {
    self.thread.async(block)
  }
  
  func sync(_ block: @escaping () -> Void) {
    self.thread.sync(block)
  }

  public func stop() {
    self.thread.stop()
  }
}

class WorkerThread: Thread {
  init(_ name: String) {
    super.init()
    self.name = name
  }
  
  override func main() {
    let runloop = RunLoop.current
    
    // According to the NSRunLoop docs, a port must be added to the
    // runloop to keep the loop alive, otherwise when you call
    // runMode:beforeDate: it will immediately return with NO. We never
    // send anything over this port, it's only here to keep the run loop
    // looping.
    runloop.add(Port(), forMode: .default)
    
    while true {
      if self.isCancelled {
        break
      }
      
      let ranLoop = runloop.run(mode: .default,
                                before: .distantFuture)
      if !ranLoop {
        break
      }
    }
  }
  
  override func cancel() {
    super.cancel()
    
    guard Thread.current != self else {
      return
    }
    
    // This call just forces the runloop in main to spin allowing main to see
    // that the isCancelled flag has been set. Note that this is only really
    // needed if there are no blocks/selectors in the queue for the thread. If
    // there are other items to be processed in the queue, the next one will be
    // executed and then the "cancel" will be seen in main, and it will exit
    // (and the other blocks will be dropped).
    self.perform(#selector(empty),
                 on: self,
                 with: nil,
                 waitUntilDone: false)
  }
  
  func stop() {
    if Thread.current == self {
      super.cancel()
    } else {
      // This call forces the runloop in main to spin allowing main to see that
      // the isCancelled flag has been set. Note that we explicitly want to send
      // it to the thread to process so it is added to the end of the queue of
      // blocks to be processed. 'stop' guarantees that all items in the queue
      // will be processed before it ends.
      self.perform(#selector(cancel),
                   on: self,
                   with: nil,
                   waitUntilDone: true)
      
      while !self.isFinished || self.isExecuting {
        // Spin until the thread is really done.
        usleep(10)
      }
    }
  }
  
  // MARK: - Private
  
  @objc
  private func empty() { }
}

private extension Thread {
  @objc
  private class func sync(_ block: BlockWrapper) {
    block.block()
  }
  
  @objc
  func async(_ block: @escaping () -> Void) {
    Thread.perform(#selector(Thread.sync),
                   on: self,
                   with: BlockWrapper(block: block),
                   waitUntilDone: false)
  }
  
  func sync(_ block: @escaping () -> Void) {
    if Thread.current == self {
      block()
    } else {
      Thread.perform(#selector(Thread.sync),
                     on: self,
                     with: BlockWrapper(block: block),
                     waitUntilDone: true)
    }
  }
}
