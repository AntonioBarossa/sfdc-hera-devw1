@SuppressWarnings('PMD.AvoidDebugStatements')
@isTest
public class HDT_BA_ExpireMigratedContractsTest {
    @TestSetup
    static void makeData(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, false, 'HERA COMM', 'Persona Fisica', 'Famiglie');
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
        for(Contract c : contracts){
            c.ServicePoint__c = points[0].Id;
            c.CustomerSignedDate = Date.today().addDays(-1);
            c.StartDate = Date.today().addDays(-10);
            c.EndDate = Date.today().addDays(-1);
            c.IsMigrated__c=true;
        }
        insert contracts;
    }

    @isTest
    private static void testBatch(){
        List<Contract> oldContracts = [select id  from Contract where IsMigrated__c = true and EndDate < :Date.today() and Status!='Cessato'];
        system.debug('There are '+oldContracts.size()+' Expired');
        Test.startTest();
        new HDT_BA_ExpireMigratedContracts().execute(((SchedulableContext) null));
        Test.stopTest();
		oldContracts = [select id  from Contract where IsMigrated__c = true and EndDate < :Date.today() and Status!='Cessato'];
        system.assertEquals(0, oldContracts.size(), 'Error, there are still Expired Active Contracts');
    }
    
    @isTest
    private static void testErrorLogHandling(){
        HDT_BA_ExpireMigratedContracts batch = new HDT_BA_ExpireMigratedContracts();
        List<String> stringsToLog = new List<String>();
        for(Integer i=0;i<420;i++){//create a list string with 420 inputs, should split into 3 logs (200 rows max for each log)
            stringsToLog.add('This is Test Error Number '+i+' lets check it\'s logged succesfully!');
        }
        batch.errors = stringsToLog;
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
        List<wrts_prcgvr__Log__c> logs = [Select id from wrts_prcgvr__Log__c];
		system.assertEquals(3, logs.size(), 'Error, there are unexpected Number of Logs');
    }
}