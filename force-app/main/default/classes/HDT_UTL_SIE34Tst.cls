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
        HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        HDT_UTL_DataFactoryTst.createCaseMorosita(5, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
     }

    @isTest
	public static void testCreateBodySie2mme(){

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
       String bodyEle  ='';
       bodyEle=HDT_UTL_SIE34.createBodySIE34_2MMEle(bodyEle,listCase);
       System.assertEquals(true, bodyEle.length()>0, 'Error in BodySIE34_2MMEle');
       String bodyGas  ='';
       bodyGas=HDT_UTL_SIE34.createBodySIE34_2MMGas(bodyGas,listCase);
       System.assertEquals(true, bodyGas.length()>0, 'Error in BodySIE34_2MMEle');
        
        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');

    }

    @isTest
	public static void testCreateBodySie2sme(){

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
       String bodyEle  ='';
       bodyEle=HDT_UTL_SIE34.createBodySIE34_2SMEEle(bodyEle,listCase);
       System.assertEquals(true, bodyEle.length()>0, 'Error in BodySIE34_2SMEEle');
       String bodyGas  ='';
       bodyGas=HDT_UTL_SIE34.createBodySIE34_2SMEGas(bodyGas,listCase);
       System.assertEquals(true, bodyGas.length()>0, 'Error in BodySIE34_2SMEEGas');
        
        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');

    }
}
