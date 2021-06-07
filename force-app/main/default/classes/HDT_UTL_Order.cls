public inherited sharing class HDT_UTL_Order {
    
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_QR_AccountContactRelation accountContactRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_SRV_ActivityCustom activityCustomSrv = new HDT_SRV_ActivityCustom();

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
        newOrder.BillingProfile__c = billingProfileId;
        newOrder.BillSendMode__c  = billingProfileList.BillSendingMethod__c;
        newOrder.BillToContactId = accountContactRelList[0].ContactId;
        newOrder.PhoneNumber__c = accountContactRelList[0].Contact.MobilePhone;
        newOrder.Email__c = accountContactRelList[0].contact.Email;
        newOrder.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);

        return newOrder;


    }

    public Boolean isCambioOfferta(Order ord){

        system.debug('HDT_UTL_Order.isCambioOfferta START');

        List<OrderItem> offertaCommerciale = orderItemQr.getRecordsByOrderIdFilteredPdrPod(ord.Id);

        system.debug('HDT_UTL_Order.isCambioOfferta offertaCommerciale: ' + offertaCommerciale);
        system.debug('HDT_UTL_Order.isCambioOfferta ContractReference__c: ' + ord.SBQQ__Quote__r.ContractReference__c);

        Boolean result = !offertaCommerciale.isEmpty() && !ord.SBQQ__Quote__r.AllowChangeUse__c && ord.SBQQ__Quote__r.ContractReference__c != null && !ord.SBQQ__Quote__r.AmendmentAllowed__c;

        system.debug('HDT_UTL_Order.isCambioOfferta RESULT: ' + result);
        
        system.debug('HDT_UTL_Order.isCambioOfferta END');

        return result;
    }

    public void switchInRipristinatorioAction(Order ord) {

        system.debug('HDT_UTL_Order.switchInRipristinatorioAction START');

        List<wrts_prcgvr__Activity__c> activityList = new List<wrts_prcgvr__Activity__c>();
        
        if (ord.ServicePoint__c != null) {
            activityList = HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePoint('Gestione Switch in Ripristinatorio', 'Creata', ord.AccountId, ord.ServicePoint__r.ServicePointCode__c);
        }

        system.debug('HDT_UTL_Order.switchInRipristinatorioAction activityList: ' + activityList);
        system.debug('HDT_UTL_Order.switchInRipristinatorioAction AmendmentAllowed__c: ' + ord.SBQQ__Quote__r.AmendmentAllowed__c);
        system.debug('HDT_UTL_Order.switchInRipristinatorioAction AllowChangeUse__c: ' + ord.SBQQ__Quote__r.AllowChangeUse__c);

        if (!activityList.isEmpty() 
            && !ord.SBQQ__Quote__r.AmendmentAllowed__c 
            && !ord.SBQQ__Quote__r.AllowChangeUse__c 
            && !isCambioOfferta(ord)) {
            
            orderSrv.updateRecord(new Order(
                Id = ord.Id,
                ProcessType__c = 'Switch in Ripristinatorio'
            ));

            activityCustomSrv.updateRecord(new wrts_prcgvr__Activity__c(
                Id = activityList[0].Id,
                Order__c = ord.Id
            ));
        }

        system.debug('HDT_UTL_Order.switchInRipristinatorioAction END');
    }

}
