@isTest
public with sharing class HDT_UTL_SIE14Tst {
    
    @TestSetup
    static void makeData(){
        List<Account> accounts= HDT_UTL_DataFactoryTst.createAccountResidenziale(3, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        Account acc1 = accounts.get(0);

        List<Contract> lc = new List<Contract>();
        Contract testContract1=new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm Marche');
        lc.add(testContract1);
        Contract testContract2=new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm Marche');
        lc.add(testContract2);
        Contract testContract3=new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm S.p.A.');
        lc.add(testContract3);

        for(Contract c : lc){
            Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
            o.SalesCompany__c=c.contractSalesCompany__c;
            insert o;
            c.SBQQ__Order__c=o.Id;
        }
        
        insert lc;
        lc.clear();

        Account acc2 = accounts.get(1);
        acc2.CategoryCode__c = 'Z006';
        update acc2;
        Contract testContract4=new Contract(AccountId=acc2.Id, ContractSalesCompany__c='Hera Comm S.p.A.');
        lc.add(testContract4);
        Contract testContract5=new Contract(AccountId=acc2.Id, ContractSalesCompany__c='Hera Comm S.p.A.');
        lc.add(testContract5);
        Contract testContract6=new Contract(AccountId=acc2.Id, ContractSalesCompany__c='EstEnergy S.p.A.');
        lc.add(testContract6);

        for(Contract c : lc){
            Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
            o.SalesCompany__c=c.contractSalesCompany__c;
            Sale__c s =HDT_UTL_DataFactoryTst.createSale(1, false, c.AccountId, 'Bozza')[0];
            s.CommercialId__c='AGSMECON1234';
            insert s;
			o.Sale__c=s.Id;
            insert o;
            c.SBQQ__Order__c=o.Id;
        }
        
        insert lc;
        lc.clear();

        Account acc3 = accounts.get(2);
        Contract testContract7=new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Acegas Aps Service');
        lc.add(testContract7);
        Contract testContract8=new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Acegas Aps Service');
        lc.add(testContract8);
        Contract testContract9=new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Hera Comm Marche');
        lc.add(testContract9);

        for(Contract c : lc){
            Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
            o.SalesCompany__c=c.contractSalesCompany__c;
            insert o;
            c.SBQQ__Order__c=o.Id;
        }
        
        insert lc;
        lc.clear();
    }

    @isTest
    static void testSie14WithSale() {
        
        List<Contract> contracts =  [SELECT Id, AccountId, SBQQ__Order__c, SBQQ__Order__r.CommercialId__c FROM Contract where ContractSalesCompany__c='EstEnergy S.p.A.'];
        update new Account(Id=contracts[0].AccountId, CategoryCode__c='');
        //system.debug('commId '+contracts[0].SBQQ__Order__r.CommercialId__c+' '+contracts.size());
        Test.startTest();
        //System.enqueueJob(new HDT_SRV_SIE14(new Map<Id,Contract>(contracts).keySet()));
        HDT_SRV_SIE14 testSie14 = new HDT_SRV_SIE14();
        testSie14.initSIE(new Map<Id,Contract>(contracts).keySet());
        Test.stopTest();
    }


    @isTest
    static void testSie14() {
        
        List<Contract> contracts =  [SELECT Id, AccountId FROM Contract];
        
        system.debug('allContracts -> ' + contracts);

        Test.startTest();
        //System.enqueueJob(new HDT_SRV_SIE14(new Map<Id,Contract>(contracts).keySet()));
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