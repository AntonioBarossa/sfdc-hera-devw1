public inherited sharing class HDT_UTL_Order {
    
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_QR_AccountContactRelation accountContactRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    public Order enrichOrder(Order newOrder){

        String servicePointFields = 'AnnualConsumption__c, SupplyType__c, WithdrawalClass__c, MarketOrigin__c';
        
        List<ServicePoint__c> servicePointList = new List<ServicePoint__c>();
        List<Contract> contractList = new List<Contract>();
        BillingProfile__c billingProfileList = new BillingProfile__c();
        List<AccountContactRelation> accountContactRelList = new List<AccountContactRelation>();

        System.debug('ServicePointId-->'+newOrder.ServicePoint__c);
        System.debug('ContractId-->'+newOrder.ContractId);
        System.debug('AccountId-->'+newOrder.AccountId);

        String billingProfileId;

        servicePointList = servicePointQr.getRecordById(newOrder.ServicePoint__c, servicePointFields);
        contractList = contractQr.getRecordById(newOrder.ContractId);

        billingProfileId = String.valueOf(contractList[0].BillingProfile__c);

        System.debug('BillingProfileId--> '+billingProfileId);

        billingProfileList = billingProfileQr.getRecordById(billingProfileId);
        accountContactRelList = accountContactRelQr.getRecordByAccountId(newOrder.AccountId);

        newOrder.AnnualConsumption__c	= servicePointList[0].AnnualConsumption__c;
        newOrder.SupplyType__c = servicePointList[0].SupplyType__c;
        newOrder.WithdrawalClass__c = servicePointList[0].WithdrawalClass__c;
        newOrder.Market__c = servicePointList[0].MarketOrigin__c;
        //newOrder.PaymentMode__c = billingProfileList.PaymentMethod__c;
        newOrder.BillSendMode__c  = billingProfileList.BillSendingMethod__c;
        newOrder.BillToContactId = accountContactRelList[0].ContactId;
        newOrder.PhoneNumber__c = accountContactRelList[0].Contact.MobilePhone;
        newOrder.Email__c = accountContactRelList[0].contact.Email;
        newOrder.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);

        return newOrder;


    }



}
