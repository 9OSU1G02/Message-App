//
//  ChannelTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/28/20.
//

import UIKit

class ChannelTableViewController: UITableViewController {

    // MARK: - Properties
    var allChannels: [Channel] = []
    var subscribedChannels: [Channel] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Channel"
        tableView.tableFooterView = UIView()
        downloadSubscribedChannel()
        downloadAllChannels()
        tableView.refreshControl = UIRefreshControl()
    }
    
    // MARK: - IBActions
    
    @IBAction func channelSegmentValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHANNEL,for: indexPath) as! ChannelTableViewCell
        let channel = channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        cell.configure(channel: channel)
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if user choose subscribed channel -- selectedSegmentIndex == 0
        return channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //If user in all channel segment
        if channelSegmentOutlet.selectedSegmentIndex == 1 {
            //show about channel
            showAboutChannelView(channel: allChannels[indexPath.row])
        }
        else {
            // show channel chat view
            showChat(channel: subscribedChannels[indexPath.row])
        }
    }
    
    //we only CAN swipe left to unfollow channel that we subscribed and NOT admin in Subscribed Channel segment
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if channelSegmentOutlet.selectedSegmentIndex == 0 {
            return subscribedChannels[indexPath.row].adminId != User.currentId
        }
        else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var channelToUnfollow = subscribedChannels[indexPath.row]
            //Remove current user id from memberIds of channel we want to unfllow then save channel to firebase
            if let index = channelToUnfollow.memberIds.firstIndex(of: User.currentId) {
                channelToUnfollow.memberIds.remove(at: index) }
            subscribedChannels.remove(at: indexPath.row)
            FirebaseChannelListener.shared.saveChannel(channelToUnfollow)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Download Channels
    private func downloadAllChannels() {
        FirebaseChannelListener.shared.downloadAllChannelFromFirebase { (allChannels) in
            self.allChannels = allChannels
            if self.channelSegmentOutlet.selectedSegmentIndex == 1 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func downloadSubscribedChannel() {
        FirebaseChannelListener.shared.downloadSubscribedChannelFromFirebase { (subscribedChannels) in
            self.subscribedChannels = subscribedChannels
            if self.channelSegmentOutlet.selectedSegmentIndex == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    // MARK: - UISconcrollView Delegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl!.isRefreshing {
            self.downloadAllChannels()
            self.refreshControl!.endRefreshing()
        }
    }
    
    // MARK: - Navigation
    private func showAboutChannelView(channel: Channel) {
        let channelVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: ABOUT_CHANNEL_VIEW_STORYBOARD_ID) as! AboutChannelTableViewController
        channelVC.channel = channel
        channelVC.delegate = self
        navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showChat(channel: Channel) {
        let channelChatVC = ChannelChatViewController(channel: channel)
        channelChatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(channelChatVC, animated: true)
    }
}

// MARK: - Extension

extension ChannelTableViewController: AboutChannelTableViewControllerDelegate {
    func didClickFollow() {
        self.downloadAllChannels()
    }
}
