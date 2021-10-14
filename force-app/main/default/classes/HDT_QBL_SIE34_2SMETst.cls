@isTest
public class HDT_QBL_SIE34_2SMETst {
	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

  public static List<Case> createCaseWithStatusClosedNw(Integer amount, Map<String,Object> params){
		
		List<Case> caseList=new List<Case>();
		
		String rtId=utlConstants.CASE_RECORDTYPEID_MOROSITA;

		for (Integer i=0; i<amount; i++){

			Case testCase=new Case();
			testCase.Phase__c='Bozza';
			testCase.Subject='test';
			testCase.Type='BP/CA - errata categoria';
			testCase.Subprocess__c='Account';
			testCase.HerokuPracticeCode__c='21313232132132';
			testCase.RecordTypeId=rtId;
			testCase.CompanyOwner__c='HERA COMM';
      for(String key:params.keySet()){
        testCase.put(key, params.get(key));
      }
			caseList.add(testCase);
		}
		insert caseList;

    for(Case testCase:caseList){
      testCase.Status='Closed';
      testCase.PraxidiaOverrallSatisfaction__c=2;
    }
    update caseList;

		return caseList;
	}

  public static List<BillingProfile__c> createBillingProfile(Integer amount, Boolean doInsert, Map<String,Object> params){
		
		List<BillingProfile__c> billingProfileList=new List<BillingProfile__c>();
		for (Integer i=0; i<amount; i++){

			BillingProfile__c testBillingProfile=new BillingProfile__c();
			testBillingProfile.InvoicingCountry__c=(String)params.get('invoicingCountry');
			testBillingProfile.ContractAccountCode__c=(String)params.get('contractAccountCode');
			testBillingProfile.BillSendingMethod__c=(String)params.get('billSendingMethod');
			testBillingProfile.InvoiceCertifiedEmailAddress__c=(String)params.get('invoiceCertifiedEmailAddress');
			testBillingProfile.InvoiceEmailAddress__c=(String)params.get('invoiceEmailAddress');
			testBillingProfile.SendCertifiedEmailConsentDate__c=Date.today();
			testBillingProfile.BankAccountSignatoryFirstName__c=(String)params.get('bankAccountSignatoryFirstName');
			testBillingProfile.BankAccountSignatoryFiscalCode__c=(String)params.get('bankAccountSignatoryFiscalCode');
			testBillingProfile.BankAccountSignatoryLastName__c=(String)params.get('bankAccountSignatoryLastName');
			testBillingProfile.BankName__c=(String)params.get('bankName');
			testBillingProfile.IbanABI__c=(String)params.get('ibanABI');
      testBillingProfile.IbanCAB__c=(String)params.get('accountId');
			testBillingProfile.IbanCIN_IBAN__c=(String)params.get('ibanCAB');
			testBillingProfile.IbanCIN__c=(String)params.get('ibanCIN');
			testBillingProfile.IbanCodeNumber__c=(String)params.get('ibanCodeNumber');
			testBillingProfile.IbanCountry__c=(String)params.get('ibanCountry');
			testBillingProfile.InvoicingCity__c=(String)params.get('invoicingCity');
			testBillingProfile.InvoicingPlace__c=(String)params.get('invoicingPlace');
			testBillingProfile.InvoicingPostalCode__c=(String)params.get('invoicingPostalCode');
			testBillingProfile.InvoicingProvince__c=(String)params.get('invoicingProvince');
			testBillingProfile.InvoicingStreetName__c=(String)params.get('invoicingStreetName');
      testBillingProfile.InvoicingStreetNumberExtension__c=(String)params.get('invoicingStreetName');
      testBillingProfile.InvoicingStreetNumber__c=(String)params.get('InvoicingStreetNumber__c');
			testBillingProfile.PaymentMethod__c=(String)params.get('paymentMethod');
			testBillingProfile.DivergentSubject__c=(String)params.get('contactId');
			

			billingProfileList.add(testBillingProfile);
		}

		if (doInsert){

			insert billingProfileList;
		}

		return billingProfileList;
	}

  @TestSetup
  static void makeData(){
    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase();
    HDT_UTL_DataFactoryTst.pClickCasePhase();
    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM','Persona fisica','Famiglie');
    List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact (1,true,accountList[0].id); 
    List<ServicePoint__c> servicepointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
    List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accountList[0].id);
    List<Case> caseList = createCaseWithStatusClosedNw(1,new Map<String,Object>{
      'AccountId'=>accountList[0].id,
      'Contract__c'=>contractList[0].id,
      'ServicePoint__c'=>null,
      'Cluster__c'=>'Preventivi'
    });
     
    List<BillingProfile__c> billingProfileList = createBillingProfile(1, true, new Map<String,Object>{
      'Status'=>'Closed',
      'cluster'=>'Preventivi',
      'invoicingCountry'=>'BG',
      'contractAccountCode'=>'BG',
      'billSendingMethod'=>'Cartaceo',
      'invoiceCertifiedEmailAddress'=>'test@yahoo.com',
      'invoiceEmailAddress'=>'test@yahoo.com',
      'bankAccountSignatoryFirstName'=>'BG',
      'bankAccountSignatoryFiscalCode'=>'BG',
      'bankAccountSignatoryLastName'=>'BG',
      'bankName'=>'BG',
      'ibanABI'=>'BG',
      'accountId'=>'BG',
      'ibanCAB'=>'BG',
      'ibanCIN'=>'B',
      'ibanCodeNumber'=>'00',
      'ibanCountry'=>'BG',
      'invoicingCity'=>'BG',
      'invoicingPlace'=>'BG',
      'invoicingPostalCode'=>'BG',
      'invoicingProvince'=>'BG',
      'invoicingStreetName'=>'BG',
      'invoicingStreetName'=>'BG',
      'InvoicingStreetNumber__c'=>'BG',
      'paymentMethod'=>'RID',
      'contactId'=>contactList[0].id
    });
    HDT_UTL_DataFactoryTst.createWebServiceConfiguration('SIE34','http://test.test','POST','user0');
    HDT_UTL_DataFactoryTst.createWebServiceCredential('user0','pass', 'usrn');
  }
  @istest
  static void testExecute (){
    String varRunId='varRunId';
    String varFileType='varFileType';
    String varDate = '2020-10-13T16:19:01.064Z';
    System.debug([SELECT Status,Cluster__c,  LastModifiedDate,ServicePoint__c FROM CAse]);
    Test.setMock(HttpCalloutMock.class, new HDT_QBL_SIE34_2SMETstMck());
    Test.startTest();
    HDT_QBL_SIE34_2SME this2sme = new HDT_QBL_SIE34_2SME(varRunId,varDate,varFileType);
    this2sme.execute(null);
    Test.stopTest();
    System.assertEquals(true,JSON.serialize(this2sme).contains('2020-10-13T16:19:01.064Z') && 
      JSON.serialize(this2sme).contains('varRunId') && JSON.serialize(this2sme).contains('varFileType'),
      'HDT_QBL_SIE34_2SME has been well instantiated will the value passed'
    );
    //No other checks because the call of this queue doesn't impact any data into the current transaction
  }
}