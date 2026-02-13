// Input validation helpers

function validateEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

function validateUsername(username) {
  // 3-50 characters, alphanumeric + underscore
  const regex = /^[a-zA-Z0-9_]{3,50}$/;
  return regex.test(username);
}

function validatePassword(password) {
  // At least 8 characters
  return password && password.length >= 8;
}

function validateCoordinates(lat, lng) {
  const latitude = parseFloat(lat);
  const longitude = parseFloat(lng);
  
  return (
    !isNaN(latitude) &&
    !isNaN(longitude) &&
    latitude >= -90 &&
    latitude <= 90 &&
    longitude >= -180 &&
    longitude <= 180
  );
}

// Middleware factory for validation
function validateRequest(schema) {
  return (req, res, next) => {
    const errors = [];

    for (const [field, rules] of Object.entries(schema)) {
      const value = req.body[field];

      if (rules.required && !value) {
        errors.push(`${field} is required`);
        continue;
      }

      if (value && rules.type) {
        if (rules.type === 'email' && !validateEmail(value)) {
          errors.push(`${field} must be a valid email`);
        }
        if (rules.type === 'username' && !validateUsername(value)) {
          errors.push(`${field} must be 3-50 alphanumeric characters`);
        }
        if (rules.type === 'password' && !validatePassword(value)) {
          errors.push(`${field} must be at least 8 characters`);
        }
      }

      if (value && rules.min && value.length < rules.min) {
        errors.push(`${field} must be at least ${rules.min} characters`);
      }

      if (value && rules.max && value.length > rules.max) {
        errors.push(`${field} must be at most ${rules.max} characters`);
      }
    }

    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }

    next();
  };
}

module.exports = {
  validateEmail,
  validateUsername,
  validatePassword,
  validateCoordinates,
  validateRequest,
};
