/**
 * @author Valere (valere@noeli-it.net)
 * @date 13/09/2021
 * @description HDT_UTL_Sales Test Class
 * @history valere - 13/09/2021– Created Class
 */
@IsTest
public class HDT_UTL_SalesTst {
    @TestSetup
    static void makeData(){
        City__c city=createCity(1, true,true,'svd0')[0];

        Account acc0=createAccountBusiness(1, true,new Map<String,String>{
            'companyOwner'=>'AAA-EBT',
            'customerMarking'=>'AAS Azienda',
            'customerCode'=>'0000000',
            'numCustomerCode'=>'400065',
            'vatNumber'=>'123400',
            'nameStart'=>'acc',
            'code'=>'00',
            'category'=>'Enti'
        })[0];
        
        
        Account acc1=createAccountBusiness(1, true,new Map<String,String>{
            'companyOwner'=>'AAA-EBT',
            'customerMarking'=>'AAS Azienda',
            'customerCode'=>'00000001',
            'numCustomerCode'=>'4565465',
            'vatNumber'=>'123456',
            'nameStart'=>'acc0',
            'category'=>'Aziende Soho'
        })[0];
        HDT_UTL_DataFactoryTst.createSale(1,true,acc0.Id,'Attiva');
        HDT_UTL_DataFactoryTst.createSale(1,true,acc1.Id,'Attiva');
        createServicePoint(1, true,city.Name,acc0.Id);
    }
    
    public static List<City__c> createCity(Integer amount, Boolean doInsert,Boolean serviceEle,String sdv){
		List<City__c> cityList=new List<City__c>();

		for (Integer i=0; i<amount; i++){

			City__c ct=new City__c();

			ct.Name='Roma';
			ct.BelfioreCode__c='Bt'+i;
            ct.ServiceEle__c=serviceEle;
            ct.SDV__c=sdv;

			cityList.add(ct);

		}

		if (doInsert){

			insert cityList;
		}

		return cityList;
	}

    public static List<Account> createAccountBusiness(Integer amount, Boolean doInsert, Map<String,String> params){

		List<Account> accList=new List<Account>();
        HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
		Id rt=utlConstants.ACCOUNT_RECORDTYPEID_BUSINESS;

		for (Integer i=0; i<amount; i++){
			Decimal numCustomerCode = Decimal.valueOf(params.get('numCustomerCode')+i);
			Decimal result = numCustomerCode + i;
			String stringResult = String.valueOf(result);
			Account acc=new Account();

			acc.RecordTypeId=rt;
			acc.Name=params.get('nameStart')+i;
			acc.CompanyOwner__c=params.get('companyOwner');
			acc.CustomerMarking__c=params.get('customerMarking');
			acc.Category__C=params.get('category');
			acc.code__c=params.get('code');
			acc.CustomerCode__c=params.get('customerCode');
			acc.VATNumber__c=params.get('vatNumber');
			acc.BillingCityCode__c='Roma';
			acc.BillingStreetName__c='via roma';
			acc.BillingStreetNumber__c='55';
			acc.LastName__c=params.get('nameStart')+i;
			acc.FiscalCode__c='SXSRLA45H28H501K';
			acc.BillingIsAddressVerified__c=true;
        	acc.IsWrongFiscalData__c = false;
        	acc.BillingIsAddressVerified__c = true;
			acc.CustomerCode__c = stringResult;

			accList.add(acc);

		}

		if (doInsert){

			insert accList;
		}

		return accList;
	}

    public static List<ServicePoint__c> createServicePoint(Integer amount, Boolean doInsert,String supplyCity,String distributor){

		List<ServicePoint__c> servPointList=HDT_UTL_DataFactoryTst.createServicePoint(1, false);
		for(ServicePoint__c sp:servPointList){
			sp.SupplyProvince__c='AQ';
			sp.GlobalMigrationKey__c='1123255';
			sp.SupplyCity__c=supplyCity;
			sp.CommoditySector__c='Energia Elettrica';
			sp.Distributor__c=distributor;
		}

		if (doInsert){

			insert servPointList;
		}

		return servPointList;
	}

    @IsTest
    static void isTransitionNoUpTest(){
        Sale__c sale0=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c!=null LIMIT 1];
        Sale__c sale1=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c=null LIMIT 1];
        Test.startTest();
        System.assert(HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='PEP'),sale0));
        System.assert(!HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='AQ'),sale1));
        System.assert(HDT_UTL_Sales.isTransitionNoUp(sale0));
        System.assert(!HDT_UTL_Sales.isTransitionNoUp(sale1));
        System.assert(HDT_UTL_Sales.isTransition(new ServicePoint__c(SupplyProvince__c='PEP'),sale0));
        System.assert(!HDT_UTL_Sales.isTransition(new ServicePoint__c(SupplyProvince__c='AQ'),sale1));
        
        Test.stopTest();
    }

    @IsTest
    static void isWinbackTest(){
        ServicePoint__c sp=[SELECT Id FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255' LIMIT 1];
        Test.startTest();
        System.assert(!HDT_UTL_Sales.isWinback(sp.Id));
        Test.stopTest();
    }

    @IsTest
    static void getAgentNameAndCodeListTest(){
        List<ServicePoint__c> serviceList=[SELECT Id,SupplyCity__c,CommoditySector__c,Distributor__r.code__c FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255'];
        Test.startTest();
        System.assert(HDT_UTL_Sales.getAgentNameAndCodeList(serviceList,'').get(serviceList[0].Id)=='');//because there are no custom metadatas
        Test.stopTest();
    }

    @IsTest
    static void getAgentNameAndCodeTest(){
        ServicePoint__c sp=[SELECT Id,SupplyCity__c,CommoditySector__c,Distributor__r.code__c FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255' LIMIT 1];
        Test.startTest();
        System.assert(HDT_UTL_Sales.getAgentNameAndCode(sp,'').get('nomeAgente')=='');//because there are no custom metadatas
        System.assert(HDT_UTL_Sales.getAgentNameAndCode(sp,'').get('codiceAgente')=='');//because there are no custom metadatas
        Test.stopTest();
    }
}