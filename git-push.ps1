Param(
  $RemoteUser,
  $RemoteUserPass,
  $RemoteServer,
  [string]$RemoteSiteLocation,
  $GitRepositoryURL = "%GitRepositoryURL%",
  $GitRepositoryBranch = "%teamcity.build.branch%",
  $CommitHash = "%build.vcs.number%"    #Abbreviated commit hash from TC
)
#
function RemoteGitPull{
  param(
    $RemoteSiteLocation,
    $GitRepositoryBranch,
    $CommitHash
  )
  function TestCommitHash{
    param($CommitHash)
    $CurrentCommitHash = (git log --pretty=format:"%H" -1);
    if ($CurrentCommitHash -ne $CommitHash) {
      write "##teamcity[buildProblem description='Current build branch is %teamcity.build.branch%, but hash commit is incorect.']";
    }
    else {write "Pass. Hash is corect"}
  }
  cd $RemoteSiteLocation;
  git fetch --all;
  $gitstatus = git status;
  Write "$gitstatus";
  $currentbranch = ($gitstatus | Select-String "On branch").line.split()[-1];
  if ($currentbranch -eq $GitRepositoryBranch) {
    Write "Pass. On branch";
    git pull origin $GitRepositoryBranch;
    if ($? != $True) {
      write "##teamcity[buildStatus status='FAILURE' text='Fail checkout %teamcity.build.branch%']";
      }
    TestCommitHash -CommitHash:$CommitHash
    }
  else {
    Write "Change branch"
    git checkout $GitRepositoryBranch;
    git pull origin $GitRepositoryBranch;
    if ($? != $True) {
      write "##teamcity[buildStatus status='FAILURE' text='Fail checkout %teamcity.build.branch%']";
      }
    TestCommitHash -CommitHash:$CommitHash
    }

}

if (!([bool]$RemoteSiteLocation)) {write-Error "Param '$RemoteSiteLocation' is Null" };
$RemoteUserPass = convertto-securestring "$RemoteUserPass" -asplaintext -force;
$Cred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$RemoteUser",$RemoteUserPass;
$RemoteSession = New-PSSession -ComputerName $RemoteServer -Credential $Cred;
#
$Error.Clear()
$ErrorActionPreference="Continue"
Invoke-Command -ScriptBlock ${Function:RemoteGitPull} -ArgumentList $RemoteSiteLocation,$GitRepositoryBranch,$CommitHash -Session $RemoteSession

