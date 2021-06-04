public inherited sharing class HDT_UTL_CompanyOwner {

    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();


    public static void feedCompanOwner(List<SObject> objs){
        List<String> owners=new List<String>();
        String userId= System.UserInfo.getUserId();
        User currentUser= HDT_QR_UserQueriesWithoutSharing.getRoleAndProfile(userId)[0];
        String objectApiName='';
        if(String.isNotBlank(currentUser.UserRole.DeveloperName)){
            if('HDT_BackOffice'.equals(currentUser.UserRole.DeveloperName)){

                List<String> accountIds= new List<String>();
                List<String> caseIds= new List<String>();
                List<String> leadIds= new List<String>();
                Set<Id> contactIds= new Set<Id>();
                List<Account> accounts= new List<Account>();
                List<Case> cases= new List<Case>();
                List<Lead> leads= new List<Lead>();
                List<Contact> contacts= new List<Contact>();
                Map<String,Account> accountsMap=new Map<String,Account>();
                Map<String,Case> casesMap=new Map<String,Case>();
                Map<String,Lead> leadsMap=new Map<String,Lead>();
                Map<String,Contact> contactsMap=new Map<String,Contact>();

                for(SObject s: objs){
                    objectApiName=String.valueOf(s.getSObjectType());
                    if(objectApiName=='Account' || objectApiName=='Lead' || objectApiName=='Campaign'){
                        if(s.get('CompanyOwner__c') == null){
                            s.addError('Company Owner must be completed!');
                        }
                    }else if(objectApiName=='Asset' || objectApiName== 'Case' || objectApiName== 'Contact' || objectApiName== 'Opportunity' ){
                        accountIds.add(String.valueOf(s.get('AccountId')));
                    }else if(objectApiName=='BillingProfile__c' || objectApiName=='SolTracking__c' || objectApiName=='wrts_prcgvr__Activity__c' ||objectApiName=='DocumentSendTracking__c'){
                        accountIds.add(String.valueOf(s.get('Account__c')));
                    }else if(objectApiName=='DocumentalActivity__c'){
                        caseIds.add(String.valueOf(s.get('CaseId__c')));
                    }else if(objectApiName=='SBQQ__Quote__c' || objectApiName=='SBQQ__Subscription__c'){
                        accountIds.add(String.valueOf(s.get('SBQQ__Account__c')));
                    }else if(objectApiName=='SMSTracking__c' || objectApiName=='PushTracking__c'){
                        leadIds.add(String.valueOf(s.get('LeadID__c')));
                        contactIds.add(String.valueOf(s.get('ContactID__c')));
                    }else if(objectApiName=='et4ae5__IndividualEmailResult__c'){
                        leadIds.add(String.valueOf(s.get('et4ae5__Lead__c')));
                        contactIds.add(String.valueOf(s.get('et4ae5__Contact__c')));
                    }
                }
                if(accountIds.size()>0){
                    accounts=accountQr.getRecordsById(accountIds, 'Id,CompanyOwner__c');
                }
                if(caseIds.size()>0){
                    cases=caseQr.getRecordsById(caseIds, 'Id,CompanyOwner__c');
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
                for(Lead l:leads){
                    leadsMap.put(l.Id,l);
                }
                for(Contact con:contacts){
                    contactsMap.put(con.Id,con);
                }
                for(SObject s: objs){
                    if(objectApiName=='Asset' || objectApiName== 'Case' || objectApiName== 'Contact' || objectApiName== 'Opportunity' ){
                        if(accountsMap.containsKey(String.valueOf(s.get('AccountId')))){
                            Account ac= accountsMap.get(String.valueOf(s.get('AccountId')));
                            s.put('CompanyOwner__c', ac.CompanyOwner__c);
                        }
                    }else if(objectApiName=='BillingProfile__c' || objectApiName=='SolTracking__c' || objectApiName=='wrts_prcgvr__Activity__c' ||objectApiName=='DocumentSendTracking__c'){
                        if(accountsMap.containsKey(String.valueOf(s.get('Account__c')))){
                            Account ac= accountsMap.get(String.valueOf(s.get('Account__c')));
                            s.put('CompanyOwner__c', ac.CompanyOwner__c);
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
                    }else if(objectApiName=='et4ae5__IndividualEmailResult__c'){
                        if(leadsMap.containsKey(String.valueOf(s.get('et4ae5__Lead__c')))){
                            Lead lead= leadsMap.get(String.valueOf(s.get('et4ae5__Lead__c')));
                            s.put('CompanyOwner__c', lead.CompanyOwner__c);
                        }else{
                            Contact cont= contactsMap.get(String.valueOf(s.get('et4ae5__Contact__c')));
                            s.put('CompanyOwner__c', cont.CompanyOwner__c);
                        }
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
        }else{
            objs[0].addError('Role is empty');
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
