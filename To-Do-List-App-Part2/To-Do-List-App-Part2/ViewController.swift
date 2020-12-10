//  ViewController.swift

//  To-Do-List-App-Part2
//  Created by Abdeali Mody on 2020-12-02.
//  Student ID - 301085484
//
//  Description - Displays list of tasks, user can add new task with the help of + button
//  Also, lets the user to click on a particular task and redirect to the task information screen
//  2nd Screen lets the user to add a task description, with due date and task complete switch.
//  Version 1.0
//  Copyright © 2020 Abdeali. All rights reserved.

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableViewTodoList: UITableView!
    
    @IBOutlet var task_name: UITextField!
    var database: Database = Database()
    var tasks:[Tasks] = []
    var selectedTask = Tasks()
    
    @IBOutlet var taskName: UITextField!

    let cellIdentifier = "CustomCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableViewTodoList.dataSource = self
        tableViewTodoList.delegate = self
        
        tasks = database.query()
    }
    
    //Add Task Function.
    @IBAction func createTasks(_ sender: UIButton)
    {
        database.insert(name: task_name.text!)
        tasks = database.query()
        //need to add
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                
         guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "todolist") as? ViewController
         else
         {
            return
         }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("qty: "+String(tasks.count))
        return tasks.count
    }
    
    //This function returns the word Complete once the user swipe left.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if (tasks[indexPath.row].task_is_completed == 1){
     
        let text = tasks[indexPath.row].name
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        cell.textLabel?.attributedText = attributeString
        cell.detailTextLabel?.text = "Completed"
        }
        else
        {
            cell.textLabel?.text = tasks[indexPath.row].name
            cell.detailTextLabel?.text = tasks[indexPath.row].duedate
        }
        return cell
    }
    
    
    //Update functinality on swiping right.
    func tableView(_ tableView: UITableView,
                       leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let update = UIContextualAction(style: .normal, title: "Update", handler: {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        guard let goToViewController = mainStoryboard.instantiateViewController(withIdentifier: "TaskDetails_ViewController") as? Task_Details_ViewController
        else
        {
            return
        }
        goToViewController.tasksList = self.tasks[indexPath.row]
        self.navigationController?.pushViewController(goToViewController, animated: true)
        success(true)
    })
        //change the background color.
        update.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [update])
    }

    //Complete & Delete Fuctionality on swipe of left.
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let complete = UIContextualAction(style: .normal, title: "Complete", handler: {
            (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
        self.database.update(name: self.tasks[indexPath.row].name, task_has_due: self.tasks[indexPath.row].task_has_due, duedate: self.tasks[indexPath.row].duedate, task_is_completed: 1)
            
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let goToViewController = mainStoryboard.instantiateViewController(withIdentifier: "todolist") as? ViewController
        else
        {
            return
        }
            
        self.navigationController?.pushViewController(goToViewController, animated: true)
        success(true)
    })
        
        complete.backgroundColor = .yellow

         let contextItem = UIContextualAction(style: .destructive, title: "Delete") {
            (contextualAction, view, boolValue) in
         let task = self.tasks[indexPath.row].name
         
         self.database.delete(name: task)
         self.tasks = self.database.query()
          
         
         tableView.beginUpdates()
         tableView.deleteRows(at: [indexPath],with: .automatic)
         tableView.endUpdates()
        }
    return UISwipeActionsConfiguration(actions: [contextItem, complete])
}

    //This function will help to move on second view controller screen.
    @objc func goNextScreenAction(_ sender:UIButton!)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "TaskDetails_ViewController") as? Task_Details_ViewController
        else
        {
            return
        }
        
        let editButtonPos:CGPoint = sender.convert(CGPoint.zero, to:self.tableViewTodoList)
        let indexPath = self.tableViewTodoList.indexPathForRow(at: editButtonPos)
        let index = indexPath!.row
        selectedTask = tasks[index]
        viewController.tasksList = selectedTask
        navigationController?.pushViewController(viewController, animated: true)
    }
}



