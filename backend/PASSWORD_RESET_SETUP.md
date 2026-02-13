# Password Reset Setup Guide

## What I Created

1. **Database migration** (`src/db/migrations/add_password_reset.sql`)
   - Creates `password_reset_tokens` table
   - Adds indexes for fast lookups
   - Includes cleanup function for expired tokens

2. **Password reset routes** (`src/routes/passwordReset.js`)
   - `POST /auth/reset-password-request` - User requests reset
   - `POST /auth/reset-password` - User completes reset with token
   - `GET /auth/reset-password/verify/:token` - iOS app verifies token before showing form

3. **Email utility** (`src/utils/email.js`)
   - Sends password reset emails via Resend API
   - Professional HTML email template
   - 15-minute expiration warning

4. **Updated server.js** - Routes are now registered

---

## Setup Steps

### 1. Install Resend Package

```bash
cd ~/projects/ctf-game/backend
npm install resend
```

### 2. Get Resend API Key

1. Go to [resend.com](https://resend.com) and sign up (free tier: 100 emails/day)
2. Create an API key
3. Add to your `.env` file:

```env
RESEND_API_KEY=re_xxxxxxxxxxxx
FROM_EMAIL=CTF Game <noreply@yourdomain.com>
APP_URL=http://localhost:3000
```

**Note:** For production, you'll need to:
- Verify your domain with Resend
- Update `FROM_EMAIL` to use your domain
- Update `APP_URL` to your production URL

For testing, you can use Resend's test email addresses.

### 3. Run Database Migration

```bash
# If using Supabase:
# Copy the SQL from add_password_reset.sql and run in Supabase SQL editor

# If using local PostgreSQL:
psql ctf_game < src/db/migrations/add_password_reset.sql
```

### 4. Test It

**Request password reset:**
```bash
curl -X POST http://localhost:3000/auth/reset-password-request \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

**Complete password reset:**
```bash
curl -X POST http://localhost:3000/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "uuid-from-email",
    "newPassword": "NewSecurePassword123!"
  }'
```

---

## iOS Integration

### 1. Forgot Password Screen

```swift
func requestPasswordReset(email: String) async throws {
    let url = URL(string: "\(apiBaseUrl)/auth/reset-password-request")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = ["email": email]
    request.httpBody = try JSONEncoder().encode(body)
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.requestFailed
    }
    
    // Show success message: "Check your email for reset link"
}
```

### 2. Deep Link Handler

Add URL scheme to handle `ctfgame://reset-password?token=xxx` links:

```swift
// In Info.plist, add URL scheme: ctfgame

// In App.swift or SceneDelegate:
.onOpenURL { url in
    if url.scheme == "ctfgame", 
       url.host == "reset-password",
       let token = url.queryParameters["token"] {
        // Navigate to ResetPasswordView with token
    }
}
```

### 3. Reset Password View

```swift
func resetPassword(token: String, newPassword: String) async throws {
    let url = URL(string: "\(apiBaseUrl)/auth/reset-password")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = [
        "token": token,
        "newPassword": newPassword
    ]
    request.httpBody = try JSONEncoder().encode(body)
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.resetFailed
    }
    
    // Success! Navigate to login screen
}
```

---

## Security Features

✅ **Token expiration** - Links expire after 15 minutes  
✅ **One-time use** - Tokens can't be reused  
✅ **Email enumeration protection** - Always returns success message  
✅ **Session invalidation** - All existing sessions logged out after reset  
✅ **Automatic cleanup** - Expired tokens cleaned up via DB function  

---

## Email Customization

Edit `src/utils/email.js` to customize:
- Email subject line
- HTML template styling
- Company branding
- Reset link format

---

## Production Checklist

- [ ] Set up custom domain with Resend
- [ ] Update `FROM_EMAIL` to use verified domain
- [ ] Update `APP_URL` to production URL
- [ ] Set up email monitoring/alerts
- [ ] Configure rate limiting on reset endpoint (already in place for /auth routes)
- [ ] Add CAPTCHA to reset request form (optional, prevents abuse)

---

## Cost

**Resend Free Tier:**
- 100 emails/day
- 3,000 emails/month
- No credit card required

**If you exceed:**
- $1 per 1,000 additional emails

For 1000 users, password resets should be minimal (~1-5% of users/month = well within free tier).
