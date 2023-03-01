import UIKit

class ScannedModelsCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var parentView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        parentView.layer.cornerRadius = 8.0
    }

}
