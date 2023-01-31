/*
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/06/2022
    * @description Controller - Gestione Allegati Obbligatori e Aggiuntivi
*/

@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class HDT_LC_AttachmentManager {

    @AuraEnabled
    public String  accountType {get;set;}
    
    @AuraEnabled
    public String  contactChannel {get;set;}
    
    @AuraEnabled
    public String  city {get;set;}

    @AuraEnabled
    public String  cluster {get;set;}

    @AuraEnabled
    public String  processType {get;set;}

    @AuraEnabled
    public String  subProcessType {get;set;}

    @AuraEnabled
    public List<String>  productCode {get;set;}

    @AuraEnabled
    public String  productDescription {get;set;}

    @AuraEnabled
    public String  subscriberType {get;set;}

    @AuraEnabled
    public String  macroTopic {get;set;}

    @AuraEnabled
    public String  additionalAttachments {get;set;}
    
    @AuraEnabled
    public String  parentOrderId {get;set;}

    public HDT_LC_AttachmentManager(){}

    public HDT_LC_AttachmentManager(String accountType, 
                                    String contactChannel, 
                                    String city, 
                                    String cluster, 
                                    String processType, 
                                    String subProcessType, 
                                    List<String> productCode,
                                    String productDescription,
                                    String subscriberType,
                                    String macroTopic){
        this.accountType = accountType;
        this.contactChannel = contactChannel;
        this.city = city;
        this.cluster = cluster;
        this.processType = processType;
        this.subProcessType = subProcessType;
        this.productCode = productCode;
        this.productDescription = productDescription;
        this.subscriberType = subscriberType;
        this.macroTopic = macroTopic;
    }

    
    @AuraEnabled
    public static String getAdditionalAttachment(Id recordId){
        String nameObject = recordId.getSObjectType().getDescribe().getName();
        if('Case'.equalsIgnoreCase(nameObject)){
            Case recordAdditional = [SELECT Id, AdditionalAttachments__c
                                        FROM Case
                                        WHERE Id =: recordId
                                        WITH SECURITY_ENFORCED];
            return recordAdditional.AdditionalAttachments__c;
        } else if('Order'.equalsIgnoreCase(nameObject)){
            Order recordAdditional = [SELECT Id, AdditionalAttachments__c
                                        FROM Order
                                        WHERE Id =: recordId
                                        WITH SECURITY_ENFORCED];
            return recordAdditional.AdditionalAttachments__c;
        }else {
            return null;
        }
        

    }

    @AuraEnabled
    public static List<ContentDocument> getRecordsById(Id recordId){

        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('ContentDocumentLink','ContentDocumentId','read');
        securityClass.checkSecurityAccess();
        List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
        
        if (cdLs.size() < 1){
            return new List<ContentDocument>();
        }

        // Make a List of ContentDocument IDs
        List <Id> cdIdList = new List <Id> ();

        for (ContentDocumentLink nextCdl : cdLs) {
            cdIdList.add(nextCdl.ContentDocumentId); 
        }        

        List<ContentDocument> contentDocuments = [SELECT Id, Title, FileType,CreatedDate FROM ContentDocument WHERE Id IN :cdIdList WITH SECURITY_ENFORCED];
        
        return contentDocuments;
        
    }
/*
    @AuraEnabled
    public static Boolean updateAttachment(Id recordId, String required, String additional){
        try{
            if('Case'.equalsIgnoreCase(sobjectType.getDescribe().getName())){
                Case toUpdRecord = new Case(Id = recordId, AttachmentsStringTARI__c = required, AdditionalAttachments__c = additional);
            } else if('Order'.equalsIgnoreCase(sobjectType.getDescribe().getName())){
                Order toUpdRecord = new Order(Id = recordId, MandatoryAttachments__c = required, AdditionalAttachments__c = additional);
            }
            system.debug('@@@@: '+toUpdRecord);
            upsert toUpdRecord;
            return true;
        }catch(exception e){
            system.debug(e);
            return false;
        }
    }
*/
    @AuraEnabled
    public static HDT_LC_AttachmentManager getOrderForButton(Id recordId){
        Order currOrder = [SELECT Id,AccountholderTypeBeneficiary__c, Channel__c, BillingCity__c, Cluster__c, ProcessType__c, Subprocess__c, CommercialProductCode__c, subscriberType__c
        FROM Order WHERE Id =:recordId 
        WITH SECURITY_ENFORCED];
        HDT_LC_AttachmentManager paramsWrap = new HDT_LC_AttachmentManager(currOrder.AccountholderTypeBeneficiary__c, 
                                                                           currOrder.Channel__c,
                                                                           currOrder.BillingCity__c, 
                                                                           currOrder.Cluster__c, 
                                                                           currOrder.ProcessType__c, 
                                                                           currOrder.Subprocess__c,
                                                                           new list<String>{currOrder.CommercialProductCode__c},
                                                                           null,
                                                                           currOrder.subscriberType__c,
                                                                           null);
                                                                            
        
        system.debug('paramsWrapSelected -> ' + paramsWrap);
        return paramsWrap;
    }

    @AuraEnabled
    public static HDT_LC_AttachmentManager getCaseForButton(Id recordId){
        Case currCase = [   SELECT Id, AccountId, ClientTypology__c, Channel__c, SupplyCity__c, Cluster__c, Type, Subprocess__c, Contract__c, Contract__r.CommercialProduct__c, SubscriberType__c, MacroTopic__c
                            FROM Case
                            WHERE Id =: recordId
                            WITH SECURITY_ENFORCED];

        List<SBQQ__Subscription__c> listSub = [   SELECT Id, ProductCode__c
                                            FROM SBQQ__Subscription__c
                                            WHERE SBQQ__Contract__c  =: currCase.Contract__c
                                            AND SBQQ__Account__c =: currCase.AccountId
                                            WITH SECURITY_ENFORCED];
        list<String> productCodes = new list<String>();
        for(SBQQ__Subscription__c currSub : listSub){
            productCodes.add(currSub.ProductCode__c);
        }

        HDT_LC_AttachmentManager paramsWrap = new HDT_LC_AttachmentManager( currCase.ClientTypology__c,
                                                                            currCase.Channel__c,
                                                                            currCase.SupplyCity__c,
                                                                            currCase.Cluster__c,
                                                                            currCase.Type,
                                                                            currCase.Subprocess__c,
                                                                            productCodes,
                                                                            null,
                                                                            currCase.SubscriberType__c,
                                                                            currCase.MacroTopic__c);
                                                                            
        
        system.debug('paramsWrapSelected -> ' + paramsWrap);
        return paramsWrap;
    }

    private static String getMandatoryAttachment(HDT_LC_AttachmentManager paramsWrap){

        String stringQuery = 'SELECT Id, MandatoryAttachments__c FROM  MandatoryAttachments__c ';
        String conditionString = '';
        if(paramsWrap.accountType != null)
	        conditionString += 'AccountType__c = \''+paramsWrap.accountType+'\' AND ';
        if(paramsWrap.contactChannel != null)
            conditionString += 'Channel__c = \''+paramsWrap.contactChannel+'\' AND ';
        if(paramsWrap.city != null){
            conditionString += '(City__c = \''+paramsWrap.city+'\' OR City__c = null) AND ';
        }else{
            conditionString += 'City__c = null AND ';
        }
        if(paramsWrap.cluster != null)
            conditionString += 'Cluster__c = \''+paramsWrap.cluster+'\' AND ';
        if(paramsWrap.processType != null)
            conditionString += 'ProcessType__c = \''+paramsWrap.processType+'\' AND ';
        if(paramsWrap.subProcessType != null){
            conditionString += '(SubProcessType__c = \''+paramsWrap.subProcessType+'\' OR SubProcessType__c = null) AND ';
        }else {
            conditionString += 'SubProcessType__c = null AND ';
        }
        if(paramsWrap.productCode.size() != 0)
            conditionString += 'ProductCode__c IN (\''+String.join(paramsWrap.productCode,'\',\'')+'\') AND ';
        if(paramsWrap.productDescription != null)
            conditionString += 'ProductDescription__c = \''+paramsWrap.productDescription+'\' AND ';
        if(paramsWrap.subscriberType != null)
            conditionString += 'SubscriberType__c = \''+paramsWrap.subscriberType+'\' AND ';
        if(paramsWrap.macroTopic != null)
            conditionString += 'MacroTopic__c = \''+paramsWrap.macroTopic+'\' AND ';

        conditionString = conditionString.removeEnd('AND ');
        stringQuery = stringQuery+'WHERE '+conditionString+'WITH SECURITY_ENFORCED ';
        stringQuery += 'ORDER BY City__c, SubProcessType__c DESC NULLS LAST';

        //system.debug('@@@@: '+stringQuery);
        List<MandatoryAttachments__c> tabellaAllegati = Database.query(stringQuery);
        //system.debug('@@@@: '+tabellaAllegati);
        return tabellaAllegati[0]?.MandatoryAttachments__c;

    }

    @AuraEnabled
    public static String getRequiredAttachment(Id recordId, HDT_LC_AttachmentManager paramsWrap){
        //caso subprocess mancante
        //caso product mancante ->

        if(paramsWrap == null){
            String nameObject = recordId.getSObjectType().getDescribe().getName();
            if('Case'.equalsIgnoreCase(nameObject)){
                paramsWrap = getCaseForButton(recordId);
            } else if('Order'.equalsIgnoreCase(nameObject)){
                paramsWrap = getOrderForButton(recordId);
            }
        }

        /*
        List<MandatoryAttachments__c> tabellaAllegati = [SELECT Id, MandatoryAttachments__c
                                  FROM  MandatoryAttachments__c 
                                  WHERE Cluster__c =: paramsWrap.cluster
                                  AND (City__c =: paramsWrap.city OR City__c = null)
                                  AND ProcessType__c =: paramsWrap.processType
                                  AND (SubProcessType__c =: paramsWrap.subProcessType OR SubProcessType__c = null)
                                  AND ProductCode__c =: paramsWrap.productCode
                                  WITH SECURITY_ENFORCED
                                  ORDER BY City__c, SubProcessType__c DESC NULLS LAST
                                 ]; 
        */
        return getMandatoryAttachment(paramsWrap);
        
        //return 'Patente; Modulo Variazione Superficie; Atto di Proprietà';
    }

    

    @AuraEnabled
    public static SObject getRecordsToCheck(Id recordId){
        SObject recordToCheck;
        String nameObject = recordId.getSObjectType().getDescribe().getName();
        if('Case'.equalsIgnoreCase(nameObject)){
            recordToCheck = [SELECT Id, DeclaredArea__c, RequestSource__c, Type, subprocess__c, Surface__c, servicePoint__r.SupplyType__c
                                        FROM Case
                                        WHERE Id =: recordId
                                        WITH SECURITY_ENFORCED];
        }
        return recordToCheck;
    }


}