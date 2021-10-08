public with sharing class HDT_LC_RequestVisitD2DCreateForm {

    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
   // private static HDT_SRV_VisitAssignmentRules visitSrv = new HDT_SRV_VisitAssignmentRules();
    private static HDT_QR_RecordType recordTypeQr = new HDT_QR_RecordType();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
   // private static HDT_QR_VisitAssignmentRules visitQr = new HDT_QR_VisitAssignmentRules();
   // private static HDT_QR_PercentageRulesForAssigningVisits percentageQr = new HDT_QR_PercentageRulesForAssigningVisits();

    @AuraEnabled
     public static Id createActivityFromLead(String leadId, string zipCode, String category , String consumption){
        try {
            System.debug('Contact ID: ' + leadId);
            System.debug('Entry2:' + zipCode);
             System.debug('Entry2:' + category);
             System.debug('Entry2:' + consumption);
            Lead l = new Lead();
            l.id = leadId;
            l.consumption__c = consumption;
            System.debug('Contact ID2');
            String owner = createVisitAssignmentRules(zipCode,category,consumption);
            System.debug('Contact ID3' + owner);
            // Contact c = contactQr.getRecordById(contactId);
            ID recordType = recordTypeQr.getRecordTypeIdByName('HDT_RT_VisitaD2D');
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                 Lead__c = leadId,
                 OwnerId = owner,
                 RecordTypeId = recordType
             );
             System.debug('********:'+activity);
            wrts_prcgvr__Activity__c res =  activitySrv.createRecord(activity);
            System.debug('Contact ID4');
            HDT_SRV_Lead.updateRecord(l);
            return res.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     }

     @AuraEnabled
     public static Id createActivityFromContact(String contactId,  string zipCode, String category , String consumption){
         try {
             System.debug('Contact ID'+contactId);
             Contact l = new Contact();
             l.id = contactId;
             l.consumption__c = consumption;
             System.debug('Contact ID2');
            String owner = createVisitAssignmentRules(zipCode,category,consumption);
             Contact c = contactQr.getRecordById(contactId);
             System.debug('Contact ID3');
             ID recordType = recordTypeQr.getRecordTypeIdByName('HDT_RT_VisitaD2D');
             System.debug('Contact ID4');
             wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                 Contact__c = contactId,
                 Account__c = c.AccountId,
                 OwnerId = owner,
                 RecordTypeId = recordType
             );
             System.debug('Contact ID5');
             wrts_prcgvr__Activity__c res =  activitySrv.createRecord(activity);
             System.debug('Contact ID6');
             /*
             Contact updateContact = new Contact(
                Id = contactId,
                Consumption__c = consumption
            );*/
            contactSrv.updateRecord(l);
            return res.Id;
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
     }


     @AuraEnabled
     public static String createVisitAssignmentRules(String zipCode, String category, String consumption){
         try {
             System.debug('Entry:' + zipCode);
             System.debug('Entry:' + category);
             System.debug('Entry:' + consumption);
            // System.debug('Entry:' + );
            HDT_QR_Group groupQr = new HDT_QR_Group();
            List<String> listAccountId = new List<String>();
            List<PercentageRulesForAssigningVisits__c> listPercentage;
            List<VisitAssignmentRules__c> listAssignment = HDT_QR_VisitAssignmentRules.getAssignmentConfigurations(zipCode, category, consumption);
            System.debug('here:' + listAssignment);
            if(listAssignment != null && !listAssignment.isEmpty()){
                listPercentage = HDT_QR_PercentageRulesForAssigningVisits.getRecordsByVisitAssignmentRules(listAssignment[0].Id);
                System.debug('here:' + listPercentage);
            }
            else{
                listPercentage = HDT_QR_PercentageRulesForAssigningVisits.getDefaultValue();
            }
            for(PercentageRulesForAssigningVisits__c pc : listPercentage){
                listAccountId.add(pc.agency__c);
                System.debug('hereFOR:');
            }

            // List<Account> listAccount = [Select id,name from account where id IN : listAccountId];
            List<Account> listAccount = accountQr.getRecordsById(listAccountId, 'Id, Name');
            
            System.debug('testDistribu' + listAccount);
            // List<Account> accounts = [SELECT Id, Name FROM Account];
            map<String, Account> accMap = new Map<String, Account>();
            List<String> accountName = new List<String>();
            List<String> lsitQueueId = new List<String>();
            Map<String, Group> grp = new Map<String, Group>();
            //Map<String, Group> accGroup = new Map<String, Group>();
            Map<String, Integer> countForQueue = new Map<String, integer>();
            Integer total = 0;
             for (Account acc : listAccount){
                accountName.add('HDT_QUE_' + acc.Name);
                accMap.put(acc.Id, acc);
             }
             System.debug(accountName);
             List<Group> queue = groupQr.getQueueByDevelopername(accountName);
             System.debug(queue);
    
            for(Group gr : queue){
                System.debug('here20');
                grp.put(gr.DeveloperName, gr);
                lsitQueueId.add(gr.id);
                countForQueue.put(gr.id,0);
                System.debug('here21');
            }
            System.debug('here');
            List<wrts_prcgvr__Activity__c> listAct = HDT_QR_ActivityCustom.getRecordByOwnerId(lsitQueueId);
            System.debug('her2e');
            for(wrts_prcgvr__Activity__c acq : listAct){
                if(countForQueue.get(acq.ownerId) != null){
                    System.debug('here4');
                    Integer i = countForQueue.get(acq.ownerId);
                    countForQueue.remove(acq.ownerId);
                    countForQueue.put(acq.ownerId,i++);
                    total ++;
                    System.debug('here6');
                }
                else{
                    System.debug('here5');
                    countForQueue.put(acq.ownerId,1);
                    total ++;
                    System.debug('here7');
                }
            }
            System.debug('here8');
            String ownerID = '';
            System.debug('here9');
            for(PercentageRulesForAssigningVisits__c pc : listPercentage){
                System.debug('here10');
                if(grp.get('HDT_QUE_' + accMap.get(pc.agency__c).name) != null){
                    System.debug('here11');
                    Integer co = countForQueue.get(grp.get('HDT_QUE_' + accMap.get(pc.agency__c).name).id);
                    if (pc.PercentageOfAssignment__c > 0 && (co == 0 || total == 0)) {
                        System.debug('here12');
                        ownerID = grp.get('HDT_QUE_' + accMap.get(pc.agency__c).name).id;
                        break;
                    }
                    else if((co/total)*100 <= pc.PercentageOfAssignment__c){
                        System.debug('here12');
                        ownerID = grp.get('HDT_QUE_' + accMap.get(pc.agency__c).name).id;
                        break;
                    }
                }
            }
            System.debug('here13:' + ownerID);
           return ownerID;
           
   
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
     }

 }