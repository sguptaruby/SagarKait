//
//  FriendListViewController.swift
//  Kait
//
//  Created by Apple on 25/03/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import UIKit

class FriendListViewController: UIViewController {
    
    @IBOutlet weak var tblFriendList:UITableView!
    @IBOutlet weak var onlineToggle:UISwitch!
    @IBOutlet weak var segment:UISegmentedControl!
    let viewModal = FriendListViewModal()
    var friendList: FriendList?
    var webChatUsers:WebChatUsers?
    var refreshControl = UIRefreshControl()
    let viewModal1 = ChatViewModal()
    var gameTimer: Timer?
    var arrActiveUser = [FriendList.Data]()
    var webChatActiveUser = [WebChatUsers.Data]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        defaultInitialization()
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gameTimer?.invalidate()
    }
    
    
    func defaultInitialization() {
        tblFriendList.register(UINib(nibName: "FriendListTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendListTableViewCell")
        tblFriendList.delegate = self
        tblFriendList.dataSource = self
        tblFriendList.tableFooterView = UIView(frame: CGRect.zero)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tblFriendList.addSubview(refreshControl)
        
       // onlineToggle.onTintColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showNavigationBar()
        self.hideBackButton()
        self.navigationItem.title = "Chats"
        self.tabBarController?.tabBar.isHidden = true
        onlineToggle.setOn(Helpers.getUserOnline(), animated: true)
         gameTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true)
        refresh(UIButton())
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        
//        if AppManager.share.selectedIndex == 0 {
//            //allAPICall()
//            webChatUsersApiCall()
//        }else{
//           // webChatUsersApiCall()
//        }
        allAPICall()
    }
    
    
    private func webChatUsersApiCall() {
        
        //self.view.showHUD()
        
        let url = URL(string: "\(Constants.API.baseURL)hil/get/active-conversations?bot_ids=WEBCHAT-\(AppManager.share.user.botId.wEBCHAT)")!
        
        
        let session = URLSession.shared
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //        do {
        //            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        //        } catch let error {
        //            print(error.localizedDescription)
        //        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("JWT \(AppManager.share.user.userToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                self.view.hideHUD()
                self.refreshControl.endRefreshing()
            }
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
//            let str = String(decoding: data, as: UTF8.self)
//            print(str)
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    self.friendList = FriendList(json: json)
                    if self.friendList == nil {
                        DispatchQueue.main.async {
                            self.showAlert(title: AlertTitle, message: "Data is not available.") {
                            }
                            
                        }
                        return
                    }
                    self.arrActiveUser = self.friendList!.data.filter{$0.isAgentAssigned == true} as [FriendList.Data]
                    DispatchQueue.main.async {
                        //print(self.arrActiveUser.count)
                        self.tblFriendList.reloadData()
                    }
                    DispatchQueue.main.async {
                        self.tblFriendList.reloadData()
                    }
                    
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.showAlert(title: AlertTitle, message: error.localizedDescription) {
                        
                    }
                }
                
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    @IBAction func btnOnlineToggle(sender:UISwitch) {
        
        let isOnline = onlineToggle.isOn
        var isTrue = ""
        if isOnline {
            isTrue = "true"
            Helpers.saveUserOnline(isOnline: true)
        }else{
            Helpers.saveUserOnline(isOnline: false)
            isTrue = "false"
        }
        viewModal.userOnline(view: view, isOnline: isTrue) { (data, error) in
            if let dict = data {
                print(dict)
            }else{
                self.showAlert(title: AlertTitle, message: error.debugDescription) {
                    
                }
            }
        }
    }
    
    
}

extension FriendListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let utterance = self.arrActiveUser[indexPath.row].utterance {
            let strType = utterance.bOTREQUEST.channel
            if #available(iOS 13.0, *) {
                let vc = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
                vc.data = self.arrActiveUser[indexPath.row]
                vc.type = strType
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let mainStroyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStroyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc.data = self.arrActiveUser[indexPath.row]
                vc.type = strType
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
//        if AppManager.share.selectedIndex == 0 {
//            //strType = "TWITTER"
//            strType = "WEBCHAT"
//        }else{
//            strType = "WEBCHAT"
//        }
        
    }
}

extension FriendListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrActiveUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListTableViewCell") as! FriendListTableViewCell
        cell.lblLineView.backgroundColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
        if  self.arrActiveUser.count != 0 {
            if let user = self.arrActiveUser[indexPath.row].chatbotUser {
                cell.lblName.text = user.name
            }else if let utterance = self.arrActiveUser[indexPath.row].utterance {
                cell.lblName.text = utterance.bOTREQUEST.userId
            }else{
                cell.lblName.text = ""
            }
            if let utterance = self.arrActiveUser[indexPath.row].utterance {
                cell.lblLastMessage.text = utterance.bOTREQUEST.text
            }else{
                cell.lblLastMessage.text = ""
            }
            cell.lblTime.text = String().getDateFromTimeStamp(timeStamp: self.arrActiveUser[indexPath.row].createdAt)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
// API calling funcations
extension FriendListViewController {
    
    func allAPICall() {
        var id = ""
        if AppManager.share.user.botId.tWITTER != "" {
            id = "TWITTER-\(AppManager.share.user.botId.tWITTER)"
        }
        if AppManager.share.user.botId.wEBCHAT != "" {
            id.append(",WEBCHAT-\(AppManager.share.user.botId.wEBCHAT)")
        }
        if AppManager.share.user.botId.WHATSAPP != "" {
            id.append(",WHATSAPP-\(AppManager.share.user.botId.WHATSAPP)")
        }
        viewModal.userID =  id
        //self.view.showHUD()
        viewModal.allApi { (code, data, error) in
            DispatchQueue.main.async {
                self.view.hideHUD()
                self.refreshControl.endRefreshing()
            }
            if let dict = data {
                self.friendList = FriendList(json: dict)
                if self.friendList == nil {
                    self.showAlert(title: AlertTitle, message: "Data is not available.") {
                    }
                    return
                }
                self.arrActiveUser = self.friendList!.data.filter{$0.isAgentAssigned == true} as [FriendList.Data]
                DispatchQueue.main.async {
                    //print(self.arrActiveUser.count)
                    self.tblFriendList.reloadData()
                }
            }else{
                self.showAlert(title: AlertTitle, message: error?.desc ?? error.debugDescription) {
                    
                }
            }
        }
    }
    
}
