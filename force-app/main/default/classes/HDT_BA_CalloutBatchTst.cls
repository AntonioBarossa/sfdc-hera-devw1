/**
 * @author Valere (valere@noeli-it.net)
 * @date 16/09/2021
 * @description HDT_BA_CalloutBatch Test Class
 * @history valere - 16/09/2021– Created Class
 */
@istest
public class HDT_BA_CalloutBatchTst {

    @TestSetup
    static void makeData(){
        // HDT_WS_Response rep = New HDT_WS_Response();
        PaperCampaignParameter__c paperCampaignParameter =  HDT_UTL_DataFactoryTst.createPaperCampaignParameter(1, true)[0];

        Campaign camp = HDT_UTL_DataFactoryTst.createCampaignWithParams(1, true,new Map<String,String>{
            'PaperCampaignParameter__c'=>PaperCampaignParameter.id,
            'Category__c'=>'Campagna Outbound',
            'Name'=>'Test Campaign',
            'Channel__c'=>'Bolletta'
        })[0];

        List<Lead> leads = HDT_UTL_DataFactoryTst.createLead (1,true);
        Account acc= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie')[0];
        List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact (1,true,acc.id);
        PaperProcessing__c paperProcessing = HDT_UTL_DataFactoryTst.createPaperProcessing(1, true, 'Testname', camp.id)[0];
        
        List<CampaignMember> cMembers = HDT_UTL_DataFactoryTst.createCampaignMember(false, camp.id, leads, contacts);
        cMembers[0].PaperProcess__c = paperProcessing.Id;
        insert cMembers;

        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('PraxidiaIntegration', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-enrichment/entities', 'POST', 'HerokuUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('postPaperProcessing', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-enrichment/entities', 'POST', 'HerokuUser');
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // It is impossible to put a realistic assert sinces the batch doesn't modify data or return anything
    @istest 
    static void methodTst() {
        Test.setMock(HttpCalloutMock.class, new HDT_BA_CalloutBatchMck());
        PaperProcessing__c paperProcessing=[SELECT Id FROM PaperProcessing__c][0];
        CampaignMember campMember=[SELECT Contact.Account.CustomerCode__c FROM CampaignMember][0];
        HDT_WRP_PaperProcessing ppwrap =  new HDT_WRP_PaperProcessing();
        ppwrap.codCliente = campMember.Contact.Account.CustomerCode__c;
        list<String> contentVersionIdList = new List<String>();
        String fileName = 'Report_Clienti_' + 'paperProcessingId' + date.today().year() + date.today().month() + date.today().day();
        contentVersionIdList.add(HDT_UTL_PaperProcessing.generateFile(new list<HDT_WRP_PaperProcessing>{ppwrap}, paperProcessing.Id, fileName));
        Test.startTest();
        
        HDT_BA_CalloutBatch baSend1 = new HDT_BA_CalloutBatch();
        baSend1.typeCallout = 'Comunicazione Cartacea';
        baSend1.dtos = contentVersionIdList;
        baSend1.filezipName = 'Lavorazione_Cartacea_';
        Database.executebatch(baSend1, 100);
        
        HDT_BA_CalloutBatch baSend2 = new HDT_BA_CalloutBatch();
        baSend2.typeCallout = 'Front Office';
        baSend2.dtos = contentVersionIdList;
        baSend2.filezipName = 'Lavorazione_Cartacea_';
        Database.executebatch(baSend2, 100);
        
        HDT_BA_CalloutBatch baSend3 = new HDT_BA_CalloutBatch();
        baSend3.typeCallout = 'Reclami';
        baSend3.dtos = contentVersionIdList;
        baSend3.filezipName = 'Lavorazione_Cartacea_';
        Database.executebatch(baSend3, 100);

        Test.stopTest();

        /**
         * No asserts because the testes batch doesn't affect any data in DB directly but asynchronous processes called from the batch
         */
    }
}