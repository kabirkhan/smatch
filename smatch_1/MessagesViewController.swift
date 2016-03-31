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
    private func addMessage(id: String, text: String, displayName: String) {
        print(senderDisplayName)
        let message = JSQMessage(senderId: id, displayName: displayName, text: text)
        messages.append(message)
    }
    
    private func observeMessages() {
         getAvatars()
        let messagesQuery = messageRef.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            let displayName = snapshot.value["senderDisplayName"] as! String
            
            self.addMessage(id, text: text, displayName: displayName)

            self.finishReceivingMessage()
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        switch message.senderId {
        case NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String:
            return CGFloat(0)
        default:
            return CGFloat(20)
        }
    }
    
    //get the display name
    override func collectionView(collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        switch message.senderId {
        case NSUserDefaults.standardUserDefaults().valueForKey(KEY_ID) as! String:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
            
        }
    }
    
    //MARK: -Get Avatars
    private func getAvatars() {
        attendeesRef = Firebase(url: "https://smatchfirstdraft.firebaseio.com/events/\(eventId!)/attendees")
        attendeesRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let attendeesIdList = snapshot.value as! [String]
            
            for attendee in attendeesIdList  {
                let facebookId = attendee.substringFromIndex(attendee.startIndex.advancedBy(9))
                
                let userID = NSString(string: facebookId)
                let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
                if let data = NSData(contentsOfURL: facebookProfileUrl!) {
                    self.avatars[attendee] = data
                }
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
       let message = self.messages[indexPath.item]
        
        if let data = avatars[message.senderId] {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: data)!, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault));
        }
        
        return nil
    }
    
    //MARK: -Factory
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleGreenColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    //MARK: -Actions
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [ // 2
            "text": text,
            "senderId": senderId,
            "senderDisplayName": senderDisplayName
        ]
        itemRef.setValue(messageItem)
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        
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
