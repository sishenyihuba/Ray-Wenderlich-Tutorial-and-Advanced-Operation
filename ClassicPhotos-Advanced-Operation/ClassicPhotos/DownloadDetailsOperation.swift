/*
  DownloadDetails.swift
  ClassicPhotos

  Created by Seyed Samad Gholamzadeh on 7/15/1396 AP.
  Copyright © 1396 AP raywenderlich. All rights reserved.
 
 Abstract:
 this file contains the code to download the feed of photos details.
*/

import Foundation

final class DownloadDetailsOperation: GroupOperation {
    //MARK: Properties
    
    let cacheFile: URL

    //MARK: Initializer
    
    /// -parameter cacheFile: The file `URL` to wich  the photos feed will be downloaded.
    init(cacheFile: URL) {
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "Download Details"

//        var photos: [PhotoRecord]?
        
        
        /*
         Since this server is out of our control and does not offer a secure
         communication channel, we'll use the http version of the URL and have
         added "earthquake.usgs.gov" to the "NSExceptionDomains" value in the
         app's info.plist file. When you communicate with your own servers,
         or when the services you use offer secure communication options, you
         should always prefer to use https.
         */
        let url = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!
        
        let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
            self.downloadFinished(url, response: response, error: error as NSError?)
            return()
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: url)
        taskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(taskOperation)
    }
    
    func downloadFinished(_ url: URL?, response: URLResponse?, error: NSError?) {
        if let localURL = url {
            do {
                /*
                 If we already have a file at this location, just delete it.
                 Also swallow the error, because we don't really care about it.
                 */
                try FileManager.default.removeItem(at: cacheFile)
            }
            catch { }
            
            do {
                try FileManager.default.moveItem(at: localURL, to: cacheFile)
            }
            catch let error as NSError {
                aggregateError(error)
            }
        }
        else if let error = error {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }

    
}
