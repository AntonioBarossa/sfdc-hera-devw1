public with sharing class HDT_LC_CambioUso {



    @AuraEnabled
    public static boolean updateCase(String caseId,String addebito,string tipoFornitura,String recapito,string tipoImpianto,boolean residente,string note){
        boolean res = true;
        HDT_SRV_Case caseSrv = new HDT_SRV_Case();
        try{
            Case c = new case();
            c.id = caseId;
            c.SupplyType__c = tipoFornitura;
            c.UseChangeCharge__c = addebito;
            c.PhoneNumber__c = recapito;
            c.ServicePointType__c = tipoImpianto;
            c.Resident__c = residente;
            c.Note__c = note;
            c.phase__c = 'In Lavorazione';
            c.status = 'In Lavorazione';
            caseSrv.updateRecord(c);
            
        }
        catch(Exception e){
            res = false;
        }
        return res;
       
    }
}
