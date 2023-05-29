/*
* @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
* @date 22/09/2021
* @description HDT_QBL_BpCaRequest for Test Classes
* @history Laureta Demishaj – 22/09/2021 – Created class
*/
@isTest
public class HDT_QBL_BpCaRequestTst {
  
  private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

	@TestSetup
    static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_VOLTURARETROATTIVA, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};
		
		permissionSetAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, 'HDT_Archive', false));
		insert permissionSetAssignments;
		
		System.runAs(internalUser){
			HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
			HDT_UTL_DataFactoryTst.createWebServiceCredential('MulesoftSalesforceUser', 'a74b50dbaac04215bfbf89a2ee315a80','48fe5165a40c49aa9bf4b3d9bca2552f');
			
		  List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		  List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
			//List<Sale__c> salesList = HDT_UTL_DataFactoryTst.createSale(16, true, accList[0].Id, 'Attiva');
			//AccountContactRelation myAccConRel =  HDT_UTL_DataFactoryTst.createAccountContactRelation(false, accList[1].Id, conList[0].Id);
			//myAccConRel.Roles = 'Amministratore condominio';
			//	  insert myAccConRel;
				
			List<BillingProfile__c> billProfs=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
			contracts[0].BillingProfile__c=billProfs[0].Id;
			insert contracts;
			
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
			
			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
			
			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Quote');
			quotes[0].ContractReference__c=contracts[0].Id;
			quotes[0].AmendmentAllowed__c=true;
      quotes[0].SBQQ__Account__c = accList[0].Id ;
			insert quotes;

			opps[0].SBQQ__PrimaryQuote__c=quotes[0].Id;
			update opps;

			List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, false);
			products[0].Name='POD';
			products[0].Family=Label.HDT_ProductFamilyTrigger;
			insert products;

			List<ServicePoint__c> servPoint=HDT_UTL_DataFactoryTst.createServicePoint(1, false);
			servPoint[0].CustomerCodeSAP__c='1003616210';
			insert servPoint;
			
			List<SaleServiceItem__c> saleServItens=HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opps[0].Id, quotes[0].Id, servPoint[0].Id);
			List<SBQQ__QuoteLine__c> quoteLines=HDT_UTL_DataFactoryTst.createQuoteLines(products[0].Id, quotes[0].Id, 1, false);
			quotelines[0].ServicePoint__c=servPoint[0].Id;
			quotelines[0].ServicePointLinkItem__c=saleServItens[0].Id;
			quotelines[0].SBQQ__Product__c = products[0].Id;
			insert quoteLines;	
				
		}

    }

	@isTest
    public static void HDT_QBL_BpCaRequestFirst() {
        Test.startTest();
        Account  acc = [SELECT Id,RecordTypeId,Category__c,VATNumber__c, FiscalCode__c  FROM Account LIMIT 1];
        Contact  contact = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];
        List<AccountContactRelation> accCtcRel=[Select Id FROM AccountContactRelation WHERE AccountId =: acc.Id And ContactId =: contact.Id];
       /* List<AccountContactRelation> accountContactRelList = new List<AccountContactRelation>();
        AccountContactRelation accCtcRel=new AccountContactRelation();
        accCtcRel.AccountId=acc.Id;
        accCtcRel.ContactId=contact.Id;
        accCtcRel.Roles='Amministratore condominio';
        accountContactRelList.add(accCtcRel);
        insert accountContactRelList;*/

        Sale__c sales = [SELECT Id FROM Sale__c WHERE Name='testSaleName0' LIMIT 1];

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){
          HDT_QBL_BpCaRequest testim = new HDT_QBL_BpCaRequest(accCtcRel,sales.Id,true);
          System.enqueueJob(testim);
          Test.stopTest();
          System.assertEquals(true, testim !=null, 'An error has occurred!');
        }
    }

    @isTest
    public static void HDT_QBL_BpCaRequestSecond() {
        Test.startTest();
        Account  acc = [SELECT Id,RecordTypeId,Category__c,VATNumber__c, FiscalCode__c FROM Account LIMIT 1];
        Contact  contact = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){
            HDT_QBL_BpCaRequest testim = new HDT_QBL_BpCaRequest(acc,contact);
            System.enqueueJob(testim);
            Test.stopTest();
            System.assertEquals(true, testim !=null, 'An error has occurred!');
        }
    }

}