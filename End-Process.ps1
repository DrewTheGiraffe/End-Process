<#
Things to fix..
- Search by string doesnt highlight any objects in list.
- End task by clicking selecting object in list.
- FindString in Search by name doesnt seem to work properly.
#>

function Paint-FocusBorder([System.Windows.Forms.Control]$control) {
    # Source: https://stackoverflow.com/questions/61429550/powershell-windows-form-border-color-controls
    $parent = $control.Parent
    $parent.Refresh()
    if ($control.Focused) {
        $control.BackColor = "Black"
        $pen = [System.Drawing.Pen]::new('Red', 2)
    }
    else {
        $control.BackColor = "Black"
        $pen = [System.Drawing.Pen]::new($parent.BackColor, 2)
    }
    $rect = [System.Drawing.Rectangle]::new($control.Location, $control.Size)
    $rect.Inflate(1,1)
    $parent.CreateGraphics().DrawRectangle($pen, $rect)
}
Function Risky { 
 cls
# ASM Functions
[Void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[Void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
 
# obj definitions
$basicForm = New-Object System.Windows.Forms.Form
$OutputWindow = New-Object System.Windows.Forms.TextBox
$ButtonEndTask = New-Object System.Windows.Forms.Button
$ButtonGetTask = New-Object System.Windows.Forms.Button
$ButtonSearch = New-Object System.Windows.Forms.Button
$TaskListBox = New-Object System.Windows.Forms.ListBox
$IDInputBox = New-Object System.Windows.Forms.TextBox
$NameInputBox = New-Object System.Windows.Forms.TextBox
$IDInputLabel = New-Object System.Windows.Forms.Label
$NameInputLabel = New-Object System.Windows.Forms.Label

#region region_Main Form
$basicForm.Name = "Risky"
$basicForm.Text = "Process Killer"
$basicForm.BackColor = "Gray"
$basicForm.StartPosition = "CenterScreen"
$basicForm.FormBorderStyle = "Fixed3D"
$basicForm.MaximizeBox = $false
$basicForm.MinimizeBox = $true
$basicForm.Size = "510,550"
#endregion

#region ID Input Label
$IDInputLabel.Location = New-Object System.Drawing.Size(125,22)
$IDInputLabel.Size = New-Object System.Drawing.Size(230,20)
$IDInputLabel.Font = New-Object System.Drawing.Font("",12)
$IDInputLabel.BackColor = [System.Drawing.Color]::FromName("Black") # "Transparent"
$IDInputLabel.ForeColor = [System.Drawing.Color]::FromName("Red")
$IDInputLabel.Text = "Enter Process ID Number here"
#endregion

#region ID Input Box 
$IDInputBox.Location = "15,50"
$IDInputBox.BackColor = "Black"
$IDInputBox.ForeColor = "White"
$IDInputBox.Width = 460
$IDInputBox.Height = 20
$IDInputBox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center;
$IDInputBox.Font = New-Object System.Drawing.Font("",10)
$IDInputBox.Add_GotFocus({ Paint-FocusBorder $this })
$IDInputBox.Add_LostFocus({ Paint-FocusBorder $this })
#endregion

#region Name Input Label
$NameInputLabel.Location = New-Object System.Drawing.Size(105,80)
$NameInputLabel.Size = New-Object System.Drawing.Size(285,20)
$NameInputLabel.Font = New-Object System.Drawing.Font("",12)
$NameInputLabel.BackColor = [System.Drawing.Color]::FromName("Black") # "Transparent"
$NameInputLabel.ForeColor = [System.Drawing.Color]::FromName("Red")
$NameInputLabel.Text = "Search Process Name Keyword Here"
#endregion

#region Name Input Box 
$NameInputBox.Location = "15,109"
$NameInputBox.BackColor = "Black"
$NameInputBox.ForeColor = "White"
$NameInputBox.Width = 460
$NameInputBox.Height = 20
$NameInputBox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center;
$NameInputBox.Font = New-Object System.Drawing.Font("",10)
$NameInputBox.Add_GotFocus({ Paint-FocusBorder $this })
$NameInputBox.Add_LostFocus({ Paint-FocusBorder $this })
#endregion

#region GetTask Button
$ButtonGetTask.Location = "330,146"
$ButtonGetTask.Size = "143,30"
$ButtonGetTask.BackColor = "Black"
$ButtonGetTask.Text = "Get Active Tasks"
$ButtonGetTask.ForeColor = "Red"
$ButtonGetTask.Font = New-Object System.Drawing.Font("",10)
$ButtonGetTask.FlatStyle = "Flat"
$ButtonGetTask.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkRed
$ButtonGetTask.Add_Click({
        $formattedtasks = Get-Process | Sort-Object CPU -Descending | Select-Object Id,ProcessName 
        $tasks = Write-Information -MessageData $formattedtasks -InformationAction Continue
 #       ForEach ($Task in $tasks) {
            
            $TaskListBox.Items.AddRange($formattedtasks) | Sort-Object -Descending
            #break;
  #      }

})
#endregion

#region Search Button
$TaskListBox.SelectionMode = "MultiExtended"
$ButtonSearch.Location = "173,146" # "15,65"
$ButtonSearch.Size = "140,30"
$ButtonSearch.BackColor = "Black"
$ButtonSearch.Text = "Search"
$ButtonSearch.ForeColor = "Red"
$ButtonSearch.Font = New-Object System.Drawing.Font("",10)
$ButtonSearch.FlatStyle = "Flat"
$ButtonSearch.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkRed
$ButtonSearch.Add_Click({
# $OutputWindow.Text = $NameInputBox.Text # NameInputBox is properly reporting...
    [int] $x =- 1;
    If ($NameInputBox.Text -ne 0) {
        do {
            $x = $TaskListBox.FindString($NameInputBox.Text, $x)
            If ($x -ne -1) {
                If ($TaskListBox.SelectedIndices.Count > 0) {
                    If ($TaskListBox.SelectedIndices[0]) {
                        return;
                    }
                    $TaskListBox.SetSelected($x, $true)
                }
            } 
        }while($x -cne -1);
    }
}) # Ported to powershell from : https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.listbox.findstring?view=windowsdesktop-5.0
#endregion

#region EndTask Button
$ButtonEndTask.Location = "17,146" # "15,65"
$ButtonEndTask.Size = "140,30"
$ButtonEndTask.BackColor = "Black"
$ButtonEndTask.Text = "End Selected Task"
$ButtonEndTask.ForeColor = "Red"
$ButtonEndTask.Font = New-Object System.Drawing.Font("",10)
$ButtonEndTask.FlatStyle = "Flat"
$ButtonEndTask.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkRed
$ButtonEndTask.Add_Click({
        # Backend code
        $theselectedtask = $IDInputBox.Text
        If ($theselectedtask -cne $null) {
            Stop-Process -Id $theselectedtask -Force
            $OutputWindow.Text = "Ended Process : $theselectedtask"
        }
        Else {
            # possible idea? -Burge
            #$ClickedTask = $TaskListBox.GetSelected($TaskListBox.SelectedItem)
            #Stop-Process -InputObject $ClickedTask -Force
            $OutputWindow.Text = "Unable to Get processes. Check your code weenie"
        }
})
#endregion

#region Task List Box
$TaskListBox.MultiColumn = $false
#$TaskListBox.AutoScrollOffset # this needs Out-Null
$TaskListBox.SelectionMode = 'MultiExtended'
$TaskListBox.BackColor = "Black"
$TaskListBox.ForeColor = "White"
$TaskListBox.Location = "15,180"
$TaskListBox.Width = 460
$TaskListBox.Height = 220
$TaskListBox.Font = New-Object System.Drawing.Font("Lucida Console",11,[System.Drawing.FontStyle]::Regular)
$TaskListBox.Add_GotFocus({ Paint-FocusBorder $this })
$TaskListBox.Add_LostFocus({ Paint-FocusBorder $this })
$TaskListBox.Disposing | Out-null
#endregion

#region Output_Window
$OutputWindow.Multiline = $true
$OutputWindow.BackColor = "Black"
$OutputWindow.ForeColor = "White"
$OutputWindow.Location = "15,400"# y = 90
$OutputWindow.Width  = 460 #X 
$OutputWindow.Height = 45 #Y
$OutputWindow.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)
$OutputWindow.Add_GotFocus({ Paint-FocusBorder $this })
$OutputWindow.Add_LostFocus({ Paint-FocusBorder $this })
$OutputWindow.Disposing | Out-Null
#endregion

#region Credits
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(145,450) # "15,100"
$objLabel.Size = New-Object System.Drawing.Size(305,90) # "300,100"
$objLabel.Font = New-Object System.Drawing.Font("",11)
$objLabel.BackColor = [System.Drawing.Color]::FromName("Transparent") # "Transparent"
$objLabel.ForeColor = [System.Drawing.Color]::FromName("DarkRed")
$objLabel.Text = "            PROCESS KILLER`n                       Devs`nRob King (Risky) | Drew Burgess"
#endregion

#region region_Add Elements
$basicForm.Controls.Add($ButtonEndTask)
$basicForm.Controls.Add($ButtonGetTask)
$basicForm.Controls.Add($ButtonSearch)
$basicForm.Controls.Add($OutputWindow)
$basicForm.Controls.Add($objLabel)
$basicForm.Controls.Add($TaskListBox)
$basicForm.Controls.Add($IDInputBox)
$basicForm.Controls.Add($IDInputLabel)
$basicForm.Controls.Add($NameInputBox)
$basicForm.Controls.Add($NameInputLabel)
#endregion

#region region_Start Form
$basicForm.Add_Shown({ Paint-FocusBorder $OutputWindow })
$basicForm.ShowDialog() | Out-Null
#$basicForm.Dispose() | Out-Null # Refreshes the form after use
#endregion

}
Risky