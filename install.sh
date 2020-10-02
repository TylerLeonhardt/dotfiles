echo "it ran" > ~/foo.txt

# If PowerShell isn't installed, install PowerShell
if ! command -v pwsh &> /dev/null
then
    wget -O - https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/install-powershell.sh | bash -s
fi

# Make PowerShell the default shell
pwshLoc=which pwsh
sudo chsh -s $pwshLoc

pwsh -nologo -noprofile -command ./install.ps1
