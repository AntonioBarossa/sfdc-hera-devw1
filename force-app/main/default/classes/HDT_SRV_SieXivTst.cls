@isTest
public with sharing class HDT_SRV_SieXivTst {
    
    static Order createOrder(Contract c, Sale__c s){
        Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
        o.SalesCompany__c=c.contractSalesCompany__c;
        o.Sale__c=s.Id;
        return o;
        //c.SBQQ__Order__c=o.Id;
        //insert c;
    }

    static Sale__c createSale(Contract c, String commId){
        Sale__c s =HDT_UTL_DataFactoryTst.createSale(1, false, c.AccountId, 'Bozza')[0];
        s.CommercialId__c=commId;
        //'AGSMECON1234';
        return s;
    }

    @TestSetup
    public static void makeData(){
        List<Account> accounts= HDT_UTL_DataFactoryTst.createAccountResidenziale(100, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        Map<Id, Order> accToOrder = new Map<Id, Order>();
        Map<Id, Sale__c> accToSale = new Map<Id, Sale__c>();
        Map<Id, Contract> accToContr = new Map<Id, Contract>();
        for(Integer i =0; i<accounts.size();i++){
            Account a = accounts[i];
            Contract c = new Contract(AccountId=a.Id, ContractSalesCompany__c='Hera Comm Marche');
            Boolean isMod2 = Math.mod(i, 2)==0;
            accToSale.put(a.id, createSale(c, isMod2? 'AGSMECON1234' : 'AGSIHSFBV'));
        }
        insert accToSale.values();

        for(Integer i =0; i<accounts.size();i++){
            Account a = accounts[i];
            Contract c = new Contract(AccountId=a.Id);
            accToOrder.put(a.id, createOrder(c, accToSale.get(a.id)));
        }
        insert accToOrder.values();


        for(Integer i =0; i<accounts.size();i++){
            Account a = accounts[i];
            
            Boolean isMod2 = Math.mod(i, 2)==0;
            Boolean isMod3 = Math.mod(i, 3)==0;
            accToContr.put(a.id, new Contract(AccountId=a.Id, SBQQ__Order__c=accToOrder.get(a.Id)?.Id, ContractSalesCompany__c=isMod3? 'Hera Comm Marche' : (isMod2? 'Hera Comm NordEst' : 'EstEnergy S.p.A.')));
        }
        insert accToContr.values();
    }

    @isTest
    static void performanceTest() {
        
        List<Contract> contracts =  [SELECT Id, AccountId FROM Contract]; 
        //system.debug('allContracts -> ' + contracts);
        Test.startTest();
        HDT_SRV_SieXiv testSieXiv = new HDT_SRV_SieXiv();
        testSieXiv.initSIE(new Map<Id,Contract>(contracts).keySet());
        Test.stopTest();
        Integer accountsToCode = [Select Count() from Account Where Segment__c='ZCOD-DA CODIFICARE'];
        system.assert(accountsToCode>0, 'Unexpected Behaviour');
    }

    
}