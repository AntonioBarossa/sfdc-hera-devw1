public with sharing class HDT_UTL_TariManagement {
    
    @InvocableMethod(label='Call Tari Action')
    public static List<HDT_WRP_TariManagementResponse> execute(List<HDT_WRP_TariManagementRequest> inputs){
        
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_ManageTari - execute - inputs: ' + inputs);
        
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)) return null;
                
        String method = inputs[0].method;
        switch on method{
            when 'checkTariProcess' {
                return checkTariProcess(inputs);
            }
            // when 'calculateAnnualPaymentEffectiveness'{
            //     return calculateAnnualPaymentEffectiveness(inputs);
            // }
            when else {
                return null;
            }
        }
    }

    // @InvocableMethod
    public static List<HDT_WRP_TariManagementResponse> checkTariProcess(List<HDT_WRP_TariManagementRequest> inputs) {

        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)) return null;
        
        HDT_WRP_TariManagementResponse response = new HDT_WRP_TariManagementResponse();
        List<HDT_WRP_TariManagementResponse> responseList = new List<HDT_WRP_TariManagementResponse>();

        String queryString = 'SELECT Id,DocumentSelected__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
        List<SObject> accountStmList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'AccountStatementFilter__c');
        
        if(accountStmList.isEmpty()) response.isTariProcess = false; //Empty list return false
        
        String documentSelectedString = (String) accountStmList[0].get('DocumentSelected__c');
        List<Object> resultList = (List<Object>) JSON.deserializeUntyped(documentSelectedString);
        
        if(resultList.isEmpty()) response.isTariProcess = false; //Empty list return false
        
        Map<String, Object> resultMap = (Map<String, Object>) resultList[0];
        List<Object> indentedList = (List<Object>) resultMap.get('secondoLivelloInformativo');
        
        for(Object secondLevelObj : indentedList){
            Map<String, Object> secondLevelMap = (Map<String, Object>) secondLevelObj;
            String resulString = (String) secondLevelMap.get('settoreMerceologico');
            response.isTariProcess = 'Ambiente'.equalsIgnoreCase(resulString); // Potrebbe essere TARI e non Ambiente
            if(!response.isTariProcess) break; // Devono essere tutti TARI ??? se si OK(Controllo !) Altrimenti Leva !!!
        }

        responseList.add(response);
        return responseList;
    }

    
    // @InvocableMethod(label='Calcola annualità pagamento')
    // public static List<HDT_WRP_TariManagementResponse> calculateAnnualPaymentEffectiveness(List<HDT_WRP_TariManagementRequest> inputs) {

    //     if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)) return null;
        
    //     HDT_WRP_TariManagementResponse response = new HDT_WRP_TariManagementResponse();
    //     List<HDT_WRP_TariManagementResponse> responseList = new List<HDT_WRP_TariManagementResponse>();

    //     String queryString = 'SELECT Id, City__c, CustomerRequestDate__c FROM Case WHERE Id=\''+inputs[0].recordId+'\'';
    //     List<SObject> caseList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'Case');
        
    //     String cityName = (String) caseList[0].get('City__c');
    //     Date crDate = (Date) caseList[0].get('CustomerRequestDate__c');

    //     List<MandatoryAttachments__c> mattachments = [SELECT Id, City__c, AttachmentString__c, UnicPaymentAnnuity__c 
    //                                                   FROM MandatoryAttachments__c 
    //                                                   WHERE City__c = :cityName];

    //     MandatoryAttachments__c thereHasToBeOne = mattachments[0];
    //     if(thereHasToBeOne.UnicPaymentAnnuity__c > crDate) response.annuality = crDate;
    //     else response.annuality = crDate.addYears(1);
    //     response.limitDate = thereHasToBeOne.UnicPaymentAnnuity__c;

    //     responseList.add(response);
    //     return responseList;
    // }
    
    public class HDT_WRP_TariManagementResponse{
    
        @InvocableVariable
        public Boolean isTariProcess;
        
        @InvocableVariable
        public Date annuality;

        @InvocableVariable
        public Date limitDate;
    }

    public class HDT_WRP_TariManagementRequest{
        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String method;
    }
}