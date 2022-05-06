/**
 * Header of the class "HDT_UTL_MassiveOrderFieldsAlignmentTst"
 * @author Edoardo Zanatta
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_MassiveOrderFieldsAlignment"
 * @Created 05/05/2022
 **/

@isTest
public class HDT_UTL_MassiveOrderFieldsAlignmentTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1,false,'HERA COMM','Azienda','Aziende SME');
        accList[0].BillingStreetNumberExtension__c = 'nExt';
        accList[0].CustomerCode__c = '0001';
        accList[0].CustomerType__c = 'Organizzazione';
        accList[0].BillingPlace__c = 'test place';
        accList[0].BillingCountry = 'Italia';
        accList[0].BillingPostalCode = '10123';
        accList[0].BillingState = 'IT';
        accList[0].BillingCity = 'Torino';
        accList[0].BillingIsAddressVerified__c = true;
        accList[0].PrimaryEmail__c = 'test.primary@email.com';
        accList[0].Phone = '123456789';
        accList[0].FiscalCode__c = 'SXSRLA45H28H5';
        accList[0].VATNumber__c = '12345678';
        accList[0].FirstName__c = 'test';
        accList[0].BPSAPModel__c = 'CLIENTI GENERICI MMS';
        insert accList;

        List<Campaign> campList = HDT_UTL_DataFactoryTst.createCampaign(1, true);

        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1,false,accList[0].id,'Bozza');
        saleList[0].Agency__c = 'test agency'; 
        saleList[0].AgencyCode__c = 'AgencyCode';
        //saleList[0].CommercialId__c; 
        saleList[0].VendorFirstName__c = 'test'; 
        saleList[0].VendorLastName__c = 'test'; 
        saleList[0].Channel__c = 'Back office'; 
        saleList[0].UpperChannelAgency__c = 'testUp'; 
        saleList[0].LowerChannelAgency__c = 'testLow'; 
        //saleList[0].SaleBy__c = User.id;
        saleList[0].Campaign__c = campList[0].id; 
        /*saleList[0].CommissioningCampaign__c; 
        saleList[0].CommissioningCampaign__r.Name; 
        saleList[0].SalesContact__c;
        saleList[0].SalesContact__r.IndividualId; 
        saleList[0].SalesContact__r.Individual.MarketingPrivacy__c; 
        saleList[0].SalesContact__r.Individual.ProfilingPrivacy__c;
        saleList[0].SalesContact__r.Phone; 
        saleList[0].SalesContact__r.MobilePhone; 
        saleList[0].CreatedBy.LoginChannel__c; 
        saleList[0].CreatedBy.Station__c; 
        saleList[0].CreatedBy.CreatorGroup__c; 
        saleList[0].AreaManager__c;*/
        insert saleList;

       
    }

    @isTest 
    static void testGetAccByIds(){

        List<Account> accList = [SELECT Id, BillingStreetNumberExtension__c, CustomerCode__c, CustomerType__c, Category__c, BillingPlace__c, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingIsAddressVerified__c,
        BillingStreetNumber__c, BillingStreetName__c, CustomerMarking__c, BillingCityCode__c, BPSAPModel__c, FiscalCode__c, VATNumber__c, RecordType.DeveloperName, Name, FirstName__c, LastName__c,
        PrimaryEmail__c, Phone FROM Account LIMIT 1];

        List<Id> idsList = new List<Id>();

        for (Account a : accList){
            idsList.add(accList[0].id);
        }

        Test.startTest();
        List<Account> accResult = HDT_UTL_MassiveOrderFieldsAlignment.getAccountByIds(idsList);
        System.assertEquals('nExt', accResult[0].BillingStreetNumberExtension__c,'getAccountByIds did not work correctly');
        Test.stopTest();
        
    }

   /* @isTest 
    static void testGetSalesByIds(){


        Test.startTest();

        Test.stopTest();
        
    }*/
}