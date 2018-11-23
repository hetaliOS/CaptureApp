//
//  SearchCaptureViewController.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/20/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit

class SearchCaptureViewController: BaseViewController {

    //MARK:- OUTLET
    @IBOutlet weak var collectionView: HomeCollectionview!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK:- PROPERTIES
    var arrCapturedImages : [CaptureModel] = []
    
    //MARK:- VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.isComeFromSearch = true
        self.collectionView.reloadData()
        arrCapturedImages = CaptureDatabaseManager.shared.getCapturedImages()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchBar.delegate = self
        
        makeSearchBArCancelButtonHighlighted()
        collectionViewBlock()
    }
    
    //MARK:- COLLECTION BLOCK
    func collectionViewBlock(){
        //Collectionview selected cell
        collectionView.blockSelectedItemCollection = {[weak self](indexPath)in
            let vc = PreviewCaptureViewController.loadController()
            vc.selectedImageIndex = indexPath.row
            vc.arrCaptureImages = self!.collectionView.arrCapturedImages
            let navViewController: UINavigationController = UINavigationController(rootViewController: vc)
            self?.present(navViewController, animated: true, completion: nil)
            // self!.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:- MAKE SEARCHBAR CANCEL BUTTON HEIGHLIGHTED
    func makeSearchBArCancelButtonHighlighted(){
        searchBar.resignFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton{
            cancelButton.isEnabled = true
        }
    }
}
extension SearchCaptureViewController: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        makeSearchBArCancelButtonHighlighted()
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        self.collectionView.arrCapturedImages.removeAll()
        self.collectionView.reloadData()
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        makeSearchBArCancelButtonHighlighted()
        
        let result = arrCapturedImages.filter{(captures)in
            let tagArray = captures.tag.components(separatedBy: ",").map{$0.lowercased().trimWhiteSpace()}
            print(tagArray)
            let searchArray = searchBar.text?.components(separatedBy: ",").map{$0.lowercased().trimWhiteSpace()}
            let listSet = NSSet(array: tagArray)
            let findListSet = NSSet(array: searchArray!)
            return findListSet.isSubset(of: listSet as! Set<AnyHashable>)
        }
        guard  result.count == 0  else {
            collectionView.arrCapturedImages = result.map{$0.imageBase64.convertToImage()}
            collectionView.reloadData()
            return
        }
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            self.collectionView.arrCapturedImages.removeAll()
            self.collectionView.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //  let strinCharecter = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "
        guard range.location == 0 else {
            return true
        }
        
        let newString = (searchBar.text! as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: .whitespaces).location != 0
        
    }
}
