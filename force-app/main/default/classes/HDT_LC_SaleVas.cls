/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/01/2021
* @description Apex controller for hdtSaleVas.js component
* @history Keltin Mesonjesi – 19/01/2021 – Created class
*/
public inherited sharing class HDT_LC_SaleVas {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action logic
     * @param String selectedOption
     * @param Order order
     * @param Contract contract
     * @param String supplyCity
     * @param String accountId
     * @param Sale sale
     */
    @AuraEnabled
    public static void confirmAction(String selectedOption, Order order, Contract contract, String supplyCity, String accountId, Sale__c sale){
        switch on selectedOption {
            when  'Ordini in corso'{
                handleActiveOrderConfirm(order, supplyCity, sale);
            }
            when 'Contratti Attivi'{
                handleActiveContractConfirm(contract, supplyCity, sale);
            }
            when 'VAS stand alone'{
                handleVasStandAloneConfirm(supplyCity, accountId, sale);
            }
            
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get list of active orders based on accountId when 'Ordini in corso' is selected
     * @param String accountId
     * @return List<Order>
     */
    @AuraEnabled
    public static List<Order> getOrdersList(String accountId){
        //Orders with status "Draft" or "In Lavorazione"
        orderSrv.checkReadAccess('Name,AccountId,OrderNumber,Status');
        return orderQr.getActiveRecordsByAccountId(accountId);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get list of active contracts based on accountId when 'Contratti Attivi' is selected
     * @param String accountId
     * @return List<Contact>
     */
    @AuraEnabled
    public static List<Contract> getContractsList(String accountId){
        //Contracts with status "Activated"
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,Status');
        return contractQr.getActiveRecordsByAccountId(accountId);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action for 'Ordini in corso'
     * @param Order order
     * @param String supplyCity
     */
    public static void handleActiveOrderConfirm(Order order, String supplyCity, Sale__c sale){
        
        if (order.Id == null || supplyCity == '') {
            throw new AuraHandledException('Devi scegliere un ordine e compilare il comune!');
        }

        Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
            Sale__c = sale.Id,
            Name = opportunitySrv.generateName(sale) + ' VAS',
            CloseDate = Date.today().addDays(30),
            StageName = 'Proposal',
            AccountId = order.AccountId
        ));

        SBQQ__Quote__c newQuote = quoteSrv.createRecord(new SBQQ__Quote__c(
            Sale__c = sale.Id,
            OrderReference__c = order.Id,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Account__c = order.AccountId,
            SBQQ__Primary__c = true,
            Agency__c = order.Agency__c,
            Market__c = order.Market__c,
            Channel__c = order.Channel__c,
            FriendCode__c = order.FriendCode__c,
            CampaignCode__c = order.CampaignCode__c,
            CreatedBy__c = order.CreatedBy__c,
            SupplyCity__c = supplyCity
        ));

        newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;

        opportunitySrv.updateRecord(newOpportunity);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action for 'Contratti Attivi'
     * @param Contract contract
     * @param String supplyCity
     */
    public static void handleActiveContractConfirm(Contract contract, String supplyCity, Sale__c sale){
        
        if (contract.Id == null || supplyCity == '') {
            throw new AuraHandledException('Devi scegliere un contrato e compilare il comune!');
        }

        Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
            Sale__c = sale.Id,
            Name = opportunitySrv.generateName(sale) + ' VAS',
            CloseDate = Date.today().addDays(30),
            StageName = 'Proposal',
            AccountId = contract.AccountId
        ));

        SBQQ__Quote__c newQuote = quoteSrv.createRecord(new SBQQ__Quote__c(
            Sale__c = sale.Id,
            ContractReference__c = contract.Id,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Account__c = contract.AccountId,
            SBQQ__Primary__c = true,
            Agency__c = contract.SBQQ__Order__r.Agency__c,
            Market__c = contract.SBQQ__Order__r.Market__c,
            Channel__c = contract.SBQQ__Order__r.Channel__c,
            FriendCode__c = contract.SBQQ__Order__r.FriendCode__c,
            CampaignCode__c = contract.SBQQ__Order__r.CampaignCode__c,
            CreatedBy__c = contract.SBQQ__Order__r.CreatedBy__c,
            SupplyCity__c = supplyCity
        ));

        newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;

        opportunitySrv.updateRecord(newOpportunity);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action for "VAS Stand Alone" option
     * @param String supplyCity
     * @param String accountId
     */
    public static void handleVasStandAloneConfirm(String supplyCity, String accountId, Sale__c sale){
        
        if (supplyCity == '') {
            throw new AuraHandledException('Devi compilare il comune!');
        }

        Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
            Sale__c = sale.Id,
            Name = opportunitySrv.generateName(sale) + ' VAS',
            CloseDate = Date.today().addDays(30),
            StageName = 'Proposal',
            AccountId = accountId
        ));

        SBQQ__Quote__c newQuote = quoteSrv.createRecord(new SBQQ__Quote__c(
            Sale__c = sale.Id,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Account__c = accountId,
            SBQQ__Primary__c = true,
            SupplyCity__c = supplyCity
        ));

        newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;

        opportunitySrv.updateRecord(newOpportunity);
    }
}
