public inherited sharing class HDT_UTL_ElectronicInvoicing {

    public String electronicInvoicingValidation(HDT_WRP_ElectronicInvoicing electronicInvoicing) {

        if (electronicInvoicing == null) {
            throw new HDT_UTL_HeraException('HDT_UTL_ElectronicInvoicing: HDT_WRP_ElectronicInvoicing input is null');
        }

        if (String.isBlank(electronicInvoicing.sendMode)) {
            return 'Il campo Modalità Invio Fatturazione Elettronica è obbligatorio.';
        }

        switch on electronicInvoicing.sendMode {
            when 'Estero' {
                if (!String.isBlank(electronicInvoicing.billSendMode) && electronicInvoicing.billSendMode.equals('Fatturazione PA')) {
                    return 'La modalità di invio bolletta non può essere valorizzata con Fatturazione PA.';
                }
            }
            when 'XML + carta/email' {
                if (String.isBlank(electronicInvoicing.xmlType)) {
                    return 'Il campo Tipo XML è obbligatorio.';
                }
                if (!String.isBlank(electronicInvoicing.officeCode) && electronicInvoicing.officeCode.length() != 7) {
                    return 'Il campo Codice Ufficio/Destinatario deve essere di 7 caratteri.';
                }
                if (!String.isBlank(electronicInvoicing.billSendMode) && electronicInvoicing.billSendMode.equals('Fatturazione PA')) {
                    return 'La modalità di invio bolletta non può essere valorizzata con Fatturazione PA.';
                }
            }
            when 'XML' {
                if (String.isBlank(electronicInvoicing.xmlType)) {
                    return 'Il campo Tipo XML è obbligatorio.';
                }
                if (String.isBlank(electronicInvoicing.officeCode) && String.isBlank(electronicInvoicing.certifiedEmail)) {
                    return 'È obbligatorio valorizzare almeno uno dei campi: Codice Ufficio/Destinatario oppure PEC Fatturazione Elettronica';
                }
                if (!String.isBlank(electronicInvoicing.officeCode) && electronicInvoicing.officeCode.length() != 7) {
                    return 'Il campo Codice Ufficio/Destinatario deve essere di 7 caratteri.';
                }
                if (!String.isBlank(electronicInvoicing.billSendMode) && electronicInvoicing.billSendMode.equals('Fatturazione PA')) {
                    return 'La modalità di invio bolletta non può essere valorizzata con Fatturazione PA.';
                }
            }
            when 'XML PA' {
                if (String.isBlank(electronicInvoicing.xmlType)) {
                    return 'Il campo Tipo XML è obbligatorio.';
                }
                if (String.isBlank(electronicInvoicing.officeCode)) {
                    return 'Il campo Codice Ufficio/Destinatario è obbligatorio.';
                }
                if (!String.isBlank(electronicInvoicing.officeCode) && electronicInvoicing.officeCode.length() != 6) {
                    return 'Il campo Codice Ufficio/Destinatario deve essere di 6 caratteri.';
                }
                if (!'Fatturazione PA'.equals(electronicInvoicing.billSendMode)) {
                    return 'La modalità di invio bolletta deve essere valorizzata con Fatturazione PA.';
                }
            }
        }

        return '';
    }

    public class HDT_WRP_ElectronicInvoicing {
        public String sendMode;
        public String billSendMode;
        public String xmlType;
        public String officeCode;
        public String certifiedEmail;
    }
}
