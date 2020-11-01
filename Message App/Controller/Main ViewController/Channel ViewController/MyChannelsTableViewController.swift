//
//  MyChannelsTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/1/20.
//

import UIKit

class MyChannelsTableViewController: UITableViewController {
    // MARK: - Properties
    var myChannels: [Channel] = []
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadUserChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadUserChannels()
    }
    
    // MARK: - IbActions
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: MY_CHANNEL_TO_ADD_CHANNEL_SEGUE, sender: self)
    }
    
    // MARK: - Download Channels
    private func downloadUserChannels() {
        FirebaseChannelListener.shared.downloadUserChannelFromFirebase { (allChannels) in
            self.myChannels = allChannels
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - Table view data source
    
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myChannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MY_CHANNEL_CELL, for: indexPath) as! ChannelTableViewCell
        cell.configure(channel: myChannels[indexPath.row])
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //show channel view
        performSegue(withIdentifier: MY_CHANNEL_TO_ADD_CHANNEL_SEGUE, sender: myChannels[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FirebaseChannelListener.shared.deleteChannel(myChannels[indexPath.row])
            myChannels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MY_CHANNEL_TO_ADD_CHANNEL_SEGUE {
            let editChannelView = segue.destination as! AddChannelTableViewController
            editChannelView.channelToEdit = sender as? Channel
        }
    }
}
