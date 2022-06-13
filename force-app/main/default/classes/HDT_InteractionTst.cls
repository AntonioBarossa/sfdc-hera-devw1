@isTest
public with sharing class HDT_InteractionTst {
    @isTest
    public static void test() {
        Test.startTest();
        HDT_UTL_DataFactoryTst.pClickInstance();

        Interaction__c interaction = new Interaction__c();
        insert interaction;

        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
            wrts_prcgvr__Status__c = 'Aperta',
            Interaction__c = interaction.Id
        );
        insert activity;

        interaction.Status__c = 'Chiusa';
        Database.SaveResult saveResult = Database.update(interaction, false);
        System.assert(!saveResult.success, '### ERROR - Interaction update succedeed');

        activity.wrts_prcgvr__Status__c = 'Chiusa';
        update activity;
        update interaction;
        System.assert(true, '### ERROR - Interaction update failed');

        Test.stopTest();
    }
}
