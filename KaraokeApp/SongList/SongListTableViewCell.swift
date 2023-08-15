//
//  SongListTableViewCell.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import UIKit

class SongListTableViewCell: UITableViewCell {

    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!

    var playTappedAction : ((UITableViewCell) -> Void)?
    var selectTappedAction : ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func playTapped(_ sender: Any) {
        playTappedAction?(self)
    }

    @IBAction func selectTapped(_ sender: Any) {
        selectTappedAction?(self)
    }
}
