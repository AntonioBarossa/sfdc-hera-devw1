/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 18/06/2021
* @description Class that holds util functions for wrts_prcgvr__Activity__c
* @history Keltin Mesonjesi – 18/06/2021 – Created class
*/
public inherited sharing class HDT_UTL_ActivityCustom {
    
    private static HDT_SRV_ActivityCustom activityCustomSrv = new HDT_SRV_ActivityCustom();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 18/06/2021
    * @description Create new wrts_prcgvr__Activity__c based on passed params
    * @param Map<String,String> params
    */
    
    @AuraEnabled
    public static boolean riassegnaComCod(string recordId){
        try{
            HDT_QR_Case caseQr = new HDT_QR_Case();
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
            Case c = caseQr.getRecordById(s.case__c);
            c.phase__c	='In Attesa Approvazione';
            caseSrv.updateRecord(c);
            return true;
        }catch(exception e){
            return false;
        }
        
    }
    @AuraEnabled
    public static boolean cambiaphaseComm(string recordId,string causale){
        try{
            HDT_QR_Case caseQr = new HDT_QR_Case();
            wrts_prcgvr__Activity__c s = HDT_QR_ActivityCustom.getRecordByIdS(recordId);
            s.wrts_prcgvr__status__c = 'Completed';
            s.approved__c = causale;
            activityCustomSrv.updateRecord(s);
            Case c = caseQr.getRecordById(s.case__c);
            c.phase__c	='In Lavorazione';
            caseSrv.updateRecord(c);
            return true;
        }
        catch(Exception e){
            return false;
        }
    }

    public static void createActivityWithParams(Map<String,String> params){

        system.debug('HDT_UTL_ActivityCustom START');
        system.debug('HDT_UTL_ActivityCustom params: ' + params);

        List<Account> accountListRetrieved = new List<Account>();

        if (params.get('FiscalCode__c') != null && params.get('VATNumber__c') != null) {
            accountListRetrieved = accountQr.getAccountByFiscalCodeAndVat(params.get('FiscalCode__c'), params.get('VATNumber__c'));
        } else if(params.get('FiscalCode__c') != null){
            accountListRetrieved = accountQr.getAccountByFiscalCode(params.get('FiscalCode__c'));
        } else {
            accountListRetrieved = accountQr.getAccountByVat(params.get('VATNumber__c'));
        }

        activityCustomSrv.createRecord(new wrts_prcgvr__Activity__c(
            RecordTypeId = getRecordTypeId(params.get('RecordTypeDeveloperName')),
            Type__c = params.get('Type__c'),
            ServicePointCode__c = params.get('ServicePointCode__c'),
            Account__c = !accountListRetrieved.isEmpty() ? accountListRetrieved[0].Id : null,
            Status__c = params.get('Status__c'),
            EffectiveDate__c = params.get('EffectiveDate__c') != null ? Date.valueOf(params.get('EffectiveDate__c')) : null,
            HerokuPracticeCode__c = params.get('HerokuPracticeCode__c')
        ));

        system.debug('HDT_UTL_ActivityCustom END');
    }


    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/02/2021
    * @description Get record type ID for record types of wrts_prcgvr__Activity__c
    * @param String
    * @return String
    */
    public static String getRecordTypeId(String recordTypeDeveloperName){
        system.debug('HDT_UTL_ActivityCustom - getRecordTypeId START');
        system.debug('HDT_UTL_ActivityCustom - recordTypeDeveloperName: ' + recordTypeDeveloperName);

        List<Schema.RecordTypeInfo> recordTypes = wrts_prcgvr__Activity__c.SObjectType.getDescribe().getRecordTypeInfos();
        String recordTypeId = '';
        for (Schema.RecordTypeInfo recordType : recordTypes) {
            if (recordType.getDeveloperName() == recordTypeDeveloperName) {
                recordTypeId = recordType.getRecordTypeId();
            }
        }

        system.debug('HDT_UTL_ActivityCustom - getRecordTypeId END');
        system.debug('HDT_UTL_ActivityCustom - recordTypeId: ' + recordTypeId);

        return recordTypeId;
    }
    
}