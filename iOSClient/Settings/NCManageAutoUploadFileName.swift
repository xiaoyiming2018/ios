//
//  NCManageAutoUploadFileName.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 19/07/17.
//  Copyright (c) 2017 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class NCManageAutoUploadFileName: XLFormViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dateExample = Date()
    
    func initializeForm() {
        
        let form : XLFormDescriptor = XLFormDescriptor() as XLFormDescriptor
        form.rowNavigationOptions = XLFormRowNavigationOptions.stopDisableRow
        
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor

        // Section Mode filename

        section = XLFormSectionDescriptor.formSection(withTitle: NSLocalizedString("_mode_filename_", comment: ""))
        form.addFormSection(section)
        
        // Maintain the original fileName
        
        row = XLFormRowDescriptor(tag: "maintainOriginalFileName", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("_maintain_original_filename_", comment: ""))
        row.value = CCUtility.getOriginalFileName(NCGlobal.shared.keyFileNameOriginalAutoUpload)
        row.cellConfig["backgroundColor"] = NCBrandColor.shared.backgroundForm
        
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textLabel.textColor"] = NCBrandColor.shared.textView

        section.addFormRow(row)
        
        // Add File Name Type
        
        row = XLFormRowDescriptor(tag: "addFileNameType", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("_add_filenametype_", comment: ""))
        row.value = CCUtility.getFileNameType(NCGlobal.shared.keyFileNameAutoUploadType)
        row.hidden = "$\("maintainOriginalFileName") == 1"
        row.cellConfig["backgroundColor"] = NCBrandColor.shared.backgroundForm

        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textLabel.textColor"] = NCBrandColor.shared.textView

        section.addFormRow(row)
                
        // Section: Rename File Name
        
        section = XLFormSectionDescriptor.formSection(withTitle: NSLocalizedString("_filename_", comment: ""))
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "maskFileName", rowType: XLFormRowDescriptorTypeAccount, title: (NSLocalizedString("_filename_", comment: "")))
        let fileNameMask : String = CCUtility.getFileNameMask(NCGlobal.shared.keyFileNameAutoUploadMask)
        if fileNameMask.count > 0 {
            row.value = fileNameMask
        }
        row.hidden = "$\("maintainOriginalFileName") == 1"
        row.cellConfig["backgroundColor"] = NCBrandColor.shared.backgroundForm
        
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textLabel.textColor"] = NCBrandColor.shared.textView

        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textColor"] = NCBrandColor.shared.textView

        section.addFormRow(row)
        
        // Section: Preview File Name
        
        row = XLFormRowDescriptor(tag: "previewFileName", rowType: XLFormRowDescriptorTypeTextView, title: "")
        row.height = 180
        row.disabled = true
        row.cellConfig["backgroundColor"] = NCBrandColor.shared.backgroundForm

        row.cellConfig["textView.backgroundColor"] = NCBrandColor.shared.backgroundForm
        row.cellConfig["textView.font"] = UIFont.systemFont(ofSize: 14.0)
        row.cellConfig["textView.textColor"] = NCBrandColor.shared.textView

        section.addFormRow(row)
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.form = form
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("_mode_filename_", comment: "")
        
        // Theming view
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheming), name: NSNotification.Name(rawValue: NCGlobal.shared.notificationCenterChangeTheming), object: nil)
        
        changeTheming()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.activeViewController = self
    }
    
    // MARK: - NotificationCenter

    @objc func changeTheming() {
        view.backgroundColor = NCBrandColor.shared.backgroundView
        tableView.backgroundColor = NCBrandColor.shared.backgroundView
        tableView.reloadData()
        
        initializeForm()
        reloadForm()
    }
    
    //MARK: XLForm

    func reloadForm() {
        
        self.form.delegate = nil
        
        let maskFileName : XLFormRowDescriptor = self.form.formRow(withTag: "maskFileName")!
        let previewFileName : XLFormRowDescriptor  = self.form.formRow(withTag: "previewFileName")!
        previewFileName.value = self.previewFileName(valueRename: maskFileName.value as? String)
        
        self.tableView.reloadData()
        self.form.delegate = self
    }
    
    override func formRowDescriptorValueHasChanged(_ formRow: XLFormRowDescriptor!, oldValue: Any!, newValue: Any!) {
        
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        if formRow.tag == "addFileNameType" {
            CCUtility.setFileNameType((formRow.value! as AnyObject).boolValue, key: NCGlobal.shared.keyFileNameAutoUploadType)
            self.reloadForm()
        }
        else if formRow.tag == "maintainOriginalFileName" {
            CCUtility.setOriginalFileName((formRow.value! as AnyObject).boolValue, key:NCGlobal.shared.keyFileNameOriginalAutoUpload)
            self.reloadForm()
        }
        else if formRow.tag == "maskFileName" {
            
            let fileName = formRow.value as? String
            
            self.form.delegate = nil
            
            if let fileName = fileName {
                formRow.value = CCUtility.removeForbiddenCharactersServer(fileName)
            }
            
            self.form.delegate = self
            
            let previewFileName : XLFormRowDescriptor  = self.form.formRow(withTag: "previewFileName")!
            previewFileName.value = self.previewFileName(valueRename: formRow.value as? String)
            
            // reload cell
            if fileName != nil {
                
                if newValue as! String != formRow.value as! String {
                    
                    self.reloadFormRow(formRow)
                    
                    NCContentPresenter.shared.messageNotification("_info_", description: "_forbidden_characters_", delay: NCGlobal.shared.dismissAfterSecond, type: NCContentPresenter.messageType.info, errorCode: NCGlobal.shared.ErrorCharactersForbidden, forced: true)
                }
            }
            
            self.reloadFormRow(previewFileName)
        }
    }
    
    // MARK: - Utility
    
    func previewFileName(valueRename : String?) -> String {
        
        var returnString : String = ""
        
        if CCUtility.getOriginalFileName(NCGlobal.shared.keyFileNameOriginalAutoUpload) {
            
            return (NSLocalizedString("_filename_", comment: "") + ": IMG_0001.JPG")
            
        } else if let valueRename = valueRename {
            
            let valueRenameTrimming = valueRename.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if valueRenameTrimming.count > 0 {
                
                self.form.delegate = nil
                CCUtility.setFileNameMask(valueRename, key: NCGlobal.shared.keyFileNameAutoUploadMask)
                self.form.delegate = self
                
                returnString = CCUtility.createFileName("IMG_0001.JPG", fileDate: dateExample, fileType: PHAssetMediaType.image, keyFileName: NCGlobal.shared.keyFileNameAutoUploadMask, keyFileNameType: NCGlobal.shared.keyFileNameAutoUploadType, keyFileNameOriginal: NCGlobal.shared.keyFileNameOriginalAutoUpload)

            } else {
                
                CCUtility.setFileNameMask("", key: NCGlobal.shared.keyFileNameAutoUploadMask)
                returnString = CCUtility.createFileName("IMG_0001.JPG", fileDate: dateExample, fileType: PHAssetMediaType.image, keyFileName: nil, keyFileNameType: NCGlobal.shared.keyFileNameAutoUploadType, keyFileNameOriginal: NCGlobal.shared.keyFileNameOriginalAutoUpload)
            }
            
        } else {
            
            CCUtility.setFileNameMask("", key: NCGlobal.shared.keyFileNameAutoUploadMask)
            returnString = CCUtility.createFileName("IMG_0001.JPG", fileDate: dateExample, fileType: PHAssetMediaType.image, keyFileName: nil, keyFileNameType: NCGlobal.shared.keyFileNameAutoUploadType, keyFileNameOriginal: NCGlobal.shared.keyFileNameOriginalAutoUpload)
        }
        
        return String(format: NSLocalizedString("_preview_filename_", comment: ""), "MM,MMM,DD,YY,YYYY and HH,hh,mm,ss,ampm") + ":" + "\n\n" + returnString
    }
}
