/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 09/08/2021
* @description HDT_LC_CopiaContratto
* @history Lorenzo – 09/08/2021 – created class
*/
public with sharing class HDT_LC_CopiaContratto {
    public static HDT_SRV_Case caseSRV= new HDT_SRV_Case();
    public static HDT_SRV_ActivityCustom activitySrv= new HDT_SRV_ActivityCustom();
    public static HDT_QR_RecordType rctype= new HDT_QR_RecordType();
    @AuraEnabled
    public static List<Order> getAccountOrder(String accountId,String tipo){
        HDT_QR_Order orderQr = new HDT_QR_Order();
        List<Order> listRes = new List<Order>();
        if(tipo == 'Copia contratto firmato'){
            
            listRes = orderQr.getRecordsByAccountIdCopContrattoFirmato(accountId);
        }else if(tipo == 'Copia contratto non firmato'){
            listRes = orderQr.getRecordsByAccountIdCopContrattoNonFirmato(accountId);
        }else if(tipo == 'Copia della registrazione'){
            listRes = orderQr.getRecordsByAccountIdCopContrattoSignatureMethod(accountid,'Vocal Order');
        }

        return listRes;
         
        
    }
    @AuraEnabled
    public static List<Order> getOrderChild(String orderId){
        System.debug('***:' + orderId);
        HDT_QR_Order orderQr = new HDT_QR_Order();

        return orderQr.getChildOrdersByParentId(orderId);
        
    }

    @AuraEnabled
    public static string confirmAction(Case c,String accountId,String orderParentId,String tipoAttivita,String tipoFirma,String tipoSend){
        
        Id recTypeId= null;
        RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
        //case c = new case();
        String res = '';
        String caseId = c.Id;
        //c.id = caseId;
        c.CopyType__c = tipoFirma;
        c.Channel__c = tipoAttivita;
        c.sendmode__c = tipoSend;
        c.order__c = orderParentId;  
        c.Status='In Lavorazione'; //HRAWRM-344 01/09/2021
        if(rc !=null){
            recTypeId= rc.Id;
        }
        if('Copia della registrazione'.equalsIgnoreCase(tipoFirma)){
            List<ContentDocumentLink> listContentDocument = [Select id from ContentDocumentLink Where LinkedEntityid = :caseId WITH SECURITY_ENFORCED];
            if(listContentDocument != null && !listContentDocument.isEmpty()){
                wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(Case__c= caseId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Invio registrazione');
                System.debug(activity);
                c.phase__c = 'In Lavorazione';
                activitySrv.createRecord(activity);
                res = 'Invio registrazione';
            }
            else{
                res = 'NoDocumenti';
            }
        }else{
            List<DocumentSendTracking__c> listDocument = getDocumentTracking(orderParentId);
            if((listDocument == null ||listDocument.isEmpty()) && tipoSend.equalsIgnoreCase('Posta Cartacea') ){
                wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(Case__c= caseId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Recupero contratto da Postel');
                activitySrv.createRecord(activity);
                c.phase__c = 'In Lavorazione';
                res = 'Recupero contratto da Postel';
            }else{
                if('Inbound'.equalsIgnoreCase(tipoAttivita) && 'Posta Cartacea'.equalsIgnoreCase(tipoSend)){
                    wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(Case__c= caseId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Invio Contratto');
                    activitySrv.createRecord(activity);
                    res = 'Invio Contratti';
                    c.phase__c = 'In Lavorazione';
                }
                else{
                    c.phase__c = 'In Lavorazione';
                }
            }
        }
        caseSRV.updateRecord(c); 
        return res;
    }
    @AuraEnabled
    public static string confirmActionDraft(Case c,String accountId,String orderParentId,String tipoAttivita,String tipoFirma,String tipoSend){
        
        Id recTypeId= null;
        RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
        //case c = new case();
        String res = '';
        //c.id = caseId;
        c.CopyType__c = tipoFirma;
        c.sendmode__c = tipoSend; 
        c.Channel__c = tipoAttivita;
        c.order__c = orderParentId;  
       // c.Status='In Lavorazione'; //HRAWRM-344 01/09/2021
        if(rc !=null){
            recTypeId= rc.Id;
        }

        caseSRV.updateRecord(c); 
        return res;
    }

    @AuraEnabled
    public static boolean chiudiAttivit(String recordId){
        try{
            // HDT_QR_Case caseQr = new HDT_QR_Case();
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
            s.wrts_prcgvr__status__c = 'Chiusa';
            activitySrv.updateRecord(s);
           // Case c = caseQr.getRecordById(s.case__c);
            Case c = new Case();
            c.Id = s.Case__c;
            c.Phase__c	='In Lavorazione';
            caseSrv.updateRecord(c);
            return true;
        }
        catch(Exception e){
            return false;
        }
    }

    @AuraEnabled
    public static boolean chiudiAttivitNoCase(String recordId){
        try{
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
            s.wrts_prcgvr__status__c = 'Chiusa';
            activitySrv.updateRecord(s);
            return true;
        }
        catch(Exception e){
            return false;
        }
    }

    @AuraEnabled
    public static List<DocumentSendTracking__c> getDocumentTracking(String orderId){
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE, [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, BounceReason__c, Case__c, EnvelopeId__c, IsBounced__c, Order__c, ReadDate__c, Receiver__c, SendDate__c, SendMode__c, Sender__c, CompanyOwner__c FROM DocumentSendTracking__c where Order__c =: orderId]);
        return securityDecision.getRecords();
    }

}
