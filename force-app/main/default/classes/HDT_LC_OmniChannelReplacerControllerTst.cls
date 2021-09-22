@isTest
public class HDT_LC_OmniChannelReplacerControllerTst {
    
    @testSetup
    static void setup() {
    
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        Account acc = accList.get(0);
        
        List<wrts_prcgvr__Activity__c> activitiesList = HDT_UTL_DataFactoryTst.createActivityCustom(1, true, acc.Id);

        wrts_prcgvr__Activity__c activity = activitiesList.get(0);
        activity.Type__c = 'Sportello';
        activity.QAdLogin__c = 'QAdLoginTest';

        update activity;

    }

    @isTest
    static void testGetSigmaLogin() {

        Test.startTest();

        String sigmaLogin = HDT_LC_OmniChannelReplacerController.getSigmaLogin();
        System.assert(!String.isBlank(sigmaLogin), 'Si è verificato un errore in fase di get del SigmaLogin');

        Test.stopTest();

    }

    @isTest
    static void testGetUserChannel(){

        Test.startTest();

        String userChannel = HDT_LC_OmniChannelReplacerController.getUserChannel();

        System.assert(!String.isBlank(userChannel), 'Si è verificato un errore in fase di get dell\' UserChannel');

        Test.stopTest();

    }

    @isTest
    static void testGetActivities(){

        String qAdLoginString = 'QAdLoginTest';

        Test.startTest();

        List<wrts_prcgvr__Activity__c> activities = HDT_LC_OmniChannelReplacerController.getActivities(qAdLoginString);
        System.assert(activities.size() != 0, 'Si è verificato un errore in fase di get delle activities');

        Test.stopTest();

    }

}
