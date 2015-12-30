del "minna-no-fighting-game.zip"
del "minna-no-fighting-game.love"
"C:\Program Files\7-Zip\7z.exe" a "minna-no-fighting-game.zip" * "-x!makeLove.*" "-x!assets\sprites\*.ase" "-x!*.zip" "-x!*.love"
ren "minna-no-fighting-game.zip" "minna-no-fighting-game.love"
pause
