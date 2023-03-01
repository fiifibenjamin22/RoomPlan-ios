import UIKit
import RoomPlan

class RoomCaptureVC: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var actionsStackView: UIStackView!
    
    private var isScanning: Bool = false
    
    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    
    private var finalResults: CapturedRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        // Set up after loading the view.
        setupRoomCaptureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        
        view.insertSubview(roomCaptureView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ flag: Bool) {
        super.viewWillDisappear(flag)
        stopSession()
    }
    
    private func startSession() {
        isScanning = true
        roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
        
        setActiveNavBar()
    }
    
    private func stopSession() {
        isScanning = false
        roomCaptureView?.captureSession.stop()
        
        setCompleteNavBar()
    }
    
    // Decide to post-process and show the final results.
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
    
    // Access the final post-processed results.
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        finalResults = processedResult
    }
    
    @IBAction func doneScanning(_ sender: UIButton) {
        if isScanning { stopSession() } else { cancelScanning(sender) }
    }

    @IBAction func cancelScanning(_ sender: UIButton) {
        //navigationController?.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Export the USDZ output by specifying the `.parametric` export option.
    // Alternatively, `.mesh` exports a nonparametric file and `.all`
    // exports both in a single USDZ.
    @IBAction func saveResults(_ sender: UIButton) {
        let number = arc4random_uniform(900000) + 100000
        let name = "Model_" + String(number) + ".usdz"
        //let destinationURL = FileManager.default.temporaryDirectory.appending(path: name)
        let destinationURL = FileManager.directoryUrl()!.appending(path: name)
        do {
            try finalResults?.export(to: destinationURL, exportOptions: .mesh)
            self.view.makeToast("Model saved")
        } catch {
            print("Error = \(error)")
        }
    }
    
    @IBAction func shareModel(_ sender: UIButton) {
        let number = arc4random_uniform(900000) + 100000
        let name = "Model_" + String(number) + ".usdz"
        //let destinationURL = FileManager.default.temporaryDirectory.appending(path: name)
        let destinationURL = FileManager.directoryUrl()!.appending(path: name)
        do {
            try finalResults?.export(to: destinationURL, exportOptions: .mesh)
            let activityVC = UIActivityViewController(activityItems: [destinationURL], applicationActivities: nil)
            activityVC.modalPresentationStyle = .popover
            
            present(activityVC, animated: true, completion: nil)
            if let popOver = activityVC.popoverPresentationController {
                popOver.sourceView = self.shareButton
            }
        } catch {
            print("Error = \(error)")
        }
    }
    
    private func setActiveNavBar() {
        UIView.animate(withDuration: 1.0, animations: {
            self.actionsStackView?.alpha = 0.0
        }, completion: { complete in
            self.actionsStackView?.isHidden = true
        })
    }
    
    private func setCompleteNavBar() {
        self.actionsStackView?.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.doneButton?.isHidden = true
            self.actionsStackView?.alpha = 1.0
        }
    }
}


