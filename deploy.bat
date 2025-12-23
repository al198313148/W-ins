@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

:: ======================================================
::           PDF管理：云端一键部署脚本-Supported by Leo
:: ======================================================
echo ========================================================
echo     PDF管理：云端一键部署脚本-Supported by Leo
echo ========================================================
echo.

:: ========================================
::           检查管理员权限
:: ========================================
echo.
echo ========================================
echo           检查管理员权限
echo ========================================

:: 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 请求管理员权限...
    :: 重新以管理员身份运行
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo √ 已获得管理员权限
echo.

:: ========================================
::           自动化部署脚本
:: ========================================
echo ========================================
echo           自动化部署脚本 (管理员模式)
echo ========================================
echo.

:: 设置变量
set SHARE_DIR=D:\share
set STARTUP_DIR=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

:: Node.js下载源（新增四个源）
set NODE_SOURCE1=https://nodejs.org/dist/v18.20.8/node-v18.20.8-x64.msi
set NODE_SOURCE2=https://proxy.bpbpanel.ip-ddns.com/https://nodejs.org/dist/v18.20.8/node-v18.20.8-x64.msi
set NODE_SOURCE3=https://lkms-hpygbgjhfhc.hf.space/https://nodejs.org/dist/v18.20.8/node-v18.20.8-x64.msi
set NODE_SOURCE4=https://py.bpbpanel.ip-ddns.com/https://nodejs.org/dist/v18.20.8/node-v18.20.8-x64.msi
set NODE_SOURCE5=https://w.dog.cloud-ip.biz/https://nodejs.org/dist/v18.20.8/node-v18.20.8-x64.msi

:: Cloudflare下载源
set CLOUDFLARE_SOURCE1=https://w.dog.cloud-ip.biz/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi
set CLOUDFLARE_SOURCE2=https://py.bpbpanel.ip-ddns.com/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi
set CLOUDFLARE_SOURCE3=https://proxy.bpbpanel.ip-ddns.com/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi
set CLOUDFLARE_SOURCE4=https://lkms-hpygbgjhfhc.hf.space/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi
set CLOUDFLARE_SOURCE5=https://lkms-hpygbgjhfhc.hf.space/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi
set CLOUDFLARE_SOURCE6=https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi  :: 原始源作为备用

:: 代码仓库源（新增四个源）
set REPO_SOURCE1=https://ww.js.elementfx.com/https://github.com/al198313148/W-share-p/archive/refs/heads/main.zip
set REPO_SOURCE2=https://lkms-hpygbgjhfhc.hf.space/https://github.com/al198313148/W-share-p/archive/refs/heads/main.zip
set REPO_SOURCE3=https://proxy.bpbpanel.ip-ddns.com/https://github.com/al198313148/W-share-p/archive/refs/heads/main.zip
set REPO_SOURCE4=https://py.bpbpanel.ip-ddns.com/https://github.com/al198313148/W-share-p/archive/refs/heads/main.zip
set REPO_SOURCE5=https://w.dog.cloud-ip.biz/https://github.com/al198313148/W-share-p/archive/refs/heads/main.zip
set REPO_SOURCE6=https://github.com/al198313148/W-share-p/archive/refs/heads/main.zip

:: 步骤1: 检查并创建share文件夹
echo [步骤1] 检查D:\share文件夹...
if not exist "%SHARE_DIR%" (
    echo 创建 %SHARE_DIR% 文件夹...
    mkdir "%SHARE_DIR%"
    echo √ 文件夹创建成功
) else (
    echo √ 文件夹已存在
)

cd /d "%SHARE_DIR%"

:: 清理可能存在的旧文件
if exist repo.zip del repo.zip >nul 2>&1
if exist "W-share-p-main" rmdir "W-share-p-main" /s /q >nul 2>&1

:: 下载代码仓库
echo.
echo [步骤1] 下载代码仓库...
set REPO_DOWNLOADED=0
set REPO_SOURCE_COUNT=0

echo 尝试从新增源下载代码仓库...
echo.

:: 尝试新增的四个源
for %%S in (
    "%REPO_SOURCE1%"
    "%REPO_SOURCE2%"
    "%REPO_SOURCE3%"
    "%REPO_SOURCE4%"
) do (
    if !REPO_DOWNLOADED! equ 0 (
        set /a REPO_SOURCE_COUNT+=1
        echo 尝试源!REPO_SOURCE_COUNT!：%%S
        curl -L -o repo.zip "%%S" >nul 2>&1
        if !errorlevel! equ 0 (
            if exist "repo.zip" (
                for /f %%i in ('powershell -Command "(Get-Item 'repo.zip').length"') do (
                    if %%i gtr 10000 (
                        echo √ 代码仓库下载成功（大小: %%i 字节）
                        set REPO_DOWNLOADED=1
                    ) else (
                        echo × 文件大小异常，继续尝试下一个源...
                        del repo.zip >nul 2>&1
                    )
                )
            )
        ) else (
            echo × 下载失败
        )
    )
)

:: 如果新增源都失败，尝试原始源
if !REPO_DOWNLOADED! equ 0 (
    echo.
    echo 所有新增源都不可用，尝试原始源...
    for %%S in (
        "%REPO_SOURCE5%"
        "%REPO_SOURCE6%"
    ) do (
        if !REPO_DOWNLOADED! equ 0 (
            set /a REPO_SOURCE_COUNT+=1
            echo 尝试备用源!REPO_SOURCE_COUNT!：%%S
            curl -L -o repo.zip "%%S" >nul 2>&1
            if !errorlevel! equ 0 (
                if exist "repo.zip" (
                    for /f %%i in ('powershell -Command "(Get-Item 'repo.zip').length"') do (
                        if %%i gtr 10000 (
                            echo √ 代码仓库下载成功（大小: %%i 字节）
                            set REPO_DOWNLOADED=1
                        )
                    )
                )
            ) else (
                echo × 下载失败
            )
        )
    )
)

if !REPO_DOWNLOADED! equ 0 (
    echo.
    echo × 所有代码仓库源都不可用
    pause
    exit /b 1
)

:: 解压代码文件
echo.
echo 解压代码文件到 %SHARE_DIR%...
powershell -Command "Expand-Archive -Path 'repo.zip' -DestinationPath '.' -Force" >nul 2>&1
if !errorlevel! equ 0 (
    echo √ 代码解压成功
    
    if exist "W-share-p-main" (
        echo 移动文件到根目录...
        xcopy "W-share-p-main\*" "." /s /e /y >nul 2>&1
        rmdir "W-share-p-main" /s /q >nul 2>&1
        echo √ 文件移动完成
    )
) else (
    echo × 解压失败
    pause
    exit /b 1
)

:: 清理zip文件
del repo.zip >nul 2>&1

:: 步骤2: 创建管理脚本（支持后台运行）
echo.
echo [步骤2] 创建管理脚本...

:: 创建daemon.vbs - 用于后台运行
echo Set ws = CreateObject("Wscript.Shell") > daemon.vbs
echo ws.currentdirectory = "D:\share" >> daemon.vbs
echo ws.run "node server.js", 0 >> daemon.vbs

echo √ 创建 daemon.vbs (后台运行脚本)

:: 创建start.bat - 启动应用（后台运行）
echo @echo off > start.bat
echo chcp 936 ^>nul >> start.bat
echo cd /d "D:\share" >> start.bat
echo echo 启动应用... >> start.bat
echo. >> start.bat
echo :: 方法1: 使用VBS后台运行 >> start.bat
echo echo 使用方法1: VBS后台运行 >> start.bat
echo start daemon.vbs >> start.bat
echo timeout /t 3 /nobreak ^>nul >> start.bat
echo. >> start.bat
echo :: 检查是否运行 >> start.bat
echo tasklist ^| findstr "node.exe" ^>nul >> start.bat
echo if errorlevel 1 ( >> start.bat
echo   echo × 应用未启动，使用方法2... >> start.bat
echo   echo 使用方法2: 独立的CMD窗口 >> start.bat
echo   start "PDF Share App" /MIN cmd /c "cd /d D:\share ^& node server.js ^& pause" >> start.bat
echo ) >> start.bat
echo. >> start.bat
echo echo √ 应用启动完成！ >> start.bat
echo echo 访问地址: http://localhost:3000 >> start.bat
echo echo 如需后台运行，请使用VBS脚本 >> start.bat
echo pause >> start.bat

:: 创建stop.bat - 停止应用
echo @echo off > stop.bat
echo chcp 936 ^>nul >> stop.bat
echo cd /d "D:\share" >> stop.bat
echo echo 停止应用... >> stop.bat
echo taskkill /F /IM node.exe /T ^>nul 2^>^&1 >> stop.bat
echo wscript //B //Nologo kill.vbs ^>nul 2^>^&1 >> stop.bat
echo timeout /t 2 /nobreak ^>nul >> stop.bat
echo echo √ 应用已停止 >> stop.bat
echo pause >> stop.bat

:: 创建kill.vbs - 用于彻底停止VBS进程
echo Set objWMIService = GetObject("winmgmts:\\.\root\cimv2") > kill.vbs
echo Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process where Name='wscript.exe' or Name='cscript.exe'") >> kill.vbs
echo For Each objProcess in colProcesses >> kill.vbs
echo     objProcess.Terminate() >> kill.vbs
echo Next >> kill.vbs

:: 创建restart.bat - 重启应用
echo @echo off > restart.bat
echo chcp 936 ^>nul >> restart.bat
echo cd /d "D:\share" >> restart.bat
echo echo 重启应用... >> restart.bat
echo call stop.bat ^>nul >> restart.bat
echo timeout /t 2 /nobreak ^>nul >> restart.bat
echo call start.bat ^>nul >> restart.bat
echo echo √ 应用已重启 >> restart.bat
echo pause >> restart.bat

:: 创建status.bat - 检查状态
echo @echo off > status.bat
echo chcp 936 ^>nul >> status.bat
echo cd /d "D:\share" >> status.bat
echo echo ======================================== >> status.bat
echo echo           应用状态检查 >> status.bat
echo echo ======================================== >> status.bat
echo echo. >> status.bat
echo echo [1] 检查Node.js进程... >> status.bat
echo tasklist ^| findstr "node.exe" >> status.bat
echo if errorlevel 1 echo × 没有Node.js进程在运行 >> status.bat
echo echo. >> status.bat
echo echo [2] 检查端口3000... >> status.bat
echo netstat -ano ^| findstr ":3000" >> status.bat
echo if errorlevel 1 echo × 端口3000未被占用 >> status.bat
echo echo. >> status.bat
echo echo [3] 测试应用连接... >> status.bat
echo curl -s -o nul -w "HTTP状态码: %%{http_code}" http://localhost:3000 --connect-timeout 3 >> status.bat
echo if errorlevel 1 echo × 应用未响应 >> status.bat
echo echo. >> status.bat
echo echo ======================================== >> status.bat
echo echo 建议： >> status.bat
echo echo 1. 普通启动：双击start.bat >> status.bat
echo echo 2. 访问地址: http://localhost:3000 >> status.bat
echo pause >> status.bat

echo √ 所有管理脚本创建完成

:: 步骤3: 创建开机启动脚本
echo.
echo [步骤3] 创建开机启动脚本...

:: 创建startup.bat（用于开机启动）
echo @echo off > startup.bat
echo chcp 936 ^>nul >> startup.bat
echo cd /d "D:\share" >> startup.bat
echo timeout /t 3 /nobreak ^>nul >> startup.bat
echo start daemon.vbs >> startup.bat
echo exit >> startup.bat

echo √ startup.bat 创建完成

:: 复制到启动文件夹
echo 复制startup.bat到启动目录...
if not exist "%STARTUP_DIR%" (
    mkdir "%STARTUP_DIR%" >nul 2>&1
)
copy "startup.bat" "%STARTUP_DIR%\" >nul 2>&1
if !errorlevel! equ 0 (
    echo √ startup.bat 已复制到启动目录
) else (
    echo × 复制到启动目录失败
)

:: 步骤4: 检查并安装Node.js（使用新增源）
echo.
echo [步骤4] 检查并安装Node.js（使用新增源）...
where node >nul 2>&1
if !errorlevel! equ 0 (
    echo √ Node.js已安装
    goto CHECK_NPM
)

echo × Node.js未安装，正在从新增源下载安装...

:: 尝试从新增的四个源下载Node.js
set NODE_DOWNLOADED=0
set NODE_SOURCE_COUNT=0

for %%S in (
    "%NODE_SOURCE1%"
    "%NODE_SOURCE2%"
    "%NODE_SOURCE3%"
    "%NODE_SOURCE4%"
    "%NODE_SOURCE5%"
) do (
    if !NODE_DOWNLOADED! equ 0 (
        set /a NODE_SOURCE_COUNT+=1
        echo 尝试Node.js源!NODE_SOURCE_COUNT!...
        curl -L -o node-installer.msi "%%S" >nul 2>&1
        if !errorlevel! equ 0 (
            if exist "node-installer.msi" (
                for /f %%i in ('powershell -Command "(Get-Item 'node-installer.msi').length"') do (
                    if %%i gtr 1000000 (
                        echo √ Node.js下载成功（大小: %%i 字节）
                        echo 安装Node.js...
                        msiexec /i node-installer.msi /quiet /qn /norestart
                        echo √ Node.js安装完成
                        del node-installer.msi >nul 2>&1
                        set NODE_DOWNLOADED=1
                        
                        :: 等待安装完成并刷新环境变量
                        echo 等待安装完成...
                        timeout /t 10 /nobreak >nul
                        echo 刷新环境变量...
                        set "PATH=C:\Program Files\nodejs;%PATH%"
                    ) else (
                        echo × 文件大小异常，继续尝试下一个源...
                        del node-installer.msi >nul 2>&1
                    )
                )
            )
        ) else (
            echo × 下载失败
        )
    )
)

if !NODE_DOWNLOADED! equ 0 (
    echo × 所有Node.js源都不可用
    echo 请手动安装Node.js: https://nodejs.org/
    goto SKIP_NODE
)

:CHECK_NPM
:: 检查npm
where npm >nul 2>&1
if !errorlevel! equ 0 (
    echo √ npm可用
) else (
    echo × npm不可用
)

:SKIP_NODE

:: 步骤5: 安装npm依赖
echo.
echo [步骤5] 安装npm依赖...

cd /d "%SHARE_DIR%"

:: 检查node是否可用
where node >nul 2>&1
if !errorlevel! neq 0 (
    echo × Node.js未找到，跳过npm安装
    goto SKIP_NPM
)

echo √ Node.js可用，安装依赖...

:: 安装项目依赖
call npm install >nul 2>&1
if !errorlevel! equ 0 (
    echo √ 项目依赖安装完成
) else (
    echo × 项目依赖安装失败
    echo 正在尝试使用淘宝镜像...
    call npm install --registry=https://registry.npmmirror.com >nul 2>&1
    if !errorlevel! equ 0 (
        echo √ 使用淘宝镜像安装成功
    ) else (
        echo × 所有安装方式都失败
    )
)

:SKIP_NPM

:: 步骤6: 检查并安装Cloudflared（使用新增源）
echo.
echo [步骤6] 检查并安装Cloudflared（使用新增源）...

where cloudflared >nul 2>&1
if !errorlevel! equ 0 (
    echo √ Cloudflared已安装
) else (
    echo × Cloudflared未安装，正在从新增源下载安装...
    
    :: 尝试从新增的五个源下载Cloudflared
    set CLOUDFLARE_DOWNLOADED=0
    set CLOUDFLARE_SOURCE_COUNT=0
    
    for %%S in (
        "%CLOUDFLARE_SOURCE1%"
        "%CLOUDFLARE_SOURCE2%"
        "%CLOUDFLARE_SOURCE3%"
        "%CLOUDFLARE_SOURCE4%"
        "%CLOUDFLARE_SOURCE5%"
        "%CLOUDFLARE_SOURCE6%"
    ) do (
        if !CLOUDFLARE_DOWNLOADED! equ 0 (
            set /a CLOUDFLARE_SOURCE_COUNT+=1
            echo 尝试Cloudflared源!CLOUDFLARE_SOURCE_COUNT!...
            curl -L -o cloudflared.msi "%%S" >nul 2>&1
            if !errorlevel! equ 0 (
                if exist "cloudflared.msi" (
                    for /f %%i in ('powershell -Command "(Get-Item 'cloudflared.msi').length"') do (
                        if %%i gtr 1000000 (
                            echo √ Cloudflared下载成功（大小: %%i 字节）
                            echo 安装Cloudflared...
                            msiexec /i cloudflared.msi /quiet /qn /norestart
                            echo √ Cloudflared安装完成
                            del cloudflared.msi >nul 2>&1
                            set CLOUDFLARE_DOWNLOADED=1
                            
                            :: 等待安装完成
                            echo 等待安装完成...
                            timeout /t 5 /nobreak >nul
                            echo 刷新环境变量...
                            set "PATH=C:\Program Files\Cloudflare\Cloudflared;%PATH%"
                        ) else (
                            echo × 文件大小异常，继续尝试下一个源...
                            del cloudflared.msi >nul 2>&1
                        )
                    )
                )
            ) else (
                echo × 下载失败
            )
        )
    )
    
    if !CLOUDFLARE_DOWNLOADED! equ 0 (
        echo × 所有Cloudflared源都不可用
    )
)

:: 步骤7: 设置计划任务确保后台运行
echo.
echo [步骤7] 设置计划任务确保后台运行...

echo 创建后台运行计划任务...
schtasks /create /tn "PDFShareApp" /tr "D:\share\daemon.vbs" /sc onlogon /ru SYSTEM /f >nul 2>&1
if !errorlevel! equ 0 (
    echo √ 计划任务创建成功
) else (
    echo × 计划任务创建失败，使用启动文件夹方式
)

:: 步骤8: 立即启动应用测试
echo.
echo [步骤8] 测试启动应用...

cd /d "%SHARE_DIR%"

:: 停止可能正在运行的应用
taskkill /F /IM node.exe /T >nul 2>&1
wscript //B //Nologo kill.vbs >nul 2>&1
timeout /t 2 /nobreak >nul

:: 使用VBS后台启动
echo 使用VBS后台启动应用...
start daemon.vbs
timeout /t 5 /nobreak >nul

:: 检查是否运行成功
echo 检查应用状态...
tasklist | findstr "node.exe" >nul 2>&1
if !errorlevel! equ 0 (
    echo √ 应用正在后台运行！
    
    :: 测试连接
    echo 测试应用连接...
    curl -s -o nul http://localhost:3000 --connect-timeout 5
    if !errorlevel! equ 0 (
        echo √ 应用响应正常
        echo 访问地址: http://localhost:3000
    ) else (
        echo × 应用未响应（可能需要更多时间启动）
    )
) else (
    echo × 应用未能后台启动
    
    :: 尝试替代方法
    echo 尝试替代启动方法...
    echo 打开独立窗口运行...
    start "PDF Share App" /MIN cmd /c "cd /d D:\share ^& node server.js ^& pause"
    timeout /t 3 /nobreak >nul
    
    tasklist | findstr "node.exe" >nul 2>&1
    if !errorlevel! equ 0 (
        echo √ 应用在独立窗口中运行
    ) else (
        echo × 所有启动方式都失败
        echo 请手动运行: node server.js
    )
)

:: 完成部署
echo.
echo ========================================
echo           部署完成！
echo ========================================
echo.
echo 重要信息：
echo 1. 应用已配置为后台运行
echo 2. 开机自启动已设置
echo 3. 管理脚本已创建
echo 4. Node.js和Cloudflared已检查/安装
echo.
echo 管理脚本说明：
echo 1. start.bat            - 启动应用（尝试后台运行）
echo 2. stop.bat             - 停止应用
echo 3. restart.bat          - 重启应用
echo 4. status.bat           - 检查应用状态
echo.
echo 确保后台运行的方法：
echo 1. 使用VBS脚本后台运行 (daemon.vbs)
echo 2. 设置计划任务自动启动
echo 3. 复制startup.bat到启动文件夹
echo.
echo 访问地址: http://localhost:3000
echo.
echo ========================================
echo 按任意键查看当前运行状态...
pause >nul

:: 显示当前状态
cls
echo ========================================
echo           当前应用状态
echo ========================================
echo.
cd /d "%SHARE_DIR%"
call status.bat

:: 显示Cloudflared服务状态
echo.
echo ========================================
echo       Cloudflared服务状态
echo ========================================
sc query Cloudflared 2>nul
if errorlevel 1060 (
    echo × Cloudflared服务未安装
) else if errorlevel 0 (
    echo √ Cloudflared服务信息如上
)
echo.
echo 按任意键退出...
pause >nul