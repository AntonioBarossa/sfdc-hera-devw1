@isTest
public with sharing class HDT_LC_AbiCodeSelectorTst {
    @TestSetup
	static void makeData(){
        AbiCode__c abicode = new AbiCode__c();
        abicode.IbanABI__c = '0123';
        abicode.BankName__c = 'BankName';
        abicode.Active__c = true;
        insert abicode;
	}

    @IsTest
	public static void test1(){
        List<SObject> objList = HDT_LC_AbiCodeSelector.getData('');
        List<SObject> objListSecond = HDT_LC_AbiCodeSelector.getData('BankName');
        System.assertEquals(false, objList.isEmpty());
        //System.assertEquals(false, objListSecond.isEmpty());
    }
}
