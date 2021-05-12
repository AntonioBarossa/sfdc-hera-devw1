public with sharing class HDT_LC_LeadCalculateFiscalCode {
    HDT_QR_Lead leadQR = new HDT_QR_Lead():
    @AuraEnabled
    public static String calculateLeadFiscalCode(String leadId){
        System.debug(leadId);
        String validateFields='';
        Lead l= leadQR.getRecordById(leadId);
        System.debug(l);
        Map<String,String> row = new Map<String, String>();

        System.debug(l.FirstName);
        if(l.LastName== null || l.LastName== ''){
            validateFields += 'Lastname ';
        }
        if(l.FirstName== null || l.FirstName== ''){
            validateFields += 'FirstName ';
        }
        if(String.valueOf(l.Birthdate__c)== null || String.valueOf(l.Birthdate__c)== ''){
            validateFields += 'Birthdate ';
        }
        if(String.valueOf(l.Gender__c)== null || String.valueOf(l.Gender__c)== ''){
            validateFields += 'Gender ';
        }
        if(String.valueOf(l.Birthplace__c)== null || String.valueOf(l.Birthplace__c)== ''){
            validateFields += 'Birthplace ';
        }
        if(String.isNotBlank(validateFields)){
            validateFields += 'must be completed!';
            return validateFields;
        }else{
            row.put('lastName', l.LastName);
            row.put('firstName', l.FirstName);
            row.put('birthDate', String.valueOf(l.Birthdate__c));
            row.put('gender', l.Gender__c);
            row.put('birthPlace', l.Birthplace__c);
            System.debug(row);
            String fiscalCode= HDT_UTL_CalculateFiscalCode.calculateFiscalCode(row);
            Lead lead= new Lead(Id=leadId,FiscalCode__c=fiscalCode);
            HDT_SRV_Lead.checkUpdateAccess(lead);
            HDT_SRV_Lead.updateRecord(lead);
            return validateFields;
        }  
    }
}