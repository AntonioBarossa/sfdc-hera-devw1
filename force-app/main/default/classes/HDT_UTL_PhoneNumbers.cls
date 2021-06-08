public inherited sharing class HDT_UTL_PhoneNumbers {

    // N.B. Marketing Cloud può inviare SMS solo a numeri italiani,
    // quindi l'unico prefisso internazionale valido è '39'

    // Un cellulare italiano può avere al massimo 10 cifre.
    // Assumiamo che il numero in input non contiene il prefisso internazionale.
    public static String validateMobileNumber(String phone) {
        
        if (String.isBlank(phone)) {
            return 'Nessun numero di telefono inserito.'; 
        }
        
        if (!phone.isNumeric()) {
            return 'Il numero di cellulare deve contenere solo numeri.'; 
        }

        if (phone.length() > 10) {
            return 'Il numero di cellulare non può avere più di 10 cifre.'; 
        }

        if (phone.length() < 9) {
            return 'Il numero di cellulare non può avere meno di 9 cifre.'; 
        }

        return '';
    }

    public static String validatePhoneNumber(String phone) {
        
        if (String.isBlank(phone)) {
            return 'Nessun numero di telefono inserito.'; 
        }
        
        if (!phone.isNumeric()) {
            return 'Il numero di telefono fisso deve contenere solo numeri.'; 
        }

        if (phone.length() > 11) {
            return 'Il numero di telefono fisso non può avere più di 11 cifre.'; 
        }

        if (phone.length() < 6) {
            return 'Il numero di telefono fisso non può avere meno di 6 cifre.'; 
        }

        if (!phone.startsWith('0')) {
            return 'Il numero di telefono fisso deve iniziare con uno "0".'; 
        }

        return '';
    }

    public static Boolean isValidMobile(String phone) {
        return String.isEmpty(validateMobileNumber(phone));
    }

    public static Boolean isValidMobileWithPrefix(String phone) {
        // Rimuoviamo il prefisso 39 e verifichiamo se il numero è valido.
        return phone.startsWith('39') && isValidMobile(phone.substring(2));
    }

    public static String withInternationPrefix(String phone) {
        if (isValidMobile(phone)) {
            return '39' + phone;
        }

        return phone;
    }

    public static String withoutInternationPrefix(String phone) {

        if (isValidMobileWithPrefix(phone)) {
            return phone.substring(2);
        }

        return phone;
    }


}
