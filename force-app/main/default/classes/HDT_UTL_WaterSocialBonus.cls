public inherited sharing class HDT_UTL_WaterSocialBonus extends HDT_SRV_AccountDataEnrichmentSupport {

    public override void setBodyRequest(){
        System.debug(LoggingLevel.DEBUG, '>>> HDT_UTL_WaterSocialBonus -> setBodyRequest...');

        List<Account> accList;
        accList = HDT_QR_AccountDataEnrichment.getAccountRecords(accList, recordId);

        if(accList.size() == 0 || String.isEmpty(accList[0].CustomerCode__c)){
            errorMessage = 'No Customer Code!';
            success = false;
        }

        body = '{"bp": "' + accList[0].CustomerCode__c + '",';
        body += '"codiceFiscaleRichiedente": "' + accList[0].FiscalCode__c + '"';
        body += '}';

        endPoint = enrichmentbMetadataList[0].Credential__c;

    }

}