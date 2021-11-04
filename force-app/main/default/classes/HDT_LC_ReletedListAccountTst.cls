/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 05/10/2021
 * @description HDT_LC_ReletedListAccount for Test Classes
 * @history Laureta Demishaj – 05/10/2021 – Created class
*/
@isTest
public class HDT_LC_ReletedListAccountTst {
    @TestSetup
    static void myData(){
    HDT_UTL_DataFactoryTst.createCity();
    List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    HDT_UTL_DataFactoryTst.CreateContact(1, true, accList[0].Id);
    }
    @isTest
    public static void insertContactTst(){
    Account acc = [SELECT Id,FiscalCode__c, BillingCity, BillingCityCode__c, BillingCountry, BillingPostalCode, BillingState, BillingStreet, BillingStreetName__c, BillingStreetCode__c, BillingStreetNumber__c, BillingStreetNumberExtension__c, BillingStreetToponym__c, BillingRegion__c, BillingPlace__c, BillingPlaceCode__c, BillingIsAddressVerified__c FROM Account LIMIT 1];
    Map<String,String> dataContact = new Map<String,String>();
    dataContact.put('birthPlace', 'Roma');
    dataContact.put('birthplace', 'Roma');
    dataContact.put('birthDate','1978-08-02');
    dataContact.put('lastName', 'Neri');
    dataContact.put('firstName', 'Angelo');
    dataContact.put('gender', 'Maschio');
    dataContact.put('accountId', acc.Id);
    dataContact.put('role', 'Titolare');
    // dataContact.put('fiscalCode', 'NRENGL78M02Bt0E');
    Map<String,String> contactAddress = new Map<String,String>();
    contactAddress.put('BillingCity', acc.BillingCity);
    contactAddress.put('BillingCityCode__c', acc.BillingCityCode__c);
    contactAddress.put('BillingCountry', acc.BillingCountry);
    contactAddress.put('BillingPostalCode', acc.BillingPostalCode);
    contactAddress.put('BillingState', acc.BillingState);
    contactAddress.put('BillingStreet', acc.BillingStreet);
    contactAddress.put('BillingStreetName__c', acc.BillingStreetName__c);
    contactAddress.put('BillingStreetCode__c', acc.BillingStreetCode__c);
    contactAddress.put('BillingStreetNumber__c', acc.BillingStreetNumber__c);
    contactAddress.put('BillingStreetNumberExtension__c', acc.BillingStreetNumberExtension__c);
    contactAddress.put('BillingStreetToponym__c', acc.BillingStreetToponym__c);
    contactAddress.put('BillingRegion__c', acc.BillingRegion__c);
    contactAddress.put('BillingPlace__c', acc.BillingPlace__c);
    contactAddress.put('BillingPlaceCode__c', acc.BillingPlaceCode__c);
    contactAddress.put('BillingIsAddressVerified__c', String.ValueOf(acc.BillingIsAddressVerified__c));

    dataContact.put('fiscalCode', HDT_UTL_CalculateFiscalCode.calculateFiscalCode(dataContact));

    Test.startTest();
    Contact response = HDT_LC_ReletedListAccount.insertContact(dataContact, contactAddress);
    Test.stopTest();
    Contact actualResponse = [SELECT Id FROM Contact WHERE FiscalCode__c = :dataContact.get('fiscalCode') LIMIT 1];
    System.assertEquals(response.Id, actualResponse.Id, 'There is no contact inserted that matches the given data!');
    System.assertNotEquals(null, actualResponse.Id, 'There is no contact inserted that matches the given data!');
    }
     @isTest
    public static void insertContactNegativeTst(){
        try{
    Account acc = [SELECT Id,FiscalCode__c, BillingCity, BillingCityCode__c, BillingCountry, BillingPostalCode, BillingState, BillingStreet, BillingStreetName__c, BillingStreetCode__c, BillingStreetNumber__c, BillingStreetNumberExtension__c, BillingStreetToponym__c, BillingRegion__c, BillingPlace__c, BillingPlaceCode__c, BillingIsAddressVerified__c FROM Account LIMIT 1];
    Map<String,String> dataContact = new Map<String,String>();
    dataContact.put('birthPlace', 'Roma');
    dataContact.put('birthplace', 'Roma');
    dataContact.put('birthDate','1978-08-02');
    dataContact.put('lastName', 'Neri');
    dataContact.put('firstName', 'Angelo');
    dataContact.put('gender', 'Maschio');
    dataContact.put('accountId', acc.Id);
    dataContact.put('role', 'Titolare');
    // dataContact.put('fiscalCode', 'NRENGL78M02Bt0X');
    Map<String,String> contactAddress = new Map<String,String>();
    contactAddress.put('BillingCity', acc.BillingCity);
    contactAddress.put('BillingCityCode__c', acc.BillingCityCode__c);
    contactAddress.put('BillingCountry', acc.BillingCountry);
    contactAddress.put('BillingPostalCode', acc.BillingPostalCode);
    contactAddress.put('BillingState', acc.BillingState);
    contactAddress.put('BillingStreet', acc.BillingStreet);
    contactAddress.put('BillingStreetName__c', acc.BillingStreetName__c);
    contactAddress.put('BillingStreetCode__c', acc.BillingStreetCode__c);
    contactAddress.put('BillingStreetNumber__c', acc.BillingStreetNumber__c);
    contactAddress.put('BillingStreetNumberExtension__c', acc.BillingStreetNumberExtension__c);
    contactAddress.put('BillingStreetToponym__c', acc.BillingStreetToponym__c);
    contactAddress.put('BillingRegion__c', acc.BillingRegion__c);
    contactAddress.put('BillingPlace__c', acc.BillingPlace__c);
    contactAddress.put('BillingPlaceCode__c', acc.BillingPlaceCode__c);
    contactAddress.put('BillingIsAddressVerified__c', String.ValueOf(acc.BillingIsAddressVerified__c));

    dataContact.put('fiscalCode', HDT_UTL_CalculateFiscalCode.calculateFiscalCode(dataContact));

    Test.startTest();
    HDT_LC_ReletedListAccount.insertContact(dataContact, contactAddress);
    Test.stopTest();   
        } catch(Exception e){
          System.assertEquals('Script-thrown exception', e.getMessage(), 'This method can\'t insert a contact, should throw an error since the fiscal code is not valid!');
        }  
    }
    @IsTest
    public static void getContListTst(){
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Contact con = [SELECT Id, BPInterlocutor__c FROM Contact LIMIT 1];
    Test.startTest();
    String response = HDT_LC_ReletedListAccount.getContList(acc.Id);
    Test.stopTest();
    System.debug(response);
    List<AccountContactRelation> actualResponse = [SELECT Id FROM AccountContactRelation WHERE ContactId = :con.Id];
    System.assertEquals(response!=null, actualResponse!=null, 'There\'s no contact related to this account');
    System.assertNotEquals(null, actualResponse, 'There\'s no contact related to this account');
    }
    @IsTest
    public static void getContListBlankStringTst(){
    Test.startTest();
    String response = HDT_LC_ReletedListAccount.getContList('');
    Test.stopTest();
    System.assertEquals(response, null, 'There should be no result to this method since the accountId parameter is blank');
    }
    @IsTest
    public static void getRecordTypeAccountListTst(){
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    String response = HDT_LC_ReletedListAccount.getRecordTypeAccount(acc.Id);
    Test.stopTest();
    System.assertEquals('HDT_RT_Business', response, 'The record type of the given account is not HDT_RT_Business');
    System.assertNotEquals(null, response, 'The record type of the given account can\'t be null');
    }
    @IsTest
    public static void getRecordTypeAccountBlankStringTst(){
    Test.startTest();
    String response = HDT_LC_ReletedListAccount.getRecordTypeAccount('');
    Test.stopTest();
    System.assertEquals(response, null, 'There record type of the given account should be null since the accountId parameter is blank');
    }
}