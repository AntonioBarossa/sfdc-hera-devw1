/**
    * @author Angelo Ballacchino (angelo.ballacchino@nttdata.com)
    * @date 10/04/2023
    */
@isTest
public class HDT_UTL_OdlAdsViewTst {
	@isTest
    static void testSetBodyRequest() {
        
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        for(Account a : acctList){
            a.CustomerCode__c = '1003616210';
        }
        
        update acctList;

        /*List<Account> accList = [
            SELECT Id, CustomerCode__c, FiscalCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1            
        ];*/
        
        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, 'odlAdsView');

        if(enrichmentbMetadataList.size()==0){
            throw new AuraHandledException('No enrichment Metadata!');
        }

        //HDT_UTL_OdlAdsView view = new HDT_UTL_OdlAdsView();
         
        Test.startTest();
        //view.setBodyRequest();
        Type t = Type.forName('HDT_UTL_OdlAdsView');
        HDT_SRV_AccountDataEnrichmentSupport support = (HDT_SRV_AccountDataEnrichmentSupport)t.newInstance();
        support.setMetadata(enrichmentbMetadataList);
        support.setRecordIds(acctList[0].Id, '');
        support.execute();
        Test.stopTest();

        System.assertEquals('{"bp": "1003616210","case": ""}', support.body);
        
        
    }
}