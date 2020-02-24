# PowerShell script file to be executed as a AWS Lambda function. 
# 
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#
# To include PowerShell modules with your Lambda function, like the AWSPowerShell.NetCore module, add a "#Requires" statement 
# indicating the module and version.

#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.0.4.0'}
#Requires -Modules @{ModuleName='AWS.Tools.EC2';ModuleVersion='4.0.4.0'}

# Uncomment to send the input event to CloudWatch Logs

$convert=ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5

$vals=$convert | ConvertFrom-Json
$tag_key=$vals.tag_key
$tag_value=$vals.tag_value
$operation=$vals.operation

$all_instances=Get-EC2Instance | Select-Object Instances -ExpandProperty Instances

write-Host "Passed tag key:" $tag_key
write-Host "Passed tag value:" $tag_value
write-host "Passed operation:" $operation

foreach ($instance in $all_instances)
{   
    write-host "Instance ID "$instance.InstanceID "Key:" $instance.Tags.Key "Value:" $instance.Tags.Value "State:" $instance.State.Name.Value
    
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
