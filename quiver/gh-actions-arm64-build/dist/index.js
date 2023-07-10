const bcrypt = require('bcrypt');

exports.handler = async (event, context) => {
    const password = "PlainTextPassword";
  
    try {
      // Generate a salt to use for hashing
      const saltRounds = 10;
      const salt = await bcrypt.genSalt(saltRounds);
  
      // Hash the password using the generated salt
      const hashedPassword = await bcrypt.hash(password, salt);
  
      // Return the hashed password
      return {
        statusCode: 200,
        body: JSON.stringify({password,hashedPassword})
      };
    } catch (error) {
      console.error(error);
      throw error;
    }
};