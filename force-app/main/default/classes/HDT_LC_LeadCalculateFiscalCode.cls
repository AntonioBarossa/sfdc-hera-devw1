/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 12/05/2021
* @description HDT_BA_OldDraftSales
* @history Lorenzo – 12/05/2021 – created class
*/

public with sharing class HDT_LC_LeadCalculateFiscalCode {
    public static HDT_QR_Lead leadQR = new HDT_QR_Lead();
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
        if(String.valueOf(l.Birthcity__c)== null || String.valueOf(l.Birthcity__c)== ''){
            validateFields += 'Birthcity ';
        }
        if(String.isNotBlank(validateFields)){
            validateFields += 'must be completed!';
            return validateFields;
        }else{
            String checkCitta = HDT_QR_City.getCityCode( l.Birthcity__c.toUpperCase());
            row.put('lastName', l.LastName);
            row.put('firstName', l.FirstName);
            row.put('birthDate', String.valueOf(l.Birthdate__c));
            row.put('gender', l.Gender__c);
            row.put('birthPlace', l.Birthcity__c);
            if(''.equals(checkCitta)){
                validateFields='Comune non Presente...';
            }
            else{
                System.debug(row);
                String fiscalCode= HDT_UTL_CalculateFiscalCode.calculateFiscalCode(row);
                Lead lead= new Lead(Id=leadId,FiscalCode__c=fiscalCode);
                HDT_SRV_Lead.checkUpdateAccess(lead);
                HDT_SRV_Lead.updateRecord(lead);
            }
            return validateFields;
        }  
    }
}
