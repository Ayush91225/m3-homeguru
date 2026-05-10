@echo off
REM Find and update learner onboarding status by email

SET EMAIL=YOUR_EMAIL_HERE

echo Searching for learner with email: %EMAIL%
echo.

REM First, scan to find the learner by email
aws dynamodb scan ^
    --table-name hg-learner-onboarding ^
    --filter-expression "email = :email" ^
    --expression-attribute-values "{\":email\": {\"S\": \"%EMAIL%\"}}" ^
    --region ap-south-1 ^
    --output json > temp_learner.json

echo.
echo Found learner data saved to temp_learner.json
echo.
echo Please check the file for learnerId, then run:
echo.
echo aws dynamodb update-item --table-name hg-learner-onboarding --key "{\"learnerId\": {\"S\": \"LEARNER_ID_FROM_FILE\"}}" --update-expression "SET onboardingComplete = :complete, currentStep = :step" --expression-attribute-values "{\":complete\": {\"BOOL\": true}, \":step\": {\"S\": \"completed\"}}" --region ap-south-1
echo.
pause
