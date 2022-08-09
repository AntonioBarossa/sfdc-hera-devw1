public inherited sharing class HDT_UTL_GaaView extends HDT_SRV_AccountDataEnrichmentSupport {

    public override void setBodyRequest(){
        System.debug(LoggingLevel.DEBUG, '>>> HDT_UTL_WaterSocialBonus -> setBodyRequest...');

        List<Account> accList;
        accList = HDT_QR_AccountDataEnrichment.getAccountRecords(accList, recordId);

        if(accList.size() == 0 || String.isEmpty(accList[0].CustomerCode__c)){
            errorMessage = 'No Customer Code!';
            success = false;
        }

        System.debug('--> relatedToId ' + relatedToId);
        String implantType = '';
        
        try{
            implantType = getRelatedRecord(relatedToId);
        } catch (Exception e){
            System.debug('--> error retrieving implantType: ' + e.getMessage() + '[' + String.valueOf(e.getLineNumber()) + ']');
        }
        
        body = '{"bp": "' + accList[0].CustomerCode__c + '",';
        body += '"impianto": "' + implantType + '"';
        body += '}';

        endPoint = enrichmentbMetadataList[0].Credential__c;

    }

    public static String getRelatedRecord(String recordId){
        Id myId = Id.valueOf(recordId);
        String sObectType = String.valueOf(myId.getSobjectType());

        System.debug('--> sObectType ' + sObectType);

        String fieldApiName = '';
        String queryString = '';
        
        switch on sObectType {
            when 'Contract' {
                fieldApiName = '';
            }	
            when 'ServicePoint__c' {
                fieldApiName = 'SAPImplantCode__c';
            }
        }

        queryString += 'SELECT Id, ' + fieldApiName + ' ';
        queryString += 'FROM ' + sObectType + ' ';
        queryString += 'WHERE Id = \'' + recordId + '\' LIMIT 1';

        System.debug('--> sObectType ' + queryString);

        List<sObject> sObjectList = new List<sObject>();
        sObjectList = HDT_QR_AccountDataEnrichment.getRecordsList(sObjectList, queryString, sObectType);
        sObject obj = sObjectList[0];

        return (String)obj.get(fieldApiName);

    }

}