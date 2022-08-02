public inherited sharing class HDT_UTL_OdlAdsView extends HDT_SRV_AccountDataEnrichmentSupport {

    public override void setBodyRequest(){
        System.debug(LoggingLevel.DEBUG, '>>> HDT_UTL_WaterSocialBonus -> setBodyRequest...');

        List<Account> accList;
        accList = HDT_QR_AccountDataEnrichment.getAccountRecords(accList, recordId);

        if(accList.size() == 0 || String.isEmpty(accList[0].CustomerCode__c)){
            errorMessage = 'No Customer Code!';
            success = false;
        }

        String caseNumber = '';

        body = '{"bp": "' + accList[0].CustomerCode__c + '",';
        body += '"case": "' + caseNumber + '"';
        body += '}';

        endPoint = enrichmentbMetadataList[0].Credential__c;

    }

}
