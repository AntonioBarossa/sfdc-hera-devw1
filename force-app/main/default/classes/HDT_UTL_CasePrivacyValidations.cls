public inherited sharing class HDT_UTL_CasePrivacyValidations implements HDT_UTL_CaseValidationInterface {

    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    public String validate(String fields, String recordId){

        String fieldq = 'Id,MarketingPrivacy__c,ProfilingPrivacy__c,HasOptedOutSoftSpam__c,HasOptedOutOfEmail__c';
        String fromq = 'Individual';
        String whereq = 'Id = \''+recordId+'\'';
        String queryString = 'SELECT ' + fieldq + ' FROM ' + fromq + ' WHERE ' +  whereq;
        List<SObject> sobjectRecordList = HDT_QR_GenericQuery.getGenericRecords(queryString, fromQ);
        Individual individualRecord = (Individual) sobjectRecordList[0];

        System.debug('HDT_UTL_CasePrivacyValidations: validating individual: ' + individualRecord);
        System.debug('HDT_UTL_CasePrivacyValidations: fields modified: ' + fields);

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        Boolean currentHasOptedOutOfEmail = (Boolean) individualRecord.get('HasOptedOutOfEmail__c');
        Boolean newHasOptedOutOfEmail = Boolean.valueOf(getFieldValue(fields, 'HasOptedOutOfEmail__c'));
        if (newHasOptedOutOfEmail && !currentHasOptedOutOfEmail) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è possibile disiscrivere il cliente dalle liste di distribuzione.'));
            return result;
        }

        String newMarketingPrivacy = getFieldValue(fields, 'MarketingPrivacy__c') != null ? getFieldValue(fields, 'MarketingPrivacy__c') : '';
        String newProfilingPrivacy = getFieldValue(fields, 'ProfilingPrivacy__c') != null ? getFieldValue(fields, 'ProfilingPrivacy__c') : '';
        Boolean newHasOptedOutSoftSpam = Boolean.valueOf(getFieldValue(fields, 'HasOptedOutSoftSpam__c'));

        Boolean currentHasOptedOutSoftSpam = (Boolean) individualRecord.get('HasOptedOutSoftSpam__c');
        String currentMarketingPrivacy = (String) individualRecord.get('MarketingPrivacy__c') != null ? (String) individualRecord.get('MarketingPrivacy__c') : '';
        String currentProfilingPrivacy = (String) individualRecord.get('ProfilingPrivacy__c') != null ? (String) individualRecord.get('ProfilingPrivacy__c') : '';

        if (newHasOptedOutOfEmail == currentHasOptedOutOfEmail && newHasOptedOutSoftSpam == currentHasOptedOutSoftSpam && 
            newMarketingPrivacy.equals(currentMarketingPrivacy) && newProfilingPrivacy.equals(currentProfilingPrivacy)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario modificare almeno un consenso privacy per poter proseguire.'));
        }

        return result;
    }

    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }

}