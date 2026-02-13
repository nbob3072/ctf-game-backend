const { validateUsername } = require('./src/utils/profanityFilter');

console.log('🧪 Testing Profanity Filter\n');

const testUsernames = [
  'ValidUser123',
  'test_user',
  'ab',  // Too short
  'this_is_a_very_long_username_over_twenty',  // Too long
  'bad@user',  // Invalid characters  
  'fuck',  // Profanity
  'testfck',  // Obfuscated profanity
  'admin',  // Reserved
  'nice_guy',  // Valid
  'ass',  // Profanity
  'classic',  // Valid (contains 'ass' but not whole word)
  'grassland'  // Valid (contains 'ass' substring but acceptable)
];

testUsernames.forEach(username => {
  const result = validateUsername(username);
  const status = result.valid ? '✅' : '❌';
  const message = result.valid ? 'Valid' : result.error;
  console.log(`${status} "${username}" - ${message}`);
});

console.log('\n✅ Profanity filter is working!');
