//
//  MessagesViewController.swift
//  smatch_1
//
//  Created by Nicholas Solow-Collins on 3/29/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {
    var eventId :String?
    
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, NSData>()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var messageRef: Firebase!
    var attendeesRef: Firebase!

    override func viewDidLoad() {
        self.tabBarController?.tabBar.hidden = true
        
        super.viewDidLoad()
        //load messages here probably
        print("hello event: \(eventId)")
        setupBubbles()
        
//        // No avatars (Remove this)
//        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
//        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        messageRef = Firebase(url: "https://smatchfirstdraft.firebaseio.com/events/\(eventId!)/messages")
        attendeesRef = Firebase(url: "https://smatchfirstdraft.firebaseio.com/events/\(eventId!)/attendees")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.hidden = false
    }

    //MARK: - Messaging Methods
    private func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    private func observeMessages() {
        getAvatars()
        let messagesQuery = messageRef.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            
            self.addMessage(id, text: text)

            self.finishReceivingMessage()
        }
    }
    
    //MARK: -Get Avatars
    private func getAvatars() {
        attendeesRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let attendeesIdList = snapshot as! [String]
            
            for i in 0..<attendeesIdList.count {
                
            }
        
        }, withCancelBlock: { error in
            
        })
    }
    
    //MARK: - JSQMessagesViewControllerDelegate Functions
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    //MARK: - Methods for JSQMessagesViewControllerDataSource
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    //removes avatar support, probably want to override this
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
       return nil
    }
    
    //MARK: -Factory
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    //MARK: -Actions
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "text": text,
            "senderId": senderId
        ]
        itemRef.setValue(messageItem) // 3
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
