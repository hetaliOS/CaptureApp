//
//  BaseViewController.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit
//TODO: VC TITLE TYPE
enum TitleType: String {
    case
    Captures,
    SearchCaptures,
    PreviewCaptures,
    none
    
    
    var titleName: String {
        switch self {
        case .Captures:
            return "Captures"
        case .SearchCaptures:
            return "Search Captures"
        case .PreviewCaptures:
            return "Preview Captures"
        case .none:
            return ""
        }
    }
}
//MARK:- LEFTBAR BUTTON TYPE
enum LeftBarButtonType: Int {
    case
    backArrow,
    camera,
    close,
    none
    
    var imageName: String {
        switch self {
        case .backArrow:
            return "back"
        case .camera:
            return "camera"
        case .close:
            return "clear"
        case .none:
            return ""
        }
    }
}
//MARK:- RIGHT BUTTON TYPE
enum RightButtonType: Int {
    case
    search,
    none
    
    var imageName: String {
        switch self {
        case .search :
            return "search"
        case .none:
            return ""
        }
    }
}
class BaseViewController: UIViewController {
    
    // MARK:- PROPERTIES
    var backButtonType: LeftBarButtonType = LeftBarButtonType.backArrow
    var rightBarButtonType : RightButtonType = RightButtonType.none
    
    var shouldPreventInteractivePopGesture:Bool = false
    var shouldHideNavigationBar:Bool = false
    
    //MARK:- BLOCK
    var rightBarButtonHandler : ((UIBarButtonItem)->Void)?
    
    // MARK:- VIEW LIFE CYCLE
    override func viewDidLoad()    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        setUp()
        
    }
    
    //MARK:-
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup Base UI
        self.doSetupBaseUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = self.shouldHideNavigationBar
        //Closing Keybord On Exiting From Vc
        self.view.endEditing(true)
    }
    //MARK:-
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    //MARK:- TOUCH BEGAN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK:- SETUP
    func setUp(){
        
        self.view.backgroundColor = UIColor.white
    }
    func doSetupBaseUI() {
        //TODO: Setting Navigation
       
        self.doSetUpNavigationBar()
         self.doSetBackButtonTypeAndTitle()
        self.setLeftBackButton()
    }
    
    // Set viewcontrollers title
    private func doSetBackButtonTypeAndTitle()
    {
        switch self
        {
        case is HomeViewController:
            self.navigationItem.title = TitleType.Captures.titleName
            self.backButtonType = .camera
        case is SearchCaptureViewController:
            self.navigationItem.title = TitleType.SearchCaptures.titleName
            self.backButtonType = .backArrow
        case is PreviewCaptureViewController:
            self.navigationItem.title = TitleType.PreviewCaptures.titleName
            self.backButtonType = .close
        default:
            break
        }
    }
  
    //Set Up Navigation Bar
    func doSetUpNavigationBar(){
        
        // NavigationBar Translucent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        //Hiding Navigation Bar
        self.navigationController?.isNavigationBarHidden =
            self.shouldHideNavigationBar
        self.navigationController?.navigationBar.isHidden = self.shouldHideNavigationBar
        
    }
    // MARK:- SET BAR BUTTON ITEM
    //Set Left Bar Button
    func setLeftBackButton(){
        // Left Item Button
        if self.backButtonType == .none {
            self.navigationItem.hidesBackButton = true
        }else {
            let buttonLeftBar = UIButton(type: UIButtonType.custom) as UIButton
            buttonLeftBar.isExclusiveTouch = true
            buttonLeftBar.frame = CGRect(x: -15, y: 0, width: 25, height: 25)
            buttonLeftBar.setImage(UIImage(named: self.backButtonType.imageName), for: .normal)
            buttonLeftBar.addTarget(self, action: #selector(self.backButtonTapHandler(sender:)), for: .touchUpInside)
            let item = UIBarButtonItem(customView: buttonLeftBar)
            self.navigationItem.leftBarButtonItem = item
        }
    }
    
    //Set Right Bar Button
    func setRightBarButtons(rightBarButtons: RightButtonType, rightBarButtonClicked:((_ barButtonItem: UIBarButtonItem)->Void)?){
        
        let buttonRightBar = UIButton(type: UIButtonType.custom) as UIButton
        buttonRightBar.frame = CGRect(x: 0, y: 0, width: getProportionalWidth(width: 50), height:  getProportionalHeight(height: 50))
        buttonRightBar.setImage(UIImage(named: rightBarButtons.imageName), for: .normal)
        buttonRightBar.addTarget(self, action: #selector(self.rightBarButton_Clicked(sender:)), for: .touchUpInside)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonRightBar)
        if rightBarButtonClicked != nil {
            self.rightBarButtonHandler = rightBarButtonClicked
        }
        
    }
    
    // MARK:- BAR BUTTON HANDLERS
    @objc func backButtonTapHandler(sender:UIButton) {
        
        switch self.backButtonType {
        case .backArrow:
            _ = self.navigationController?.popViewController(animated: true)
        case .close:
            _ = self.dismiss(animated: true, completion: nil)
        case .none:
            break
        default: break
            
        }
    }
    @objc func rightBarButton_Clicked(sender : UIBarButtonItem){
        if self.rightBarButtonHandler != nil {
            self.rightBarButtonHandler!(sender)
        }
    }
}
