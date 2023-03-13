public with sharing class HDT_UTL_TariManagement {
    
    @InvocableMethod(label='Call Tari Action')
    public static List<HDT_WRP_TariManagementResponse> execute(List<HDT_WRP_TariManagementRequest> inputs){
        
        System.debug(LoggingLevel.DEBUG, 'HDT_UTL_ManageTari - execute - inputs: ' + inputs);
        
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].caseId)) return null;
                
        String method = inputs[0].method;
        switch on method{
            when 'checkTariProcess' {
                return checkTariProcess(inputs);
            }
            when 'calculateAnnualPaymentEffectiveness'{
                return calculateAnnualPaymentEffectiveness(inputs);
            }
            when else {
                return null;
            }
        }
    }

    // @InvocableMethod
    public static List<HDT_WRP_TariManagementResponse> checkTariProcess(List<HDT_WRP_TariManagementRequest> inputs) {

        System.debug('checkTariProcess inputs: ' + JSON.serializePretty(inputs));

        HDT_WRP_TariManagementResponse response = new HDT_WRP_TariManagementResponse();
        List<HDT_WRP_TariManagementResponse> responseList = new List<HDT_WRP_TariManagementResponse>();

        response.isTariProcess = false;

        if(String.isBlank(inputs[0].catalogId)){
            
            String queryString = 'SELECT Id, Commodity__c FROM Case WHERE Id=\''+inputs[0].caseId+'\'';
            List<SObject> caseList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'Case');

            String commodityStr = (String) caseList[0].get('Commodity__c');
            if('Ambiente'.equalsIgnoreCase(commodityStr)) response.isTariProcess = true;

        }
        else{ 

            String queryString = 'SELECT Id,DocumentSelected__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].catalogId+'\'';
            List<SObject> accountStmList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'AccountStatementFilter__c');
            
            String documentSelectedString = (String) accountStmList[0].get('DocumentSelected__c');
            List<Object> resultList = (List<Object>) JSON.deserializeUntyped(documentSelectedString);
            
            Map<String, Object> resultMap = (Map<String, Object>) resultList[0];
            List<Object> indentedList = new List<Object>();
            if(resultMap.get('secondoLivelloInformativo') != null) indentedList = (List<Object>) resultMap.get('secondoLivelloInformativo');
            if(resultMap.get('secondoLivelloInformativoF2') != null) indentedList = (List<Object>) resultMap.get('secondoLivelloInformativoF2');
            
            for(Object secondLevelObj : indentedList){
                Map<String, Object> secondLevelMap = (Map<String, Object>) secondLevelObj;
                String resulString = (String) secondLevelMap.get('settoreMerceologico');
                response.isTariProcess = 'Ambiente'.equalsIgnoreCase(resulString); // Potrebbe essere TARI e non Ambiente
                if(!response.isTariProcess) break; // Devono essere tutti TARI ??? se si OK(Controllo !) Altrimenti Leva !!!
            }

        }

        responseList.add(response);
        return responseList;
    }

    
    //@InvocableMethod(label='Calcola annualità pagamento')
    public static List<HDT_WRP_TariManagementResponse> calculateAnnualPaymentEffectiveness(List<HDT_WRP_TariManagementRequest> inputs) {

        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].caseId)) return null;
        
        HDT_WRP_TariManagementResponse response = new HDT_WRP_TariManagementResponse();
         List<HDT_WRP_TariManagementResponse> responseList = new List<HDT_WRP_TariManagementResponse>();

         String queryString = 'SELECT Id, SupplyCity__c, DeclarationDate__c FROM Case WHERE Id=\''+inputs[0].caseId+'\'';
         List<SObject> caseList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'Case');
        
        String cityName = (String) caseList[0].get('SupplyCity__c');
        Date crDate = (Date) caseList[0].get('DeclarationDate__c');

        /*List<MandatoryAttachments__c> mattachments = [SELECT Id, City__c, MandatoryAttachments__c, UnicPaymentAnnuity__c 
                                                       FROM MandatoryAttachments__c 
                                                       WHERE City__c = :cityName];*/

        List<CityTechnicalData__c> ctechnicaldata = [SELECT Id, UnicPaymentLimitDate__c, UnicPaymentAlert__c, CadastralCity__c 
                                                     FROM CityTechnicalData__c
                                                     WHERE CadastralCity__c = : cityName
                                                     WITH SECURITY_ENFORCED];                                               

        CityTechnicalData__c thereHasToBeOne = ctechnicaldata[0];
        Boolean showMess = thereHasToBeOne.UnicPaymentLimitDate__c < crDate;
        response.annuality = thereHasToBeOne.UnicPaymentLimitDate__c > crDate ? String.valueOf(crDate.year()) : String.valueOf(crDate.year()+1);
        response.showMessage = showMess; 
        system.debug('@@@@: '+response.annuality);
        response.message = !String.isBlank(thereHasToBeOne.UnicPaymentAlert__c) ? thereHasToBeOne.UnicPaymentAlert__c : 'Attenzione: avvisare il cliente che la rata unica sarà attiva dall\'anno prossimo.';
        response.limitDate = thereHasToBeOne.UnicPaymentLimitDate__c;

        responseList.add(response);
        return responseList;
    }
    
    public class HDT_WRP_TariManagementResponse{
    
        @InvocableVariable
        public Boolean isTariProcess;
        
        @InvocableVariable
        public String annuality;

        @InvocableVariable
        public Date limitDate;

        @InvocableVariable
        public String message;

        @InvocableVariable
        public Boolean showMessage;
    }

    public class HDT_WRP_TariManagementRequest{
        @InvocableVariable
        public String caseId;

        @InvocableVariable
        public String catalogId;

        @InvocableVariable
        public String method;

    }
}