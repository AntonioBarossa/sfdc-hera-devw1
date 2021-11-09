/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 07/10/2021
* @description HDT_BA_AppoitmentManagmentActivity for Test Classes
* @history Elfrida Kora – 07/10/2021 – Created class
* @Modified: 26/10/2021 Luca Belometti WR (luca.belometti@webresults.it) - fix some issue inside the Setup and TestMethod
*/

@IsTest
public class HDT_BA_AppoitmentManagmentActivityTst {
              
    @TestSetup
    static void allData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        Date dt = date.today();
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,acctList[0].Id);

        HDT_UTL_Constants constants = new HDT_UTL_Constants();

        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acctList[0].Id);
        actList[0].Status__c = 'Appuntamento confermato';
        actList[0].Type__c = 'Presa Appuntamento';
        actList[0].AppointmentDate__c = dt.addDays(1);
        actList[0].Email__c = 'test@test.com';
        actList[0].Mobile__c = '0695689475';
        actList[0].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;
        insert actList;

        List<wrts_prcgvr__Activity__c> actList1 = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acctList[0].Id);
        actList1[0].Status__c = 'Appuntamento confermato';
        actList1[0].Type__c = 'Presa Appuntamento';
        actList1[0].AppointmentDate__c = dt.addDays(1);
        actList1[0].Email__c = 'test1@test.com';
        actList1[0].Mobile__c = '0695689476';
        actList1[0].ParentActivity__c = actList[0].Id;
        actList1[0].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;
        insert actList1;

        List<SMSTracking__c> smsList = HDT_UTL_DataFactoryTst.createSmsTracking(1,false,conList[0].Id);
         smsList[0].Activity__c = actList[0].Id;
         smsList[0].Undelivered__c = true; 
         
         insert smsList;

        List<Campaign> campList = HDT_UTL_DataFactoryTst.createCampaign(1,true);
        List<et4ae5__Automated_Send__c> sends = HDT_UTL_DataFactoryTst.createTriggeredSend(1,true);

        List<et4ae5__SendDefinition__c> sdList = HDT_UTL_DataFactoryTst.createSendDefinition(1,true,campList[0].Id);
        List<et4ae5__IndividualEmailResult__c> indEmailList = HDT_UTL_DataFactoryTst.createIndividualEmailResult(1,false,sends[0].Id);
        
        indEmailList[0].Activity__c = actList[0].Id; 
        indEmailList[0].et4ae5__Opened__c = false;
        indEmailList[0].DateTimeRef__c =  Datetime.newInstance(2021, 11, 11, 11, 30, 0);
        indEmailList[0].Account__c = acctList[0].Id;
        insert indEmailList;

        indEmailList[0].et4ae5__TriggeredSendDefinition__c = null;
        indEmailList[0].et4ae5__SendDefinition__c = sdList[0].Id;

        update indEmailList;

    }
    
     @isTest
    public static void testExecuteBatch(){

        Test.startTest();
        
        HDT_BA_AppoitmentManagmentActivity appManage = new HDT_BA_AppoitmentManagmentActivity();
        Database.executeBatch(appManage);
        Test.stopTest();
        List<wrts_prcgvr__Activity__c> actList = [SELECT Id,Status__c,Account__c,Name FROM wrts_prcgvr__Activity__c ];

        System.assertEquals(true, actList.size() > 0, 'Created and insert Activity');
        System.assertNotEquals(true, actList.size() == 0, 'Created and insert Activity');

    }
    
}