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
            implantType = getImplantType(relatedToId);
        } catch (Exception e){
            System.debug('--> error retrieving implantType: ' + e.getMessage() + '[' + String.valueOf(e.getLineNumber()) + ']');
            errorMessage = e.getMessage() + '[' + String.valueOf(e.getLineNumber()) + ']';
            success = false;
        }
        
        if(String.isEmpty(implantType)){
            errorMessage = 'L\'impianto non è indicato nel service point!';
            success = false;
        }

        body = '{"bp": "' + accList[0].CustomerCode__c + '",';
        body += '"impianto": "' + implantType + '"';
        body += '}';

        endPoint = enrichmentbMetadataList[0].Credential__c;

    }

    public static String getImplantType(String recordId){
        Id myId = Id.valueOf(recordId);
        String sObectType = String.valueOf(myId.getSobjectType());
        String implantType = '';
        List<sObject> sObjectList = new List<sObject>();
        
        System.debug('--> sObectType ' + sObectType);
        
        String fieldApiName = '';
        String queryString = '';
        
        switch on sObectType {
            when 'Contract' {
                fieldApiName = 'ServicePoint__r.SAPImplantCode__c';
            }	
            when 'ServicePoint__c' {
                fieldApiName = 'SAPImplantCode__c';
            }
        }

        queryString += 'SELECT Id, ' + fieldApiName + ' ';
        queryString += 'FROM ' + sObectType + ' ';
        queryString += 'WHERE Id = \'' + recordId + '\' LIMIT 1';
        sObjectList = HDT_QR_AccountDataEnrichment.getRecordsList(sObjectList, queryString, sObectType);

        switch on sObectType {
            when 'Contract' {
                List<Contract> contractList = (List<Contract>)sObjectList;
                implantType = contractList[0].ServicePoint__r.SAPImplantCode__c;
            }	
            when 'ServicePoint__c' {
                List<ServicePoint__c> spList = (List<ServicePoint__c>)sObjectList;
                implantType = spList[0].SAPImplantCode__c;
            }
        }
        
        return implantType;
    }

}