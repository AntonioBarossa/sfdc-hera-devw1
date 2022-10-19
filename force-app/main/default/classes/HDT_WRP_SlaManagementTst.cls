@isTest
public with sharing class HDT_WRP_SlaManagementTst {
    
    @isTest
    static void generateEventWrappersTst(){
        HDT_WRP_SlaManagement.HDT_WRP_Event eventWrp=new HDT_WRP_SlaManagement.HDT_WRP_Event();
        System.assertEquals(true, eventWrp!=null, 'wrapper evento inizializzato');
    }

    @isTest
    static void generateAdminWrapperTst(){
        HDT_WRP_SlaManagement.HDT_WRP_AdminRule adminWrp= new HDT_WRP_SlaManagement.HDT_WRP_AdminRule();
        System.assertEquals(true, adminWrp!=null, 'wrapper admin inizializzato');
    }

    @isTest 
    static void generateRuleDetailWrapperTst(){
        HDT_WRP_SlaManagement.HDT_WRP_RuleDetail detailWrp= new HDT_WRP_SlaManagement.HDT_WRP_RuleDetail();
        System.assertEquals(true, detailWrp!=null, 'wrapper rule detail inizializzato');
    }
}
