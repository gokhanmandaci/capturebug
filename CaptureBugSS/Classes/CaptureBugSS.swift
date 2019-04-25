//
//  LogMeBugMainVC.swift
//  faceitforme
//
//  Created by Gökhan Mandacı on 20/03/2017.
//  Copyright © 2017 gokhanmandaci. All rights reserved.
//

import UIKit
import MessageUI
import CoreMotion

public class CaptureBugSS: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    // MARK: Properties
    /// Reporter names, developers
    let reporters = ["Gökhan Mandacı", "Cemal Bayri", "Tuğşad Aydın", "Yiğit Yalnızça"]
    /// Reporter emails
    let reporterEmails = ["gokhan.mandaci@elektronet.com.tr", "cemal.bayri@elektronet.com.tr", "tugsad.aydin@elektronet.com.tr", "yigit@elektronet.com.tr"]
    /// Swipe status
    var swiped = false
    /// Last point touched
    var lastPoint = CGPoint.zero
    /// Width of lines drawn
    var brushWidth: CGFloat = 10.0
    /// Opacity of lines
    var opacity: CGFloat = 1.0
    
    
    @IBOutlet weak var imgBug: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var vwReport: UIView!
    @IBOutlet weak var vwDescription: UIView!
    @IBOutlet weak var vwReporter: UIView!
    @IBOutlet weak var txtvDescription: UITextView!
    @IBOutlet weak var tbvReporter: UITableView!
    
    // MARK: Actions
    /**
     Closes the LogMeBug view controller.
     
     - Parameter sender: Cancel button.
     
     - Returns: None.
     */
    @IBAction func btnCancelAction(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Merges temp image and main image. Clears temp image and shows report popup.
     
     - Parameter sender: Report button.
     
     - Returns: None.
     */
    @IBAction func btnReportAction(_ sender: Any) {
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(imgBug.frame.size)
        imgBug.image?.draw(in: CGRect(x: 0, y: 0, width: imgBug.frame.size.width, height: imgBug.frame.size.height), blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height), blendMode: .normal, alpha: opacity)
        imgBug.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
        vwDescription.isHidden = false
        vwReporter.isHidden = true
        showViewWithAnimation(vwReport)
        txtvDescription.becomeFirstResponder()
    }
    
    /**
     Cleans temp image.
     
     - Parameter sender: Clean button
     
     - Returns: None.
     */
    @IBAction func btnCleanAction(_ sender: Any) {
        tempImageView.image = nil
    }
    
    /**
     Closes report view.
     
     - Parameter sender: Close button
     
     - Returns: None.
     */
    @IBAction func btnCloseReportViewAction(_ sender: Any) {
        hideViewWithAnimation(vwReport)
        view.endEditing(true)
    }
    
    /**
     Hides description view and shows reporter selection view.
     
     - Parameter sender: Clean button
     
     - Returns: None.
     */
    @IBAction func btnGoOnAction(_ sender: Any) {
        hideViewWithAnimation(vwDescription)
        showViewWithAnimation(vwReporter)
        view.endEditing(true)
    }

    // MARK: Class Functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        tbvReporter.delegate = self
        imgBug.image = ssImage
        self.becomeFirstResponder()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        vwReport.isHidden = true
        view.endEditing(true)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    /**
     Draws a line between two points.
     
     - Parameter fromPoint: Line's starting point
     - Parameter toPoint: Line's ending point
     
     - Returns: None.
     */
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setBlendMode(CGBlendMode.normal)
        context!.strokePath()
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reporters.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tbvReporter.dequeueReusableCell(withIdentifier: "reporterReuseId") as UITableViewCell!
        cell.textLabel?.text = reporters[indexPath.row]
        return cell
    }
    
    var reporterEmail = ""
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reporterEmail = reporterEmails[indexPath.row]
        let mailComposeViewController = configuredMailComposeViewController(imgBug.image!)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController(_ image: UIImage) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([reporterEmail])
        mailComposerVC.setSubject("Hata Bildirimi")
        mailComposerVC.setMessageBody(txtvDescription.text, isHTML: false)
        let imageData: Data = UIImagePNGRepresentation(image)! as Data
        mailComposerVC.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        print("error")
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }

}

var ssImage: UIImage?

/**
 Takes screenshot, all screen.
 
 - Returns: None.
 */
func captureScreen() {
    UIGraphicsBeginImageContext((UIApplication.shared.keyWindow?.frame.size)!)
    UIApplication.shared.keyWindow?.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    ssImage = image
    let storyboard = UIStoryboard(name: "CaptureBugSS", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "capturebugsstrid") as UIViewController
    UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
}

/**
 Shows a hidden view with basic animation
 
 - Parameter view: A view to be shown
 
 ### Usage Example: ###
 ````
 showViewWithAnimation(view)
 ````
 
 - Returns: None.
 */
func showViewWithAnimation(_ view: UIView){
    UIView.transition(with: view, duration: 0.33, options: .transitionCrossDissolve, animations: {
        view.isHidden = false
    }, completion: nil)
    
}

/**
 Hides a visible view with basic animation
 
 - Parameter view: A view to be hidden
 
 ### Usage Example: ###
 ````
 hideViewWithAnimation(view)
 ````
 
 - Returns: None.
 */
func hideViewWithAnimation(_ view: UIView) {
    UIView.transition(with: view, duration: 0.33, options: .transitionCrossDissolve, animations: {
        view.isHidden = true
    }, completion: nil)
}
