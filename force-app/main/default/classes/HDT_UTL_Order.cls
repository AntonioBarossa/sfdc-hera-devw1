public inherited sharing class HDT_UTL_Order {
    
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_QR_AccountContactRelation accountContactRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    private static HDT_SRV_ActivityCustom activityCustomSrv = new HDT_SRV_ActivityCustom();
    private static HDT_SRV_Order ordSrv = new HDT_SRV_Order();
    /*public Order enrichOrder(Order newOrder){

        String servicePointFields = 'AnnualConsumption__c, SupplyType__c, WithdrawalClass__c, MarketOrigin__c';
        
        //List<ServicePoint__c> servicePointList = new List<ServicePoint__c>();
        List<Contract> contractList = new List<Contract>();
        //BillingProfile__c billingProfileList = new BillingProfile__c();
        //List<AccountContactRelation> accountContactRelList = new List<AccountContactRelation>();

        System.debug('ServicePointId-->'+newOrder.ServicePoint__c);
        //System.debug('ContractId-->'+newOrder.ContractId);
        //System.debug('AccountId-->'+newOrder.AccountId);

        //String billingProfileId;

        //servicePointList = servicePointQr.getRecordById(newOrder.ServicePoint__c, servicePointFields);
        //contractList = contractQr.getRecordById(newOrder.ContractId);

        //billingProfileId = String.valueOf(contractList[0].BillingProfile__c);

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


    }*/
    private static Map<String,Object> rateCategoryAlgo(List<RateCategory__c> listRate, Order o)
    {
        boolean res = false;
        String code = '';
        for(RateCategory__c r : listRate){
            if(r.DistributorCode__c == o.ServicePoint__r.distributor__r.code__c && r.operatore__c == 'Uguale'){
                code = r.CalculatedValue__c;
                res = true;
                break;
            }
            else if(r.DistributorCode__c != o.ServicePoint__r.distributor__r.code__c && r.operatore__c == 'Diverso'){
                code = r.CalculatedValue__c;
                res = true;
                break;
            }
            else if(r.operatore__c == 'N/A'){
                code = r.CalculatedValue__c;
                res = true;
                break;
            }
        }
        if(!res){
            listRate = HDT_QR_RateCategory.getRateList(o.ServicePoint__c != null ? o.ServicePoint__r.CommoditySector__c : 'Energia Elettrica',o.ServicePoint__r.distributor__r.code__c,'N/A',o.SupplyType__c != null ? o.SupplyType__c : o.supplyTypeTechnical__c);
            for(RateCategory__c r : listRate){
                if(r.DistributorCode__c == o.ServicePoint__r.distributor__r.code__c && r.operatore__c == 'Uguale'){
                    code = r.CalculatedValue__c;
                    res = true;
                    break;
                }
                else if(r.DistributorCode__c != o.ServicePoint__r.distributor__r.code__c && r.operatore__c == 'Diverso'){
                    code = r.CalculatedValue__c;
                    res = true;
                    break;
                }
                else if(r.operatore__c == 'N/A'){
                    code = r.CalculatedValue__c;
                    res = true;
                    break;
                }
            }
        }

        return new Map<String, Object>{'code'=> code, 'res'=>res};
    }

    @auraEnabled
    public static boolean calculateRateCategory(Order ord){
        HDT_QR_Order orQr = new HDT_QR_Order();
        Order o = orQr.getRecordById(ord.id);
        boolean res = false;
        String code = '';
        List<RateCategory__c> listRate = new List<RateCategory__c>();
        if(o.Market__c != null && o.Market__c.equalsIgnoreCase('Regolamentato'))
        {
            listRate = HDT_QR_RateCategory.getRecordByMarket(o.Market__c);
        }
        else
        {
            listRate = HDT_QR_RateCategory.getRateList(o.ServicePoint__c != null ? o.ServicePoint__r.CommoditySector__c : 'Energia Elettrica',o.ServicePoint__r.distributor__r.code__c,o.CommercialProduct__c,o.SupplyType__c != null ? o.SupplyType__c : o.supplyTypeTechnical__c);
        }
        Map<String, Object> rateResult = rateCategoryAlgo(listRate, o);
        code = (String) rateResult.get('code');
        res = (Boolean) rateResult.get('res');
        //System.debug('**********:' + listRate);
        //Map<String,String> mapCal = new Map<String,String>();
        Order oUp = new Order();
        oUp.id = o.id;
        oUp.rateCategory__c = code;
        /*if(listRate != null && !listRate.isEmpty()){
            for(RateCategory__c r: listRate){
                if(mapCal.get(r.operatore__c) != null){
                    mapCal.put(r.operatore__c,r.CalculatedValue__c);
                }
            }
            if(mapCal.get('Diverso') != null){
                oUp.rateCategory__c = mapCal.get('Diverso');
                res = true;
            }
            else if(mapCal.get('N/A') != null){
                oUp.rateCategory__c = mapCal.get('N/A');
                res = true;
            }
            else if(mapCal.get('Uguale') != null){
                oUp.rateCategory__c = mapCal.get('Uguale');
                res =  true;
            }

        }*/

        if(res){
            ordSrv.updateRecord(oUp);
        }
        return res;
    }
    @auraEnabled
    public static boolean annullaContratti(String orderId){
        try{
        List<Order> getOrderChildVas = new List<Order>();//orderQr.getOrderVasToDelete(orderId);
        Case cb = caseQr.getCaseRelated(orderId);
        List<Order> ordToUpdate = new List<Order>(); 
        for(Order ord : getOrderChildVas){
            ord.status = 'Annullato';
            ord.phase__c = 'Annullato';
            ord.CancellationReason__c = 'Annullamento per Dati Discordanti';
            ordToUpdate.add(ord);
        }
        cb.status = 'Annullato';
        cb.phase__c = 'Annullato';
        cb.CancellationReason__c = 'Annullamento per Dati Discordanti';
        ordSrv.updateRecords(ordToUpdate);
        caseSrv.updateRecord(cb);
        return true;
        }catch(Exception e){
            return false;
        }
    }

    @AuraEnabled
    public static boolean checkToDiscordanti(String OrderId){
        try{
            Order newOrder = orderQr.getRecordById(OrderId);
            List<OrderItem> mainOrderItem = orderItemQr.getMainItem(OrderId);
            HDT_SRV_ActivityCustom actSrv = new HDT_SRV_ActivityCustom();
            List<wrts_prcgvr__Activity__c> listActivity = HDT_QR_ActivityCustom.getRecordScartoDiscordante(newOrder.ServicePoint__c,newOrder.AccountId);
            if(listActivity != null && !listActivity.isEmpty() && !mainOrderItem.isEmpty() && mainOrderItem[0].Product2.Family.equalsIgnoreCase('Offerta commerciale')){
                system.debug('DENTRO TRAVASO DATO DISCORDANTE 2');
                wrts_prcgvr__Activity__c wr = listActivity[0];
                wr.wrts_prcgvr__Status__c = 'Chiusa';
                //actSrv.updateRecord(wr);
                Order oldOrder = orderQr.getRecordById(wr.order__c);
                travasaOrder(oldOrder,newOrder);
                //return true;
            }
            return true;
        }catch(Exception e){
            system.debug('checkToDiscordanti exception: ' + e.getMessage());
            return false;
        }
    }
    @AuraEnabled
    public static void travasaOrder(Order oldOrder, order orderToUpdate){
        system.debug('DENTRO TRAVASO DATO DISCORDANTE');
        orderToUpdate.exciseEle__c =  oldOrder.exciseEle__c;
        orderToUpdate.ExciseGas__c =  oldOrder.ExciseGas__c;
        orderToUpdate.vat__c = oldOrder.vat__c;
        orderToUpdate.AnnualConsumption__c = oldOrder.AnnualConsumption__c;
        orderToUpdate.MarketOrigin__c = oldOrder.MarketOrigin__c;
        orderToUpdate.recordtypeId = oldOrder.recordtypeid;
        orderToUpdate.Market__c = oldOrder.Market__c;
        orderToUpdate.PowerAvailable__c = oldOrder.PowerAvailable__c;
        orderToUpdate.VoltageLevel__c = oldOrder.VoltageLevel__c;
        orderToUpdate.processType__c = oldOrder.recordtype.developername == 'HDT_RT_SwitchIn' ? 'Switch in Fittizio' : oldOrder.processtype__c;
        orderToUpdate.AllowSwitchInDummy__c = oldOrder.recordtype.developername == 'HDT_RT_SwitchIn' ? true : false;
        orderToUpdate.DisconnectibilityPhone__c = oldOrder.DisconnectibilityPhone__c;
        orderToUpdate.MaxRequiredPotential__c = oldOrder.MaxRequiredPotential__c;
        orderToUpdate.HerokuPracticeCode__c = oldOrder.HerokuPracticeCode__c;
        orderToUpdate.UseTypeEnergy__c = oldOrder.UseTypeEnergy__c;
        orderToUpdate.UseCategory__c = oldOrder.UseCategory__c;
        orderToUpdate.MeterSN__c = oldOrder.MeterSN__c;
        orderToUpdate.Resident__c = oldOrder.Resident__c;
        orderToUpdate.RemiCode__c = oldOrder.RemiCode__c;
        orderToUpdate.SupplyCity__c = oldOrder.SupplyCity__c;
        orderToUpdate.CommercialProductVersion__c = oldOrder.CommercialProductVersion__c ;
        orderToUpdate.CommercialProductCode__c = oldOrder.CommercialProductCode__c ;
        orderToUpdate.CommercialProduct__c = oldOrder.CommercialProduct__c;
        orderToUpdate.SupplyStreetName__c = oldOrder.SupplyStreetName__c;
        orderToUpdate.SupplyStreetNumber__c = oldOrder.SupplyStreetNumber__c;
        orderToUpdate.SupplyStreetNumberExtension__c = oldOrder.SupplyStreetNumberExtension__c;
        orderToUpdate.SupplyPlace__c = oldOrder.SupplyPlace__c;
        orderToUpdate.SupplyPostalCode__c = oldOrder.SupplyPostalCode__c;
        orderToUpdate.SupplyCountry__c = oldOrder.SupplyCountry__c;
        orderToUpdate.PowerCommitted__c = oldOrder.PowerCommitted__c;
        orderToUpdate.ServicePointCode__c = oldOrder.ServicePointCode__c;
        orderToUpdate.SAPImplantCode__c = oldOrder.SAPImplantCode__c;
        orderToUpdate.ImplantType__c = oldOrder.ImplantType__c;
        orderToUpdate.SupplyCityCode__c = oldOrder.SupplyCityCode__c;
        orderToUpdate.SupplyState__c = oldOrder.SupplyState__c;
        orderToUpdate.Disconnectable__c = oldOrder.Disconnectable__c;
        orderToUpdate.DisconnectibilityType__c = oldOrder.DisconnectibilityType__c;
        orderToUpdate.ConnectionType__c = oldOrder.ConnectionType__c;
        orderToUpdate.InstanceSelfCertification__c = oldOrder.InstanceSelfCertification__c;
        orderToUpdate.ConnectionMandate__c = oldOrder.ConnectionMandate__c;
        orderToUpdate.SelfCertificationConnection__c = oldOrder.SelfCertificationConnection__c;
        orderToUpdate.RequestOption__c = oldOrder.RequestOption__c;
        orderToUpdate.MeterClass__c =oldOrder.MeterClass__c;
        orderToUpdate.PrecheckResultSII__c = oldOrder.PrecheckResultSII__c;
        orderToUpdate.Step__c = 2;
        orderToUpdate.ProcessCode__c = oldOrder.ProcessCode__c;
        orderToUpdate.WaiverRightAfterthought__c = oldOrder.WaiverRightAfterthought__c;
        orderToUpdate.HerAteco__c = oldOrder.HerAteco__c;
        orderToUpdate.AtecoCode__c = oldOrder.AtecoCode__c;
        orderToUpdate.CommentForDL__c = oldOrder.CommentForDL__c;
        orderToUpdate.PhoneNumber__c = oldOrder.PhoneNumber__c;
        orderToUpdate.RateCategory__c = oldOrder.RateCategory__c;
        orderToUpdate.WithdrawalClass__c = oldOrder.WithdrawalClass__c;
        orderToUpdate.SupplyType__c = oldOrder.SupplyType__c;
        orderToUpdate.DistributorCode__c = oldOrder.DistributorCode__c;
        orderToUpdate.PressureLevel__c = oldOrder.PressureLevel__c;
        orderToUpdate.RequestPhase__c = oldOrder.RequestPhase__c;
       // orderToUpdate.Phase__c = 'Comunicazione Verso Heroku';
        orderToUpdate.PowerRequested__c = oldOrder.PowerRequested__c;
        orderToUpdate.EnergyService__c = oldOrder.EnergyService__c;
        orderToUpdate.LiftingPeople__c = oldOrder.LiftingPeople__c;
        orderToUpdate.MeterType__c = oldOrder.MeterType__c;
        orderToUpdate.IsRemoteManaged__c = oldOrder.IsRemoteManaged__c;
        orderToUpdate.CustomerRequestDate__c = oldOrder.CustomerRequestDate__c;
        orderToUpdate.Commodity__c = oldOrder.Commodity__c;
        orderToUpdate.SubjectCode__c = oldOrder.SubjectCode__c;
        orderToUpdate.InvoiceCertifiedEmailAddress__c = oldOrder.InvoiceCertifiedEmailAddress__c;
        orderToUpdate.ElectronicInvoicingMethod__c = oldOrder.ElectronicInvoicingMethod__c;
        orderToUpdate.XMLType__c =  oldOrder.XMLType__c;
        orderToUpdate.CIG__c  = oldOrder.CIG__c;
        orderToUpdate.CUP__c  = oldOrder.CUP__c;
        orderToUpdate.IbanIsForeign__c = oldOrder.IbanIsForeign__c;
        orderToUpdate.IbanCIN_IBAN__c = oldOrder.IbanCIN_IBAN__c;
        orderToUpdate.IbanCIN__c = oldOrder.IbanCIN__c;
        orderToUpdate.IbanABI__c = oldOrder.IbanABI__c;
        orderToUpdate.IbanCAB__c = oldOrder.IbanCAB__c;
        orderToUpdate.IbanCodeNumber__c = oldOrder.IbanCodeNumber__c;
        orderToUpdate.BankAccountSignatoryFiscalCode__c = oldOrder.BankAccountSignatoryFiscalCode__c;
        orderToUpdate.BankAccountSignatoryFirstName__c = oldOrder.BankAccountSignatoryFirstName__c;
        orderToUpdate.BankAccountSignatoryLastName__c = oldOrder.BankAccountSignatoryLastName__c;
        orderToUpdate.BillSendMode__c = oldOrder.BillSendMode__c;
        orderToUpdate.PaymentMode__c = oldOrder.PaymentMode__c;
        orderToUpdate.InvoiceEmailAddress__c = oldOrder.InvoiceEmailAddress__c;
        orderToUpdate.BillingCity__c = oldOrder.BillingCity__c;
        orderToUpdate.BillingCountry__c = oldOrder.BillingCountry__c;
        orderToUpdate.BillingProvince__c = oldOrder.BillingProvince__c;
        orderToUpdate.BillingStreetName__c = oldOrder.BillingStreetName__c;
        orderToUpdate.BillingStreetNumber__c = oldOrder.BillingStreetNumber__c;
        orderToUpdate.BillingStreetNumberExtension__c = oldOrder.BillingStreetNumberExtension__c;
        orderToUpdate.BillingPostalCode__c = oldOrder.BillingPostalCode__c;
        orderToUpdate.BillingCityCode__c = oldOrder.BillingCityCode__c;
        orderToUpdate.SignatoryType__c = oldOrder.SignatoryType__c;
        orderToUpdate.SendCertifiedEmailConsentDate__c = oldOrder.SendCertifiedEmailConsentDate__c;
        orderToUpdate.CreateContractAccount__c = oldOrder.CreateContractAccount__c;
        orderToUpdate.IbanCountry__c = oldOrder.IbanCountry__c;
        orderToUpdate.isDatoDiscordante__c = true;
        orderToUpdate.Contact__c = oldOrder.Contact__c;
        orderToUpdate.OrderReference__c = oldOrder.Id;
        orderToUpdate.AggregateBilling__c = oldOrder.AggregateBilling__c;
        HDT_UTL_DatabaseService.updateSObject(orderToUpdate);
    }


    /**@frpanico 2022-07-12
     * Metodo che ritorna la fase di annullamento
     * Se la pratica e' stata gia' inviata verso Heroku
     * Deve andare in Annullamento - Da Inviare
     * Altrimenti Annullato
     */
    public static Map<String, String> checkCancellationPhase(Set<String> orderIds)
    {
        Set<String> nonSendablePhases = new Set<String>{'Amm. Precheck KO SII','Amm. Precheck OK SII', 'Esito KO da DL', 'Esito KO da SII', 'Ammissibilità KO','Dati discordanti'};
        List<Order> orderList = [SELECT Id, Phase__c, HerokuPracticeCode__c, PhaseStory__c, ProcessType__c, EffectiveDate__c FROM Order WHERE Id IN :orderIds WITH SECURITY_ENFORCED];
        Map<String, String> resultMap = new Map<String, String>();
        Boolean switchCancellationEligibility = true;
        for(Order singleOrder: orderList)
        {
            switchCancellationEligibility = (singleOrder.ProcessType__c!= null && singleOrder.ProcessType__c.containsIgnoreCase('Switch In')) ? (singleOrder.PhaseStory__c != null && singleOrder.PhaseStory__c.containsIgnoreCase('Ammissibilità OK')) : true;
            if(singleOrder.HerokuPracticeCode__c != null && !nonSendablePhases.contains(singleOrder.Phase__c) && switchCancellationEligibility)
            {
                resultMap.put(singleOrder.Id, 'Annullamento - Da Inviare');
            }
            else
            {
                resultMap.put(singleOrder.Id, 'Annullato');
            }
        }
        return resultMap;        
    }

}