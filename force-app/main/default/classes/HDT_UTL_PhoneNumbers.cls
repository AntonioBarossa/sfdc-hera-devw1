public inherited sharing class HDT_UTL_PhoneNumbers {
    
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

    public static String addInternationalPrefixTo(String phone) {
        // Marketing Cloud può inviare SMS solo a numeri italiani.
        return '39' + phone;
    }

}
