/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 20/07/2021
 * @description Test Class for HDT_LC_FormAccountResidenziale.cls
 * @history Fabricio Petkevicius Nunes – 20/07/2021 – Created class
 * @Modified by Cesare Bagnolini - 20/10/2021 - added method 'testinsertAccountRes'
 */
@isTest
public class HDT_LC_FormAccountResidenzialeTst{
	@TestSetup
	static void setup(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		accList[0].FirstName__c='test';
		accList[0].BillingCityCode__c='RO';       
		insert accList;

		List<Contact> conList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);

		System.debug('SETUPaccList = '+accList);
		System.debug('SETUPconList = '+conList);
        
        List<City__c> cities = HDT_UTL_DataFactoryTst.createCity();
        
	}

	@isTest
	static void testinsertAccount(){

		Test.startTest();

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		accList[0].FirstName__c='testInsertAccount';

        List<City__c> cities = HDT_UTL_DataFactoryTst.createCity();

        Map<String, String> dataAccount=new Map<String, String>{
                    'firstName'=>accList[0].FirstName__c, 
                    'recordTypeId'=>accList[0].RecordTypeId,
                    'customerMarking'=>accList[0].CustomerMarking__c, 
                    'category'=>accList[0].Category__c, 
                    'companyOwner'=>accList[0].CompanyOwner__c, 
                    'name'=>accList[0].Name,
                    'lastName'=>accList[0].LastName__c, 
                    'role' => 'admin',
                    'birthplace'=>cities[0].Name,
                    'birthDate'=>String.valueof(system.today())
                    };

        Map<String, String> infoData = new Map<String, String>();
        infoData.put('lastName'     , dataAccount.get('lastName')   );
        infoData.put('firstName'    , dataAccount.get('firstName')  );
        infoData.put('birthDate'    , dataAccount.get('birthDate')  );
        infoData.put('birthPlace'   , dataAccount.get('birthplace') );
        infoData.put('gender'       , dataAccount.get('gender')     );

        dataAccount.put('fiscalCode',HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoData));
        System.debug('fiscalCode>>> ' + dataAccount.get('fiscalCode') );

        Map<String, String> accountAddress=new Map<String, String>{
                'billingCity'=>'Roma',
                'billingStreetName__c'=>accList[0].BillingStreetName__c,
                'billingCityCode__c'=>accList[0].BillingCityCode__c,
                'billingStreetNumber__c'=>'21',
                'BillingIsAddressVerified__c'=>'true'
                };

		Account accTest=HDT_LC_FormAccountResidenziale.insertAccount(dataAccount, accountAddress);

		System.assertEquals(HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoData), accTest.FiscalCode__c, 'Account Fiscal Code is wrong');
		System.assertNotEquals(null, accTest.FiscalCode__c, 'insertAccount did not work correctly');

		Test.stopTest();
	}
    
    @isTest
	static void testinsertAccountRes(){

		List<Account> tacc=[SELECT Id, Name, LastName__c, RecordTypeId, FiscalCode__c, CustomerMarking__c, Category__c, 
                            CompanyOwner__c, BillingStreetName__c, BillingCityCode__c, BillingStreetNumber__c
		                    FROM Account
		                    WHERE Name='test account0'
		                    LIMIT 1];

        List<City__c> cities = HDT_UTL_DataFactoryTst.createCity();
        System.debug('city: '+ cities[0].Name);
		Map<String, String> dataAccount=new Map<String, String>{
                    'firstName'=>'test', 
                    'recordTypeId'=>tacc[0].RecordTypeId,
                    'customerMarking'=>tacc[0].CustomerMarking__c, 
                    'category'=>tacc[0].Category__c, 
                    'companyOwner'=>tacc[0].CompanyOwner__c, 
                    'name'=>tacc[0].Name,
                    'lastName'=>tacc[0].LastName__c, 
                    'role' => 'admin',
                    'birthplace'=>cities[0].Name,
                    'birthDate'=>String.valueof(system.today())
                    };

        Map<String, String> infoData = new Map<String, String>();
        infoData.put('lastName'     , dataAccount.get('lastName')   );
        infoData.put('firstName'    , dataAccount.get('firstName')  );
        infoData.put('birthDate'    , dataAccount.get('birthDate')  );
        infoData.put('birthPlace'   , dataAccount.get('birthplace') );
        infoData.put('gender'       , dataAccount.get('gender')     );

        dataAccount.put('fiscalCode',HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoData));

		Map<String, String> accountAddress=new Map<String, String>{
            	'billingCity'=>'Roma',
                'billingStreetName__c'=>tacc[0].BillingStreetName__c,
                'billingCityCode__c'=>tacc[0].BillingCityCode__c,
                'billingStreetNumber__c'=>'21',
                'BillingIsAddressVerified__c'=>'true'
                };
                    
        Map<String,String> accountAddresRes = new Map<String,String>{
            'ShippingIsAddressVerified__c'=>'true',
            'ShippingCity'=>'Springfield'
        };
                    
		Test.startTest();
            
		    Account accTest=HDT_LC_FormAccountResidenziale.insertAccount(dataAccount, accountAddress, accountAddresRes);
        
        Test.stopTest();

		System.assertEquals('Springfield', accTest.ShippingCity, 'insertAccount did not work correctly');
		System.assertNotEquals(null, accTest, 'insertAccount did not work correctly');
	}
}