public with sharing class HDT_UTL_ActivityCustomProcess {


    //HDT_SRV_Lead leadSrv = new HDT_SRV_Lead();


    public static void changeAssignRelatedRecord(List<wrts_prcgvr__Activity__c> triggernew , List<wrts_prcgvr__Activity__c> triggerold){
        HDT_QR_Recordtype recQR = new HDT_QR_Recordtype();
        String recordtypeid = recQR.getRecordTypeIdByName('HDT_RT_VisitaD2D');
        HDT_QR_Contact contactQr = new HDT_QR_Contact();
        HDT_SRV_Account accountSrv = new HDT_SRV_Account();
        Map<id,String> mapIdOwnerIdBef = new Map<Id,String>();
        Map<id,String> mapIdOwnerIdAfter = new Map<Id,String>();
        Map<id,String> mapContactIdOwner = new Map<Id,String>();
        String userId = userinfo.getuserid();
        List<Lead> listLead = new List<Lead>();
        List<String> listContactId = new List<String>();
        List<Account> listAccount = new List<Account>();
		System.debug('DENTRO HANDLER HANDLER: ' + triggernew);
        List<wrts_prcgvr__Activity__c> listActD2DBef = filterByD2D(triggerold,recordtypeid);
        for(wrts_prcgvr__Activity__c art : listActD2DBef){
            System.debug('DENTRO HANDLER HANDLER2:' + art);
            mapIdOwnerIdBef.put(art.id,art.ownerId);
        } 
        List<wrts_prcgvr__Activity__c> listActD2DAfter = filterByD2D(triggernew,recordtypeid);
       /* for(wrts_prcgvr__Activity__c art : listActD2DBef){
            mapIdOwnerIdAfter.put(art.id,art.ownerId);
        }*/
        for(wrts_prcgvr__Activity__c art : listActD2DAfter){
            if(mapIdOwnerIdBef.get(art.id)!= null && art.ownerId == userId && mapIdOwnerIdBef.get(art.id) != art.ownerId){
                if(art.lead__c != null){
                    listLead.add(new Lead(id=art.lead__c,ownerId=art.ownerId));
                }
                else if(art.Contact__c != null){
                    listContactId.add(art.Contact__c);
                    mapContactIdOwner.put(art.contact__c,art.OwnerId);
                }
            }
        }
        List<Contact> contactList = contactQr.getRecordsById(listContactId);
        for(Contact c : contactList){
            if(mapContactIdOwner.get(c.id)!= null){
                listAccount.add(new Account(id=c.AccountId,ownerId=mapContactIdOwner.get(c.id)));
            }
        }
        if(listLead != null && !listLead.isEmpty()){
            HDT_SRV_Lead.updateRecord(listLead);
        }
        if(listAccount != null && !listAccount.isEmpty()){
            accountSrv.updateRecords(listAccount);
        }
    }
    private static List<wrts_prcgvr__Activity__c> filterByD2d(List<wrts_prcgvr__Activity__c> li,String recordtypeid){
        List<wrts_prcgvr__Activity__c> rep = new List<wrts_prcgvr__Activity__c>();
        System.debug('DENTRO HANDLER HANDLER4:');
        for(wrts_prcgvr__Activity__c act : li){
            if(recordtypeid.equalsIgnoreCase(act.recordtypeid)){
                System.debug('DENTRO HANDLER HANDLER5:');
                rep.add(act);
            }
        }
        return rep;
    }
}