@IsTest
public with sharing class HDT_UTL_GlobalMigrationKeyTst {
    @TestSetup
    static void makeData(){
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,false,'MMS','MMS Azienda','Aziende SME');
        accs[0].CustomerCode__c = '1111111111';
        insert accs;
        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,false,accs[0].Id);
        contracts[0].SAPContractCode__c = '1111111111';
        insert contracts;
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
        points[0].SAPImplantCode__c = '1111111111';
        insert points;
        List<BillingProfile__c> bProfiles = HDT_UTL_DataFactoryTst.createBillingProfile(1,false,accs[0].Id);
        bProfiles[0].ContractAccountCode__c = '1111111111';
        insert bProfiles;
    }

    @IsTest
    public static void testAccount(){
        SObject obj = [SELECT id FROM Account LIMIT 1];
        String migrationKey;
        Test.startTest();
            obj.put('Description','TEST');
            update obj;
            obj.put('CustomerCode__c','');
            update obj;
            System.assertEquals(null, migrationKey, 'L\'account non è stato aggiornato');
            migrationKey = (String) [SELECT id, GlobalMigrationKey__c FROM Account LIMIT 1].get(0).get('GlobalMigrationKey__c');
            obj.put('CustomerCode__c','2222222222');
            update obj;
        Test.stopTest();
        migrationKey = (String) [SELECT id, GlobalMigrationKey__c FROM Account LIMIT 1].get(0).get('GlobalMigrationKey__c');
        System.assertEquals('A_2222222222', migrationKey, 'L\'account non è stato aggiornato');
    }

    @IsTest
    public static void testBillingProfile(){
        SObject obj = [SELECT id FROM BillingProfile__c LIMIT 1];
        Test.startTest();
            obj.put('BankAccountSignatoryLastName__c','TEST');
            update obj;
            obj.put('ContractAccountCode__c','2222222222');
            update obj;
        Test.stopTest();
        String migrationKey = (String) [SELECT id, GlobalMigrationKey__c FROM BillingProfile__c LIMIT 1].get(0).get('GlobalMigrationKey__c');
        System.assertEquals('BP_2222222222', migrationKey, 'Il Billing Profile non è stato aggiornato');
    }

    @IsTest
    public static void testServicePoint(){
        SObject obj = [SELECT id FROM ServicePoint__c LIMIT 1];
        Test.startTest();
            obj.put('SupplyPostalCode__c','12345');
            update obj;
            obj.put('SAPImplantCode__c','2222222222');
            update obj;
        Test.stopTest();
        String migrationKey = (String) [SELECT id, GlobalMigrationKey__c FROM ServicePoint__c LIMIT 1].get(0).get('GlobalMigrationKey__c');
        System.assertEquals('SP_2222222222', migrationKey, 'Il Billing Profile non è stato aggiornato');
    }

    @IsTest
    public static void testContract(){
        SObject obj = [SELECT id FROM Contract LIMIT 1];
        Test.startTest();
            obj.put('Description','TEST');
            update obj;
            obj.put('SAPContractCode__c','2222222222');
            update obj;
        Test.stopTest();
        String migrationKey = (String) [SELECT id, GlobalMigrationKey__c FROM Contract LIMIT 1].get(0).get('GlobalMigrationKey__c');
        System.assertEquals('CO_2222222222', migrationKey, 'Il Contratto non è stato aggiornato');
    }
    @IsTest
    public static void testDistributor(){
        Test.startTest();
            Account distributor = new Account();
            distributor.Code__c = 'DISTRIBUTOR';
            distributor.Name = 'DISTRIBUTOR';
            distributor.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributore').getRecordTypeId();
            distributor.CompanyOwner__c = 'MMS';
            insert distributor;
            distributor = [SELECT Id,Code__c,GlobalMigrationKey__c FROM Account WHERE Code__c = 'DISTRIBUTOR' LIMIT 1];
            System.assertEquals(distributor.Code__c, distributor.GlobalMigrationKey__c, 'Il Distributore è stato aggiornato');
            distributor.Code__c = 'DISTRIBUTOR_2';
            update distributor;
            distributor = [SELECT Id,Code__c,GlobalMigrationKey__c FROM Account WHERE Code__c = 'DISTRIBUTOR_2' LIMIT 1];
            System.assertEquals(distributor.Code__c, distributor.GlobalMigrationKey__c, 'Il Distributore è stato aggiornato');
        Test.stopTest();
    }
}
