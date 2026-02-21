/// Holds the current admin session so the shell and routes can preserve it when navigating.
class CurrentAdminHolder {
  CurrentAdminHolder._();

  static String? adminId;
  static String? adminName;
  static String? adminEmail;
  static String? adminRole;

  static void set(String id, {String? name, String? email, String? role}) {
    adminId = id;
    if (name != null) adminName = name;
    if (email != null) adminEmail = email;
    if (role != null) adminRole = role;
  }

  static void clear() {
    adminId = null;
    adminName = null;
    adminEmail = null;
    adminRole = null;
  }
}
