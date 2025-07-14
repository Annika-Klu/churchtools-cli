class Toast {
    [char]$InfoIcon = [char]9989
    [char]$ErrorIcon = [char]0x274C

    [void] Show([string]$Type, [string]$Title, [string]$Message) {
        $icon = ""
        switch ($Type.ToLower()) {
            'info'  { $icon = $this.InfoIcon }
            'error' { $icon = $this.ErrorIcon }
        }
        New-BurntToastNotification -Text "$icon $Title", $Message
    }
}
