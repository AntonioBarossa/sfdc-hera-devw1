public with sharing class HDT_BA_UpdateOfferCode implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{
    String method;
    public HDT_BA_UpdateOfferCode(String method) {
        this.method = method;
    }

    public void execute(SchedulableContext sc) { 
        if(this.method.equals('FirstCommunicationCode')){
            Id batchId = Database.executeBatch(new HDT_BA_UpdateOfferCode(this.method), 1);
        }else {
            Id batchId = Database.executeBatch(new HDT_BA_UpdateOfferCode(this.method), 200);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, SapContractCode__c, Pod__c, OfferCode__c, Profile__c, Commodity__c, EffectiveDate__c, CodTzero__c, EffectiveMonths__c, CausalCode__c FROM OfferCodeUpdateLog__c ';
        if(this.method.equals('FirstCommunicationCode')){
            query += 'WHERE CodTzero__c =  \'Y\'';
        }else{
            query += 'WHERE CodTzero__c =  \'N\'';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<OfferCodeUpdateLog__c> scope){
        List<Case> listOfCaseToInsert = new List<Case>();
        Set<String> setOfSapContractCode = new Set<String>();
        Map<String, OfferCodeUpdateLog__c> mapSapContractCodeOfferCodeUpdateLog = new Map<String, OfferCodeUpdateLog__c>();
        Map<String, OfferCodeUpdateLog__c> mapIdOfferCodeUpdateLog = new Map<String, OfferCodeUpdateLog__c>();
        for(OfferCodeUpdateLog__c offerCodeUpdLog : scope){
            setOfSapContractCode.add(offerCodeUpdLog.SapContractCode__c);
            mapSapContractCodeOfferCodeUpdateLog.put(offerCodeUpdLog.SapContractCode__c, offerCodeUpdLog);
            mapIdOfferCodeUpdateLog.put(offerCodeUpdLog.Id, offerCodeUpdLog);
        }
        List<Contract> listOfContract = new List<Contract>();
        HDT_QR_Contract queryContract = new HDT_QR_Contract();
        listOfContract = queryContract.getContractBySapCodeBpManagementBulk(setOfSapContractCode);
        Map<String, String> mapIdContractIdOfferCodeUpdateLog = new Map<String, String>();
        for(Contract contr : listOfContract){
            if(mapSapContractCodeOfferCodeUpdateLog.containsKey(contr.SapContractCode__c)){
                mapIdContractIdOfferCodeUpdateLog.put(contr.Id,mapSapContractCodeOfferCodeUpdateLog.get(contr.SapContractCode__c).Id);
            }
        }
        
        listOfCaseToInsert = HDT_SRV_AnagAlignment.bulkCreateAnagAlignmentOfferCode(scope);
        List<Database.SaveResult> listOfDmlInsertCase = Database.insert(listOfCaseToInsert, false);
        List<OfferCodeUpdateLog__c> listOfOfferCodeUpdateLogToDelete = new List<OfferCodeUpdateLog__c>();
        Map<String, String> mapIdCaseCodTZero = new Map<String, String>();
        for(Integer i = 0; i < listOfDmlInsertCase.size(); i++){
            Database.SaveResult sr = listOfDmlInsertCase[i];
            Case cas = listOfCaseToInsert[i];
            if(sr.isSuccess()){
                if(mapIdContractIdOfferCodeUpdateLog.containsKey(cas.Contract__c)){
                    String offerCodeUpdateLogId = mapIdContractIdOfferCodeUpdateLog.get(cas.Contract__c);
                    if(mapIdOfferCodeUpdateLog.containsKey(offerCodeUpdateLogId)){
                        listOfOfferCodeUpdateLogToDelete.add(mapIdOfferCodeUpdateLog.get(offerCodeUpdateLogId));
                        mapIdCaseCodTZero.put(sr.getId(),mapIdOfferCodeUpdateLog.get(offerCodeUpdateLogId).CodTzero__c);
                    }     
                }
            }
        }
        List<CaseExtension__c> listOfCaseExtension = new List<CaseExtension__c>();
        if(!mapIdCaseCodTZero.isEmpty()){
            for(String idCase : mapIdCaseCodTZero.keySet()){
                CaseExtension__c caseExtension = new CaseExtension__c ();
                caseExtension.ExternalKey__c = idCase;
                caseExtension.CodTzero__c = mapIdCaseCodTZero.get(idCase);
                listOfCaseExtension.add(caseExtension);
            }
            HDT_UTL_DatabaseService.upsertSObjectExternalId(listOfCaseExtension, 'CaseExtension__c', 'ExternalKey__c');
        }
        if(!listOfOfferCodeUpdateLogToDelete.isEmpty()){
            HDT_UTL_DatabaseService.deleteSObject(listOfOfferCodeUpdateLogToDelete);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(!this.method.equals('FirstCommunicationCode')){
            this.method = 'FirstCommunicationCode';
            if(!Test.isRunningTest()){
                Id batchId = Database.executeBatch(new HDT_BA_UpdateOfferCode(this.method), 1);
            }  
            System.debug('Finish batch HDT_BA_AlignSapOfferCodeTable with method UpgradeCode and starting FirstCommunicationCode');
        }else{
            System.debug('Finish batch HDT_BA_AlignSapOfferCodeTable with method FirstCommunicationCode');
        }
        
    }
}