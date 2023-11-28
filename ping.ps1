<#

Example usage: .\ping.ps1 -JSON '["google.com","bing.com"]'

INPUT:
JSON Array of FQDNs of servers to ping
Example: ["google.com","bing.com"]

OUTPUT:
JSON Array of objects containing the server fqdn (server) and whether or not the server was ping-able (up)
Example:
[
    {
        "server":  "google.com",
        "up":  "False"
    },
    {
        "server":  "bing.com",
        "up":  "False"
    }
]

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$JSON
)

try {
    # Check we're receiving valid format JSON
    $objects = $JSON | ConvertFrom-Json -ErrorAction Stop

    # Check to make sure we only receive a string or list/array of strings
    $objects | ForEach-Object {
        if ($_.GetType().Name -ne "String") {
            throw "Expected Object type String. Got Type $($_.GetType().Name)"
        } 
    }
}
catch {
    "Error parsing JSON" | Write-Debug
    $Error[0] | Write-Error
    exit
}

$output = [System.Collections.ArrayList]@()

$objects | ForEach-Object {
    try {
        $pingResult = Test-NetConnection -ComputerName $_ -ErrorAction Stop -WarningAction Stop
    }
    catch {
        "Test-NetConnection failed. Trying Test-Connection as backup" | Write-Debug 
        $pingResult = Test-Connection -ComputerName $_ -ErrorAction Stop -Quiet
    }

    $null = $output.Add(
        [PSCustomObject]@{
            server = $_
            up = $pingResult.ToString()
        }
    )
}

$output | ConvertTo-Json
