#!/bin/bash

# Test CTF Game Backend API
API_URL="https://ctf-game-backend-production.up.railway.app/api"

echo "Testing CTF Game Backend API..."
echo "================================"

echo -e "\n1. Health Check:"
curl -s "$API_URL/../health" | jq

echo -e "\n2. Get Teams:"
curl -s "$API_URL/teams" | jq

echo -e "\n3. Register Test User:"
TIMESTAMP=$(date +%s)
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"testuser${TIMESTAMP}\",
    \"email\": \"test${TIMESTAMP}@example.com\",
    \"password\": \"password123\",
    \"teamId\": 1
  }")
echo "$REGISTER_RESPONSE" | jq

# Extract token if registration successful
TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.token // empty')

if [ -n "$TOKEN" ]; then
  echo -e "\n4. Get Nearby Flags (with auth):"
  curl -s "$API_URL/flags?latitude=40.3573&longitude=-74.6672&radius=5000" \
    -H "Authorization: Bearer $TOKEN" | jq
  
  echo -e "\n5. Get Leaderboard:"
  curl -s "$API_URL/leaderboard?type=global&limit=10" \
    -H "Authorization: Bearer $TOKEN" | jq
else
  echo -e "\n⚠️  Registration failed, skipping authenticated endpoints"
fi

echo -e "\nDone!"
