@isTest
public class HDT_LC_CtToolbar_Test {

    @TestSetup
    static void setup(){

        
        HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

        CampaignMemberAssigment__c cma = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'Test Assignment').get(0);

        List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(1, false);
        cp[0].AssignmentType__c = 'Peso Percentuale';
        cp[0].CampaignMemberAssigment__c = cma.Id;
        insert cp;

        List<Lead> lead = HDT_UTL_DataFactoryTst.createLead(2, false);
        lead.get(0).LastName = 'ln';
        lead.get(0).FirstName = 'fn';
        lead.get(0).Email = 'em@lead.com';
        lead.get(1).LastName = 'ln2';
        lead.get(1).FirstName = 'fn2';
        lead.get(1).Email = 'em2@lead.com';
        insert lead;
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Partner').getRecordTypeId();
        insert acc;
        List<Contact> ctt = HDT_UTL_DataFactoryTst.createContact(2, true, acc[0].Id);
        HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, acc.get(0).Id, cma.Id, 'Preview', 50.0);

        List<CampaignMember> cmb = HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(0)}, new List<Contact>{ctt.get(0)});
        cmb.addAll(HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(1)}, new List<Contact>{ctt.get(1)}));

        cmb.get(0).Agency__c = acc.get(0).Id;
        cmb.get(1).Agency__c = acc.get(0).Id;

        insert cmb;
    }

    @isTest
    private static void testCampaignMember(){     
        
        List<CampaignMember> cmb = [Select Id from CampaignMember];

        Test.startTest();

        boolean b = HDT_LC_CtToolbar.updateCampaignMember('1', cmb[0].Id, '');
        
    	boolean b1 = HDT_LC_CtToolbar.updateCampaignMemberStatus('test', cmb[0].Id, true);

        Test.stopTest();

        System.assertEquals(true, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    
    }


    @isTest private static void testActivity(){

        List<CampaignMember> cmb = [Select Id from CampaignMember];

        Test.startTest();
        
  		String s = HDT_LC_CtToolbar.createActivityInbound('test','test','test1');

        wrts_prcgvr__Activity__c actv = HDT_LC_CtToolbar.createActivity( null, null, '123456', cmb[0].Id, null);
        
        boolean b = HDT_LC_CtToolbar.updateActivity('123456', '20222403',3,4);
        
        Test.stopTest();
        System.assertEquals(true, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    }


    @isTest private static void testOthers(){

        Test.startTest();

        //String s1 = HDT_LC_CtToolbar.getCachedUuid();
        //String s1 = 'myUuid';
        //HDT_LC_CtToolbar.cacheUuid(s1);
        //List<String> s1list = HDT_LC_CtToolbar.getCachedUuidInvocable();
        String s = HDT_LC_CtToolbar.getStatusByEcid('1');
        Boolean b1;
        try{
         b1 = HDT_LC_CtToolbar.saveEcidInSales(null, null);
        }catch(exception e){
            System.debug(e);
        }

        Test.stopTest();
        System.assertEquals(null, b1, 'evaluate did not work correctly');
    }
        
}