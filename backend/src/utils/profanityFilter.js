// Simple profanity filter for usernames
// This is a basic implementation - for production, consider using a library like 'bad-words'

const profaneWords = [
  // Common profanity
  'fuck', 'shit', 'damn', 'hell', 'ass', 'bitch', 'bastard', 'crap',
  'dick', 'cock', 'pussy', 'cunt', 'twat', 'slut', 'whore',
  
  // Variations and common substitutions
  'fck', 'fuk', 'fvck', 'f*ck', 'sh*t', 'b*tch', 'a$$',
  'azz', 'biatch', 'biotch', 'phuck', 'phuk',
  
  // Slurs (basic list - expand as needed)
  'nigger', 'nigga', 'spic', 'chink', 'kike', 'fag', 'faggot',
  'retard', 'retarded', 'tranny',
  
  // Add more as needed
  'porn', 'xxx', 'sex', 'rape', 'nazi', 'hitler',
  'kill', 'murder', 'terrorist', 'bomb'
];

// Pattern-based detection for l33t speak and obfuscation
const obfuscationPatterns = [
  { pattern: /f[u*@#$%^&]ck/gi, word: 'fuck' },
  { pattern: /sh[i!1*]t/gi, word: 'shit' },
  { pattern: /b[i!1*]tch/gi, word: 'bitch' },
  { pattern: /a[s$5]s/gi, word: 'ass' },
  { pattern: /d[i!1]ck/gi, word: 'dick' },
  { pattern: /n[i!1]gg[ae]r/gi, word: 'slur' },
  { pattern: /f[a@]g/gi, word: 'slur' }
];

/**
 * Check if a string contains profanity
 * @param {string} text - Text to check
 * @returns {boolean} - True if profanity found
 */
function containsProfanity(text) {
  if (!text || typeof text !== 'string') {
    return false;
  }
  
  const lowerText = text.toLowerCase();
  
  // Check against word list (whole word matches only)
  for (const word of profaneWords) {
    const regex = new RegExp(`\\b${word}\\b`, 'i');
    if (regex.test(lowerText)) {
      return true;
    }
  }
  
  // Check obfuscation patterns
  for (const { pattern } of obfuscationPatterns) {
    if (pattern.test(text)) {
      return true;
    }
  }
  
  return false;
}

/**
 * Validate username against profanity and other rules
 * @param {string} username - Username to validate
 * @returns {{valid: boolean, error?: string}} - Validation result
 */
function validateUsername(username) {
  if (!username || typeof username !== 'string') {
    return { valid: false, error: 'Username is required' };
  }
  
  // Trim whitespace
  username = username.trim();
  
  // Length check
  if (username.length < 3) {
    return { valid: false, error: 'Username must be at least 3 characters' };
  }
  
  if (username.length > 20) {
    return { valid: false, error: 'Username must be 20 characters or less' };
  }
  
  // Alphanumeric + basic characters
  if (!/^[a-zA-Z0-9_-]+$/.test(username)) {
    return { valid: false, error: 'Username can only contain letters, numbers, underscores, and hyphens' };
  }
  
  // Profanity check
  if (containsProfanity(username)) {
    return { valid: false, error: 'Username contains inappropriate language' };
  }
  
  // Reserved words
  const reserved = ['admin', 'moderator', 'system', 'official', 'staff', 'support', 'root'];
  if (reserved.includes(username.toLowerCase())) {
    return { valid: false, error: 'This username is reserved' };
  }
  
  return { valid: true };
}

/**
 * Sanitize a string by replacing profanity with asterisks
 * @param {string} text - Text to sanitize
 * @returns {string} - Sanitized text
 */
function sanitize(text) {
  if (!text || typeof text !== 'string') {
    return text;
  }
  
  let sanitized = text;
  
  // Replace profane words
  for (const word of profaneWords) {
    const regex = new RegExp(`\\b${word}\\b`, 'gi');
    sanitized = sanitized.replace(regex, '*'.repeat(word.length));
  }
  
  // Replace obfuscated patterns
  for (const { pattern, word } of obfuscationPatterns) {
    sanitized = sanitized.replace(pattern, '*'.repeat(word.length));
  }
  
  return sanitized;
}

module.exports = {
  containsProfanity,
  validateUsername,
  sanitize
};
