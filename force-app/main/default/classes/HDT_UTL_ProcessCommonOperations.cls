@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_ProcessCommonOperations {

    public static HDT_WRP_SaveResponse databaseInsert(List<sObject> itemList, List<String> itemIds, String sObjectType){
        HDT_WRP_SaveResponse saveResponse = new HDT_WRP_SaveResponse();
        saveResponse.reponseItemList = new List<MassiveLoaderRequestItem__c>();
        saveResponse.savedObject = new List<sObject>();
        saveResponse.itemIdToObjId = new Map<Id, Id>();

        SObjectType objtype = Schema.getGlobalDescribe().get(sObjectType);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable()){

            List<Database.SaveResult> insertResults = Database.insert(itemList, false);

            for(Integer n=0; n<insertResults.size(); n++){
                Database.SaveResult sr = insertResults[n];

                if(sr.isSuccess()) {

                    MassiveLoaderRequestItem__c itemSuccess;
                    itemSuccess = new MassiveLoaderRequestItem__c();
                    itemSuccess.Id = itemIds[n];
                    itemSuccess.Status__c = 'Chiuso';
                    saveResponse.reponseItemList.add(itemSuccess);
                    saveResponse.savedObject.add(itemList[n]);
                    saveResponse.itemIdToObjId.put(itemIds[n], sr.getId());

                } else {

                    MassiveLoaderRequestItem__c itemError;
                    itemError = new MassiveLoaderRequestItem__c();
                    itemError.Id = itemIds[n];
                    itemError.Status__c = 'Errore';

                    String errorMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage += '[' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + '] ';
                        System.debug(LoggingLevel.DEBUG, '>>> errorMessage ' + errorMessage);
                    }

                    itemError.StatusDescription__c = errorMessage.abbreviate(250);
                    saveResponse.reponseItemList.add(itemError);
                    
                }
            }
        }

        return saveResponse;

    }

    public static void runCompatibility(List<Case> savedCase){
        Map<Id, String> compatibilityMap = checkCompatibilityPostSales(savedCase);
        //System.debug(LoggingLevel.DEBUG, '>>> compatibilityMap ' + String.valueOf(compatibilityMap));

        //***************** */
        // example to test Phase__c => Da Inviare           
        //Set<Id> i = compatibilityMap.keySet();
        //List<Id> listkey = new List<Id>();
        //listkey.addAll(i);
        //compatibilityMap.remove(listkey[0]);
        //***************** */

        updateCaseAfterCompatibility(compatibilityMap, savedCase);
        getLimitDetails('AFTER Compatibility');

    }
    
    private static Map<Id, String> checkCompatibilityPostSales(List<Case> csList){

        List<ServiceRequest__c> srList = new List<ServiceRequest__c>();
        List<ServiceRequest__c> srListToDelete = new List<ServiceRequest__c>();
        Map<Id, String> caseIdToCompatibility = new Map<Id, String>();

        try {
            String compatibility = '';

            ServiceRequest__c srvRequest;
            for(Case cs : csList){
                srvRequest = new ServiceRequest__c();
                srvRequest.Case__c = cs.Id;
                srvRequest.ServicePointCode__c = cs.PODPDRFormula__c;
                srvRequest.Status__c = HDT_UTL_MatrixCompatibility.getStatus(cs.Status, 'Case');
                srvRequest.CommoditySector__c = cs.CommodityFormula__c;
                srvRequest.Type__c = 'Case';
    
                if(cs.ServicePoint__c != null){
                    srvRequest.ServicePoint__c = cs.ServicePoint__c;
                } else {
                    srvRequest.Account__c = cs.AccountId;
                    srvRequest.BillingProfile__c = cs.BillingProfile__c;
                }
    
                //srvRequest.ProcessType__c = 'Chiusura contatore - EE';
                srvRequest.ProcessType__c = HDT_UTL_MatrixCompatibility.getProcessType(cs.Type, 'Case', cs.Commodity__c);
                srList.add(srvRequest);
            }

            HDT_UTL_DatabaseService.insertSObject(srList);

            for(ServiceRequest__c sReq : srList){
                wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = HDT_UTL_MatrixCompatibility.checkCompatibility(sReq);

                System.debug(LoggingLevel.DEBUG, '>>> ObjectCompatibility: ' + result);

                //list of incompatible records
                if(!result.incompatibilities.isEmpty()){
                    compatibility = HDT_UTL_MatrixCompatibility.getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                    caseIdToCompatibility.put(sReq.Case__c, compatibility);
                    srListToDelete.add(sReq);
                } else {
                    caseIdToCompatibility.put(sReq.Case__c, '');
                }
            }
            
            if(srListToDelete.size() > 0){
                //HDT_UTL_DatabaseService.deleteSObject(srListToDelete);
            }

            return caseIdToCompatibility;

        } catch (Exception e) {
            throw e;
        }
    }

    private static void updateCaseAfterCompatibility(Map<Id, String> incompatibleCaseIdSet, List<Case> savedCase){

        for(Case c : savedCase){
            if(incompatibleCaseIdSet.containsKey(c.Id)){
                c.Phase__c = 'Bozza Annullata';
                c.Status = 'Closed';
                c.CancellationReason__c = 'Processo incompatibile';
            } else {
                c.Phase__c = 'Da Inviare';
            }
        }

        HDT_UTL_DatabaseService.updateSObject(savedCase);

    }

    public static Case setCaseField(Case newCase, Id recordTypeId){
        newCase.RecordTypeId = recordTypeId;
        newCase.Status = 'In Lavorazione';
        newCase.Phase__c = 'Bozza';
        newCase.CompanyOwner__c = 'HERA COMM';
        newCase.Commodity__c = 'Energia Elettrica';
        return newCase;
    }

    public static void getLimitDetails(String stageName){
        List<String> limitList = new List<String>();
        limitList.add('>>> CpuTime: ' + String.valueOf(Limits.getCpuTime()) + ' of ' + String.valueOf(Limits.getLimitCpuTime()));
        limitList.add('>>> DML: ' + String.valueOf(Limits.getDMLStatements()) + ' of ' + String.valueOf(Limits.getLimitDMLStatements()));
        limitList.add('>>> HeapSize: ' + String.valueOf(Limits.getHeapSize()) + ' of ' + String.valueOf(Limits.getLimitHeapSize()));
        limitList.add('>>> Queries: ' + String.valueOf(Limits.getQueries()) + ' of ' + String.valueOf(Limits.getLimitQueries()));

        System.debug(LoggingLevel.DEBUG, '---------------- ' + stageName + ' ----------------');
        for(String s : limitList){
            System.debug(s);
        }

    }

    public class HDT_WRP_SaveResponse {
        public List<MassiveLoaderRequestItem__c> reponseItemList;
        public List<sObject> savedObject;
        public Map<Id, Id> itemIdToObjId;
    }

}