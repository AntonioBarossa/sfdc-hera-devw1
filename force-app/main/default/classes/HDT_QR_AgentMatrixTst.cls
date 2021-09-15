/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 20/07/2021
* @description HDT_QR_AgentMatrix for Test Classes
* @history Luis Bispo – 20/07/2021 – Created class
*/

@isTest
public with sharing class HDT_QR_AgentMatrixTst {

    @testSetup
        static void setup(){
            HDT_UTL_DataFactoryTst.createAgentMatrix(1, true, 'Channel 1');
        }


    @isTest
    public static void testGetRecordsByChannel(){
        Test.startTest();
        AgentMatrix__c[] testAgent = HDT_QR_AgentMatrix.getRecordsByChannel('Channel 1');
        
        System.assert(testAgent!=null);
        System.assertNotEquals(new List<AgentMatrix__c>{new AgentMatrix__c()},testAgent);
        Test.stopTest();
    }

    @isTest
    public static void testGetAllRecords(){
        Test.startTest();
        AgentMatrix__c[] testAgent = HDT_QR_AgentMatrix.getAllRecords();  
              
        System.assert(testAgent!=null);
        System.assertNotEquals(new List<AgentMatrix__c>{new AgentMatrix__c()},testAgent);

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordByAgencyName(){
        
        AgentMatrix__c updateAgentMatrix = [SELECT id, AgencyName__c
                            FROM AgentMatrix__c
                            LIMIT 1];
        
        updateAgentMatrix.AgencyName__c = 'Test Engineering';
        update updateAgentMatrix;

        Test.startTest();   
        AgentMatrix__c[] testAgent = HDT_QR_AgentMatrix.getRecordByAgencyName(updateAgentMatrix.AgencyName__c);  

        System.assert(testAgent != null);
        System.assertNotEquals(new List<AgentMatrix__c>{new AgentMatrix__c()},testAgent);

        Test.stopTest();
    }

    
    @isTest
    public static void testGetRecordByAgencyNameAndChannel(){
        Test.startTest();

        AgentMatrix__c[] testAgent = HDT_QR_AgentMatrix.getRecordByAgencyNameAndChannel('AgencyName', 'Channel');  

        System.assert(testAgent != null);
        System.assertNotEquals(new List<AgentMatrix__c>{new AgentMatrix__c()},testAgent);

        Test.stopTest();
    }

    
    @isTest
    public static void testGetAgentByUserNameAndChannel(){
        Test.startTest();

        AgentMatrix__c[] testAgent = HDT_QR_AgentMatrix.getAgentByUserNameAndChannel('userName' ,'Channel');   

        System.assert(testAgent!=null);
        System.assertNotEquals(new List<AgentMatrix__c>{new AgentMatrix__c()},testAgent);
        
        Test.stopTest();
    }


}
