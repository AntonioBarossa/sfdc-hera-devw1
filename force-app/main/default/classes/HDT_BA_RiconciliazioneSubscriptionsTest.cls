@isTest
public with sharing class HDT_BA_RiconciliazioneSubscriptionsTest {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;

        System.runAs(internalUser){
            Integer i=0;
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(4,false,accId);
            i=0;
            for(Contact c : contacts){
                c.Email='email@'+i+'.it';
                c.Company__c='MMS';
                i++;
            }
            insert contacts;
            
            List<Contact> contactsDuplicate = HDT_UTL_DataFactoryTst.createContact(4,false,accId);
            
            i=0;
            for(Contact c : contactsDuplicate){
                c.FirstName='test2'+i;
                c.LastName='tester2'+i;
                c.Email='email@'+i+'.it';
                c.Company__c='MMS';
                i++;
            }
            insert contactsDuplicate;
            
            
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1, false);
            products[0].Family = 'VAS Opzione prodotto';
            products[0].Name = 'POD';
            insert products;

            List<Product2> products2 = HDT_UTL_DataFactoryTst.createProduct2(1, false);
            products2[0].Family = 'Offerta Commerciale';
            products2[0].Name = 'OFC';
            insert products2;
            
            List<Contract> contractsOC = HDT_UTL_DataFactoryTst.createContract(4,false,accId);
            List<Contract> contractsVAS = HDT_UTL_DataFactoryTst.createContract(4,false,accId);
            List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
            List<SBQQ__Subscription__c> subs2 = new List<SBQQ__Subscription__c>();
            i=0;
            for(Contract contr : contractsOC){
                contr.Contact__c=contactsDuplicate[i].id;
                contr.SAPContractCode__c='30000001'+i;
                contr.OldContractMoMi__c='30000000'+i;
                i++;
            }
            i=0;
            for(Contract contr : contractsVAS){
                contr.Contact__c=contactsDuplicate[i].id;
                contr.SAPContractCode__c='30000000'+i;
                i++;
            }
            insert contractsOC;
            insert contractsVAS;
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id pointId = points[0].id; 
            for(Contract contr : contractsOC){
                subs.addAll(HDT_UTL_DataFactoryTst.createSubscription(1,false,accId,contr.id,pointId));
            }
            for(Contract contr : contractsVAS){
                subs2.addAll(HDT_UTL_DataFactoryTst.createSubscription(1,false,accId,contr.id,pointId));
            }
            for(SBQQ__Subscription__c s : subs){
                s.VasPracticeCode__c = 'vascode';
                s.SBQQ__Product__c = products2[0].Id;
            }

            for(SBQQ__Subscription__c s : subs2){
                s.VasPracticeCode__c = 'vascode';
                s.SBQQ__Product__c = products[0].Id;
            }
            
            insert subs;
            insert subs2;
            
        }
    }

    @IsTest
    public static void rincociliaSubscription(){
        List<SBQQ__Subscription__c> subs = [select Id,SBQQ__Contract__c,SBQQ__Contract__r.SAPContractCode__c, SBQQ__Contract__r.OldContractMoMi__c from SBQQ__Subscription__c where  SBQQ__Contract__r.OldContractMoMi__c != null and SBQQ__Product__r.Family = 'Offerta commerciale' and CreatedDate >= TODAY];
        List<SBQQ__Subscription__c> subs2=[SELECT Id,SBQQ__Contract__r.OldContractMoMi__c,SBQQ__Contract__r.SAPContractCode__c, CompanyOwner__c ,PaymentMode__c ,DurationVas__c ,DwellingType__c ,EmailRecipientVAS__c ,KeepConsumptionsAnalysis__c ,OccupantsNumber__c ,OwnerAC__c ,RecordTypeId ,SBQQ__Account__c ,SBQQ__BundledQuantity__c ,SBQQ__Contract__c ,SBQQ__CustomerPrice__c ,SBQQ__ListPrice__c ,SBQQ__NetPrice__c ,SBQQ__Number__c ,SBQQ__OptionLevel__c ,SBQQ__OptionType__c ,SBQQ__PricingMethod__c ,SBQQ__Product__c ,SBQQ__ProductOption__c ,SBQQ__ProductSubscriptionType__c ,SBQQ__ProrateMultiplier__c ,SBQQ__Quantity__c ,SBQQ__RenewalQuantity__c ,SBQQ__RequiredByProduct__c ,SBQQ__RootId__c ,SBQQ__SubscriptionEndDate__c ,SBQQ__SubscriptionStartDate__c ,SBQQ__SubscriptionType__c ,ServicePoint__c ,Surface__c ,VasActivationDate__c FROM SBQQ__Subscription__c where SBQQ__Product__r.Family like 'VAS%'];
        Test.startTest();
        Database.executeBatch(new HDT_BA_RiconciliazioneSubscriptions());
        Test.stopTest();

        subs2=[SELECT Id,SBQQ__Contract__r.OldContractMoMi__c,SBQQ__Contract__r.SAPContractCode__c, CompanyOwner__c ,PaymentMode__c ,DurationVas__c ,DwellingType__c ,EmailRecipientVAS__c ,KeepConsumptionsAnalysis__c ,OccupantsNumber__c ,OwnerAC__c ,RecordTypeId ,SBQQ__Account__c ,SBQQ__BundledQuantity__c ,SBQQ__Contract__c ,SBQQ__CustomerPrice__c ,SBQQ__ListPrice__c ,SBQQ__NetPrice__c ,SBQQ__Number__c ,SBQQ__OptionLevel__c ,SBQQ__OptionType__c ,SBQQ__PricingMethod__c ,SBQQ__Product__c ,SBQQ__ProductOption__c ,SBQQ__ProductSubscriptionType__c ,SBQQ__ProrateMultiplier__c ,SBQQ__Quantity__c ,SBQQ__RenewalQuantity__c ,SBQQ__RequiredByProduct__c ,SBQQ__RootId__c ,SBQQ__SubscriptionEndDate__c ,SBQQ__SubscriptionStartDate__c ,SBQQ__SubscriptionType__c ,ServicePoint__c ,Surface__c ,VasActivationDate__c FROM SBQQ__Subscription__c where SBQQ__Product__r.Family like 'VAS%'];

        System.assertEquals(subs.size()*2, subs2.size(), 'Cloned');


    }

}
