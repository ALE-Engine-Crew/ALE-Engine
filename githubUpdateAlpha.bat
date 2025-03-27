@echo off

title GitHub Update

echo Add all changes to git

git add .

set /p commitMessage=Enter commit name: 

echo Running git commit with the provided name...

git commit -m "%commitMessage%"

echo Pushing to the 'alpha' branch...

git push origin alpha

echo Finished!

pause
