::公共资源目录
set publicdir=public

::公共主片头片尾文件名
set headerFile=header.mp4
set footerFile=footer.mp4

::临时片头文件名(不带扩展名)(会自动适应视频宽高)(会存放在产出目录下)
set tempHeaderFileName=tempheader
set tempFooterFileName=tempfooter

echo ************[PTOOLS-AUTOVIDEROPROCESS-ADDITIONHEADER %version%]************
echo 注：同目录下存放mp4视频
echo 注：公共目录下要有片头片尾文件
::存储处理后的视频目录，不存在自动创建目录
set /p newdir=输入存储目录名(输入"."则为"output")：
::视频宽度，用于使片头适应视频源尺寸
set /p mainW=视频的帧宽度(写错会导致片头与视频源帧不同尺寸)：
::视频高度，用于使片头适应视频源尺寸
set /p mainH=视频的帧高度(写错会导致片头与视频源帧不同尺寸)：
::询问是否记录文件完整性报告
set /p isWriteReport=是否写文件完整性报告(y/n)：

if %newdir%==. (
	set newdir=output
)

mkdir %newdir%
echo 执行过程记录表>%newdir%\过程记录.txt
::生成适应视频宽高片头
::header
ffmpeg -i %publicdir%\%headerFile% -vf "scale=%mainW%:%mainH%" %newdir%\%tempHeaderFileName%.mp4
ffmpeg -i %newdir%\%tempHeaderFileName%.mp4 -vcodec copy -acodec copy -vbsf h264_mp4toannexb %newdir%\%tempHeaderFileName%.ts
del %newdir%\%tempHeaderFileName%.mp4
::footer
ffmpeg -i %publicdir%\%footerFile% -vf "scale=%mainW%:%mainH%" %newdir%\%tempFooterFileName%.mp4
ffmpeg -i %newdir%\%tempFooterFileName%.mp4 -vcodec copy -acodec copy -vbsf h264_mp4toannexb %newdir%\%tempFooterFileName%.ts
del %newdir%\%tempFooterFileName%.mp4
for /f "delims=" %%a in ('dir /b *.mp4') do (
echo processing:%%a>>%newdir%\过程记录.txt
ffmpeg -i %%a -vcodec copy -acodec copy -vbsf h264_mp4toannexb %newdir%\%%a.ts
ffmpeg -i "concat:%newdir%\%tempHeaderFileName%.ts|%newdir%\%%a.ts|%newdir%\%tempFooterFileName%.ts" -acodec copy -vcodec copy -absf aac_adtstoasc %newdir%\%%a
del %newdir%\%%a.ts
echo success:%%a>>%newdir%\过程记录.txt
)
del %newdir%\%tempHeaderFileName%.ts
del %newdir%\%tempFooterFileName%.ts
::生成检查完整性
if not %isWriteReport%==y goto behindWriteReport
echo 文件完整性报告>%newdir%\文件完整性报告.txt
echo file_Exist:file_Name>>%newdir%\文件完整性报告.txt
for /f "delims=" %%i in ('dir /b *.mp4') do (
if exist %newdir%\%%i (echo true:%%i>>%newdir%\文件完整性报告.txt) else echo false:%%i>>%newdir%\文件完整性报告.txt
)
:behindWriteReport 