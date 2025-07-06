class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} harus diisi';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    
    // Remove all non-digit characters
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.length < 10 || cleanValue.length > 15) {
      return 'Nomor telepon tidak valid';
    }
    
    return null;
  }

  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} harus diisi';
    }
    
    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'Field'} harus berupa angka';
    }
    
    return null;
  }

  static String? positiveNumber(String? value, [String? fieldName]) {
    final numberValidation = number(value, fieldName);
    if (numberValidation != null) return numberValidation;
    
    final numValue = int.parse(value!);
    if (numValue <= 0) {
      return '${fieldName ?? 'Field'} harus lebih dari 0';
    }
    
    return null;
  }

  static String? price(String? value) {
    return positiveNumber(value, 'Harga');
  }

  static String? stock(String? value) {
    final numberValidation = number(value, 'Stok');
    if (numberValidation != null) return numberValidation;
    
    final numValue = int.parse(value!);
    if (numValue < 0) {
      return 'Stok tidak boleh negatif';
    }
    
    return null;
  }

  static String? url(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'URL'} harus diisi';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return '${fieldName ?? 'URL'} tidak valid';
    }
    
    return null;
  }

  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kode pos harus diisi';
    }
    
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.length != 5) {
      return 'Kode pos harus 5 digit';
    }
    
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    
    if (value != originalPassword) {
      return 'Password tidak cocok';
    }
    
    return null;
  }

  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} harus diisi';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Field'} minimal $minLength karakter';
    }
    
    return null;
  }

  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty values, use required() for mandatory fields
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'Field'} maksimal $maxLength karakter';
    }
    
    return null;
  }
}
