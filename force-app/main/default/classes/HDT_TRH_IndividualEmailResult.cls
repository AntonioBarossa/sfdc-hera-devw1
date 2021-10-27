 /**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_IndividualEmailResult
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_IndividualEmailResult extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
    }
    public override void beforeUpdate(){
        setAccount(trigger.new);
    }
    public override void afterUpdate(){
        HDT_UTL_Scarti.createScartoForMarketingCloud(trigger.new,trigger.oldMap);
    }

    public static void setAccount(List<SObject> objs){

        HDT_QR_Account accountQr = new HDT_QR_Account();
        HDT_QR_Case caseQr = new HDT_QR_Case();
        HDT_QR_Order orderQr = new HDT_QR_Order();
        HDT_QR_Lead leadQr = new HDT_QR_Lead();
        HDT_QR_Contact contactQr = new HDT_QR_Contact();
        String objectApiName='';

        List<String> accountIds= new List<String>();
        List<String> caseIds= new List<String>();
        List<String> orderIds= new List<String>();
        List<String> leadIds= new List<String>();
        Set<Id> contactIds= new Set<Id>();
        List<Account> accounts= new List<Account>();
        List<Case> cases= new List<Case>();
        List<Order> orders= new List<Order>();
        List<Lead> leads= new List<Lead>();
        List<Contact> contacts= new List<Contact>();
        Map<String,Account> accountsMap=new Map<String,Account>();
        Map<String,Case> casesMap=new Map<String,Case>();
        Map<String,Order> ordersMap=new Map<String,Order>();
        Map<String,Lead> leadsMap=new Map<String,Lead>();
        Map<String,Contact> contactsMap=new Map<String,Contact>();

        for(SObject s: objs){
            objectApiName=String.valueOf(s.getSObjectType());
            if(objectApiName=='et4ae5__IndividualEmailResult__c'){
                leadIds.add(String.valueOf(s.get('et4ae5__Lead__c')));
                contactIds.add(String.valueOf(s.get('et4ae5__Contact__c')));
                caseIds.add(String.valueOf(s.get('CaseID__c')));
                orderIds.add(String.valueOf(s.get('OrderID__c')));
            }
        }
        if(accountIds.size()>0){
            accounts=accountQr.getRecordsById(accountIds, 'Id,CompanyOwner__c');
        }
        if(caseIds.size()>0){
            cases=caseQr.getRecordsById(caseIds, 'Id,CompanyOwner__c,AccountId');
        }
        if(orderIds.size()>0){
            orders=orderQr.getRecordsByIdWithFields(orderIds, 'Id,CompanyOwner__c,AccountId');
        }
        if(leadIds.size()>0){
            leads=leadQr.getRecordsById(leadIds);
        }
        if(contactIds.size()>0){
            contacts=contactQr.getRecordsByIds(contactIds);
        }

        for(Account a:accounts){
            accountsMap.put(a.Id,a);
        }
        for(Case c:cases){
            casesMap.put(c.Id,c);
        }
        for(Order o:orders){
            ordersMap.put(o.Id,o);
        }
        for(Lead l:leads){
            leadsMap.put(l.Id,l);
        }
        for(Contact con:contacts){
            contactsMap.put(con.Id,con);
        }
        for(SObject s: objs){
            if(objectApiName=='et4ae5__IndividualEmailResult__c'){
                // EVERIS: per i soli oggetti di Marketing Cloud, valorizziamo anche l'Id dell'Account recuperato dal Case/Order correlato alla comunicazione.
                if (casesMap.containsKey(String.valueOf(s.get('CaseID__c')))){
                    Case caseObj = casesMap.get(String.valueOf(s.get('CaseID__c')));
                    if (caseObj != null){
                        s.put('Account__c', caseObj.AccountId);
                    }
                }else if(ordersMap.containsKey(String.valueOf(s.get('OrderID__c')))) { // Added check making sure the ordersMap contains the id from the IndividualEmailResult
                    Order orderObj = ordersMap.get(String.valueOf(s.get('OrderID__c')));
                    if (orderObj != null){
                        s.put('Account__c', orderObj.AccountId);
                    }
                }
                // EVERIS END
            }
        }
    }
}