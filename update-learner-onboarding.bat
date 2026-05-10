@echo off
REM Update learner onboarding status in DynamoDB
REM Replace LEARNER_ID with the actual learnerId from your database

SET LEARNER_ID=YOUR_LEARNER_ID_HERE

echo Updating learner onboarding status for: %LEARNER_ID%

aws dynamodb update-item ^
    --table-name hg-learner-onboarding ^
    --key "{\"learnerId\": {\"S\": \"%LEARNER_ID%\"}}" ^
    --update-expression "SET onboardingComplete = :complete, currentStep = :step, updatedAt = :updated" ^
    --expression-attribute-values "{\":complete\": {\"BOOL\": true}, \":step\": {\"S\": \"completed\"}, \":updated\": {\"S\": \"%date:~-4%-%date:~4,2%-%date:~7,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%Z\"}}" ^
    --region ap-south-1 ^
    --return-values ALL_NEW

echo.
echo ✅ Onboarding status updated successfully!
pause
