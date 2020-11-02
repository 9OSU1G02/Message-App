//
//  UserTableViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 10/28/20.
//

import UIKit

class UserTableViewController: UITableViewController {
    // MARK:  Properties
    var allUsers: [User] = []
    var filteredUsers: [User] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //createDummyUsers()
        // initial Refresh Control
        setupSearchController()
        downloadUsers()
        tableView.refreshControl =  UIRefreshControl()
    }
        
        // MARK: - Table view data source & delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive && searchController.searchBar.text != "" ? filteredUsers.count : allUsers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: USER_CELL, for: indexPath) as! UserTableViewCell
        let user = searchController.isActive && searchController.searchBar.text != "" ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        cell.configure(user: user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Profile View
        let user = searchController.isActive && searchController.searchBar.text != "" ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        showUserProfile(user)
    }
    // MARK:  Navigation
    func showUserProfile(_ user: User?) {
        let profileView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: PROFILE_VIEW_STORYBOARD_ID) as! UserProfileTableViewController
        profileView.user = user
        navigationController?.pushViewController(profileView, animated: true)
    }
    
    // MARK:  Download all users and reload data
    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUserFromFireBase { [weak self](allFirebaseUsers) in
            self?.allUsers = allFirebaseUsers
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK:  Setup Search Controller
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
        definesPresentationContext = true
    }
    
    /// - Parameter searchText: text form serarchBar of searchController
    private func filteredContentForSearchText(searchText: String) {
        filteredUsers = allUsers.filter({ (user) -> Bool in
            //if user have userName contains searchText -> return that user to filteredUsers
            return user.username.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    // MARK:  UIScrollViewDelegate
    //Trigger when scrolling movement comes to a halt -> Perorm Refreshing
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl!.isRefreshing {
            downloadUsers()
            refreshControl!.endRefreshing()
        }
    }
}

extension UserTableViewController: UISearchResultsUpdating {
    //Trigger everytime when we type in search bar
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
