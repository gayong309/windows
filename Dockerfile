# Gunakan Windows Server Core sebagai image dasar
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# ARG untuk token Ngrok dan password admin
ARG NGROK_TOKEN
ARG PASSWORD

# Install Ngrok
RUN powershell -Command `
    Invoke-WebRequest -Uri https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -OutFile ngrok.zip ; `
    Expand-Archive -Path ngrok.zip -DestinationPath C:\ngrok ; `
    Remove-Item -Force ngrok.zip

# Autentikasi Ngrok dengan token
RUN C:\ngrok\ngrok.exe authtoken %NGROK_TOKEN%

# Enable Remote Desktop
RUN powershell -Command `
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 ; `
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" ; `
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1

# Atur password untuk user default (disini "Administrator")
RUN powershell -Command `
    net user Administrator %PASSWORD%

# Expose port RDP
EXPOSE 3389

# Start Ngrok dan layanan RDP
CMD powershell -Command `
    Start-Process C:\ngrok\ngrok.exe "tcp 3389" ; `
    net start termservice ; `
    Wait-Event -Timeout 3600
    
