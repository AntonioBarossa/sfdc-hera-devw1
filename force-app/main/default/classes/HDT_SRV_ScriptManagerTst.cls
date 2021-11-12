/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 13/10/2021
* @description Test Class for HDT_SRV_ScriptManager
*/
@isTest
public with sharing class HDT_SRV_ScriptManagerTst {

    private static final String PHASE_INC = 'Bozza';
    
    @testSetup
    static void setup() {
        HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

        List<ScriptConfig__c> scList = HDT_UTL_DataFactoryTst.createScriptConfig(1,true);

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC);
        ordList[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        ordList[0].Name = 'Father';
        ordList[0].SignatureMethod__c = 'OTP Coopresenza';
        insert ordList;
        List<Order> ordListChild = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC);
        ordListChild[0].Name = 'Son';
        ordListChild[0].ParentOrder__c = ordList[0].Id;
        ordListChild[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        ordListChild[0].CommercialProductCode__c = 'TEST_OFFER_1';
        insert ordListChild;
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].id);
        actList[0].SuspensionDueDate__c = system.now().addDays(1); 
        actList[0].Status__c = 'Sospesa'; 
        actList[0].Type__c = 'Quality Call'; 
        actList[0].RecordTypeDevName__c  = 'HDT_RT_Scarto';
        insert actList;

        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);

        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, true);
        
        List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1,false);
        campaignList[0].Name = 'LEAD CALLBACK';
        campaignList[0].ScriptConfig__c = scList[0].Id;
        insert campaignList;
        Id campaignId = campaignList[0].Id;
       
        HDT_UTL_DataFactoryTst.createCampaignMember(true,campaignId,leadList,conList);
    }

    @isTest
    static void testGetOrderScriptConfig(){

        List<HDT_ScriptPerCommOffer__mdt> scriptsMapMock = HDT_SRV_ScriptManager.scriptsMapping;

        HDT_ScriptPerCommOffer__mdt mappingMock = new HDT_ScriptPerCommOffer__mdt();
        mappingMock.Object__c = 'Order';
        mappingMock.SignatureMethod__c = 'OTP Coopresenza';
        mappingMock.OfferCode__c = 'TEST_OFFER_1';
        mappingMock.ScriptName__c = 'Hera';

        scriptsMapMock.add(mappingMock);

        Order order = [SELECT Id, Name, ParentOrder__c FROM Order WHERE Order.Name like:'Father'];
        
        Test.startTest();
        List<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> config = HDT_SRV_ScriptManager.getScriptConfig(order.Id);
        Test.stopTest();

        System.assertEquals(true, !config.isEmpty(), 'The configurations were not retrieved correctly');
        System.assertNotEquals(true, config.isEmpty(), 'The configurations were not retrieved correctly');
        System.assertEquals('Hera', config[0].scriptName, 'The configurations were not retrieved correctly');
    }

    @isTest
    static void testGetActivityScriptConfig(){

        List<HDT_ScriptPerCommOffer__mdt> scriptsMapMock = HDT_SRV_ScriptManager.scriptsMapping;

        HDT_ScriptPerCommOffer__mdt mappingMock = new HDT_ScriptPerCommOffer__mdt();
        mappingMock.Object__c = 'Activity';
        mappingMock.ActivityType__c = 'Quality Call';
        mappingMock.ScriptName__c = 'Hera';

        scriptsMapMock.add(mappingMock);

        wrts_prcgvr__Activity__c actCustom = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];
        
        Test.startTest();
        List<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> config = HDT_SRV_ScriptManager.getScriptConfig(actCustom.Id);
        Test.stopTest();

        System.assertEquals(true, !config.isEmpty(), 'The configurations were not retrieved correctly');
        System.assertNotEquals(true, config.isEmpty(), 'The configurations were not retrieved correctly');
        System.assertEquals('Hera', config[0].scriptName, 'The configurations were not retrieved correctly');
    }

    @isTest
    static void testGetCampaignMemberScriptConfig(){

        CampaignMember campMember = [SELECT Id FROM CampaignMember LIMIT 1];
        
        Test.startTest();
        list<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> config = HDT_SRV_ScriptManager.getScriptConfig(campMember.Id);
        Test.stopTest();

        System.assertEquals(true, !config.isEmpty(), 'The configurations were not retrieved correctly');
        System.assertNotEquals(true, config.isEmpty(), 'The configurations were not retrieved correctly');
        System.assertEquals('Hera', config[0].scriptName, 'The configurations were not retrieved correctly');
    }
}
