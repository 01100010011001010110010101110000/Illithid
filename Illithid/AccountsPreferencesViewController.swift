//
//  AccountsPreferencesViewController.swift
//  Illithid
//
//  Created by Tyler Gregory on 11/20/18.
//  Copyright © 2018 flayware. All rights reserved.
//

import Cocoa

import CleanroomLogger

class AccountsPreferencesViewController: NSViewController {
  @IBOutlet var addRedditAccountButton: NSButton!
  @IBOutlet var accountsTableView: NSTableView!
  @IBOutlet var removeRedditAccountButton: NSButton!

  @IBAction func addRedditAccountButtonClicked(_: NSButton) {
    RedditClientBroker.broker.addAccount(window: view.window!, completion: {
      self.accountsTableView.reloadData()
    })
  }

  @IBAction func removeRedditAccountButtonClicked(_: NSButton) {
    let columnIndex = accountsTableView.column(withIdentifier: ColumnIdentifiers.UsernameColumn)
    let usernameColumn = accountsTableView.tableColumns[columnIndex]
    let rowIndex = accountsTableView.selectedRow
    if let deleteView = self.tableView(accountsTableView, viewFor: usernameColumn, row: rowIndex) as? NSTableCellView {
      guard let username = deleteView.textField?.stringValue else {
        return
      }
      RedditClientBroker.broker.removeAccount(toRemove: username)
      accountsTableView.reloadData()
    } else {
      Log.info?.message("Attempted to delete nonexistant row")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    accountsTableView.delegate = self
    accountsTableView.dataSource = self
  }
}

extension AccountsPreferencesViewController: NSTableViewDataSource {
  func numberOfRows(in _: NSTableView) -> Int {
    let accounts = RedditClientBroker.broker.listAccounts()
    Log.debug?.message("We have \(accounts.count) reddit clients")
    return accounts.count
  }
}

extension AccountsPreferencesViewController: NSTableViewDelegate {
  fileprivate enum CellIdentifiers {
    static let UsernameCell = NSUserInterfaceItemIdentifier("UsernameCellID")
  }

  fileprivate enum ColumnIdentifiers {
    static let UsernameColumn = NSUserInterfaceItemIdentifier("UsernameColumnID")
  }

  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    var accountNames = Array(RedditClientBroker.broker.listAccounts().keys).sorted()
    let account = accountNames[row]
    Log.debug?.message("Writing \(account) to preferences table")

    if let cell = tableView.makeView(withIdentifier: CellIdentifiers.UsernameCell, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = account
      return cell
    } else {
      return nil
    }
  }

  func tableViewSelectionDidChange(_: Notification) {
    let rowIndex = accountsTableView.selectedRow
    let columnIndex = accountsTableView.column(withIdentifier: ColumnIdentifiers.UsernameColumn)
    let usernameColumn = accountsTableView.tableColumns[columnIndex]
    if let usernameView = self.tableView(accountsTableView, viewFor: usernameColumn, row: rowIndex) as? NSTableCellView {
      guard let username = usernameView.textField?.stringValue else {
        return
      }
      RedditClientBroker.broker.setCurrentAccount(name: username)
    }
  }
}
