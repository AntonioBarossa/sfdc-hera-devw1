/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 13/10/2021
 * @description HDT_LC_SoldBy Test Class
 * @history Sabina Levonja – 13/10/2021 – Created Class
 */
@isTest
public with sharing class HDT_LC_SoldByTst {
    @TestSetup
    static void setup(){
        
    	List<AgentMatrix__c> agentList= HDT_UTL_DataFactoryTst.createAgentMatrix(1,false,'Telefono');
        agentList[0].UserIdentification__c= UserInfo.getUserName();
        agentList[0].AgencyName__c='Test';
        insert agentList;
        HDT_UTL_DataFactoryTst.createLead(1,true);

	}
    @isTest
    public static void testGetLeadInfo() {

        Test.startTest();
			Lead l=[Select Id from Lead limit 1];
        	Lead res= HDT_LC_SoldBy.getLeadInfo(l.Id);
        Test.stopTest();

        System.assertNotEquals(null, res,'The lead has not been found');
    }
    
    @isTest
    public static void testHandleAutomaticAgentAssign() {

        Test.startTest();
        	AgentMatrix__c ag= [Select Id,Channel__c From AgentMatrix__c limit 1];
			Lead l=[Select Id from Lead limit 1];
        	HDT_LC_SoldBy.handleAutomaticAgentAssign(ag.Channel__c,l.Id);
        Test.stopTest();

		Lead lead= [Select Id, Channel__c from Lead limit 1];
        System.assertEquals(ag.Channel__c, lead.Channel__c,'The Channel__c field has not been updated');
        System.assertNotEquals(null, lead.Channel__c,'The lead has not been updated');
    }
    @isTest
    public static void testUpdateLead() {

        Test.startTest();
			Lead l=[Select Id,LastName,CompanyOwner__c from Lead limit 1];
        	l.Lastname='Test';
        	l.CompanyOwner__c='Reseller';
        	HDT_LC_SoldBy.updateLead(l);
        Test.stopTest();
        
		Lead lead = [Select Id,LastName,CompanyOwner__c from Lead limit 1];
        System.assertEquals(l.Lastname, lead.LastName,'The Lastname field has not been updated');
        System.assertNotEquals(false, lead.CompanyOwner__c == l.CompanyOwner__c,'The CompanyOwner__c field has not been updated');
    }
    @isTest
    public static void testGetChannelAgency() {

        Test.startTest();
        	AgentMatrix__c ag= [Select Id,Channel__c,AgencyName__c From AgentMatrix__c limit 1];
        	List<AgentMatrix__c> resp= HDT_LC_SoldBy.getChannelAgency(ag.Channel__c);
        Test.stopTest();

        System.assertEquals(ag.AgencyName__c, resp[0].AgencyName__c,'The agent has not been found');
        System.assertNotEquals(true, resp.isEmpty(),'The AgentMatrix__c list is empty');
    }
    
    @isTest
    public static void testGetAgents() {

        Test.startTest();
        	AgentMatrix__c ag= [Select Id,Channel__c,AgencyName__c From AgentMatrix__c limit 1];
        	List<AgentMatrix__c> resp= HDT_LC_SoldBy.getAgents(ag.AgencyName__c,ag.Channel__c);
        Test.stopTest();

        System.assertEquals(ag.AgencyName__c, resp[0].AgencyName__c,'The agent has not been found');
        System.assertNotEquals(true, resp.isEmpty(),'The AgentMatrix__c list is empty');
    }
}