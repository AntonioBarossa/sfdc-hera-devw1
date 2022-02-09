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

        HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();
		HDT_UTL_DataFactoryTst.pClickCasePhase();

        HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

        List<ScriptConfig__c> scList = HDT_UTL_DataFactoryTst.createScriptConfig(1,true);

        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        productList[0].CategoryFamily__c = 'Hera Impronta Zero';
        productList[0].ProductCode = 'HIZL_E_24';
        insert productList;

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, PHASE_INC);
        ordList[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        ordList[0].Name = 'Father';
        ordList[0].SignatureMethod__c = 'Vocal Order';
        ordList[1].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        ordList[1].Name = 'Father 2';
        ordList[1].SignatureMethod__c = 'OTP Remoto';
        insert ordList;

        Product2 prod = [SELECT Id FROM Product2 WHERE ProductCode = 'HIZL_E_24' LIMIT 1];

        Id pricebookId = Test.getStandardPricebookId();

        List<Order> ordListChild = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC);
        ordListChild[0].Name = 'Son';
        ordListChild[0].ParentOrder__c = ordList[0].Id;
        ordListChild[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        ordListChild[0].CommercialProductCode__c = 'HIZL_E_24';
        ordListChild[0].Pricebook2Id=pricebookId;
        insert ordListChild;

        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(2, true, accList[0].Id, 'Attiva');


        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
        Id pointId = points[0].id;

        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(productList,true,pricebookId);
        Id entryId = entries[0].id;

        Order child = [SELECT Id FROM Order WHERE Name = 'Son'];

        List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(10,true,child.Id,pointId,prod.Id,entryId);
        Id orderItemId = orderItems[0].id;

        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].id);
        actList[0].SuspensionDueDate__c = System.now().addDays(1).date(); 
        actList[0].wrts_prcgvr__Status__c = 'Sospesa'; 
        actList[0].Type__c = 'Quality Call'; 
        actList[0].RecordTypeDevName__c  = 'HDT_RT_Scarto';
        insert actList;

        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);

        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, true);
        
        List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(2,false);
        campaignList[0].Name = 'LEAD CALLBACK';
        campaignList[0].ScriptConfig__c = scList[0].Id;
        campaignList[0].Tipology__c = 'Comfort Call';
        campaignList[1].Name = 'LEAD CALLBACK 2';
        campaignList[1].ScriptConfig__c = scList[0].Id;
        campaignList[1].FlowType__c = 'Aggiornamento Anagrafica';
        insert campaignList;
        Id campaignId = campaignList[0].Id;
        Id campaignId2 = campaignList[1].Id;

        List<CampaignMember> cmpMemberList = HDT_UTL_DataFactoryTst.createCampaignMember(true,campaignId,leadList,conList);
        List<CampaignMember> cmpMemberList2 = HDT_UTL_DataFactoryTst.createCampaignMember(true,campaignId2,leadList,conList);
    }

    @isTest
    static void testGetOrderScriptConfig(){

        List<HDT_ScriptPerCommOffer__mdt> scriptsMapMock = HDT_SRV_ScriptManager.scriptsMapping;

        HDT_ScriptPerCommOffer__mdt mappingMock = new HDT_ScriptPerCommOffer__mdt();
        mappingMock.Object__c = 'Order';
        mappingMock.SignatureMethod__c = 'Vocal Order';
        mappingMock.OfferCode__c = 'Hera Impronta Zero';
        mappingMock.ScriptName__c = 'Hera Impronta Zero';
        mappingMock.OfferName__c = 'Hera Impronta Zero';

        scriptsMapMock.add(mappingMock);

        Order order = [SELECT Id, Name, ParentOrder__c FROM Order WHERE Order.Name like:'Father'];
        
        Test.startTest();
        List<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> config = HDT_SRV_ScriptManager.getScriptConfig(order.Id);
        Test.stopTest();

        System.assert(config.size() > 0, 'The configurations were not retrieved correctly');
        // System.assertEquals(true, !config.isEmpty(), 'The configurations were not retrieved correctly');
        // System.assertNotEquals(true, config.isEmpty(), 'The configurations were not retrieved correctly');
        // System.assertEquals('Hera', config[0].scriptName, 'The configurations were not retrieved correctly');
    }

    @isTest
    static void testGetOrderScriptConfigOtpRemoto(){

        List<HDT_ScriptPerCommOffer__mdt> scriptsMapMock = HDT_SRV_ScriptManager.scriptsMapping;

        HDT_ScriptPerCommOffer__mdt mappingMock = new HDT_ScriptPerCommOffer__mdt();
        mappingMock.Object__c = 'Order';
        mappingMock.DeveloperName = 'Mini_VO';
        mappingMock.ScriptFlowName__c = 'HDL_FL_VO_Script_Mini_VO';

        scriptsMapMock.add(mappingMock);

        Order order = [SELECT Id, Name, ParentOrder__c FROM Order WHERE Order.Name = 'Father 2'];
        
        Test.startTest();
        List<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> config = HDT_SRV_ScriptManager.getScriptConfig(order.Id);
        Test.stopTest();

        System.assert(config.size() > 0, 'The configurations were not retrieved correctly');
    }

    @isTest
    static void testGetFlowCampaign(){

        CampaignMember cmpMember = [SELECT Id FROM CampaignMember WITH SECURITY_ENFORCED LIMIT 1];

        List<HDT_ScriptPerCommOffer__mdt> scriptsMapMock = HDT_SRV_ScriptManager.scriptsMapping;

        HDT_ScriptPerCommOffer__mdt mappingMock = new HDT_ScriptPerCommOffer__mdt();
        mappingMock.Object__c = 'Campaign';
        mappingMock.ActivityType__c = 'Comfort Call';

        scriptsMapMock.add(mappingMock);

        Test.startTest();
        String result = HDT_SRV_ScriptManager.getFlowCampaign(cmpMember.Id);
        Test.stopTest();
    
        System.assertNotEquals(result, null, 'Si è verificato un errore in fase di get del flow');
    }

    @isTest
    static void testGetFlowCampaignWithFlowType(){

        CampaignMember cmpMember = [SELECT Id FROM CampaignMember WHERE Campaign.Tipology__C = NULL WITH SECURITY_ENFORCED LIMIT 1];

        List<HDT_ScriptPerCommOffer__mdt> scriptsMapMock = HDT_SRV_ScriptManager.scriptsMapping;

        HDT_ScriptPerCommOffer__mdt mappingMock = new HDT_ScriptPerCommOffer__mdt();
        mappingMock.Object__c = 'Campaign';
        mappingMock.OfferName__c = 'Aggiornamento Anagrafica';
        mappingMock.ScriptFlowName__c = 'HDT_Script_Aggiornamento_Anagrafica';

        scriptsMapMock.add(mappingMock);

        Test.startTest();
        String result = HDT_SRV_ScriptManager.getFlowCampaign(cmpMember.Id);
        Test.stopTest();
    
        System.assertNotEquals(result, null, 'Si è verificato un errore in fase di get del flow');
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
