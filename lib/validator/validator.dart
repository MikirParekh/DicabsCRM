String? validateUserCode(String? value) {
  // if (value == null || value.isEmpty) {
  //   return 'Please enter your email';
  // }
  // final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  // if (!emailRegex.hasMatch(value)) {
  //   return 'Please enter a valid email';
  // }
  // return null;
}


String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  // if (value.length < 8) {
  //   return 'Password must be at least 8 characters long';
  // }
  // if (!RegExp(r'[A-Z]').hasMatch(value)) {
  //   return 'Password must contain at least one uppercase letter';
  // }
  // if (!RegExp(r'[a-z]').hasMatch(value)) {
  //   return 'Password must contain at least one lowercase letter';
  // }
  // if (!RegExp(r'[0-9]').hasMatch(value)) {
  //   return 'Password must contain at least one number';
  // }
  // if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
  //   return 'Password must contain at least one special character (e.g., !, @, #, \$, &, *)';
  // }
  return null;
}