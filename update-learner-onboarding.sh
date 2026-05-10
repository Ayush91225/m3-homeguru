#!/bin/bash

# Update learner onboarding status in DynamoDB
# Replace LEARNER_ID with the actual learnerId from your database

LEARNER_ID="YOUR_LEARNER_ID_HERE"

echo "Updating learner onboarding status for: $LEARNER_ID"

aws dynamodb update-item \
    --table-name hg-learner-onboarding \
    --key "{\"learnerId\": {\"S\": \"$LEARNER_ID\"}}" \
    --update-expression "SET onboardingComplete = :complete, currentStep = :step, updatedAt = :updated" \
    --expression-attribute-values '{
        ":complete": {"BOOL": true},
        ":step": {"S": "completed"},
        ":updated": {"S": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'"}
    }' \
    --region ap-south-1 \
    --return-values ALL_NEW

echo "✅ Onboarding status updated successfully!"
