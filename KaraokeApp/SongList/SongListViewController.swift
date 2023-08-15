//
//  SongListViewController.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import UIKit

class SongListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let audioSystem = SongListAudioSystem()

    var currentSong: Song? = nil

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        audioSystem.start()
    }

    deinit {
        audioSystem.stop()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Song.songListData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongListTableViewCell") as! SongListTableViewCell
        let song = Song.songListData[indexPath.row]

        cell.playTappedAction = self.playTapped
        cell.selectTappedAction = self.selectTapped

        cell.songName.text = song.displayName
        cell.songDuration.text = song.duration

        return cell
    }

    func playTapped(sender: UITableViewCell) {
        let cell = sender as! SongListTableViewCell
        let indexPath = tableView.indexPath(for: sender)
        let song = Song.songListData[indexPath!.row]

        if currentSong?.path != song.path {
            currentSong = song
            audioSystem.loadSong(songURL: song.path)
        }

        if audioSystem.audioPlayerNode.isPlaying {
            audioSystem.pause()
        } else {
            audioSystem.play()
        }
    }

    func selectTapped(sender: UITableViewCell) {
        let cell = sender as! SongListTableViewCell
        let indexPath = tableView.indexPath(for: sender)
        let song = Song.songListData[indexPath!.row]

        audioSystem.stop()
        let sender: Song = song
        self.performSegue(withIdentifier: "showSing", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let singViewController = segue.destination as! SingViewController
        let song = sender as! Song
        singViewController.currentSong = song
    }
}
