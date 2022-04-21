@isTest
public with sharing class HDT_UTL_SIE14Tst {
    
    static void createOrder(Contract c){
        Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
        o.SalesCompany__c=c.contractSalesCompany__c;
        insert o;
        c.SBQQ__Order__c=o.Id;
        insert c;
    }

    static void createOrderAndSale(Contract c){
            Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
            o.SalesCompany__c=c.contractSalesCompany__c;
            Sale__c s =HDT_UTL_DataFactoryTst.createSale(1, false, c.AccountId, 'Bozza')[0];
            s.CommercialId__c='AGSMECON1234';
            insert s;
            o.Sale__c=s.Id;
            insert o;
            c.SBQQ__Order__c=o.Id;
            insert c;
    }

    @TestSetup
    static void makeData(){
        List<Account> accounts= HDT_UTL_DataFactoryTst.createAccountResidenziale(3, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');

        Account acc1 = accounts.get(0);
        createOrder(new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm Marche'));
        createOrder(new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm Marche'));
        createOrder(new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm S.p.A.'));

        Account acc2 = accounts.get(1);
        acc2.CategoryCode__c = 'Z006';
        update acc2;

        createOrderAndSale(new Contract(AccountId=acc2.Id, ContractSalesCompany__c='Hera Comm S.p.A.'));
        createOrderAndSale(new Contract(AccountId=acc2.Id, ContractSalesCompany__c='Hera Comm S.p.A.'));
        createOrderAndSale(new Contract(AccountId=acc2.Id, ContractSalesCompany__c='EstEnergy S.p.A.'));
        
        Account acc3 = accounts.get(2);
        createOrder(new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Acegas Aps Service'));
        createOrder(new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Acegas Aps Service'));
        createOrder(new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Hera Comm Marche'));
    }

    @isTest
    static void testSie14WithSale() {
        
        List<Contract> contracts =  [SELECT Id, AccountId, SBQQ__Order__c, SBQQ__Order__r.CommercialId__c FROM Contract where ContractSalesCompany__c='EstEnergy S.p.A.'];
        update new Account(Id=contracts[0].AccountId, CategoryCode__c='');
        Test.startTest();
        HDT_SRV_SIE14 testSie14 = new HDT_SRV_SIE14();
        testSie14.initSIE(new Map<Id,Contract>(contracts).keySet());
        Test.stopTest();
    }


    @isTest
    static void testSie14() {
        
        List<Contract> contracts =  [SELECT Id, AccountId FROM Contract];
        
        system.debug('allContracts -> ' + contracts);

        Test.startTest();
        HDT_SRV_SIE14 testSie14 = new HDT_SRV_SIE14();
        testSie14.initSIE(new Map<Id,Contract>(contracts).keySet());
        Test.stopTest();
    }
    /*
    private static boolean doLogicAndSimplifyExpr(String expression, String operator, SObject obj){
        List<String> indexes = new List<String>();
        for(String s : expression.split(operator)){
            indexes.add(s.trim());
        }
        switch on operator {
            when  'AND' {
                checkLogicAndGate(indexes, obj);
            }
            when 'OR' {
                
            }
        }
    }*/
    
    /*private static boolean checkLogicAndGate(SObject obj, List<String> indexes){//Logica AND
        //l'oggetto contiene una lista di condizioni. Se la lista è vuota O se tutte sono vere, torna true.
        if(indexes?.size() > 0){
            if(!this.conditions?.size()>0)   return false;
            for(String booleanIndex : indexes){
                if(booleanIndex=='true') return true;
                if(booleanIndex=='false') return false;
                Integer index = Integer.valueOf(booleanIndex);
                if(!this.conditions?.size()>booleanIndex) return false;
                HDT_WRP_SIECondition condition = this.conditions.get(booleanIndex);
                String actualValue=utlSbj.dinamicFieldValue(condition.fieldName, obj);
                if(!condition.checkCondition(actualValue))   return false;//Alla prima espressione falsa, il processo si blocca negativamente.
            }
        }
        return true;//Se è tutto vero o la lista è vuota, torna true.
    }*/
/*
    private static boolean checkLogicAndGate(SObject obj, List<String> indexes){//Logica AND
        //l'oggetto contiene una lista di condizioni. Se la lista è vuota O se tutte sono vere, torna true.
        if(indexes?.size() > 0){
            if(!this.conditions?.size()>0)   return false;
            for(String booleanIndex : indexes){
                if(booleanIndex=='true') return true;
                if(booleanIndex=='false') return false;
                Integer index = Integer.valueOf(booleanIndex);
                if(!this.conditions?.size()>booleanIndex) return false;
                HDT_WRP_SIECondition condition = this.conditions.get(booleanIndex);
                String actualValue=utlSbj.dinamicFieldValue(condition.fieldName, obj);
                if(!condition.checkCondition(actualValue))   return false;//Alla prima espressione falsa, il processo si blocca negativamente.
            }
        }
        return true;//Se è tutto vero o la lista è vuota, torna true.
    }*/
    
}