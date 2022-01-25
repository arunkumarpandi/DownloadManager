//
//  ViewController.swift
//  Task
//
//  Created by Arunkumar on 23/01/22.
//

import UIKit
import Alamofire
import AVFoundation
import AVKit



class ViewController: UIViewController,URLSessionDataDelegate {
    
    @IBOutlet var progressLabel : UILabel!
    @IBOutlet var playButton : UIButton!
    var isDownloading : Bool = false
    var isOffline : Bool = false
    
    var downloadTimer: Timer?
    var session : URLSession!
    
    let byteFormatter: ByteCountFormatter = {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB]
            formatter.countStyle = .file
            return formatter
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        progressLabel.text = ""
//        progressLabel.text = fileIsExist() ? "100 %" : "0 %"
        playButton.setTitle(fileIsExist() ? "Play" : "Download", for: .normal)
        
    }
    
    func fileIsExist() -> Bool {
        //let documnets = NSHomeDirectory() + "/Documents/" + "task" + ".mp4"
        var isExist = false
        let path = NSHomeDirectory() + "/Documents/"
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent("task.mp4") {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    print("FILE AVAILABLE")
                    isExist = true
                } else {
                    print("FILE NOT AVAILABLE")
                }
            } else {
                print("FILE PATH NOT AVAILABLE")
            }
        
//        // Get the document directory url
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        do {
//            // Get the directory contents urls (including subfolders urls)
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
//            isExist = directoryContents.count > 0 ? true : false
//        } catch {
//            print(error)
//        }
        return isExist
    }
    
    func getFileURL() -> String {
        let documnets = NSHomeDirectory() + "/Documents/" + "task" + ".mp4"
//        var fileURL : URL?
//        // Get the document directory url
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        do {
//            // Get the directory contents urls (including subfolders urls)
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
//            if directoryContents.count > 0 {
//                fileURL = directoryContents[0]
//            }
//        } catch {
//            print(error)
//        }
        return documnets
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.restorationIdentifier = "task"
    }
    
    func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        else {
            // something failed
            return nil
        }
        return freeSize.int64Value
    }
    
    fileprivate func checkDeviceAvaliableSize() -> Int64 {
        var size:Int64 = 0
        if let bytes = deviceRemainingFreeSpaceInBytes() {
//            print("free space: \(bytes)")
            size = bytes
        } else {
            print("failed")
        }
        return size
    }
    
    @objc func checkNetwork() {
        if Reachability.isConnectedToNetwork() {
            if(isOffline) {
                download()
                isOffline = false
            }
        } else {
            isOffline = true
        }
    }
    
    func playVideo(filePath:String)
    {
        print("playVideo \(filePath)")
//        let videoURL = URL(fileURLWithPath: filePath)
        let path = filePath.contains("file://") ? filePath : "file://" + filePath
        let videoURL = URL(string: path)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }

    }
    
    
    @IBAction func download() {
        
        if fileIsExist() && getFileURL() != "" {
            playVideo(filePath: getFileURL())
            return
        }
        
        guard let url = URL(string: videoURL) else {
            print("The given url is not valid")
            return
        }
        
        downloadTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkNetwork), userInfo: nil, repeats: true)
        
        /*
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        self.request = AF.download(url,method: .get,to: destination).downloadProgress(closure: { (progress) in
            //progress closure
//            print("====> progress \(progress)")
            self.updateUI(totalBytesWritten: progress.completedUnitCount, totalBytesExpectedToWrite: progress.totalUnitCount)

        }).response(completionHandler: { (response) in
            //here you able to access the DefaultDownloadResponse
            //result closure
            switch response.result{
            case .success:
                if response.fileURL != nil, let filePath = response.fileURL?.absoluteURL {
                    print("File Path \(filePath)")
                    self.playVideo(filePath: filePath.path)
                }
                break
            case .failure:
                print("Failure...")
                if let d = response.resumeData {
                    self.request?.cancel()
                    if response.fileURL != nil, let filePath = response.fileURL?.absoluteURL {
                        try? d.write(to: filePath)
                    }
                }
                break
            }
        })
         */
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let urlconfig = URLSessionConfiguration.background(withIdentifier: "MyDownload session")
//        urlconfig.timeoutIntervalForRequest = 12
//        urlconfig.timeoutIntervalForResource = 12
        urlconfig.isDiscretionary = true
        urlconfig.sessionSendsLaunchEvents = true
        session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: .main)
       
        if appDelegate.fileData == nil {
            session.downloadTask(with: url).resume()
        } else {
            guard let resumeData = appDelegate.fileData else {
                // inform the user the download can't be resumed
                return
            }
            let downloadTask = session.downloadTask(withResumeData: resumeData as Data)
            downloadTask.resume()
        }
         
    }
}




extension ViewController : URLSessionDownloadDelegate {
   
    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        print("Downloading...")
//    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("We want to play the video")
        
        print("Download complete - \(location)")
        let locationPath = location.path
        //Copy to the user directory (file names are named after timestamps)
        let documnets = NSHomeDirectory() + "/Documents/" + "task" + ".mp4"
        print(" Documents \(documnets)")
        //Create a File Manager
        let fileManager = FileManager.default
        try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
        playButton.setTitle(fileIsExist() ? "Play" : "Download", for: .normal)
        playVideo(filePath: documnets)
        downloadTimer?.invalidate()
    }
    
   
    
    func updateUI(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100
        print("Downloaded \(written) / \(expected)" + String(format: " - %.0f", progress) + " %")
        progressLabel.text = "Downloaded \(written) / \(expected)" + String(format: " - %.1f", progress) + " %"
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if checkDeviceAvaliableSize() > totalBytesExpectedToWrite {
            updateUI(totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        } else {
            print("Download cancel")
            SharedClass.sharedInstance.alert(view: self, title: "Can't Download", message: "No avaliable space in your device")
            downloadTask.cancel(byProducingResumeData: {data in
                guard let resumeData = data else {
                    return
                }
                appDelegate.fileData = resumeData
            })
        }
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else {
            print("Download error : \(error?.localizedDescription)")
            return
        }
        
        print("Data Saved....")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userInfo = (error as NSError).userInfo
        if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            print("Data Saved....")
            appDelegate.fileData = resumeData
//            UserDefaults.standard.set(self.fileData, forKey: "file")
//            UserDefaults.standard.synchronize()
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let backgroundCompletionHandler =
                    appDelegate.backgroundCompletionHandler else {
                        return
                    }
            backgroundCompletionHandler()
        }
    }
}

