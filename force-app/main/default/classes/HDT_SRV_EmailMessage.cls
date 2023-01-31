@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_EmailMessage {
    
    //DEBUG
    public static final String CLASS_NAME = 'HDT_SRV_EmailMessage';
    
    //DATA
    public static final String CASE_TYPE1 = 'Dichiarazione di intento';
    public static final String CASE_TYPE2 = 'Comunicazione di Fallimento';
    public static final String CASE_TYPE3 = 'Richiesta Parere';
    // public static final String CASE_TYPE4 = 'Gestione Rifiuti'; // HRAWRM-1941 (3 Riadattamento Processo)
    // public static final String CASE_TYPE5 = 'Ambiente annullo richiesta senza appuntamento'; // HRAWRM-1941 (3 Riadattamento Processo)
    
    public static void insertEmailMessage(EmailMessage m){
        HDT_UTL_DatabaseService.insertSObject(m);
    }
    
    public static void checkEmailSender(List<EmailMessage> emailList){
        
		//DEBUG
		String debugString = CLASS_NAME + ' - checkEmailSender';
		System.debug(LoggingLevel.DEBUG, debugString + ' - emailList size: ' + emailList.size());
        
        Map<SObject,Id> mapEmailCase = new Map<SObject,Id>();
        String userEmail = UserInfo.getUserEmail();
        Id parentId;
        String objectName = '';
        for(EmailMessage email : emailList){
            String fromAddress = email.FromAddress;
            if (fromAddress != null && fromAddress.equals(userEmail)) {
                email.addError('Non è possibile inviare la comunicazione utilizzando la propria Email personale come mittente. Selezionare un mittente alternativo.');
            }
            parentId = email.parentId;
            if(parentId != null){
                objectName = parentId.getSobjectType().getDescribe().getName();
            }else {
                objectName = '';
            }
            if(String.isNotBlank(objectName)){
                switch on objectName{

                    when 'Case'{
                        mapEmailCase.put(email, parentId);
                    }
                    when else{
                        /*
                        * @Author: Salvatore A. Sarà 18/10/2021
                        * Risoluzione "Avoid Empty Block Statements"
                        */
                        mapEmailCase = null;
                    }
                }
            }    
        }
        if(mapEmailCase.size()>0){
            manageEmailCase(mapEmailCase);
        }
    }
    
    
    public static void checkIncomingEmails(List<EmailMessage> emailList){
        
		//DEBUG
		String debugString = CLASS_NAME + ' - checkIncomingEmails';
		System.debug(LoggingLevel.DEBUG, debugString + ' - emailList size: ' + emailList.size());
        
        Map<SObject,Id> mapEmailCase = new Map<SObject,Id>();
        Id parentId;
        String objectName='';
        
        for(EmailMessage email : emailList){
            parentId = email.parentId;
            if(parentId != null){
                objectName = parentId.getSObjectType().getDescribe().getName();
            }else {
                objectName = '';
            }
            if(String.isNotBlank(objectName)){
                switch on  objectName {
                    when 'Case' {
                        mapEmailCase.put(email, parentId);
                    }
                    when else {
                        /*
                        * @Author: Salvatore A. Sarà 18/10/2021
                        * Risoluzione "Avoid Empty Block Statements"
                        */
                        mapEmailCase = null;
                    }
                }
            }
        }
        if(mapEmailCase.size()>0){
            manageEmailCase(mapEmailCase);
        }
    }
    
    
    private static void manageEmailCase(Map<SObject, Id> params){
        
		//DEBUG
		String debugString = CLASS_NAME + ' - manageEmailCase';
		System.debug(LoggingLevel.DEBUG, debugString + ' - params size: ' + params.size());
        
        HDT_QR_Case caseQr = new HDT_QR_Case();
        Map<Id,Case> mapIdCase = new Map<Id,Case>();
        List<Case> caseToUpdate = new List<Case>();
        Case parentRecord = new Case();
        
        List<Id> caseIdList = params.values();
        String idString = String.join( new List<Id>(caseIdList) , '\',\'');
        String queryString = 'SELECT Id, ParentId, Type, RecordType.DeveloperName, Phase__c FROM Case WHERE Id in (\''+ idString +'\')';
        List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'Case');
        List<Case> caseList = (List<Case>) recordList;
        
        try{
            parentRecord = caseQr.getParentCaseById(caseList[0].ParentId);
            System.debug(LoggingLevel.DEBUG, debugString + ' - ###Found Records --> ' + parentRecord);
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, debugString + e.getMessage());
        }
        
        for(Case single : (List<Case>)recordList){
            mapIdCase.put(single.Id, single);
        }
        
        //
        for (SObject emailObj : params.keySet()) {
            EmailMessage email = (EmailMessage) emailObj;
            
            if(email.Incoming){
                Case caseRecord = mapIdCase.get(email.ParentId);
                System.debug(LoggingLevel.DEBUG, debugString + ' - Incoming Mail, case type: ' + caseRecord.Type);
                
                if(CASE_TYPE1.equalsIgnoreCase(caseRecord.Type) || CASE_TYPE2.equalsIgnoreCase(caseRecord.Type) || CASE_TYPE3.equalsIgnoreCase(caseRecord.Type) /* || CASE_TYPE4.equalsIgnoreCase(caseRecord.Type) || CASE_TYPE5.equalsIgnoreCase(caseRecord.Type) */ ){ // HRAWRM-1941 (3 Riadattamento Processo)
                        caseRecord.Phase__c = 'Risposta Ricevuta';
                        //Gestione avanzamento ParentCase di Reclamo
                        if(CASE_TYPE3.equals(caseRecord.Type)){
                            System.debug(LoggingLevel.DEBUG, debugString + ' - ### Inside Parere Condition ###');
                            caseRecord.Phase__c = 'Completata';
                            if(parentRecord != null){
                                System.debug(LoggingLevel.DEBUG, debugString + ' - ### Inside Parent Condition ###');
                                parentRecord.Phase__c = 'Risposta Parere Ricevuta';
                                caseToUpdate.add(parentRecord);
                                System.debug(LoggingLevel.DEBUG, debugString + ' - ### adding parentRecord --> ' + parentRecord);
                            }
                        }
                }
                caseToUpdate.add(caseRecord);
                System.debug(LoggingLevel.DEBUG, debugString + ' - ### adding caseRecord --> ' + caseRecord);
                
            } else {
                Case caseRecord = mapIdCase.get(email.ParentId);
                System.debug(LoggingLevel.DEBUG, debugString + ' - NOT incoming Mail, case type: ' + caseRecord.Type);
                
                if(CASE_TYPE1.equalsIgnoreCase(caseRecord.Type) || CASE_TYPE2.equalsIgnoreCase(caseRecord.Type) || CASE_TYPE3.equalsIgnoreCase(caseRecord.Type)){
                    if(CASE_TYPE3.equalsIgnoreCase(caseRecord.Type)){
                        caseRecord.Phase__c = 'In attesa risposta parere';
                    } else {
                        caseRecord.Phase__c = 'In attesa risposta Mail';
                    }
                }
                caseToUpdate.add(caseRecord);
                System.debug(LoggingLevel.DEBUG, debugString + ' - ### adding caseRecord --> ' + caseRecord);
            }
        }
        
        System.debug(LoggingLevel.DEBUG, debugString + ' - ### Case To Update --> ' + caseToUpdate);
        if(caseToUpdate.size()>0){
            Boolean result = HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
            System.debug(LoggingLevel.DEBUG, 'RESULT: ' + result);
        }
    }    

    public static void checkBlacklistOneshot(List<EmailMessage> emailList){

        List<String> receiverEmails = new List<String>();
        for (EmailMessage email : emailList) {
            if (email.Incoming == False) {
                receiverEmails.add(email.ToAddress);
            }
        }

        if (receiverEmails.isEmpty()) {
            return;
        }

        List<Contact> contacts = [SELECT Id, Email, IndividualId, Individual.OneshotBlacklist__c FROM Contact WHERE Email IN :receiverEmails WITH SECURITY_ENFORCED];
        Map<String, Boolean> blacklistMap = new Map<String,Boolean>();
        for (Contact c : contacts) {
            blacklistMap.put(c.Email, c.Individual.OneshotBlacklist__c);
        }

        for (EmailMessage email : emailList) {
            if (blacklistMap.get(email.ToAddress) == True) {
                email.addError('Impossibile inviare l\'E-Mail poichè il cliente destinatario è inserito nella Blacklist Oneshot.');
            }
        }

    }
}