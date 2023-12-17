//
//  PixelateDataCollectionViewCell.swift
//  Pixelate
//
//  Created by Taneja-Mac on 25/03/19.
//  Copyright © 2019 Taneja-Mac. All rights reserved.
//

import UIKit

class PixelateDataCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ssLabel: UILabel!
    @IBOutlet weak var isoLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderMe(thickness: 2.5)
        self.borderColor(color: .white)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.borderMe(thickness: 2.5)
        self.borderColor(color: .white)
    }
    
    func setData(_ pixelateData: PixelateData) {
        self.ssLabel.text = "SS: \(pixelateData.shutterSpeed ?? "")"
        self.isoLabel.text = "ISO: \(pixelateData.iso ?? "")"
    }
}
