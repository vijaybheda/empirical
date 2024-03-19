bool validateEmail(String email) {
  if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email) &&
      email.isNotEmpty) {
    return false;
  } else {
    return true;
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

bool checkPassword(String password) {
  if (RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(password) &&
      password.isNotEmpty) {
    return true;
  } else {
    return false;
  }
}
