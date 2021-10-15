/**
 * @author Valere (valere@noeli-it.net)
 * @date 14/10/2021
 * @description HDT_QBL_SIE34_2MM Test Classes
 * @history valere - 14/10/2021– Created Class
 */
@isTest
public class HDT_QBL_SIE34_2MMTst {
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM','Persona fisica','Famiglie');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact (1,true,accountList[0].id); 
        List<ServicePoint__c> servicepointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accountList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseWithStatusClosedNw(1,new Map<String,Object>{
            'AccountId'=>accountList[0].id,
            'Contract__c'=>contractList[0].id,
            'Cluster__c'=>'Preventivi'
        });
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('SIE34','http://test.test','POST','user0');
        HDT_UTL_DataFactoryTst.createWebServiceCredential('user0','pass', 'usrn');
    }
    @istest
    static void testExecute (){
        String varRunId='varRunId00';
        String varFileType='varFileType00';
        DateTime varDate = DateTime.newInstance(2020,11,1);
        System.debug([SELECT Status,Cluster__c,  LastModifiedDate,ServicePoint__c FROM Case]);
        Test.setMock(HttpCalloutMock.class, new HDT_QBL_SIE34_2MMTstMck());
        Test.startTest();
        HDT_QBL_SIE34_2MM this2sme = new HDT_QBL_SIE34_2MM(varRunId,varDate,varFileType,new List<String>{'test'});
        this2sme.execute(null);
        Test.stopTest();
        System.assertEquals(true,JSON.serialize(this2sme).contains('varRunId00') && JSON.serialize(this2sme).contains('varFileType00'),
        'HDT_QBL_SIE34_2MM has been well instantiated will the value passed'
        );
        //No other checks because the call of this queue doesn't impact any data into the current transaction
    }
}
