@IsTest
public with sharing class HDT_LC_SoldByControllerTst {
    @TestSetup
    static void makeData(){
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','G3 - MMS Azienda','Aziende SME');
        Id accId = accs[0].id;
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(16, false, accId, 'Attiva');
        sales[0].Channel__c = 'Sportello';
    }

}