/**
 * Created by c.salvati on 13/04/2023.
 */

@IsTest
private class HDT_LC_RecordEditFormInputControllerTst {

    @TestSetup
    static void setup(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, false, 'HERA COMM', 'D1 - Persona fisica', 'Famiglie');
        accounts[1].CustomerLifeCycleWaste__c = 'ONBOARDING';
        insert accounts;

        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(5, false);
        points[0].CommoditySector__c = 'Gas';
        points[1].CommoditySector__c = 'Ambiente';
        points[2].CommoditySector__c = 'Acqua';
        points[3].CommoditySector__c = 'Teleriscaldamento';
        points[4].CommoditySector__c = 'Energia Elettrica';
        insert points;

        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(6, false, accounts[0].Id);
        contracts[0].ServicePoint__c = points[0].Id;
        contracts[0].CustomerSignedDate = Date.today().addDays(-1);
        contracts[0].StartDate = Date.today().addDays(-1);
        contracts[0].EndDate = Date.today().addDays(1);
        contracts[1].ServicePoint__c = points[1].Id;
        contracts[1].CustomerSignedDate = Date.today().addDays(-2);
        contracts[1].StartDate = Date.today().addDays(2);
        contracts[1].EndDate = Date.today().addDays(4);
        contracts[1].AccountId = accounts[1].Id;
        contracts[2].ServicePoint__c = points[2].Id;
        contracts[2].CustomerSignedDate = Date.today().addDays(-2);
        contracts[2].StartDate = Date.today().addDays(2);
        contracts[2].EndDate = Date.today().addDays(4);

        contracts[3].ServicePoint__c = points[3].Id;
        contracts[3].CustomerSignedDate = Date.today();
        contracts[3].StartDate = Date.today();
        contracts[3].EndDate = Date.today().addDays(-1);
        contracts[4].ServicePoint__c = points[3].Id;
        contracts[4].CustomerSignedDate = Date.today().addDays(-61);
        contracts[4].StartDate = Date.today().addDays(-61);
        contracts[4].EndDate = Date.today().addDays(4);
        contracts[5].ServicePoint__c = points[4].Id;
        contracts[5].CustomerSignedDate = Date.today().addDays(-400);
        contracts[5].StartDate = Date.today().addDays(-400);
        contracts[5].EndDate = Date.today().addDays(4);
        insert contracts;

        Case caso = HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, null, null, contracts[0].Id, null)[0];
        insert caso;
    }

    @IsTest
    static void DependentFieldTest() {
        Case myCase=[SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        Map<String,Object>params=new Map<String,Object>{
         'fieldName'=> 'FourthLevelComplaintClassification__c','objectId'=> myCase.Id, 'process' => 'Rich Info EE', 'controllingField' =>'ThirdLevelComplaintClassification__c'
        };
        Test.startTest();
        params=HDT_LC_RecordEditFormInputController.init(params);
        Test.stopTest();
        System.assertEquals(true,params.containsKey('firstLevelValue'),'no first level value');
    }

    @IsTest
    static void DependentFieldKoTest() {
        Case myCase=[SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        Map<String,Object>params=new Map<String,Object>{
                'fieldName'=> 'FirstLevelComplaintClassification__c','objectId'=> myCase.Id, 'process' => 'Rich Info EE', 'controllingField' =>'ThirdLevelComplaintClassification__c'
        };
        String errorMessage='';
        Test.startTest();
            try{
                params=HDT_LC_RecordEditFormInputController.init(params);
            }catch (Exception e){
                errorMessage=e.getMessage();
            }
        Test.stopTest();
        System.assertEquals(true,String.isNotBlank(errorMessage),'string is blank, no Exception');
    }
    @IsTest
    static void notDependentFieldTest() {
        Case myCase=[SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        Map<String,Object>params=new Map<String,Object>{
                'fieldName'=> 'FourthLevelComplaintClassification__c','objectId'=> myCase.Id, 'process' => 'Rich Info EE'
        };
        Test.startTest();
        params=HDT_LC_RecordEditFormInputController.init(params);
        Test.stopTest();
        System.assertEquals(true,params.containsKey('fieldValue'),'no fieldValue parameter');
        System.assertEquals(true,params.containsKey('fieldLabel'),'no fieldLabel parameter');
    }

    @IsTest
    static void notDependentFieldKoTest() {
        Case myCase=[SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        Map<String,Object>params=new Map<String,Object>{
                'fieldName'=> 'FourthLevelComplaintClassification__c','objectId'=> '500', 'process' => 'Rich Info EE'
        };
        String errorMessage='';
        Test.startTest();
        try{
            params=HDT_LC_RecordEditFormInputController.init(params);
        }catch (Exception e){
            errorMessage=e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true,String.isNotBlank(errorMessage),'a record was found');
    }
}