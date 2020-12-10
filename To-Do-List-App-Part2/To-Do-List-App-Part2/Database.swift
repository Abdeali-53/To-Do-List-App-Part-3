//
//  Database.swift
//  To-Do-List-App-Part2
//  Created by Abdeali Mody on 2020-12-02.
//  Student ID - 301085484
//  Version 1.0
//  Copyright © 2020 Abdeali. All rights reserved.

import Foundation

class Database
{
    init()
    {
        database = open()
        createTable()
    }
    
    var database: OpaquePointer?
    
    func open() -> OpaquePointer?
    {
      var database: OpaquePointer? = nil

      if sqlite3_open(dataFilePath(), &database) == SQLITE_OK
      {
        print("Successfully opened connection to database at \(dataFilePath())")
        return database
      }
      else
      {
        print("Unable to open database.")
        return nil
      }
    }
    
    let createTableString2 = """
    DROP TABLE TASKS_TODOLIST
    """
    
    
  let createTableString = """
    CREATE TABLE TASKS_TODOLIST(
    NAME CHAR(255),
    TASK_HAS_DUE NUMBER,
    DUEDATE CHAR(50),
    TASK_IS_COMPLETED NUMBER
    );
    """
    

    func createTable()
    {
      // 1
      var statement1: OpaquePointer?
      // 2
      if sqlite3_prepare_v2(database, createTableString, -1, &statement1, nil) ==
          SQLITE_OK
      {
        // 3
        if sqlite3_step(statement1) == SQLITE_DONE
        {
          print("\n table created.")
        }
        else
        {
          print("\n table is not created.")
        }
      }
      else
      {
        print("\nCREATE TABLE statement is not prepared.")
      }
      // 4
      sqlite3_finalize(statement1)
    }


    func insert(name:String)
    {
        
        let insertStatementString = "INSERT INTO TASKS_TODOLIST (NAME) VALUES (?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
           
         
            if sqlite3_step(insertStatement) == SQLITE_DONE {
  
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func query() -> [Tasks] {
        let queryStatementString = "SELECT  NAME , COALESCE(DUEDATE, '') AS DUEDATE , TASK_IS_COMPLETED FROM TASKS_TODOLIST "
        var queryStatement: OpaquePointer? = nil
        var tasks : [Tasks] = []
            
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
              let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
              let due = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
              let task_is_completed = Int(sqlite3_column_int(queryStatement, 2))
                tasks.append(Tasks(name: name, duedate: due,task_is_completed: task_is_completed ))
      
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return tasks
    }
    
    func queryWhereWithName(name: String) -> Tasks {
        let queryStatementString = "SELECT NAME, TASK_HAS_DUE, COALESCE(DUEDATE, '') AS DUEDATE, TASK_IS_COMPLETED FROM TASKS_TODOLIST WHERE NAME = ? "
        var queryStatement: OpaquePointer? = nil
        var tasks : Tasks = Tasks()
            
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (name as NSString).utf8String, -1, nil)
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
              let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
              let task_has_due = Int(sqlite3_column_int(queryStatement, 1))
              let duedate = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
              let task_is_completed = Int(sqlite3_column_int(queryStatement, 3))
             
              tasks = Tasks(name: name, description: "", duedate: duedate, task_has_due: task_has_due, task_is_completed: task_is_completed)
      
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return tasks
    }

    let updateStatementString = "UPDATE TASKS_TODOLIST SET  TASK_HAS_DUE = ? , DUEDATE = ? , TASK_IS_COMPLETED = ?  WHERE NAME = ? ;"

    func update(name: String,  task_has_due: Int, duedate: String, task_is_completed: Int)
    {
      var statement: OpaquePointer?
      if sqlite3_prepare_v2(database, updateStatementString, -1, &statement, nil) ==
          SQLITE_OK
      {
        
        
        sqlite3_bind_int(statement, 1, Int32(task_has_due))
        sqlite3_bind_text(statement, 2,duedate, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(task_is_completed))
        sqlite3_bind_text(statement, 4,name, -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE
        {
          print("\nSuccessfully updated row.")
        }
        else
        {
          print("\nCould not update row.")
        }
      }
      else
      {
        print("\nUPDATE statement is not prepared")
      }
      sqlite3_finalize(statement)
    }
    
   

    let deleteStatementString = "DELETE FROM TASKS_TODOLIST WHERE NAME = ? ;"
    
    func delete(name: String)
    {
      var statement: OpaquePointer?
      if sqlite3_prepare_v2(database, deleteStatementString, -1, &statement, nil) ==
          SQLITE_OK
      {
        sqlite3_bind_text(statement, 1,name, -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE
        {
          print("\nSuccessfully deleted row.")
        }
        else
        {
          print("\nCould not delete row.")
        }
      }
      else
      {
        print("\nDELETE statement could not be prepared")
      }
      
      sqlite3_finalize(statement)
    }
    
    
    func dataFilePath() -> String
    {
            let urls = FileManager.default.urls(for:
                .documentDirectory, in: .userDomainMask)
            var url:String?
            url = urls.first?.appendingPathComponent("data.plist").path
            return url!
        }
}

class Tasks
{
    var name: String = ""
    var description: String = ""
    var task_has_due: Int = 0
    var duedate: String = ""
    var task_is_completed: Int = 0
    
    init(name: String, description: String, duedate: String, task_has_due: Int, task_is_completed: Int)
    {
        self.name = name
        self.description = description
        self.task_has_due = task_has_due
        self.duedate = duedate
        self.task_is_completed = task_is_completed
    }
    
    init(name: String, duedate: String, task_is_completed: Int)
    {
        self.name = name
        self.duedate = duedate
        self.task_is_completed = task_is_completed

    }
    
    init(){
    }
}


