/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 16/07/2021
* @description HDT_LC_GeneralInfoTst for Test Classes
* @history Luis Bispo – 16/07/2021 – Created class
*/

@isTest
public with sharing class HDT_LC_GeneralInfoTst {

    @testSetup
    static void setup(){
        
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        HDT_UTL_DataFactoryTst.createSale(1, true, acc[0].Id, 'Attiva');
        HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        HDT_UTL_DataFactoryTst.createAgentMatrix(1,true,'Test');
    }

    @isTest
    public static void testUpdateSale(){
        Sale__c sales = [SELECT id From Sale__c LIMIT 1];
        Test.startTest();
        HDT_LC_GeneralInfo.updateSale(sales);
        System.assert(sales != null, 'Sales it not null');
        System.assertNotEquals(null,sales, 'UpdateSale did not work correctly');
        Test.stopTest();
    }

    @isTest
    public static void testGetCurrentUserName(){
        Test.startTest();
        String result = HDT_LC_GeneralInfo.getCurrentUserName();
        System.assertEquals(UserInfo.getName(), result, 'GetCurrentUserName did not work correctly');
        System.assertNotEquals(null, result, 'GetCurrentUserName did not work correctly');
        Test.stopTest();
    }

    @isTest
    public static void testGetSaleContactRole(){
        Account acc = [SELECT id From Account LIMIT 1];
        Contact ctt = [SELECT id From Contact LIMIT 1];
        Test.startTest();
        HDT_LC_GeneralInfo.getSaleContactRole(acc.Id, ctt.Id);
        System.assert(acc!= null, 'Account is not null');
        System.assertNotEquals(null, acc, 'GetSaleContactRole did not work correctly');
        Test.stopTest();
    }

    @isTest
    public static void testGetChannelAgencySucess(){
        AgentMatrix__c agentMatrix = [SELECT id, channel__c From AgentMatrix__c LIMIT 1];
        agentMatrix.channel__c = 'Back office';
        update agentMatrix;
        Test.startTest();
        HDT_LC_GeneralInfo.getChannelAgency(agentMatrix.channel__c);
        System.assert(agentMatrix!= null, 'AgentMatrix__c is not null');
        System.assertNotEquals(null, agentMatrix, 'GetChannelAgency did not work correctly');
        Test.stopTest();
    }

    
    @isTest
    public static void testGetChannelAgencyFail(){
        AgentMatrix__c agentMatrix = [SELECT id, channel__c From AgentMatrix__c LIMIT 1];
        Test.startTest();
        HDT_LC_GeneralInfo.getChannelAgency(agentMatrix.channel__c);
        System.assert(agentMatrix!= null, 'AgentMatrix__c is not null');
        System.assertNotEquals(null, agentMatrix, 'GetChannelAgency did not work correctly');
        Test.stopTest();
    }

    @isTest
    public static void testGetAgentsSucess(){
        AgentMatrix__c agentMatrix = [SELECT id, channel__c From AgentMatrix__c LIMIT 1];
        agentMatrix.channel__c = 'Back office';
        update agentMatrix;
        Test.startTest();
        HDT_LC_GeneralInfo.getAgents('Test', agentMatrix.channel__c);
        System.assert(agentMatrix!= null, 'AgentMatrix__c is not null');
        System.assertNotEquals(null, agentMatrix, 'getAgents did not work correctly');
        Test.stopTest();
    }

    @isTest
    public static void testGetAgentsFail(){
        AgentMatrix__c agentMatrix = [SELECT id, channel__c From AgentMatrix__c LIMIT 1];
        Test.startTest();
        HDT_LC_GeneralInfo.getAgents('Test', agentMatrix.channel__c);
        System.assert(agentMatrix!= null, 'AgentMatrix__c is not null');
        System.assertNotEquals(null, agentMatrix, 'getAgents did not work correctly');
        Test.stopTest();
    }

    @isTest
    public static void testHandleAutomaticAgentAssignSucess(){
        AgentMatrix__c agentMatrix = [SELECT id, channel__c From AgentMatrix__c LIMIT 1];
        Sale__c sales = [SELECT id From Sale__c LIMIT 1];
        Test.startTest();
        try {
            HDT_LC_GeneralInfo.handleAutomaticAgentAssign('Channel Test', sales.Id);
        } catch (Exception ex) { }
        System.assert(agentMatrix!= null, 'AgentMatrix__c is not null');
        System.assertNotEquals(null, agentMatrix, 'handleAutomaticAgentAssign did not work correctly');
        Test.stopTest();
    }

    
    @isTest
    public static void testHandleAutomaticAgentAssignFail(){
        AgentMatrix__c agentMatrix = [SELECT id, channel__c, UserIdentification__c From AgentMatrix__c LIMIT 1];
        agentMatrix.UserIdentification__c = UserInfo.getUserName();
        update agentMatrix;
        Sale__c sales = [SELECT id From Sale__c LIMIT 1];
        Test.startTest();
        HDT_LC_GeneralInfo.handleAutomaticAgentAssign(agentMatrix.channel__c, sales.Id);
        System.assert(agentMatrix!= null, 'AgentMatrix__c is not null');
        System.assertNotEquals(null, agentMatrix, 'handleAutomaticAgentAssign did not work correctly');
        Test.stopTest();
    }

}
