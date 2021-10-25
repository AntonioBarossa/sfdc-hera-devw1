/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 13/10/2021
* @description Test Class for HDT_SRV_ScriptManager
*/
@isTest
public with sharing class HDT_SRV_ScriptManagerTst {
    
    @testSetup
    static void setup() {
        HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

        final String PHASE_INC = 'Bozza';

        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

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
        insert ordListChild;
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].id);
        actList[0].SuspensionDueDate__c = system.today(); 
        actList[0].Status__c = 'Sospesa'; 
        actList[0].Type__c = 'Quality Call'; 
        actList[0].RecordTypeDevName__c  = 'HDT_RT_Scarto';
        insert actList;  
        
        // HDT_ScriptPerCommOffer__mdt scriptPerCommOffer0 = new HDT_ScriptPerCommOffer__mdt();
        // scriptPerCommOffer0.DeveloperName = 'QualityCall';
        // scriptPerCommOffer0.MasterLabel = 'QualityCall';
        // scriptPerCommOffer0.Language = 'it';
        // scriptPerCommOffer0.Label = 'QualityCall';
        // scriptPerCommOffer0.QualifiedApiName = 'QualityCall';
        // scriptPerCommOffer0.ScriptName__c = 'QualityCall';
        // scriptPerCommOffer0.Object__c = 'Activity';
        // scriptPerCommOffer0.ActivityType__c = 'QualityCall';

        // HDT_ScriptPerCommOffer__mdt scriptPerCommOffer1 = new HDT_ScriptPerCommOffer__mdt();
        // scriptPerCommOffer1.DeveloperName = 'OTPCoopresenza-MiniVocalOrder';
        // scriptPerCommOffer1.MasterLabel = 'OTPCoopresenza-MiniVocalOrder';
        // scriptPerCommOffer1.Language = 'it';
        // scriptPerCommOffer1.Label = 'OTPCoopresenza-MiniVocalOrder';
        // scriptPerCommOffer1.QualifiedApiName = 'OTPCoopresenza_MiniVocalOrder';
        // scriptPerCommOffer1.ScriptName__c = 'Mini Vocal Order';
        // scriptPerCommOffer1.Object__c = 'Order';
        // scriptPerCommOffer1.SignatureMethod__c = 'OTP Coopresenza';

        //List<HDT_ScriptPerCommOffer__mdt> test = HDT_SRV_ScriptManager.scriptPerCommOffers;

    }

    @isTest
    static void testGetOrderScriptConfig(){

        Test.startTest();

        Order order = [SELECT Id, Name, ParentOrder__c FROM Order WHERE Order.Name like:'Father'];

        list<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> config = HDT_SRV_ScriptManager.getScriptConfig(order.ID);

        Test.stopTest();

    }

    @isTest
    static void testGetActivityScriptConfig(){

        Test.startTest();

        wrts_prcgvr__Activity__c actCustom = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];

        list<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> config = HDT_SRV_ScriptManager.getScriptConfig(actCustom.ID);

        Test.stopTest();

    }
}
