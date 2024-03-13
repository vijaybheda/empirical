bool validateEmail(String email, bool emailError) {
  if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email) &&
      email.isNotEmpty) {
    return emailError = false;
  } else {
    return emailError = true;
  }
}

String validatePassword(String password, String cpassword) {
  if (RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(password) &&
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(cpassword) &&
      password.isNotEmpty &&
      cpassword.isNotEmpty) {
    if (password == cpassword) {
      return "Valid Password";
    } else {
      return "Password Mismatch";
    }
  } else {
    return "Invalid Format";
  }
}

String checkPassword(String password) {
  if (RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(password) &&
      password.isNotEmpty) {
    return "Valid Password";
  } else {
    return "Invalid Password";
  }
}
