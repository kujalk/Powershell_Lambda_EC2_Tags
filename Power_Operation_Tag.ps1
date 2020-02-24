<#
1. pwsh
2. Import-Module AWSPowerShell.NetCore
3. Set-AWSCredential -ProfileName JanaLogin
#>


Import-Module AWSPowerShell.NetCore

Initialize-AWSDefaultConfiguration -ProfileName JanaLogin -Region ap-southeast-1

$all_instances=Get-EC2Instance | Select-Object Instances -ExpandProperty Instances

$tag_key=Read-Host "Provide the Tag Key"
$tag_value=Read-Host "Provide the Tag Value"
$operation=Read-Host "start/stop"

foreach ($instance in $all_instances)
{
    
    write-host "Instance ID "$instance.InstanceID "Key:" $instance.Tags.Key "Value:" $instance.Tags.Value
    if(($instance.Tags.Key -eq $tag_key) -and ($instance.Tags.Value -eq $tag_value))
    {
    if ($operation -eq "start")
    {
        if($instance.State.Name.Value -eq "stopped")
        {
            $action=$instance | Start-EC2Instance
            write-host "Starting "$instance.InstanceID
        }

        else
        {
            write-Host "No action needed for" $instance.InstanceID
        }
    }

    if ($operation -eq "stop")
    {
        if($instance.State.Name.Value -eq "running")
        {
            $action=$instance | Stop-EC2Instance
            write-host "Stopping "$instance.InstanceID
        }

        else
        {
            write-Host "No action needed for" $instance.InstanceID
        }
    }
    }
}