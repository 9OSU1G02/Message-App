//
//  ChatTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/28/20.
//

import UIKit

class ChatTableViewController: UITableViewController {
    // MARK:  Properties
    var allRecents: [RecentChat] = []
    var filterRecents: [RecentChat] = []
    let searchController = UISearchController(searchResultsController: nil)
    var isRefresh = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        downloadRecentChats()
        setupSearchController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isRefresh = false
    }
    override func viewDidAppear(_ animated: Bool) {
        presentOnboardingIfNeccessary()
        downloadRecentChats()
        isRefresh = false
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If search controller is active and serarch bar have text then filteredUsers
        return searchController.isActive && searchController.searchBar.text != "" ? filterRecents.count : allRecents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RECENT_CHAT_CELL, for: indexPath) as! RecentTableViewCell
        if isRefresh {
            cell.isRefresh = isRefresh
        }
        let recent = searchController.isActive && searchController.searchBar.text != "" ? filterRecents[indexPath.row] : allRecents[indexPath.row]
        cell.configureCell(recent: recent)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Continue chat with user and go to chat room
        let recent = searchController.isActive && searchController.searchBar.text != "" ? filterRecents[indexPath.row] : allRecents[indexPath.row]
        FirebaseRecentListener.shared.clearUnreadCounter(recent: recent)
        gotoChat(recent: recent)
    }
    
    // MARK:  TableView delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // If user use search then delete row -> recent object in filterRecents
            let recent = searchController.isActive && searchController.searchBar.text != "" ? filterRecents[indexPath.row] : allRecents[indexPath.row]
            FirebaseRecentListener.shared.deleteRecent(recent)
            searchController.isActive && searchController.searchBar.text != "" ? self.filterRecents.remove(at: indexPath.row) : allRecents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    private func presentOnboardingIfNeccessary() {
        guard let user = User.currentUser, user.hasSeenOnboard == false else { return }
        let onboardingVC = OnboardingViewController()
        onboardingVC.delegate = self
        onboardingVC.modalPresentationStyle = .fullScreen
        present(onboardingVC, animated: true, completion: nil)
    }
    
    // MARK:  Navigation
    func gotoChat(recent: RecentChat) {
        //make sure we have 2 recents because (case user1 start chat but user 2 has delete recent so user 2 will not get message from user 2 ---> Create new recent for user 2)
        RestartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        let privateChatView = ChatViewController(chatRoomId: recent.chatRoomId, recepientId: recent.receiverId, recipientName: recent.receiverName)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
    
    // MARK:  Download Chats
    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatsFromFireStore {[weak self] (allRecent) in
            self?.allRecents = allRecent
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    private func setupSearchController() {
        tableView.tableFooterView = UIView()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Don't obserures background when click on searchbar
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        //delegate of Search Controller ( updateSearchResults )
        searchController.searchResultsUpdater = self
        // FIXME:  "Does matter at current time, maybe cause a bug later"
        //definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String) {
        filterRecents = allRecents.filter({(recent) -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if self.refreshControl!.isRefreshing {
            self.downloadRecentChats()
            self.refreshControl!.endRefreshing()
            self.isRefresh = true
        }
    }
}

extension ChatTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
extension ChatTableViewController: OnboardingController {
    func controllerWantToDismiss(_ controller: OnboardingViewController) {
        FirebaseUserListener.shared.updateUserHasSeenOnboardingWithFireBase(user: User.currentUser!)
        dismiss(animated: true, completion: nil)
    }
}

