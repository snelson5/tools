$port=$args[0]

$instance = Get-EC2Instance -InstanceId 'XXX'
$instance.Instances
$instanceId = $instance.Instances.InstanceId
Start-EC2Instance -InstanceId $instanceId

function Wait-EC2InstanceState {
    [OutputType('void')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Amazon.EC2.Model.Reservation]$Instance,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('running','stopped')]
        [string]$DesiredState,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$RetryInterval = 10
    )
    $instanceId = $Instance.Instances.InstanceId
    while ((Get-EC2InstanceStatus -IncludeAllInstance $true -InstanceId $instanceId).InstanceState.Name.Value -ne $DesiredState) {
        Write-Verbose "Waiting for our instance to reach the state of [$($DesiredState)]..."
        Start-Sleep -Seconds $RetryInterval
    }
}

Get-EC2Instance | Wait-EC2InstanceState -DesiredState running
aws ssm start-session --target XXX --document-name AWS-StartSSHSession --parameters portNumber=$port
