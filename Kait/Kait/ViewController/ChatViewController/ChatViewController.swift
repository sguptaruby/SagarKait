//
//  ChatViewController.swift
//  Kait
//
//  Created by Apple on 26/03/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import UIKit
import Starscream
import IQKeyboardManagerSwift

var hasSafeArea: Bool {
    guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
        return false
    }
    return true
}

class ChatViewController: UIViewController {
    
    @IBOutlet weak var chattableView:UITableView!
    @IBOutlet weak var txtChatView:UITextView!
    @IBOutlet weak var btnSend:UIButton!
    @IBOutlet weak var textViewHeight:NSLayoutConstraint!
    @IBOutlet weak var textViewBottom:NSLayoutConstraint!
    @IBOutlet weak var tblYAxis:NSLayoutConstraint!
    let viewModal = ChatViewModal()
    var data:FriendList.Data!
    var chatHistroy: ChatHistory!
    var arrChat = [Chat]()
    let urlSession = URLSession(configuration: .default)
    var socket:WebSocket!
    var type:String!
    var placeHolderMessage = "Write your message here..."
    var isKeyBoardOpen = false
    private var firstLaunch : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        defaultInitialization()
        //chatHistoryAPICall()
        //self.friendApiCall()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.friendApiCall()
        chatHistoryAPICall()
        self.tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
        UserDefaults.standard.set(false, forKey: "HasAtLeastLaunchedOnce")
        UserDefaults.standard.synchronize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    func defaultInitialization() {
        
        btnSend.backgroundColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
        btnSend.layer.cornerRadius = btnSend.frame.height/2
        btnSend.layer.masksToBounds = true
        chattableView.register(UINib(nibName: "SenderTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderTableViewCell")
        chattableView.register(UINib(nibName: "ReciverTableViewCell", bundle: nil), forCellReuseIdentifier: "ReciverTableViewCell")
        chattableView.delegate = self
        chattableView.dataSource = self
        chattableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let btnChatBot = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btnChatBot.setImage(UIImage(named: "backtobot"), for: .normal)
        btnChatBot.addTarget(self, action: #selector(unassignConversation), for: .touchUpInside)
        let barRightButton = UIBarButtonItem(customView: btnChatBot)
        self.navigationItem.rightBarButtonItem = barRightButton
        
        txtChatView.layer.cornerRadius = txtChatView.frame.height/2
        txtChatView.layer.borderWidth = 1
        txtChatView.layer.borderColor = UIColor.lightGray.cgColor
        txtChatView.delegate = self
        txtChatView.text = placeHolderMessage
        txtChatView.textColor = UIColor.lightGray
        if #available(iOS 13.0, *) {
            txtChatView.textColor = UIColor.label
        } else {
            txtChatView.textColor = UIColor.lightGray
        }
    
        let strUtl = "\(Constants.API.socketURL)ws/hil/\(AppManager.share.user.restaurantRecordId)/\(AppManager.share.user.userId)/"
        
        
        guard let url = URL(string: strUtl) else {
            fatalError("invailid url")
        }
        self.initWebSocket(url: url)
       
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        
        
        if isKeyBoardOpen {
            return
        }
        isKeyBoardOpen = true
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            chattableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+80, right: 0)
           // print(keyboardSize)
            if hasSafeArea {
                if UIApplication.isFirstLaunch() {
                    self.textViewBottom.constant = keyboardSize.height+50
                }else{
                    self.textViewBottom.constant = keyboardSize.height
                }
               
            }else{
                if UIApplication.isFirstLaunch() {
                    self.textViewBottom.constant = keyboardSize.height+50
                }else{
                    self.textViewBottom.constant = keyboardSize.height
                }
            }
            UIView.animate(withDuration: 0.0) {
               self.view.layoutIfNeeded()
            }
        }
        if self.arrChat.count == 0 {
            return
        }
        chattableView.scrollToRow(at: IndexPath(item:self.arrChat.count-1, section: 0), at: .top, animated: true)
        chattableView.scrollIndicatorInsets = chattableView.contentInset
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.textViewBottom.constant = 10
        isKeyBoardOpen = false
        chattableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.chattableView.scrollToRow(at: IndexPath(item:self.arrChat.count-1, section: 0), at: .bottom, animated: false)
    }
    
    func initWebSocket(url:URL) {
        var request = URLRequest(url:url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
    }
    
    func reloadData(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.arrChat.count > 0 {
                self.chattableView.reloadData()
                self.chattableView.scrollToRow(at: IndexPath(item:self.arrChat.count-1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    
    @IBAction func btnSendAction(senser:UIButton) {
        if txtChatView.text == placeHolderMessage || txtChatView.text == "" {
            return
        }
        sendMessageApiCall(text: txtChatView.text)
    }
    
    private func sendMessageApiCall(text:String) {
        let dict = ["channel":type!,
                    "bot_id":data.utterance?.bOTREQUEST.botId ?? "",
                    "user_id":data.utterance?.bOTREQUEST.userId ?? "",
                    "data":["type_of_request":"actions",
                            "action":"send_text_response",
                            "text":text]
            ] as [String : Any]
        viewModal.senc_dict = dict
        viewModal.sendMessage { (code, data, error) in
            if let dict = data {
                print(dict)
                let timeStamp = Date.currentTimeStamp
                let chat = Chat(type: "_BOT_RESPONSE_", text: text, created_at: Int(timeStamp), inline_buttons: [])
                self.arrChat.append(chat)
                DispatchQueue.main.async {
                    self.textViewHeight.constant = 50
                    self.chattableView.reloadData()
                   // self.updateLastRow()
                 // self.scrollToBottom(animated: true)
                    self.chattableView.scrollToRow(at: IndexPath(item:self.arrChat.count-1, section: 0), at: .bottom, animated: false)
                }
                self.txtChatView.text = ""
            }else{
                self.showAlert(title: AlertTitle, message: error.debugDescription) {
                    
                }
            }
        }
    }
    
    
    @objc private func unassignConversation() {
        let dict = [
            "type": "request",
            "restaurant_id": AppManager.share.user.restaurantRecordId,
            "channel": type!,
            "bot_id": data.utterance?.bOTREQUEST.botId ?? "",
            "user_id": data.utterance?.bOTREQUEST.userId ?? "",
            "is_assigned": "false",
            "data": [
                "type_of_request": "actions",
                "action": "intimate_agent_assignment",
                "is_assigned": false
            ],
            "bot_request": [
                "text": "",
                "channel": type!,
                "bot_id": data.utterance?.bOTREQUEST.botId ?? "",
                "user_id": data.utterance?.bOTREQUEST.userId ?? ""
                ] as JSONDictionary
            ] as JSONDictionary
        viewModal.unassignConversation(dict: dict) { (code, dict, error) in
            if let jsonDict = dict {
                print(jsonDict)
                DispatchQueue.main.async {
                    self.showAlert(title: AlertTitle, message: "Chat assign back to bot.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.showAlert(title: AlertTitle, message: error.debugDescription) {
                        
                    }
                }
                
            }
        }
    }
    
    
    /// modify chat json data
    private func manageDataChatData() {
        let data = self.chatHistroy.data
        for item in data {
            if item.utteranceType == "_BOT_REQUEST_" {
                if let utterance = item.utterance {
                    if let text = utterance.bOTREQUEST!.text {
                        let chat = Chat(type: item.utteranceType, text: text, created_at: item.createdAt, inline_buttons: [])
                        arrChat.append(chat)
                    }
                }
                
            }else{
                //var inline_buttons = [String]()
                if let utterance = item.utterance {
                    if let reponse = utterance.bOTRESPONSE {
                        
                        for item1 in reponse {
                            if let inline = item1.quickReplies {
                                let inline_buttons = inline.inlineButtons!.map({ $0.title})
                                let chat = Chat(type: item.utteranceType, text: inline.headerText, created_at: item.createdAt, inline_buttons: inline_buttons)
                                arrChat.append(chat)
                            }else{
                                if let texts = item1.texts {
                                    for text in texts {
                                        let chat = Chat(type: item.utteranceType, text: text, created_at: item.createdAt, inline_buttons: [])
                                        arrChat.append(chat)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        //        DispatchQueue.main.async {
        //            //self.chattableView.reloadData()
        //
        //        }
        self.reloadData()
    }
    
    
    
    /// Chat history api call
    func chatHistoryAPICall() {
        viewModal.bot_id = data.utterance?.bOTREQUEST.botId//"1136230203775041539"
        viewModal.user_id = data.utterance?.bOTREQUEST.userId//"1250312192190107649"
        viewModal.type = type
        self.view.showHUD()
        viewModal.getChatHistory { (code, data, error) in
            self.view.hideHUD()
            
            if let dict = data {
                print(dict)
                self.chatHistroy = ChatHistory(json: dict)
                if self.chatHistroy != nil {
                    self.manageDataChatData()
                }
            }else{
                self.showAlert(title: AlertTitle, message: error?.desc ?? error.debugDescription) {
                    
                }
            }
        }
    }
    
    /// modify socket json data
    /// - Parameter text: message coming from server
    private func manageSocketChatData(text:String) {
        if let data = text.data(using: .utf8) {
            if let chat = try? JSONDecoder().decode(SocketChatModal.self, from: data) {
                if chat.message.type == "response" {
                    print(chat.message.type)
                    self.responseUser(text: text)
                }else if chat.message.type == "request"{
                    print(chat.message.type)
                    self.requestUser(text: text)
                }else{
                    
                }
            }
        }
    }
    
    private func responseUser(text:String) {
        let timestamp = Date().timeIntervalSince1970
        if let data = convertToDictionary(text: text) {
            if let message = data["message"] as? [String:Any] {
                if let data = message["data"] as? [String:Any] {
                    if let quick_replies = data["quick_replies"] as? [String:Any] {
                        let strMessage = quick_replies["header_text"] as! String
                        var lineButton = [String]()
                        if let inline_buttons = quick_replies["inline_buttons"] as? [[String:Any]] {
                            for dict in inline_buttons {
                                let name = dict["title"] as? String ?? ""
                                lineButton.append(name)
                            }
                        }
                        let chat = Chat(type: "_BOT_RESPONSE_", text: strMessage, created_at: Int(timestamp), inline_buttons: lineButton)
                        arrChat.append(chat)
                        reloadData()
                        //                        DispatchQueue.main.async {
                        //                            self.chattableView.reloadData()
                        //                        }
                    }
                }
            }
        }
    }
    
    private func requestUser(text:String) {
        let timestamp = Date().timeIntervalSince1970
        if let data = convertToDictionary(text: text) {
            if let message = data["message"] as? [String:Any] {
                if let data = message["data"] as? [String:Any] {
                    //print(data)
                    let strMessage = data["text"] as! String
                    let chat = Chat(type: "_BOT_REQUEST_", text: strMessage, created_at: Int(timestamp), inline_buttons: [])
                    arrChat.append(chat)
                    reloadData()
                    //                    DispatchQueue.main.async {
                    //                        self.chattableView.reloadData()
                    //                    }
                }
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let textViewFixedWidth: CGFloat = self.txtChatView.frame.size.width
        let _: CGSize = self.txtChatView.sizeThatFits(CGSize(width: textViewFixedWidth, height: CGFloat(MAXFLOAT)))
        let newFrame: CGRect = self.txtChatView.frame
        
        
        if txtChatView.numberOfLine() > 2 {
            textViewHeight.constant = 100
        }else{
            textViewHeight.constant = 50
        }
        //var textViewYPosition = self.txtChatView.frame.origin.y
//        let heightDifference = self.txtChatView.frame.height - newSize.height
//        if (abs(heightDifference) > 5) {
//            newFrame.size = CGSize(width: fmax(newSize.width, textViewFixedWidth), height: newSize.height)
//            updateParentView(heightDifference: heightDifference)
//        }
        
        self.txtChatView.frame = newFrame
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewHeight.constant = 50
        txtChatView.resignFirstResponder()
        if txtChatView.text.isEmpty {
            txtChatView.text = placeHolderMessage
            if #available(iOS 13.0, *) {
                txtChatView.textColor = UIColor.label
            } else {
                txtChatView.textColor = UIColor.lightGray
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        var color:UIColor
        if #available(iOS 13.0, *) {
            color = UIColor.label
        } else {
            color = UIColor.lightGray
        }
        
        if txtChatView.textColor == color {
            txtChatView.text = nil
            if #available(iOS 13.0, *) {
                txtChatView.textColor = UIColor.label
            } else {
                txtChatView.textColor = UIColor.black
            }
            
        }
    }
    
    func updateParentView(heightDifference: CGFloat) {
        //
        var newContainerViewFrame: CGRect = self.chattableView.frame
        //
        let containerViewHeight = self.chattableView.frame.size.height
        print("container view height: \(containerViewHeight)\n")
        //
        let newContainerViewHeight = containerViewHeight + heightDifference
        print("new container view height: \(newContainerViewHeight)\n")
        //
        let containerViewHeightDifference = containerViewHeight - newContainerViewHeight
        print("container view height difference: \(containerViewHeightDifference)\n")
        //
        newContainerViewFrame.size = CGSize(width: self.chattableView.frame.size.width, height: newContainerViewHeight)
        //
        //newContainerViewFrame.origin.y - containerViewHeightDifference
        //
        self.chattableView.frame = newContainerViewFrame
    }
    
    
    
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SenderTableViewCell") as! SenderTableViewCell
        cell.selectionStyle = .none
        let cellReciver = tableView.dequeueReusableCell(withIdentifier: "ReciverTableViewCell") as! ReciverTableViewCell
        cellReciver.selectionStyle = .none
        if self.arrChat.count != 0 {
            if self.arrChat[indexPath.row].type == "_BOT_REQUEST_" {
                cell.lblMessage.text = self.arrChat[indexPath.row].text
                cell.lblDate.text = String().getDateFromTimeStamp(timeStamp: self.arrChat[indexPath.row].created_at)
                cell.lblDate.textColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
                cell.lblMessage.textColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
                // cell.lblMOM.text = self.arrChat[indexPath.row].inline_buttons.joined(separator: "/ ")
                return cell
            }else{
                
                cellReciver.lblMessage.text = self.arrChat[indexPath.row].text
                cellReciver.lblDate.text = String().getDateFromTimeStamp(timeStamp: self.arrChat[indexPath.row].created_at)
                cellReciver.lblMOM.text = self.arrChat[indexPath.row].inline_buttons.joined(separator: "/ ")
                return cellReciver
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0)
        if indexPath.row == lastRowIndex - 1 {
            tableView.sizeToFit()
            self.scrollToBottom(animated: true)
        }
    }
    
    func scrollToBottom(animated: Bool) {
        if chattableView.contentSize.height < chattableView.bounds.size.height { return }
        if isKeyBoardOpen {
            let bottomOffset = CGPoint(x: 0, y: chattableView.contentSize.height - chattableView.bounds.size.height)
            chattableView.setContentOffset(bottomOffset, animated: animated)
        }else{
            let bottomOffset = CGPoint(x: 0, y: chattableView.contentSize.height - chattableView.bounds.size.height)
            chattableView.setContentOffset(bottomOffset, animated: animated)
        }
    }
    
}

extension UITextView {
    
    
    
    func sizeFit(width: CGFloat) -> CGSize {
        let fixedWidth = width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: fixedWidth, height: newSize.height)
    }
    
    func numberOfLine() -> Int {
        let size = self.sizeFit(width: self.bounds.width)
        let numLines = Int(size.height / (self.font?.lineHeight ?? 1.0))
        return numLines
    }
    
}


extension ChatViewController:WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("SocketDidConnect:\(socket.isConnected)")
        //        let strData = """
        //{
        //  "message": {
        //    "channel": "TWITTER",
        //    "bot_id": "1136230203775041539",
        //    "user_id": "780340738890629121",
        //    "data": {
        //      "user_id": "780340738890629121",
        //      "channel": "TWITTER",
        //      "quick_replies": {
        //        "header_text": "Please select one of our branches",
        //        "inline_buttons": [
        //          {
        //            "title": "Adailiya",
        //            "payload": "_*2",
        //            "type": "inline_button"
        //          },
        //          {
        //            "title": "Qortuba",
        //            "payload": "_*4",
        //            "type": "inline_button"
        //          }
        //        ]
        //      },
        //      "bot_id": "1136230203775041539"
        //    },
        //    "is_agent_assigned": false,
        //    "type": "response",
        //    "agent_id": null
        //  },
        //  "type": "send_message_to_client"
        //}
        //"""
        //
        //        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
        //            self.manageSocketChatData(text: strData)
        //        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        //
        //        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("SocketDidDisConnect:\(String(describing: error.debugDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("ReceiveMessage:\(text)")
        self.manageSocketChatData(text: text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("ReceiveData:\(data)")
    }
     
    
}

