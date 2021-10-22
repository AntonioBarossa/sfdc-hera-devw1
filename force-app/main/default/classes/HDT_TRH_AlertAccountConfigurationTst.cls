/*
    @Author:        Francesco Vitiello
    CreatedDate:    01/09/2021
*/

@isTest
public with sharing class HDT_TRH_AlertAccountConfigurationTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_TRH_AlertAccountConfigurationTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void handleAlertsTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'handleAlertsTest';
        System.debug(debugString);
        
        //SETUP

        String rtName = 'HDT_RT_AlertDisassociazioneUtenteWeb';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        AlertConfiguration__c myAlert = new AlertConfiguration__c();
        myAlert.AlertType__c = 'Periodo autolettura';
        AlertAccountConfiguration__c myAlertAccConfig = new AlertAccountConfiguration__c();
        myAlertAccConfig.Account__c = accList[1].Id;
        myAlertAccConfig.IsEmailChannelActive__c = true;
        myAlertAccConfig.IsActive__c = true;
        
        List<Contact> myContactList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        AccountContactRelation myAccContRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true,accList[1].Id,myContactList[0].Id);

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');

        
        
        //TESTING
        Test.startTest();
        insert myAlert;
        myAlertAccConfig.AlertConfiguration__c = myAlert.Id;    
        Insert myAlertAccConfig;
        myAlertAccConfig.IsEmailChannelActive__c= false;
        Update myAlertAccConfig;
        Test.stopTest();
        
        //ASSERTS
        System.assert(myAlert != null, 'Attenzione,myAlert non può essere null!');
        System.assert(myAlertAccConfig != null, 'Attenzione, myAlertAccConfig non può essere null!');
    }


}
