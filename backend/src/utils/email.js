const { Resend } = require('resend');

// Initialize Resend client
const resend = new Resend(process.env.RESEND_API_KEY);

/**
 * Send password reset email
 * @param {string} email - Recipient email address
 * @param {string} username - User's username
 * @param {string} resetToken - Password reset token
 */
async function sendPasswordResetEmail(email, username, resetToken) {
  // Construct reset URL (update with your actual app URL)
  const resetUrl = `${process.env.APP_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;

  try {
    const { data, error } = await resend.emails.send({
      from: process.env.FROM_EMAIL || 'CTF Game <noreply@yourdomain.com>',
      to: [email],
      subject: 'Reset Your Password',
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
          </head>
          <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background-color: #f4f4f4; padding: 20px; border-radius: 8px;">
              <h1 style="color: #2c3e50; margin-top: 0;">Password Reset Request</h1>
              
              <p>Hi ${username},</p>
              
              <p>We received a request to reset your password for your CTF Game account. If you didn't make this request, you can safely ignore this email.</p>
              
              <p>To reset your password, click the button below:</p>
              
              <div style="text-align: center; margin: 30px 0;">
                <a href="${resetUrl}" 
                   style="background-color: #3498db; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; font-weight: bold;">
                  Reset Password
                </a>
              </div>
              
              <p style="color: #666; font-size: 14px;">Or copy and paste this link into your browser:</p>
              <p style="color: #3498db; word-break: break-all; font-size: 14px;">${resetUrl}</p>
              
              <p style="color: #e74c3c; font-weight: bold; margin-top: 30px;">⏰ This link will expire in 15 minutes.</p>
              
              <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
              
              <p style="color: #666; font-size: 12px;">
                If you didn't request this password reset, please ignore this email or contact support if you have concerns.
              </p>
              
              <p style="color: #666; font-size: 12px;">
                — The CTF Game Team
              </p>
            </div>
          </body>
        </html>
      `,
    });

    if (error) {
      console.error('Failed to send password reset email:', error);
      throw new Error('Failed to send email');
    }

    console.log('Password reset email sent:', data);
    return data;
  } catch (error) {
    console.error('Email sending error:', error);
    throw error;
  }
}

module.exports = {
  sendPasswordResetEmail,
};
