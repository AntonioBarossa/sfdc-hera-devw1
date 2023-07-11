@isTest 
public class HDT_UTL_TqrifTst { 

    @TestSetup
    static void makeData(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'D3 - Azienda', 'Aziende Soho');
        accList[0].VATNumber__c = '49130710046';
        insert accList;
        
        List<Contact> lc = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        AccountContactRelation acr = [Select id, IsDirect, IsActive, Roles From AccountContactRelation WHERE AccountId=:accList[0].Id];
        // system.debug('++++ ivaste');
        // system.debug(acr);
        acr.Roles='Titolare';
        update acr;
        //HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[0].Id, lc[0].Id);

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
        List<Equipment__c> eqs = HDT_UTL_DataFactoryTst.createEquipment(4, false, accList[0].Id, contractList[0].Id);
        for(Equipment__c eq : eqs){
            eq.Volumetry__c = 50;
        }
        insert eqs;
        Case c = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, null, null, contractList[0].Id, null)[0];
        insert new ProcessEquipment__c(Case__c= c.Id, OldGarbageBag1__c=eqs[1].EquipmentCode__c, OldGarbageBag2__c=eqs[2].EquipmentCode__c );
    }

    @isTest 
    public static void testCreateEquipmentHandler(){
        ProcessEquipment__c prcEq = [SELECT Case__c, OldGarbageBag1__c, OldGarbageBag2__c FROM ProcessEquipment__c LIMIT 1];
        // system.debug('++++ ivaste');
        // system.debug(prcEq);
        HDT_UTL_Tqrif utlTqrif = new HDT_UTL_Tqrif();
        Case c = new HDT_QR_HerokuPostSalesManager().getCaseRecord(prcEq.Case__c);
        c.EquipmentDeliveryOption__c = 'Sportello';
        
        List<Case> result;

        Test.startTest();
        utlTqrif.getProcessEquipment(prcEq.Case__c);
        Set<String> equipmentCodes = utlTqrif.getEquipmentCodes(prcEq.Case__c);
        
        //TEST1
        result = utlTqrif.createEquipmentHandler(c, equipmentCodes);
        Assert.areEqual(1, result.size(), 'It should return just one Case (for under 120L)');

        //TEST3
        List<Equipment__c> eqsToUpdate = new List<Equipment__c>{ new Equipment__c(EquipmentCode__c=prcEq.OldGarbageBag1__c, Volumetry__c=130)};
        upsert eqsToUpdate EquipmentCode__c;

        //result = utlTqrif.createEquipmentHandler(c, equipmentCodes);
        //Assert.areEqual(2, result.size(), 'It should return two Case (for under 120L and for Over 120L)');

        c.EquipmentDeliveryOption__c = 'Domicilio';

        result = utlTqrif.createEquipmentHandler(c, equipmentCodes);
        Assert.areEqual(1, result.size(), 'It should return just one Case (for both 120L and for Over 120L for "domicilio")');

        //TEST4
        eqsToUpdate = new List<Equipment__c>{ new Equipment__c(EquipmentCode__c=prcEq.OldGarbageBag2__c, Volumetry__c=130)};
        upsert eqsToUpdate EquipmentCode__c;
        c.EquipmentDeliveryOption__c = 'Sportello';
        result = utlTqrif.createEquipmentHandler(c, equipmentCodes);
        Assert.areEqual(1, result.size(), 'It should return just one Case (for over 120L)');
        
		utlTqrif.startProcess(c);
        Assert.areEqual([Select Count() FROM ProcessEquipment__c WHERE Case__c !=:c.Id], 1, 'It should insert just 1 processEquipment');
        // system.debug('++++ ivaste');
        // system.debug([Select Case__c, OldGarbageBag1__c, OldGarbageBag2__c FROM ProcessEquipment__c WHERE Case__c !=:c.Id]);
        Test.stopTest();
    }
    
    @isTest 
    public static void testCreateMultipleProcessEquipment(){
        ProcessEquipment__c prcEq = [SELECT Case__c, OldGarbageBag1__c, OldGarbageBag2__c FROM ProcessEquipment__c LIMIT 1];
        system.debug('++++ ivaste');
        system.debug(prcEq);
        HDT_UTL_Tqrif utlTqrif = new HDT_UTL_Tqrif();
        Case c = new HDT_QR_HerokuPostSalesManager().getCaseRecord(prcEq.Case__c);
        c.EquipmentDeliveryOption__c = 'Sportello';
        
        List<Case> result;

        Test.startTest();
        utlTqrif.getProcessEquipment(prcEq.Case__c);
        Set<String> equipmentCodes = utlTqrif.getEquipmentCodes(prcEq.Case__c);

        //TEST2
        List<Equipment__c> eqsToUpdate = new List<Equipment__c>{ new Equipment__c(EquipmentCode__c=prcEq.OldGarbageBag1__c, Volumetry__c=130)};
        upsert eqsToUpdate EquipmentCode__c;
        
        utlTqrif.startProcess(c);
        Assert.areEqual([Select Count() FROM ProcessEquipment__c WHERE Case__c !=:c.Id], 2, 'It should insert 2 processEquipment');
        //system.debug('++++ ivaste');
        //system.debug([Select Case__c, OldGarbageBag1__c, OldGarbageBag2__c FROM ProcessEquipment__c WHERE Case__c !=:c.Id]);
        Test.stopTest();
    }
}