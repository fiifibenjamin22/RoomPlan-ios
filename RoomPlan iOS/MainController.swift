import UIKit
import QuickLook
class MainController: UIViewController {
    
    @IBOutlet weak var scannedDataAvailableView: UIView!
    @IBOutlet weak var scannedDataNotAvailableView: UIView!
    @IBOutlet weak var gridCollectionView: UICollectionView!

    var paths = [String]()
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Scanned Rooms"
        self.navigationController?.isNavigationBarHidden = false
        getScannedRooms()
    }

    
    @IBAction func scanBtnPressed(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RoomCaptureVC") as! RoomCaptureVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpCollectionView() {
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 4
        gridCollectionView
            .setCollectionViewLayout(layout, animated: true)
    }
    
    private func getScannedRooms() {
        let models = FileManager.allScannedModels()
        guard let models = models else {
            scannedDataAvailableView.isHidden = true
            scannedDataNotAvailableView.isHidden = false
            return
        }
        if models.count > 0 {
            scannedDataAvailableView.isHidden = false
            scannedDataNotAvailableView.isHidden = true
            
            paths = models.compactMap({
                $0.lastPathComponent
            })
            gridCollectionView.reloadData()
            
        }else {
            scannedDataAvailableView.isHidden = true
            scannedDataNotAvailableView.isHidden = false
        }
        
    }

}

extension MainController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScannedModelsCell", for: indexPath) as! ScannedModelsCell
        cell.title.text = paths[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 8.0, bottom: 1.0, right: 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing
        return CGSize(width: widthPerItem - 8, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
        
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let pathUrl = FileManager.directoryUrl()!.appending(path: paths[selectedIndex])
        let path = pathUrl.path()
        let url = URL(fileURLWithPath: path)
        return url as QLPreviewItem
    }
}

