/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 04/06/2021
 * @description HDT_UTL_CompanyOwner Classes
 * @history Sabina Levonja 04/06/2021 – Created class
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount, PMD.AvoidDeeplyNestedIfStmts')
public inherited sharing class HDT_UTL_CompanyOwner {

    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();

    public static void feedCompanyOwner(List<SObject> objs){
        String userId= System.UserInfo.getUserId();
        User currentUser= HDT_QR_UserQueriesWithoutSharing.getRoleAndProfile(userId)[0];
        String objectApiName='';
        Map<String, String> accRecTypeIdMap = new Map<String, String>();

        for(Schema.RecordTypeInfo rt : Account.SObjectType.getDescribe().getRecordTypeInfos()){
            accRecTypeIdMap.put(rt.getRecordTypeId(), rt.getDeveloperName());
        }
        
        if('HDT_BackOffice'.equals(currentUser.UserRole.DeveloperName) || String.isBlank(currentUser.UserRole.DeveloperName)){

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
                if(objectApiName=='Lead' && s.get('LeadSource') != null && s.get('LeadSource') == 'DBU')break;
                String rtId = '';
                objectApiName=String.valueOf(s.getSObjectType());
                if(objectApiName.equalsIgnoreCase('Account')){
                    rtId = (String) s.get('RecordTypeId');
                }
                
                if((objectApiName=='Account' && !accRecTypeIdMap.get(rtId).equalsIgnoreCase('HDT_RT_Distributore') && !accRecTypeIdMap.get(rtId).equalsIgnoreCase('HDT_RT_Partner')) || (objectApiName=='Lead' && s.get('LeadSource') != 'DBU')){
                    if(s.get('CompanyOwner__c') == null){
                        s.addError('Company Owner must be completed!');
                    }
                }else if(objectApiName=='Asset' || objectApiName== 'Case' || objectApiName== 'Contact' || objectApiName== 'Opportunity' ){
                    accountIds.add(String.valueOf(s.get('AccountId')));
                    if(objectApiName == 'Case' && s.get('Lead__c') != null)
                    {
                        leadIds.add(String.valueOf(s.get('Lead__c')));
                    }
                }else if(objectApiName=='BillingProfile__c' || objectApiName=='SolTracking__c' || objectApiName=='DocumentSendTracking__c'){
                    accountIds.add(String.valueOf(s.get('Account__c')));
                }else if(objectApiName=='wrts_prcgvr__Activity__c'){
                    accountIds.add(String.valueOf(s.get('Account__c')));
                    leadIds.add(String.valueOf(s.get('Lead__c')));
                    caseIds.add(String.valueOf(s.get('Case__c')));
                    orderIds.add(String.valueOf(s.get('Order__c')));
                    if(s.get('wrts_prcgvr__ObjectId__c') != null){
                        Id objId= String.valueOf(s.get('wrts_prcgvr__ObjectId__c'));
                        Schema.sObjectType entityType = objId.getSObjectType();
                        
                        if(entityType == Case.sObjectType){
                            caseIds.add(String.valueOf(s.get('wrts_prcgvr__ObjectId__c')));
                        }else{
                            orderIds.add(String.valueOf(s.get('wrts_prcgvr__ObjectId__c')));
                        }
                    }
                }else if(objectApiName=='DocumentalActivity__c'){
                    caseIds.add(String.valueOf(s.get('CaseId__c')));
                }else if(objectApiName=='SBQQ__Quote__c' || objectApiName=='SBQQ__Subscription__c'){
                    accountIds.add(String.valueOf(s.get('SBQQ__Account__c')));
                }else if(objectApiName=='SMSTracking__c' || objectApiName=='PushTracking__c'){
                    leadIds.add(String.valueOf(s.get('LeadID__c')));
                    contactIds.add(String.valueOf(s.get('ContactID__c')));
                    caseIds.add(String.valueOf(s.get('CaseID__c')));
                    orderIds.add(String.valueOf(s.get('OrderID__c')));
                }else if(objectApiName=='et4ae5__IndividualEmailResult__c'){
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
                if(objectApiName.equalsIgnoreCase('Lead'))break;
                if(objectApiName=='Asset' || objectApiName== 'Case' || objectApiName== 'Contact' || objectApiName== 'Opportunity' ){
                    if(accountsMap.containsKey(String.valueOf(s.get('AccountId')))){
                        Account ac= accountsMap.get(String.valueOf(s.get('AccountId')));
                        s.put('CompanyOwner__c', ac.CompanyOwner__c);
                    }
                    if(!leadsMap.isEmpty() && leadsMap.containsKey(String.valueOf(s.get('Lead__c'))))
                    {
                        Lead l = leadsMap.get(String.valueOf(s.get('Lead__c')));
                        s.put('CompanyOwner__c',l.CompanyOwner__c);
                    }
                }else if(objectApiName=='BillingProfile__c' || objectApiName=='SolTracking__c' ||objectApiName=='DocumentSendTracking__c'){
                    if(accountsMap.containsKey(String.valueOf(s.get('Account__c')))){
                        Account ac= accountsMap.get(String.valueOf(s.get('Account__c')));
                        s.put('CompanyOwner__c', ac.CompanyOwner__c);
                    }
                }else if(objectApiName=='wrts_prcgvr__Activity__c'){
                    if(accountsMap.containsKey(String.valueOf(s.get('Account__c')))){
                        Account ac= accountsMap.get(String.valueOf(s.get('Account__c')));
                        s.put('CompanyOwner__c', ac.CompanyOwner__c);
                    }else if(leadsMap.containsKey(String.valueOf(s.get('Lead__c')))){
                        Lead lead= leadsMap.get(String.valueOf(s.get('Lead__c')));
                        s.put('CompanyOwner__c', lead.CompanyOwner__c);
                    }else if (casesMap.containsKey(String.valueOf(s.get('Case__c'))) || casesMap.containsKey(String.valueOf(s.get('wrts_prcgvr__ObjectId__c')))){
                        Case caseObj = new Case();
                        if(s.get('Case__c') != null){
                            caseObj = casesMap.get(String.valueOf(s.get('Case__c')));
                        }else{
                            caseObj = casesMap.get(String.valueOf(s.get('wrts_prcgvr__ObjectId__c')));  
                        }
                        s.put('CompanyOwner__c', caseObj.CompanyOwner__c);
                    }else if (ordersMap.containsKey(String.valueOf(s.get('Order__c'))) || ordersMap.containsKey(String.valueOf(s.get('wrts_prcgvr__ObjectId__c')))){
                        Order orderObj = new Order();
                        if(s.get('Order__c') != null){
                            orderObj = ordersMap.get(String.valueOf(s.get('Order__c')));
                        }else{
                            orderObj = ordersMap.get(String.valueOf(s.get('wrts_prcgvr__ObjectId__c')));
                        }
                        s.put('CompanyOwner__c', orderObj.CompanyOwner__c);
                    }
                }else if(objectApiName=='DocumentalActivity__c'){
                    if(casesMap.containsKey(String.valueOf(s.get('CaseId__c')))){
                        Case cs= casesMap.get(String.valueOf(s.get('CaseId__c')));
                        s.put('CompanyOwner__c', cs.CompanyOwner__c);
                    }
                }else if(objectApiName=='SBQQ__Quote__c' || objectApiName=='SBQQ__Subscription__c'){
                    if(accountsMap.containsKey(String.valueOf(s.get('SBQQ__Account__c')))){
                        Account ac= accountsMap.get(String.valueOf(s.get('SBQQ__Account__c')));
                        s.put('CompanyOwner__c', ac.CompanyOwner__c);
                    }
                }else if(objectApiName=='SMSTracking__c' || objectApiName=='PushTracking__c'){
                    if(leadsMap.containsKey(String.valueOf(s.get('LeadID__c')))){
                        Lead lead= leadsMap.get(String.valueOf(s.get('LeadID__c')));
                        s.put('CompanyOwner__c', lead.CompanyOwner__c);
                    }else{
                        Contact cont= contactsMap.get(String.valueOf(s.get('ContactID__c')));
                        s.put('CompanyOwner__c', cont.CompanyOwner__c);
                    }
                    // EVERIS: per i soli oggetti di Marketing Cloud, valorizziamo anche l'Id dell'Account recuperato dal Case/Order correlato alla comunicazione.
                    if (casesMap.containsKey(String.valueOf(s.get('CaseID__c')))){
                        Case caseObj = casesMap.get(String.valueOf(s.get('CaseID__c')));
                        if (caseObj != null){
                            s.put('Account__c', caseObj.AccountId);
                        }
                    }else{
                        Order orderObj = ordersMap.get(String.valueOf(s.get('OrderID__c')));
                        if (orderObj != null){
                            s.put('Account__c', orderObj.AccountId);
                        }
                    }
                    // EVERIS END
                }else if(objectApiName=='et4ae5__IndividualEmailResult__c'){
                    if(leadsMap.containsKey(String.valueOf(s.get('et4ae5__Lead__c')))){
                        Lead lead= leadsMap.get(String.valueOf(s.get('et4ae5__Lead__c')));
                        s.put('CompanyOwner__c', lead.CompanyOwner__c);
                    }else if(contactsMap.containsKey(String.valueOf(s.get('et4ae5__Contact__c')))) { // Added check making sure the contactsMap contains the id from the IndividualEmailResult
                        Contact cont= contactsMap.get(String.valueOf(s.get('et4ae5__Contact__c')));
                        s.put('CompanyOwner__c', cont.CompanyOwner__c);
                    }
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
        else{
            for(SObject s: objs){
                if(s.get('CompanyOwner__c') == null){
                    fillCompanyOwner(s,currentUser.UserRole.DeveloperName);
                }
            }
        }       
    }

    public static void fillCompanyOwner(SObject s,String role){
        switch on role{
            when  'HDT_FrontOffice_AAAEBT'{
                s.put('CompanyOwner__c', 'AAA-EBT');
            }
            when  'HDT_FrontOffice_MMS'{
                s.put('CompanyOwner__c', 'MMS');
            }
            when  'HDT_FrontOffice_Reseller'{
                s.put('CompanyOwner__c', 'Reseller');
            }
            when else {	
                s.put('CompanyOwner__c', 'HERA COMM');
            }
        }
    }
}