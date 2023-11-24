//
//  NCManageDatabase+Tag.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 13/11/23.
//  Copyright © 2023 Marino Faggiana. All rights reserved.
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
import RealmSwift
import NextcloudKit

class tableTag: Object {

    @objc dynamic var account = ""
    @objc dynamic var ocId = ""
    @objc dynamic var tagIOS: Data?

    override static func primaryKey() -> String {
        return "ocId"
    }
}

extension NCManageDatabase {

    func addTag(_ ocId: String, tagIOS: Data?, account: String) {

        do {
            let realm = try Realm()
            try realm.write {
                let addObject = tableTag()
                addObject.account = account
                addObject.ocId = ocId
                addObject.tagIOS = tagIOS
                realm.add(addObject, update: .all)
            }
        } catch let error {
            NextcloudKit.shared.nkCommonInstance.writeLog("Could not write to database: \(error)")
        }
    }

    func deleteTag(_ ocId: String) {

        do {
            let realm = try Realm()
            try realm.write {
                let results = realm.objects(tableTag.self).filter("ocId == %@", ocId)
                realm.delete(results)
            }
        } catch let error {
            NextcloudKit.shared.nkCommonInstance.writeLog("Could not write to database: \(error)")
        }
    }

    func getTags(predicate: NSPredicate) -> Results<tableTag>? {

        do {
            let realm = try Realm()
            return realm.objects(tableTag.self).filter(predicate)
        } catch let error as NSError {
            NextcloudKit.shared.nkCommonInstance.writeLog("Could not write to database: \(error)")
        }

        return nil
    }

    func getTag(predicate: NSPredicate) -> tableTag? {

        do {
            let realm = try Realm()
            return realm.objects(tableTag.self).filter(predicate).first
        } catch let error as NSError {
            NextcloudKit.shared.nkCommonInstance.writeLog("Could not write to database: \(error)")
        }

        return nil
    }
}
