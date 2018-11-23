//
//  Database.swift
//  Capture
//
//  Created by Hetal Chauhan on 11/21/18.
//  Copyright © 2018 Hetal. All rights reserved.
//

import UIKit
import GRDB

enum CaptureDatabaseColoums:String {
    case id = "id"
    case imageBase64 = "imageBase64"
    case tag = "tag"
    case isSyncToServer = "isSyncedToServer" // Bool
}
class CaptureDatabaseManager: NSObject {
    
    /// SQLFile Configuration
    private lazy var configuration:Configuration = Configuration()
    
    /// Database path where the SQFile stored
    private var databasePath:URL!
    
    /// Database query pool
    private var databasePool:DatabasePool!
    
    /// Database Manager Shared Instances
    static var shared:CaptureDatabaseManager = CaptureDatabaseManager()
    
    let captureTable = "CaptureImage"
    /// Database Migrator
    private var migrator: DatabaseMigrator {
        
        var migrator = DatabaseMigrator()
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            migrator.registerMigration("v1") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: self.captureTable) { t in
                
                    // An integer primary key auto-generates unique IDs
            t.column(CaptureDatabaseColoums.id.rawValue, .integer).primaryKey(onConflict: Database.ConflictResolution.fail, autoincrement: true)
                t.column(CaptureDatabaseColoums.imageBase64.rawValue, .integer)
                t.column(CaptureDatabaseColoums.tag.rawValue, .text)
                t.column(CaptureDatabaseColoums.isSyncToServer.rawValue, Database.ColumnType.boolean).defaults(to: false)
            
            }
        }
        return migrator
    }
    // Init CaptureDatabaseManager
    override init() {
        super.init()
        
        // Check for Database Path
        if let databasePathURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Capture.sqlite"){
            self.databasePath = databasePathURL
        }else{
            fatalError("Database Path Not Found!!!")
        }
        
        // Check for database opration pool access
        if let databasePool = try? DatabasePool.init(path: databasePath.absoluteString){
            self.databasePool = databasePool
        }else{
            fatalError("Database pool can't be created!!!")
        }
        do{
            try self.migrator.migrate(self.databasePool)
        }catch{
            fatalError("Migration Process Failed")
        }
        print("Database Path \(String(describing: self.databasePath))")
        
        //self.setDummyData()
    }
    
    public func initDatabase(FromApplication application:UIApplication) -> Void {
        self.databasePool.setupMemoryManagement(in: application)
    }
    
    // MARK:- Base Insert query..
    /// Generate SQL Statement Based On Parameters
    ///
    /// - Parameters:
    ///   - tbl: Table Details
    ///   - columnNames: Coloum Details
    ///   - value: Coloum Values
    /// - Returns: SQL String
    func insertSQLStatement(withTable tbl:String,withColumn columnNames:[String], withValue value:StatementArguments) -> String {
        var strColumnsQuestions:String = ""
        var strColumnName:String = ""
        
        for column in columnNames
        {
            if strColumnName.count > 0
            {
                strColumnName = strColumnName.appending(" , \(column) ")
            }
            else
            {
                strColumnName = column
            }
            
            if strColumnsQuestions.count > 0
            {
                strColumnsQuestions = strColumnsQuestions.appending(", ? ")
            }
            else
            {
                strColumnsQuestions = "? "
            }
        }
        
        return """
        INSERT INTO \(tbl) (\(strColumnName))
        VALUES ( \(strColumnsQuestions) )
        """
    }
    
    // MARK:- Base Update query..
    
    /// Generate SQL Statement Based On Parameters
    ///
    /// - Parameters:
    ///   - tbl: Table Details
    ///   - columnNames: Coloum Details
    ///   - value: Coloum Values
    /// - Returns: SQL String
    func updatetSQLStatement(withTable tbl:String,
                             withColumnAndvalue columnAndValues:[String:Any],
                             where oldColumnAndValues:[String:Any]) -> String {
        
        var strNewValues:String = ""
        var strWithColumnAndValues:String = ""
        
        for (index, element) in columnAndValues.enumerated() {
            //print("Item \(index): \(element)")
            strNewValues = strNewValues + "\(element.key)=\'\(element.value)\',"
        }
        strNewValues.removeLast()
        
        for (index, element) in oldColumnAndValues.enumerated() {
            if oldColumnAndValues.count > 1 {
                if index == oldColumnAndValues.count{
                    //Last index(not apppend AND)
                    strWithColumnAndValues = strWithColumnAndValues + "\(element.key)=\'\(element.value)\'"
                    
                }else{
                    //All other index and value
                    strWithColumnAndValues = strWithColumnAndValues + "\(element.key)=\'\(element.value)\' and"
                }
            }else{
                strWithColumnAndValues = strWithColumnAndValues + "\(element.key)=\'\(element.value)\'"
            }
        }
        
        return """
        UPDATE \(tbl)
        SET \(strNewValues)
        WHERE \(strWithColumnAndValues)
        """
    }
    
    // MARK:- Base SELECT query..
    
    /// genral select SQL stament for get data
    ///
    /// - Parameters:
    ///   - tbl:  Table Details
    ///   - columnAndValues:  Coloum Details
    /// - Returns: SQL String
    func getSQLStatement(withTable tbl:String,
                         where columnAndValues:[String:Any]) -> String {
        
        var strWhereColumnValues:String = ""
        
        for (index, element) in columnAndValues.enumerated() {
            if columnAndValues.count > 1 {
                if index == columnAndValues.count - 1{
                    //Last index(not apppend AND)
                    strWhereColumnValues = strWhereColumnValues + "\(element.key)=\'\(element.value)\'"
                }else{
                    //All other indes and value
                    strWhereColumnValues = strWhereColumnValues + "\(element.key)=\'\(element.value)\' and "
                }
            }else{
                strWhereColumnValues = strWhereColumnValues + "\(element.key)=\'\(element.value)\'"
            }
        }
        
        if strWhereColumnValues.count>0{
            return """
            SELECT * from \(tbl)
            WHERE \(strWhereColumnValues)
            """
        }else{
            return """
            SELECT * from \(tbl)
            """
        }
    }
    
    // MARK:- Insert Funcation...
    
    /// Insert Records to database
    ///
    /// - Parameters:
    ///   - tbl: Table Details
    ///   - columnNames: Coloum Details
    ///   - value: Coloum Value
    /// - Returns: Success or Failure of Insert Statement
    func insertRecord(withTable tbl:String,withColumn columnNames:[String], withValue value:StatementArguments) -> Bool {
        do {
            let sqlQuery = self.insertSQLStatement(withTable: tbl, withColumn: columnNames, withValue: value)
            if let pool = self.databasePool{
                try pool.write { (db) in
                    try db.execute(sqlQuery, arguments: value)
                }
                return true
            }
            return false
        }
        catch {
          //  print(error.localizedDescription)
        }
        return false
    }
    
    
    // MARK:- Update Funcation...
    @discardableResult
    func updateRecord(withTable tbl:String,withColumn columnAndValues:[String:Any], where oldColumnAndValues:[String:Any]) -> Bool {
        do {
            let sqlQuery = self.updatetSQLStatement(withTable: tbl, withColumnAndvalue: columnAndValues, where: oldColumnAndValues)
            if let pool = self.databasePool{
                try pool.write { (db) in
                    
                    let argument : StatementArguments = StatementArguments(columnAndValues)!
                    //                    argument.append(contentsOf: StatementArguments(oldColumnAndValues))
                    try db.execute(sqlQuery, arguments: argument)
                }
                return true
            }
            return false
        }
        catch {
            print(error.localizedDescription)
        }
        return false
    }
    // MARK: - Select Funcation...
    
    /// Select Record From Database
    ///
    /// - Parameter sqlQuery: SQL Query
    /// - Returns: Return Array Of records
    func selectData(fromSQLQuery sqlQuery:String) -> [Row] {
        var records:[Row] = []
        do {
            if let pool = self.databasePool{
                try pool.read
                { (db)  in
                    let rows = try Row.fetchAll(db, sqlQuery)
                    records = rows
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return records
    }
    
    
}
extension CaptureDatabaseManager
{
    // Create Entry for capture image
    func addCaptureImage(captureModel : CaptureModel) {
        self.insertRecord(withTable: captureTable,
                                                withColumn: [
                                                    CaptureDatabaseColoums.imageBase64.rawValue,
                                                    CaptureDatabaseColoums.tag.rawValue,
                                                    CaptureDatabaseColoums.isSyncToServer.rawValue],
                                                withValue: [
                                                    captureModel.imageBase64,
                                                    captureModel.tag,
                                                    captureModel.isSyncedToServer,
                                                   ])
        
    }
    //Update Capture Table
    func updateCaptureTable(captureModel : CaptureModel){
        self.updateRecord(withTable: captureTable,
                          withColumn: [
                            CaptureDatabaseColoums.imageBase64.rawValue:captureModel.imageBase64,
                            CaptureDatabaseColoums.tag.rawValue:captureModel.tag,
                            CaptureDatabaseColoums.isSyncToServer.rawValue:captureModel.isSyncedToServer],
                          where: [
                            CaptureDatabaseColoums.id.rawValue:captureModel.id])
        
    }
    //Get Capture Image
    func getCapturedImages(whereValue:[String:Any] = [:]) -> [CaptureModel] {
        var capturedImageArray : [CaptureModel] = []
        let query =  getSQLStatement(withTable: captureTable, where: whereValue )
        let getData = self.selectData(fromSQLQuery: query)
        for data in getData{
            
            var swiftDict : [String:Any] = [:]
            for (columnName, dbValue) in data {
                //  swiftDict[columnName] = dbValue.storage.value
                
                if let value  = dbValue.storage.value as? Bool{
                    swiftDict[columnName] = value
                }else if let value = dbValue.storage.value as? Int64{
                    swiftDict[columnName] = value
                }else if let value = dbValue.storage.value as? Int{
                    swiftDict[columnName] = value
                }else{
                    swiftDict[columnName] = dbValue.storage.value
                }
                
            }
            let captureModel = CaptureModel(NSDictionary(dictionary: swiftDict))
            capturedImageArray.append(captureModel)
        }
        return capturedImageArray
    }
    
    //MARK:- GET IMAGE TAG
    func syncForGetImageTag(){
        //Get Unsync data from database
        let arrCaptures = CaptureDatabaseManager.shared.getCapturedImages(whereValue: [CaptureDatabaseColoums.isSyncToServer.rawValue: 0])
        Service.multipleImageDetection(captures: arrCaptures) { (isSuccess, message, arrCaptureModel) in
            if isSuccess{
                for captures in arrCaptures{
                    CaptureDatabaseManager.shared.updateCaptureTable(captureModel: captures)
                }
            }
        }
        
        //For Single image tag detect
       /* for capture in arrCaptures{
            //Get tag from serever and update
            Service.imageDetection(model: capture) { (isSuccess, message, arrTag) in
                if isSuccess{
                    let tags = (arrTag?.joined(separator: ","))!
                    capture.isSyncedToServer = true
                    capture.tag = arrTag?.joined(separator: ",")
                    CaptureDatabaseManager.shared.updateCaptureTable(captureModel: captures)
                }
            }
        }*/
    }

}
