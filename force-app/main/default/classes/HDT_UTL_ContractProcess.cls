/**
* @author 'Keltin Mesonjesi' (keltin.mesonjesi@protonmail.ch);
* @date 19/04/2020
* @description Class HDT_UTL_ContractProcess.cls
* @history Lucas da Silva Fernandes – 19/04/2020 – Updated Header
*/

public inherited sharing class HDT_UTL_ContractProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    
    public static void orderCompletataPhaseManagement(List<Contract> newContractList){
        
        //get List of orderIds from Contract
        List<String> orderIds = new List<String>();

        for (Contract newContract : newContractList) {
            orderIds.add(newContract.SBQQ__Order__c);
        }

        //retrieve orders with billingProfile and ServicePoint
        List<Order> orders = orderQr.getRecordsByOrdersIdsBulk(orderIds);

        //update BillingProfile__c & ServicePoint__c on Contract
        for (Order order : orders) {
            if (order.BillingProfile__c != null && order.ServicePoint__c != null) {
                for (Contract newContract : newContractList) {
                    if (newContract.SBQQ__Order__c == order.Id) {
                        newContract.BillingProfile__c = order.BillingProfile__c;
                        newContract.ServicePoint__c = order.ServicePoint__c;
                    }
                }
            }
        }
    }

    public static void moveOut( Id recordId, string apiName ){

        List<sObject> ids = new List<sObject>();
        List<Contract> contrs = new List<Contract>();
        Contract contr = new Contract();
        String sObjType = recordId.getSObjectType().getDescribe().getName();

        ids = Database.query('SELECT '+ String.escapeSingleQuotes(apiName)
                           + ' FROM '+ String.escapeSingleQuotes(sObjType)
                           + ' WHERE Id = :recordId ' 
                           + ' WITH SECURITY_ENFORCED');

        for (sObject sObj : ids) {
            contr.Id = (Id)sObj.get(apiName); 
            if ( contr.Id != null ){             
                contr.Status = 'Cessato';
                contr.EndDate = date.Today();
            }
            contrs.add(contr);
        }
        HDT_UTL_DatabaseService.updateSObject(contrs);
    }
    private static Contract createContractFromOrder(Order orderCompleted){
        Contract contract = new Contract();
        contract.AccountId = orderCompleted.AccountId;
        contract.StartDate = Date.today();
        contract.EndDate = Date.newInstance(2099, 01, 01);
        contract.ContractTerm = 1200;
        contract.Status = 'Attivo';
        contract.CustomerSignedDate = orderCompleted.SignedDate__c;
        //contract.StatusCode = 'Draft';
        //contract.SBQQ__ActiveContract__c = 0;
        contract.SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date';
        //contract.SBQQ__ExpirationDate__c = Date.newInstance(2099, 01, 01);
        contract.ContractSalesCompany__c = orderCompleted.SalesCompany__c;
        contract.ContractType__c = 'Tacito rinnovo';
        contract.DeclaredExemptionThreshold__c = '0';
        contract.EstimatedEndDate__c = Date.newInstance(2099, 01, 01);
        contract.OriginalBailment__c = 0;
        contract.PostponementTimeUnitNumber__c = '6';
        contract.PostponementTimeUnit__c = 'Mesi';
        contract.PurchaseDate__c = Date.today();
        contract.TargetBailment__c = 0;
        contract.TerminationTimeUnitNumber__c ='6';
        contract.TerminationTimeUnit__c = 'Mesi';
        contract.TotalTurnoverVATExempted__c = '0';
        contract.WithdrawalTimeUnitNumber__c = '6';
        contract.WithdrawalTimeUnit__c = 'Mesi';
        contract.InvoicingPeriodDescription__c = 'Full Potential Digi6';
        contract.InvoicingPeriod__c = '1';
        contract.Contact__c = orderCompleted.Contact__c;
        contract.DL155RemiCode__c = orderCompleted.RemiCode__c;
        contract.SBQQ__Order__c = orderCompleted.Id;
        contract.ServicePoint__c   = orderCompleted.ServicePoint__c;
        contract.BillingProfile__c = orderCompleted.BillingProfile__c;
        contract.Market__c         = orderCompleted.Market__c; 
        contract.VAT__c            = orderCompleted.VAT__c ;  //02/09/2021 Email Fix Campo VAT__c su Contratto
        //contract.ActivatedDate      = orderCompleted.EffectiveDate__c ; //HRAWRM-638  17/09/2021
        contract.SapContractCode__c = orderCompleted.SapContractCode__c ; //HRAWRM-638  17/09/2021
        contract.Pricebook2Id = orderCompleted.Pricebook2Id;
        contract.SBQQ__AmendmentPricebookId__c = orderCompleted.Pricebook2Id;
        contract.CommercialProduct__c = orderCompleted.CommercialProduct__c ;
        HDT_UTL_DatabaseService.insertSObject(contract);
        if(String.isNotBlank(orderCompleted.ServicePoint__c)){
            ServicePoint__c sp = new ServicePoint__c();
            sp.Id = orderCompleted.ServicePoint__c;
            sp.MeterStatus__c='Attivo';
            HDT_UTL_DatabaseService.updateSObject(sp);
        }
        return contract;
    }
    private static SBQQ__Subscription__c createSubscription(OrderItem item,Contract contract,Order orderCompleted){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        HDT_QR_RecordType qrRecordType  = new HDT_QR_RecordType();
        sub.RecordTypeId = String.isNotBlank(item.Service__c) && item.Service__c.equalsIgnoreCase('Gas')?qrRecordType.getRecordTypeIdByName('HDT_RT_SectionBonusforGasservice', 'SBQQ__Subscription__c'):qrRecordType.getRecordTypeIdByName('HDT_RT_SectionBonusforEEservice', 'SBQQ__Subscription__c');
        sub.SBQQ__Account__c=orderCompleted.AccountId;
        sub.SBQQ__Bundle__c=true;
        sub.SBQQ__BundledQuantity__c=1;
        sub.SBQQ__Contract__c=contract.Id;
        sub.SBQQ__CustomerPrice__c=0;
        //sub.SBQQ__EndDate__c=Date.newInstance(2099, 01, 01);
        sub.SBQQ__ListPrice__c=0;
        sub.SBQQ__NetPrice__c=0;
        sub.SBQQ__Number__c=1;
        sub.SBQQ__PricingMethod__c='List';
        //sub.SBQQ__ProductId__c=item.Product2Id;
        sub.SBQQ__ProductSubscriptionType__c= 'Renewable';
        sub.SBQQ__Product__c=item.Product2Id;
        sub.SBQQ__ProrateMultiplier__c=1;
        sub.SBQQ__Quantity__c=1;
        //sub.SBQQ__RenewalProductId__c=item.Product2Id;
        sub.SBQQ__RenewalQuantity__c=1;
        //sub.SBQQ__RootId__c=
        //sub.SBQQ__StartDate__c=contract.StartDate;
        sub.SBQQ__SubscriptionEndDate__c=contract.EndDate;
        sub.SBQQ__SubscriptionStartDate__c=contract.StartDate;
        sub.SBQQ__SubscriptionType__c='Renewable';
        sub.CompanyOwner__c='HERA COMM';
        sub.PaymentMode__c=orderCompleted.PaymentMode__c;
        //sub.PriceF0__c=0;
        //sub.PriceF3__c=0;
        sub.SendingBillMode__c=orderCompleted.BillSendMode__c;
        sub.ServicePoint__c=orderCompleted.ServicePoint__c;
        //sub.Service__c= item.Service__c;
        sub.Version__c=item.Product2.Version__c;
        sub.Surface__c = item.Surface__c;
        sub.OccupantsNumber__c = item.OccupantsNumber__c;
        return sub;
    }

    private static void completeSubscriptionChild(SBQQ__Subscription__c sub, Id rootId, Id requiredBy){
        sub.SBQQ__RootId__c = rootId;
        sub.SBQQ__RequiredById__c = requiredBy;
    }
    
    /**
    * @author NTTDATA
    * @date 10/03/2022
    * @description Metodo crea Contratto e Subscription per gli Ordini di attivazione creati massivamente. Per gli ordini di aggiunta bonus e VAS si occupa di creare le subscription
    */

    public static void handleMassiveContractCreation(String orderId){
        if (String.isNotBlank(orderId)){
            HDT_QR_Order qrOrder = new HDT_QR_Order();
            
            Order orderCompleted = HDT_QR_Order.getOrderWithLines(orderId);
            List<OrderItem> orderItemList = orderCompleted.OrderItems;
            //Se l'order è di Attivazione è necessario creare il contratto e il root subscription
            if(!orderCompleted.ProcessType__c.contains('VAS')){
                Contract contract = createContractFromOrder(orderCompleted);
                List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
                for (OrderItem item : orderItemList) {
                    if(String.isNotBlank(item.ProductFamily__c) && item.ProductFamily__c.equalsIgnoreCase('Offerta commerciale')){
                        SBQQ__Subscription__c sub = createSubscription(item,contract,orderCompleted);
                        subList.add(sub);
                    }
                }
                if(!subList.isEmpty()){
                    HDT_UTL_DatabaseService.insertSObject(subList);
                    subList[0].SBQQ__RootId__c = subList[0].Id;
                    HDT_UTL_DatabaseService.updateSObject(subList);
                }
            }
            //Se l'ordine è di Bonus e Contributi è necessario ricercare il contratto esistente e creare le subscription come figlie dell'offerta commerciale
            else if(orderCompleted.ProcessType__c.contains('Aggiunta Sconti o Bonus VAS')) {
                Contract contract = HDT_QR_Contract.getContractWithSubscriptions(orderCompleted.ServicePoint__c);
                List<SBQQ__Subscription__c> contractSubList = contract.SBQQ__Subscriptions__r;
                Id rootId;
                List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
                for(SBQQ__Subscription__c singleSub : contractSubList){
                    if(String.isBlank(singleSub.SBQQ__RequiredById__c )){
                        rootId = singleSub.Id;
                        break;
                    }
                }
                for (OrderItem item : orderItemList) {
                    SBQQ__Subscription__c sub = createSubscription(item,contract,orderCompleted);
                    completeSubscriptionChild(sub, rootId,rootId);
                    subList.add(sub);
                }
                if(!subList.isEmpty()){
                    HDT_UTL_DatabaseService.insertSObject(subList);
                }
            }else if (orderCompleted.ProcessType__c.equalsIgnoreCase('VAS')) {
                Contract contract = HDT_QR_Contract.getContractWithSubscriptions(orderCompleted.ServicePoint__c);
                List<SBQQ__Subscription__c> contractSubList = contract.SBQQ__Subscriptions__r;
                Id rootId;
                Id parentProductId;
                Id parentSubId;
                List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
                for(SBQQ__Subscription__c singleSub : contractSubList){
                    if(String.isBlank(singleSub.SBQQ__RequiredById__c )){
                        rootId = singleSub.Id;
                        break;
                    }
                }
                for (OrderItem item : orderItemList) {
                    SBQQ__Subscription__c sub = createSubscription(item,contract,orderCompleted);
                    if(String.isBlank(item.SBQQ__RequiredBy__c)){
                        parentProductId = item.Product2Id;
                        completeSubscriptionChild(sub, rootId,rootId);
                    }
                    //completeSubscriptionChild(sub, rootId,rootId);
                    subList.add(sub);
                }
                if(!subList.isEmpty()){
                    HDT_UTL_DatabaseService.insertSObject(subList);
                }
                for(SBQQ__Subscription__c single : subList){
                    if(single.SBQQ__Product__c == parentProductId){
                        parentSubId = single.Id;
                    }
                }
                for(SBQQ__Subscription__c single : subList){
                    if(single.SBQQ__Product__c != parentProductId){
                        completeSubscriptionChild(single, rootId,parentSubId);
                    }
                }
                if(!subList.isEmpty()){
                    HDT_UTL_DatabaseService.updateSObject(subList);
                }
            }

        }  
        
    }

}