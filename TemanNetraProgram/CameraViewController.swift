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
    var recognizedTextSize: Float = 0
    var posisiSudahPas = false
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
    var sudahTahan = 1
    var voiceOverCondition = UIAccessibility.isVoiceOverRunning
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(imageView.frame.size)
        startLiveVideo()
        startTextRecognition()
        titikTengahDeviceX = Float(imageView.frame.width/2)
        titikTengahDeviceY = Float(imageView.frame.height/2)
        print("TitikX: ", titikTengahDeviceX)
        print("TitikY: ", titikTengahDeviceY)
        
        //func segue swipe
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        
        self.view.addGestureRecognizer(leftSwipe)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired  = 2
        self.imageView.addGestureRecognizer(tap)
        //startTextDetection()
        // Do any additional setup after loading the view.
        if voiceOverCondition == true {
            print("voice over nyala")
        }
        else {
            print("voice over mati")
        }
        
        
        //double  tap
//        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
//        tap.numberOfTapsRequired  = 2
//        self.imageView.addGestureRecognizer(tap)
    }
    
        override func becomeFirstResponder() -> Bool {
            return true
        }
        
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                synthesizer.stopSpeaking(at: .immediate)
            }
        }
    
    @IBAction func buttonAlertSave(_ sender: Any) {
        
        let alert = UIAlertController(title: "Judul Catatan", message: "Berikan judul untuk menyimpan catatan ini ke dalam Arsip", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Simpan", style: .default, handler: { action in
            if let catatan  = alert.textFields?.first?.text {
                print("ok")
            }
        }))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Buat judul catatanmu"
        })
        
        alert.addAction(UIAlertAction(title: "Batal", style:  .cancel, handler: nil))
        self.present(alert, animated: true)
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
    
    
    
    func startTextRecognition(){
            let textRequest = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
            textRequest.usesLanguageCorrection = false
            //textRequest.regionOfInterest = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
            //textRequest.minimumTextHeight = 0.0625
            self.requests = [textRequest]
        }
        
        func recognizeTextHandler(request: VNRequest, error: Error?){
            if(synthesizer.isSpeaking == false)
            {
                guard let observations = request.results as? [VNRecognizedTextObservation] else {print("no result"); return}
                
                DispatchQueue.main.async()
                {
                    self.avgConfidence = 0
                    self.totalConfidence = 0
                    self.observationCounter = 0
                    self.titikTengahTextX = 0
                    self.titikTengahTextY = 0
                    self.koordinatTextTerdekatX = 9999
                    self.koordinatTextTerdekatY = 9999
                    self.recognizedText = ""
                    self.atas = false
                    self.bawah = false
                    self.kiri = false
                    self.kanan = false
                    self.recognizedTextSize = 12
                    self.imageView.layer.sublayers?.removeSubrange(1...)
                    for observation in observations
                    {
                        let penampungTitikTengahText = self.highlightWord(char: observation)
                    
                        self.titikTengahTextX = Float(penampungTitikTengahText.x)
                        self.titikTengahTextY = Float(penampungTitikTengahText.y)
                        print("X :", self.titikTengahTextX)
                        print("Y :", self.titikTengahTextY)
                        if(self.titikTengahTextX < self.titikTengahDeviceX)
                        {
                            self.koordinatTextTerdekatX = self.titikTengahDeviceX - self.titikTengahTextX
                            self.kiri = true
                            self.kanan = false
                            print("perlu ke kiri")
                        }
                        else if(self.titikTengahTextX - self.titikTengahDeviceX < self.koordinatTextTerdekatX)
                        {
                            self.koordinatTextTerdekatX = self.titikTengahTextX - self.titikTengahDeviceX
                            self.kiri = false
                            self.kanan = true
                            print("perlu ke kanan")
                        }
                        
                        if(self.titikTengahTextY < self.titikTengahDeviceY)
                        {
                            self.koordinatTextTerdekatY = self.titikTengahDeviceY - self.titikTengahTextY
                            self.atas = true
                            self.bawah = false
                            print("perlu ke atas")
                        }
                        else if(self.titikTengahTextY - self.titikTengahDeviceY < self.koordinatTextTerdekatY)
                        {
                            self.koordinatTextTerdekatY = self.titikTengahTextY - self.titikTengahDeviceY
                            self.atas = false
                            self.bawah = true
                            print("perlu ke bawah")
                        }
                        guard let candidate = observation.topCandidates(1).first else { continue }
                        self.totalConfidence += candidate.confidence
                        self.observationCounter += 1
                        print("Koordinat terdekat X: ", self.koordinatTextTerdekatX)
                        print("Koordinat terdekat Y: ", self.koordinatTextTerdekatY)
                        if(self.recognizedTextSize > 5 && self.recognizedTextSize < 26)
                        {
                            self.recognizedText += candidate.string + " "
                        }
                    }
                    if(self.recognizedTextSize < 5)
                    {
                        let speechUtterance = AVSpeechUtterance(string: "Mendekat")
                        speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                        self.synthesizer.speak(speechUtterance)
                    }
                    else if(self.recognizedTextSize > 26)
                    {
                        let speechUtterance = AVSpeechUtterance(string: "Menjauh")
                        speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                        self.synthesizer.speak(speechUtterance)
                    }
                    else if(self.koordinatTextTerdekatX > self.koordinatTextTerdekatY && self.koordinatTextTerdekatX > 50)
                    {
                        if(self.kiri == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Kiri")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                        else if(self.kanan == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Kanan")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                    }
                    else if(self.koordinatTextTerdekatY > 50)
                    {
                        if(self.atas == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Atas")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                        else if(self.bawah == true)
                        {
                            let speechUtterance = AVSpeechUtterance(string: "Bawah")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                        }
                    }
                    if(self.koordinatTextTerdekatX < 50 && self.koordinatTextTerdekatY < 50 && self.recognizedTextSize > 5 && self.recognizedTextSize < 26)
                    {
                        self.posisiSudahPas = true
                        if(self.sudahTahan == 1)
                        {
                            self.synthesizer.stopSpeaking(at: .immediate)
                            let speechUtterance = AVSpeechUtterance(string: "Tahan")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                            self.sudahTahan += 1
                        }
                        print("Posisi sudah pas")
                    }
                    else
                    {
                        self.posisiSudahPas = false
                        self.sudahTahan = 1
                        print("Belum pas")
                    }
                    if(self.posisiSudahPas == true)
                    {
                        if(self.spokenText != self.recognizedText && self.recognizedText != "")
                        {
                            self.spokenText = self.recognizedText
                            if(self.counter >= 7)
                            {
                                self.counter -= 3
                            }
                            else
                            {
                                self.counter = 0
                            }
                        }
                        self.avgConfidence = self.totalConfidence/self.observationCounter
                        if(self.spokenText == self.recognizedText)
                        {
                            self.counter += 5
                            print(self.spokenText, self.recognizedText, self.counter)
                        }
                        if(self.avgConfidence >= 0.5 && self.counter > 30)
                        {
                            self.synthesizer.stopSpeaking(at: .immediate)
                            let speechUtterance = AVSpeechUtterance(string: "\(self.spokenText)")
                            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id")
                            self.synthesizer.speak(speechUtterance)
                            self.counter = 0
                            self.sudahTahan = 1
                            print(self.recognizedText,self.avgConfidence)
                        }
                    }
                }
            }
        }
    
    
    func highlightWord(char: VNRecognizedTextObservation) -> CGPoint {
        
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
        recognizedTextSize = Float((1 - maxY) * myHeight - yCord)
        //print("Ukuran Text: ", recognizedTextSize)
        
        return CGPoint(x: midX, y: midY)
    }
    
        
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
    
    @objc func doubleTapped() {
        
        let alert = UIAlertController(title: "Judul Catatan", message: "Berikan judul untuk menyimpan catatan ini ke dalam Arsip", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Simpan", style: .default, handler: { action in
            if let catatan  = alert.textFields?.first?.text {
                print("ok")
            }
        }))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Buat judul catatanmu"
        })
        
        alert.addAction(UIAlertAction(title: "Batal", style:  .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
}




