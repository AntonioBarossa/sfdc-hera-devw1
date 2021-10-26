/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 19/10/2021
* @description Test Class for HDT_UTL_SIE34
*/
@isTest
public with sharing class HDT_UTL_SIE34Tst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> cases = HDT_UTL_DataFactoryTst.createCaseMorosita(5, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
     }

    @isTest
	public static void testCreateBodySIE34_2MME(){

        Boolean finished = false;

        String query = 'SELECT Contract__r.ContractSalesCompany__c,BillingProfile__r.InvoicingCountry__c,BillingProfile__r.ContractAccountCode__c,Account.LastName__c,Account.BillingCity,Account.BillingPlace__c, Account.BillingPostalCode,Account.BillingState,Account.BillingStreetName__c,Account.BillingStreetNumberExtension__c, Account.BillingStreetNumber__c, Account.Category__c, Account.CustomerCode__c,'+
       'Account.CustomerType__c,Account.FirstName__c, Account.FiscalCode__c,Account.VATNumber__c,BillingProfile__r.BillSendingMethod__c, BillingProfile__r.InvoiceCertifiedEmailAddress__c,BillingProfile__r.InvoiceEmailAddress__c, BillingProfile__r.SendCertifiedEmailConsentDate__c,'+
       'BillingProfile__r.BankAccountSignatoryFirstName__c,BillingProfile__r.BankAccountSignatoryFiscalCode__c,BillingProfile__r.BankAccountSignatoryLastName__c,BillingProfile__r.BankAgency__c,BillingProfile__r.BankName__c,BillingProfile__r.IbanABI__c,BillingProfile__r.IbanCAB__c,'+
       'BillingProfile__r.IbanCIN_IBAN__c,BillingProfile__r.IbanCIN__c,BillingProfile__r.IbanCodeNumber__c,BillingProfile__r.IbanCountry__c,BillingProfile__r.InvoicingAddressFormula__c, BillingProfile__r.InvoicingCity__c,'+
       'BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumberExtension__c,'+
       'BillingProfile__r.InvoicingStreetNumber__c, BillingProfile__r.PaymentMethod__c,SubProcess__c, Amount__c,AnnualConsumption__c, AtecoCode__c, CaseNumber,CausalCode__c,CommodityFormula__c,ComplaintEntryChannel__c,'+
       'ConnectionType__c,CreatedBy.Name,CreatedDate,CustomerRequestDate__c,Disconnectable__c,DisconnectibilityType__c,DisplacementDistance__c,DistributorCode__c,DistributorNote__c,Distributor__c,EndDate__c,FirstName__c,'+
       'LastName__c,Market__c,Mobile__c,OperationCode__c,PODPDRFormula__c,Phase__c,PhoneNumber__c,PowerContractualFormula__c,Power__c,QuotationNumber__c,QuotationType__c,RemoteManagementSystem__c,ServicePointType__c,'+
       'SupplyType__c,Taxes__c,TensionOption__c,UseTypeEnergy__c,VATPercentage__c,Voltage__c,Contact.FAX,Contact.FirstName,Contact.LastName,Contact.MobilePhone,ServicePoint__r.SupplyCityCode__c,ServicePoint__r.SupplyCity__c,'+
       'ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumberExtension__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,'+
       'BillingProfile__r.DivergentSubject__r.ContactCode__c,BillingProfile__r.DivergentSubject__r.FirstName,BillingProfile__r.DivergentSubject__r.FiscalCode__c,BillingProfile__r.DivergentSubject__r.LastName,BillingProfile__r.DivergentSubject__r.MailingCity,BillingProfile__r.DivergentSubject__r.MailingPostalCode,BillingProfile__r.DivergentSubject__r.MailingState,BillingProfile__r.DivergentSubject__r.MailingStreetName__c,BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c,Contact.Email'+
       ' FROM Case ';

       Test.startTest();


       List<Case> listCase = Database.query(query);
       String body0  ='';
       body0=HDT_UTL_SIE34.createBodySIE34_2MMEle(body0,listCase);
       System.assertEquals(true, body0.length()>0, 'Error in BodySIE34_2MMEle');
       String body1  ='';
       body1=HDT_UTL_SIE34.createBodySIE34_2MMGas(body1,listCase);
       System.assertEquals(true, body1.length()>0, 'Error in BodySIE34_2MMEle');
        
        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
	public static void testCreateBodySIE34_2SME(){

        Boolean finished = false;

        String query = 'SELECT Contract__r.ContractSalesCompany__c,BillingProfile__r.InvoicingCountry__c,BillingProfile__r.ContractAccountCode__c,Account.LastName__c,Account.BillingCity,Account.BillingPlace__c, Account.BillingPostalCode,Account.BillingState,Account.BillingStreetName__c,Account.BillingStreetNumberExtension__c, Account.BillingStreetNumber__c, Account.Category__c, Account.CustomerCode__c,'+
       'Account.CustomerType__c,Account.FirstName__c, Account.FiscalCode__c,Account.VATNumber__c,BillingProfile__r.BillSendingMethod__c, BillingProfile__r.InvoiceCertifiedEmailAddress__c,BillingProfile__r.InvoiceEmailAddress__c, BillingProfile__r.SendCertifiedEmailConsentDate__c,'+
       'BillingProfile__r.BankAccountSignatoryFirstName__c,BillingProfile__r.BankAccountSignatoryFiscalCode__c,BillingProfile__r.BankAccountSignatoryLastName__c,BillingProfile__r.BankAgency__c,BillingProfile__r.BankName__c,BillingProfile__r.IbanABI__c,BillingProfile__r.IbanCAB__c,'+
       'BillingProfile__r.IbanCIN_IBAN__c,BillingProfile__r.IbanCIN__c,BillingProfile__r.IbanCodeNumber__c,BillingProfile__r.IbanCountry__c,BillingProfile__r.InvoicingAddressFormula__c, BillingProfile__r.InvoicingCity__c,'+
       'BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumberExtension__c,'+
       'BillingProfile__r.InvoicingStreetNumber__c, BillingProfile__r.PaymentMethod__c,SubProcess__c, Amount__c,AnnualConsumption__c, AtecoCode__c, CaseNumber,CausalCode__c,CommodityFormula__c,ComplaintEntryChannel__c,'+
       'ConnectionType__c,CreatedBy.Name,CreatedDate,CustomerRequestDate__c,Disconnectable__c,DisconnectibilityType__c,DisplacementDistance__c,DistributorCode__c,DistributorNote__c,Distributor__c,EndDate__c,FirstName__c,'+
       'LastName__c,Market__c,Mobile__c,OperationCode__c,PODPDRFormula__c,Phase__c,PhoneNumber__c,PowerContractualFormula__c,Power__c,QuotationNumber__c,QuotationType__c,RemoteManagementSystem__c,ServicePointType__c,'+
       'SupplyType__c,Taxes__c,TensionOption__c,UseTypeEnergy__c,VATPercentage__c,Voltage__c,Contact.FAX,Contact.FirstName,Contact.LastName,Contact.MobilePhone,ServicePoint__r.SupplyCityCode__c,ServicePoint__r.SupplyCity__c,'+
       'ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumberExtension__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,'+
       'BillingProfile__r.DivergentSubject__r.ContactCode__c,BillingProfile__r.DivergentSubject__r.FirstName,BillingProfile__r.DivergentSubject__r.FiscalCode__c,BillingProfile__r.DivergentSubject__r.LastName,BillingProfile__r.DivergentSubject__r.MailingCity,BillingProfile__r.DivergentSubject__r.MailingPostalCode,BillingProfile__r.DivergentSubject__r.MailingState,BillingProfile__r.DivergentSubject__r.MailingStreetName__c,BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c,Contact.Email'+
       ' FROM Case ';

       Test.startTest();

       List<Case> listCase = Database.query(query);
       String body2  ='';
       body2=HDT_UTL_SIE34.createBodySIE34_2SMEEle(body2,listCase);
       System.assertEquals(true, body2.length()>0, 'Error in BodySIE34_2SMEEle');
       String body3  ='';
       body3=HDT_UTL_SIE34.createBodySIE34_2SMEGas(body3,listCase);
       System.assertEquals(true, body3.length()>0, 'Error in BodySIE34_2SMEEGas');
        
        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');

    }
}

