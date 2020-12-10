//
//  Task_Details_ViewController.swift
//  To-Do-List-App-Part2
//  Created by Abdeali Mody on 2020-12-02.
//  Student ID - 301085484
//  Version 1.0
//  Copyright © 2020 Abdeali. All rights reserved.

import UIKit

class Task_Details_ViewController: UIViewController {

    
    @IBOutlet var desc: UITextField!
    @IBOutlet var due: UISwitch!
    @IBOutlet var due_date: UIDatePicker!
    @IBOutlet var hasCompletedTask: UISwitch!
    
    var database: Database = Database()
    
    var tasksList: Tasks? = nil
    var task_name:String = ""
    var descrip: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        task_name = tasksList!.name

        
        //getting the information from the database related to the selected task.
        let task : Tasks = database.queryWhereWithName(name: tasksList!.name)
        
        if(task.task_is_completed == 1)
        {
            hasCompletedTask.isOn = true
        }
        if (task.task_has_due == 1)
        {
            due.isOn = true
 
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dueDate = dateFormatter.date(from: task.duedate)
        }
    }
    
    //Due Date Switch Function.
    @IBAction func due_Switch(_ sender: UISwitch)
    {
        due_date.isUserInteractionEnabled = (!due_date.isUserInteractionEnabled)
    }
    
    // Due Date picker function.
    @IBAction func duedate(_ sender: UIDatePicker)
    {
        date = due_date.date
    }

    @IBOutlet var is_completed: UISwitch!
    var date = Date()

    //Crate or Update Button function.
    @IBAction func create(_ sender: UIButton)
    {
        var dateString  = ""
        var has_due_validation = 0
        
        //If due date switch is on it provide's Due Date with task name.
        if (due.isOn)
        {
            has_due_validation = 1
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateString = dateFormatter.string(from: due_date.date)
        }
    
        var is_completed_validation = 0
        
        if (is_completed.isOn)
        {
            is_completed_validation = 1
        }
        
        let alert = UIAlertController(title: "Create", message: "Are you sure you want to create or update this task?", preferredStyle: .alert)
        
        //addAction method is used to provide addtional buttons in the alert box for eg: Yes & No
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {action in ()} ))
        
        //I have kept Style attribute to "default" and It will perform the default operations.
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            (self.database.update(name: self.task_name, task_has_due: has_due_validation, duedate: dateString, task_is_completed: is_completed_validation))

            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    
             guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "todolist") as? ViewController else {
                return
            }
            self.navigationController?.pushViewController(viewController, animated: true)
     } ))
        
        present(alert,animated: true)
    }
    
    //This function will delete the task.
    @IBAction func deleteTasks(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Are you sure you want to delete the task?", message: nil, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            //This will delete the information from the database and go back to home screen.
            self.database.delete(name: self.task_name)
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    
             guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "todolist") as? ViewController else {
                return
             }
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        //The user will remain on the same screen
        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        present(alert, animated: true, completion: nil)
    }
   
    //This function will help user to not make any changes in exsisting task and go back to main screen.
    @IBAction func cancelTasks(_ sender: UIButton)
    {
        //going back to main screen
        let alert = UIAlertController(title: "Are you sure you want to cancel the task?", message: nil, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            //going back to main screen
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "todolist") as? ViewController
            else
            {
              return
            }
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        //The user will stay on same screen.
        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        present(alert, animated: true, completion: nil)
    }
    
}
