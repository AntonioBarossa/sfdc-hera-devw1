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
    public String  commodity {get;set;}

    @AuraEnabled
    public String  productCode {get;set;}

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
                                    String commodity,
                                    String productCode,
                                    String productDescription,
                                    String subscriberType,
                                    String macroTopic){
        this.accountType = accountType;
        this.contactChannel = contactChannel;
        this.city = city;
        this.cluster = cluster;
        this.processType = processType;
        this.subProcessType = subProcessType;
        this.commodity = commodity;
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
        Order currOrder = [SELECT Id,AccountholderTypeBeneficiary__c, Channel__c, BillingCity__c, Cluster__c, ProcessType__c, Subprocess__c, commodity__c, CommercialProductCode__c, subscriberType__c
        FROM Order WHERE Id =:recordId 
        WITH SECURITY_ENFORCED];
        HDT_LC_AttachmentManager paramsWrap = new HDT_LC_AttachmentManager(currOrder.AccountholderTypeBeneficiary__c, 
                                                                           currOrder.Channel__c,
                                                                           currOrder.BillingCity__c, 
                                                                           currOrder.Cluster__c, 
                                                                           currOrder.ProcessType__c, 
                                                                           currOrder.Subprocess__c,
                                                                           currOrder.commodity__c,
                                                                           currOrder.CommercialProductCode__c,
                                                                           null,
                                                                           currOrder.subscriberType__c,
                                                                           null);
                                                                            
        
        system.debug('paramsWrapSelected -> ' + paramsWrap);
        return paramsWrap;
    }

    @AuraEnabled
    public static String getRequiredAttachment(Id recordId, HDT_LC_AttachmentManager paramsWrap){
        //caso subprocess mancante
        //caso product mancante ->
        List<MandatoryAttachment__c> tabellaAllegati = [SELECT Id, MandatoryAttachments__c
                                  FROM  MandatoryAttachment__c 
                                  WHERE Cluster__c =: paramsWrap.cluster
                                  AND (City__c =: paramsWrap.city OR City__c = null)
                                  AND ProcessType__c =: paramsWrap.processType
                                  AND (SubProcessType__c =: paramsWrap.subProcessType OR SubProcessType__c = null)
                                  AND ProductCode__c =: paramsWrap.productCode
                                  AND Commodity__c =: paramsWrap.commodity
                                  WITH SECURITY_ENFORCED
                                  ORDER BY City__c, SubProcessType__c DESC NULLS LAST
                                 ]; 
        
        return tabellaAllegati[0]?.MandatoryAttachments__c;
        
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