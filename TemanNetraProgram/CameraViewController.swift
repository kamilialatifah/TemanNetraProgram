//
//  CameraViewController.swift
//  TemanNetraProgram
//
//  Created by Georgius Yoga Dewantama on 20/08/19.
//  Copyright © 2019 Georgius Yoga Dewantama. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Vision

class CameraViewController: UIViewController {

    var counter = 0
    @IBOutlet weak var imageView: UIImageView!
    let synthesizer = AVSpeechSynthesizer()
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var spokenText: String = ""
    var titikTengahDeviceX: Float = 0
    var titikTengahDeviceY: Float = 0
    var posisiSudahPas = false
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLiveVideo()
      //  startTextRecognition()
        titikTengahDeviceX = Float(imageView.frame.width/2)
        titikTengahDeviceY = Float(imageView.frame.height/2)
        //startTextDetection()
        // Do any additional setup after loading the view.
        
        //func segue swipe
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        
        self.view.addGestureRecognizer(leftSwipe)
    }
    
        override func becomeFirstResponder() -> Bool {
            return true
        }
        
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
    //            let appDelegate = UIApplication.shared.delegate as? AppDelegate
    //
    //            guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
    //
    //            let archive = Archive(context: managedContext)
    //
    //            archive.title = "test"
    //            archive.text = self.spokenText
    //
    //            do {
    //                try managedContext.save()
    //                print("berhasil menyimpan")
    //            } catch  {
    //                print("Gagal menyimpan")
    //            }
                synthesizer.stopSpeaking(at: .immediate)
            }
        }
        
        func startLiveVideo() {
            cameraView.session = session
            
            let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
            var cameraDevice: AVCaptureDevice?
            for device in cameraDevices.devices {
                if device.position == .back {
                    cameraDevice = device
                    break
                }
            }
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
                if session.canAddInput(captureDeviceInput) {
                    session.addInput(captureDeviceInput)
                }
            }
            catch {
                print("Error occured \(error)")
                return
            }
            session.sessionPreset = .high
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
            }
            cameraView.videoPreviewLayer.videoGravity = .resize
            session.startRunning()
        }
    
    private var cameraView: CameraView{
        
        return  imageView as! CameraView
    }
        
        /*func startTextRecognition(){
            let textRequest = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
            textRequest.usesLanguageCorrection = false
            //textRequest.regionOfInterest = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
            //textRequest.minimumTextHeight = 0.0625
            self.requests = [textRequest]
            
        }
        */
        /*
        func recognizeTextHandler(request: VNRequest, error: Error?){
            if(synthesizer.isSpeaking == false)
            {
                guard let observations = request.results as? [VNRecognizedTextObservation] else {print("no result"); return}
                
                DispatchQueue.main.async()
                {
                    var avgConfidence: Float = 0
                    var totalConfidence: Float = 0
                    var observationCounter: Float = 0
                    var titikTengahTextX: Float = 0
                    var titikTengahTextY: Float = 0
                    var koordinatTextTerdekatX: Float = 9999
                    var koordinatTextTerdekatY: Float = 9999
                    var recognizedText: String = ""
                    var atas = false
                    var bawah = false
                    var kiri = false
                    var kanan = false
                    self.imageView.layer.sublayers?.removeSubrange(1...)
                    for observation in observations
                    {
                        let penampungTitikTengahText = self.highlightWord(char: observation)
                        titikTengahTextX = Float(penampungTitikTengahText.x)
                        titikTengahTextY = Float(penampungTitikTengahText.y)
    //                    print("X :", titikTengahTextX)
    //                    print("Y :", titikTengahTextY)
                        if(titikTengahTextX < self.titikTengahDeviceX)
                        {
                            koordinatTextTerdekatX = self.titikTengahDeviceX - titikTengahTextX
                            kiri = true
                            kanan = false
                            print("perlu ke kiri")
                        }
                        else if(titikTengahTextX - self.titikTengahDeviceX < koordinatTextTerdekatX)
                        {
                            koordinatTextTerdekatX = titikTengahTextX - self.titikTengahDeviceX
                            kiri = false
                            kanan = true
                            print("perlu ke kanan")
                        }
                        
                        if(titikTengahTextY < self.titikTengahDeviceY)
                        {
                            koordinatTextTerdekatY = self.titikTengahDeviceY - titikTengahTextY
                            atas = true
                            bawah = false
                            print("perlu ke atas")
                        }
                        else if(titikTengahTextY - self.titikTengahDeviceY < koordinatTextTerdekatY)
                        {
                            koordinatTextTerdekatY = titikTengahTextY - self.titikTengahDeviceY
                            atas = false
                            bawah = true
                            print("perlu ke atas")
                        }
                        guard let candidate = observation.topCandidates(1).first else { continue }
                        totalConfidence += candidate.confidence
                        observationCounter += 1
                        recognizedText += candidate.string + " "
                    }
                    if(koordinatTextTerdekatX > koordinatTextTerdekatY)
                    {
                        if(kiri == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Kiri")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                        else if(kanan == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Kanan")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                    }
                    else
                    {
                        if(atas == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Atas")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                        else if(bawah == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Bawah")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                    }
                    if(koordinatTextTerdekatX < 50 && koordinatTextTerdekatY < 50)
                    {
                        self.synthesizer.stopSpeaking(at: .immediate)
                        self.posisiSudahPas = true
                        print("Posisi sudah pas")
                    }
                    else
                    {
                        self.posisiSudahPas = false
                        print("Belum pas")
                    }
                    if(self.posisiSudahPas == true)
                    {
                        if(self.spokenText != recognizedText && recognizedText != "")
                        {
                            self.spokenText = recognizedText
                            if(self.counter >= 7)
                            {
                                self.counter -= 3
                            }
                            else
                            {
                                self.counter = 0
                            }
                        }
                        avgConfidence = totalConfidence/observationCounter
                        if(self.spokenText == recognizedText)
                        {
                            self.counter += 5
                            print(self.spokenText, recognizedText, self.counter)
                        }
                        if(avgConfidence >= 0.5 && self.counter > 30)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "\(self.spokenText)")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                            
                            self.counter = 0
                            print(recognizedText,avgConfidence)
                        }
                    }
                }
            }
        }
    */
        
    //    func startTextDetection() {
    //        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
    //        textRequest.reportCharacterBoxes = true
    //        self.requests = [textRequest]
    //    }
    //
    //    func detectTextHandler(request: VNRequest, error: Error?) {
    //        guard let observations = request.results else {
    //            print("no result")
    //            return
    //        }
    //        let result = observations.map({$0 as? VNTextObservation})
    //
    //        DispatchQueue.main.async() {
    //            self.imageView.layer.sublayers?.removeSubrange(1...)
    //            for region in result {
    //                guard let rg = region else {
    //                    continue
    //                }
    //                self.highlightWord(box: rg)
    //
    //                if let boxes = region?.characterBoxes {
    //                    for characterBox in boxes {
    //                        self.highlightLetters(box: characterBox)
    //                    }
    //                }
    //            }
    //        }
    //    }
    //
    /*    func highlightWord(char: VNRecognizedTextObservation) -> CGPoint {
            
            var maxX: CGFloat = 999.0
            var minX: CGFloat = 0.0
            var maxY: CGFloat = 999.0
            var minY: CGFloat = 0.0

            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
            
            let myWidth = imageView.frame.size.width
            let myHeight = imageView.frame.size.height
            let xCord = maxX * myWidth
            let yCord = (1 - minY) * myHeight
            let midX = (xCord + minX * myWidth) / 2
            let midY = (yCord + (1 - maxY) * myHeight) / 2
            return CGPoint(x: midX, y: midY)
        }*/

//        func highlightLetters(box: VNRectangleObservation) {
//            let xCord = box.topLeft.x * imageView.frame.size.width
//            let yCord = (1 - box.topLeft.y) * imageView.frame.size.height
//            let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
//            let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
//
//            let outline = CALayer()
//            outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
//            outline.borderWidth = 1.0
//            outline.borderColor = UIColor.blue.cgColor
//
//            imageView.layer.addSublayer(outline)
//        }
        
//        func fetchData()
//        {
//            let appDelegate = UIApplication.shared.delegate as? AppDelegate
//            guard let managedContext = appDelegate?.persistentContainer.viewContext else { return  }
//
//
//            var archives = [Archive]()
//
//            do {
//                archives = try managedContext.fetch(Archive.fetchRequest())
//
//                for archive in archives
//                {
//                    let text = archive.text
//
//                    self.spokenText! = text!
//                }
//            } catch  {
//                print("Gagal memanggil")
//            }
//
//        }
//
//    //}
    }

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
   //func untuk segue swipe
@objc func swipeAction(swipe: UISwipeGestureRecognizer) {
            
    performSegue(withIdentifier: "goRight", sender: self)
            
        }
    
    
}


