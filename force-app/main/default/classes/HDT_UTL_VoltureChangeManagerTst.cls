/**@frpanico 12/10/2021
 * Test Class for the Class HDT_UTL_VoltureChangeManagerTst
 */
@IsTest
public with sharing class HDT_UTL_VoltureChangeManagerTst {
    
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Order> orderList = new List<Order>();

        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');	
		orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');

    }

    @IsTest
    static void cloneSobjTst()
    {
        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c 
        FROM Order];   
        
        Map<String,Object> extraParams = new Map<String,Object>{'sobjName' => 'Order'};
        
        Test.startTest();
        Order clonedOrder = (Order)voltureChangeUtl.cloneSObject(orderList[0], extraParams);
        Test.stopTest();

        System.assertEquals(orderList[0].AccountId, clonedOrder.get('AccountId'), 'Order non clonato correttamente');

    }

    @IsTest
    static void accountCheckBusinessTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderList = [SELECT Id, Account.RecordType.DeveloperName FROM Order WHERE Account.RecordType.DeveloperName = 'HDT_RT_Business'];
        Map<String,Object> accountCheckParams = new Map<String,Object>
        {
            'accountType' => orderList[0].Account.RecordType.DeveloperName,
            'orderId' => orderList[0].Id,
            'dataDecorrenza' => System.today(),
            'preavvisoRecesso' => ''
        };
        Test.startTest();
        accountCheck = voltureChangeUtl.accountCheck(accountCheckParams);
        Test.stopTest();

        System.assertEquals(HDT_UTL_VoltureChangeUtilities.communicationPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void accountCheckBusinessWaitingTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderList = [SELECT Id, Account.RecordType.DeveloperName FROM Order WHERE Account.RecordType.DeveloperName = 'HDT_RT_Business'];
        Map<String,Object> accountCheckParams = new Map<String,Object>
        {
            'accountType' => orderList[0].Account.RecordType.DeveloperName,
            'orderId' => orderList[0].Id,
            'dataDecorrenza' => System.today(),
            'preavvisoRecesso' => 3
        };
        Test.startTest();
        accountCheck = voltureChangeUtl.accountCheck(accountCheckParams);
        Test.stopTest();

        System.assertEquals(HDT_UTL_VoltureChangeUtilities.waitingPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void accountCheckResidenzialeTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderList = [SELECT Id, Account.RecordType.DeveloperName FROM Order WHERE Account.RecordType.DeveloperName = 'HDT_RT_Business'];
        Map<String,Object> accountCheckParams = new Map<String,Object>
        {
            'accountType' => 'HDT_RT_Residenziale',
            'orderId' => orderList[0].Id,
            'dataDecorrenza' => System.today(),
            'preavvisoRecesso' => 3
        };
        Test.startTest();
        accountCheck = voltureChangeUtl.accountCheck(accountCheckParams);
        Test.stopTest();

        System.assertEquals(HDT_UTL_VoltureChangeManager.lawEightyPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }
}
