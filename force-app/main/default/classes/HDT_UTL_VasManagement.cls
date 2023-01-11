/**
 * @description       : Generating requests for activating/disactivating VAS
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-07-29
 * @last modified by  : gabriele.rota@webresults.it
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2021-07-12   gabriele.rota@webresults.it   Initial Version
**/
public with sharing class HDT_UTL_VasManagement {

    private static final String VAS_STANDALONE_PRICEBOOK = 'VAS STANDALONE';

    /**
    * @description Generates VAS activation request
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param orderId  
    * @return HDT_WRP_VASActivationReq 
    **/
    public static HDT_WRP_VASActivationReq getActivationRequest(Id orderId) {
        Order currentOrder = getOrderData(orderId);
        HDT_WRP_VASActivationReq actReq = new HDT_WRP_VASActivationReq(currentOrder);
        return actReq;
    }

    /**
    * @description Generates VAS deactivation request
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param caseId 
    * @return HDT_WRP_VASDisactivationReq 
    **/
    public static HDT_WRP_VASDisactivationReq getDeactivationRequest(Id sobjId) {
        Boolean queryExc = false;
        HDT_WRP_VASDisactivationReq disactReq;
        Order currentOrder = new Order();
        Map<String,Object> requestMap = new Map<String,Object>();
        String objectName = ((Id) sobjId).getSobjectType().getDescribe().getName();
        Id orderId;
        Case currentCase;
        switch on objectName{
            when 'Case'{
                Id caseId = sobjId;
                currentCase = [SELECT Account.CustomerCode__c, CaseNumber, VasStatus__c, Order__c, Asset.SBQQ__OrderProduct__r.OrderId,
                Subscription__r.SBQQ__Contract__r.SBQQ__Order__c, Asset.VasPracticeCode__c,Subscription__r.VasPracticeCode__c, 
                Subscription__r.SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c,  Subscription__r.SBQQ__Contract__r.ContractSalesCompany__c,
                Account.FirstName__c, Account.LastNameRcuFormula__c, Account.FiscalCode__c, Account.VATNumber__c, Subscription__r.SBQQ__ProductName__c,
                Subscription__r.Version__c,Subscription__r.SBQQ__Contract__r.SAPContractCode__c,Subscription__r.SBQQ__Product__r.DescriptionSAP__c
                FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
            
                orderId = currentCase.Order__c;
                if (String.isBlank(orderId)) {
                    orderId = currentCase.Asset.SBQQ__OrderProduct__r.OrderId;
                }
                if (String.isBlank(orderId)) {
                    orderId = currentCase.Subscription__r.SBQQ__Contract__r.SBQQ__Order__c;
                }
            }when 'Order'{
                orderId=sobjId;
                currentCase= new Case(VasStatus__c='ANNUL PER RIPENS');
            }
        }
        try
        {
            currentOrder = getOrderData(orderId);
        }
        catch(Exception e)
        {
            queryExc = true;
            requestMap.put('partner',currentCase.Account.CustomerCode__c);
            requestMap.put('codFiscale',currentCase.Account?.FiscalCode__c);
            requestMap.put('partitaIva',currentCase.Account?.VATNumber__c);
            requestMap.put('pod',currentCase.Subscription__r.SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c);
            requestMap.put('intestatario','');
            requestMap.put('servizioIp',(currentCase.Subscription__r.SBQQ__Product__r.DescriptionSAP__c).abbreviate(30));
            requestMap.put('versione',currentCase.Subscription__r.Version__c);
            requestMap.put('nrContrattoIp',currentCase.Subscription__r.SBQQ__Contract__r.SAPContractCode__c);
            requestMap.put('statoPratica',currentCase.VasStatus__c);
            String keyString = (String)currentCase.getSObject('Asset')?.get('VasPracticeCode__c')!= null 
            ? (String)currentCase.getSObject('Asset')?.get('VasPracticeCode__c')
            : (String)currentCase.getSObject('Subscription__r')?.get('VasPracticeCode__c') != null
                ? (String)currentCase.getSObject('Subscription__r')?.get('VasPracticeCode__c')
                : (String)currentOrder.get('VasPracticeCode__c');
            requestMap.put('keyServizio', keyString);
        }
        if(queryExc)
        {
            disactReq = new HDT_WRP_VASDisactivationReq(requestMap);
        }
        else
        {
            disactReq = new HDT_WRP_VASDisactivationReq(currentOrder, currentCase);
        }
        return disactReq;
    }

    /**
    * @description Query on Order object and related records
    * @author gabriele.rota@webresults.it | 2021-07-13 
    * @param orderId 
    * @return Order 
    **/
    private static Order getOrderData(Id orderId) {
        //TODO: move query in HDT_QR_Order class
        return [SELECT Account.CustomerCode__c, SalesCompany__c, ContractAccountCode__c, CustomerCode__c, CustomerFiscalCode__c, CustomerVATNumber__c,
            ServicePointCode__c, SalesCompanyCode__c, CustomerName__c, CustomerLastName__c, CommercialProduct__c,CommercialProductCode__c, CommercialProductVersion__c,
            OrderNumber, VasServiceActivationDate__c, ShippingStreetToponym__c, ShippingStreetName__c, ShippingStreetNumber__c,
            ShippingCity__c, ShippingPlace__c, ShippingPostalCode__c, ShippingProvince__c, PhoneNumber__c, ShippingMail__c, SignedDate__c,
            ContractReference__r.SAPContractCode__c,OrderReference__c,ContractReference__c,ContractReference__r.ServicePoint__r.ServicePointCode__c,
            OrderReference__r.ServicePointCodeFormula__c,SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Quote__r.SBQQ__TotalCustomerDiscountAmount__c,
            SBQQ__Quote__r.SBQQ__PriceBook__r.Name, SBQQ__Quote__r.ListAmountVAT__c, SBQQ__Quote__r.TotalDiscountAmountVAT__c,
            CommercialProductLink__r.FreeVas__c, CommercialProductLink__r.DurationDay__c, CommercialProductLink__r.DurationDayGas__c, VasPracticeCode__c, TotalAmount,
            (SELECT Quantity, UnitPrice, ListPrice, PriceNet__c, PriceNetDiscounted__c, Percentage__c, VASBillingMode__c, SBQQ__RequiredBy__c, VasActivationDate__c,
                DurationDay__c, PaymentMode__c, Product2.IVA__c,
                Product2.Name, Product2.NumberRateMonthly__c, Product2.DescriptionSAP__c,DelayEffectiveDate__c, Product2.DurationVas__c, Product2.WaitingPeriod__c
                FROM OrderItems)
            FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED];
    }

    /**
    * @description Join given string values e.g. ["Mickey","Mouse"] => "Mickey Mouse"
    * @author gabriele.rota@webresults.it | 2021-07-13 
    * @param strValues 
    * @return String 
    **/
    private static String joinStringValues(List<String> strValues) {
        List<String> finalStrValues = new List<String>();
        for (String strValue:strValues) {
            if (String.isNotBlank(strValue)) {
                finalStrValues.add(strValue);
            }
        }
        return String.join(finalStrValues, ' ');
    }

    /**
    * @description Get company code from company name
    * @author federico.defelice@webresults.it | 2021-07-13 
    * @param salesCompany 
    * @return String 
    **/
    private static String getCompanyCode(String salesCompany, String servicePointCode){
        if(String.isBlank(servicePointCode) && String.isBlank(salesCompany)){
            return null;
        }else if(String.isNotBlank(salesCompany)){
            List<HDT_HeraCompany__mdt> companies = [select CompanyCode__c from HDT_HeraCompany__mdt where SalesCompany__c=:salesCompany WITH SECURITY_ENFORCED];
            return companies.isEmpty()? null : companies?.get(0)?.CompanyCode__c; 
        }
        else{
            List<ServicePoint__c> lpc = [Select Vendor__c from ServicePoint__c where ServicePointCode__c=:servicePointCode WITH SECURITY_ENFORCED LIMIT 1 ];
            if(lpc.size()>0){
                List<HDT_HeraCompany__mdt> companies = [select CompanyCode__c from HDT_HeraCompany__mdt where SalesCompany__c=:lpc[0].Vendor__c WITH SECURITY_ENFORCED];
                return companies.isEmpty()? null : companies?.get(0)?.CompanyCode__c;
            }
        }
        
        return null;
    }

    public static String updateVasPhase(string vasPhase, Order ord ) {
//.equalsIgnoreCase
        String newPhase = '';
        if ( vasPhase == 'Esportazione VS Siebel'){
            newPhase = vasPhase;
        }
        else if ( ord.ComfortCallDaysDue__c != null){
            newPhase = 'In attesa conferma cliente';
        }
        else if ( ord.VASType__c == 'VAS Servizio' && !ord.IsEarlyActivation__c ){
            newPhase =  'In attesa tempi di ripensamento';
        }else if( ord.VASType__c == 'VAS Fatturabili' ){
            newPhase = 'Comunicazione verso Heroku';
        }else{
            newPhase =  'Comunicazione Motore VAS';
        }
        /*Order orderToUpdate = new Order();
        orderToUpdate.Id = ord.Id;
        orderToUpdate.Phase__c = newPhase;
        HDT_UTL_DatabaseService.updateSObject(orderToUpdate);
        if(newPhase.equalsIgnoreCase('Comunicazione verso Heroku') || newPhase.equalsIgnoreCase('Comunicazione Motore VAS'))
        {
            Schedulable instance = (Schedulable) wrts_prcgvr.VersionManager.newClassInstance('AsyncJobBatchSchedule');
            instance.execute(null);
        }*/

        /* Platform Event non sembra partire correttamente */
        /*HDT_PEV_VoltureChangeManagerUpdateSObj__e platEvent = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
        platEvent.SerializedSobj__c = JSON.serialize(orderToUpdate);
        Database.SaveResult sr = Eventbus.publish(platEvent);*/

        return newPhase;

    }

    /**
    * @description Class for common fields of activation/deactivation requests
    * @author gabriele.rota@webresults.it | 2021-07-13 
    **/
    public virtual class HDT_WRP_VasReq extends HDT_WS_Request{
        String societa;
        String partner;
        String codFiscale;
        String partitaIva;
        String pod;
        String intestatario;
        String servizioIp;
        String versione;
        String keyServizio;
        Date dataCessazione;

        /**
        * @description Constructor with order
        * @author gabriele.rota@webresults.it | 2021-07-13 
        * @param currentOrder 
        **/
        public HDT_WRP_VASReq(){ societa = '';}
        public HDT_WRP_VASReq(Order currentOrder) {
            societa = getCompanyCode(currentOrder.SalesCompany__c, currentOrder.ServicePointCode__c);
            //societa = currentOrder.SalesCompanyCode__c;
            partner = currentOrder.Account.CustomerCode__c;
            codFiscale = currentOrder.CustomerFiscalCode__c;
            partitaIva = currentOrder.CustomerVATNumber__c;
            if(String.isNotBlank(currentOrder.ServicePointCode__c)){
                pod = currentOrder.ServicePointCode__c;
            }else if(currentOrder.OrderReference__c!=null){
                pod = currentOrder.OrderReference__r.ServicePointCodeFormula__c;
            }else if(currentOrder.ContractReference__c!=null){
                pod = currentOrder.ContractReference__r.ServicePoint__r?.ServicePointCode__c;
            }

            List<String> strValues = new List<String>{currentOrder.CustomerName__c, currentOrder.CustomerName__c};
            intestatario = '';

            //servizioIp = currentOrder.CommercialProductCode__c?.abbreviate(30);
            versione = currentOrder.CommercialProductVersion__c?.split('\\.\\d+')[0];
            keyServizio = currentOrder.OrderNumber;

            //dataCessazione = null
        }

        /**
        * @description Constructor with order and case
        * @author gabriele.rota@webresults.it | 2021-07-13 
        * @param currentOrder 
        **/
        public HDT_WRP_VASReq(Order currentOrder, Case currentCase) {
            this(currentOrder);
            //this.keyServizio = currentCase.CaseNumber;
        }
    }

    /**
    * @description Class for deactivation specific fields
    * @author gabriele.rota@webresults.it | 2021-07-13 
    **/
    public class HDT_WRP_VasDisactivationReq extends HDT_WRP_VASReq{
        String nrContrattoIp;
        String numDocRif;
        String statoPratica;
        Date dataDecorrenza;//temp 01/20/21

        /**
        * @description Constructor with order and case
        * @author gabriele.rota@webresults.it | 2021-07-13 
        * @param currentOrder 
        **/
        public HDT_WRP_VASDisactivationReq(Order currentOrder, Case currentCase) {
            super(currentOrder, currentCase);
            /**@frpanico 03/03/2022
             * Fix keyServizio
             */
            String keyString = (String)currentCase.getSObject('Asset')?.get('VasPracticeCode__c')!= null 
            ? (String)currentCase.getSObject('Asset')?.get('VasPracticeCode__c')
            : (String)currentCase.getSObject('Subscription__r')?.get('VasPracticeCode__c') != null
                ? (String)currentCase.getSObject('Subscription__r')?.get('VasPracticeCode__c')
                : (String)currentOrder.get('VasPracticeCode__c');

            OrderItem parentOrderItem;
            for (OrderItem ordItem:currentOrder.OrderItems) {
                if (String.isBlank(ordItem.SBQQ__RequiredBy__c)) {
                    parentOrderItem = ordItem;
                    break;
                }
            }
            servizioIp = parentOrderItem.Product2.DescriptionSAP__c.abbreviate(30);
            

            keyServizio = keyString;

            nrContrattoIp = currentOrder.ContractReference__r?.SAPContractCode__c;

            //numDocRif = null
            statoPratica = currentCase.VasStatus__c;

            dataCessazione = Date.today();

            dataDecorrenza = Date.today();//temp 01/20/21
            
        }

        public HDT_WRP_VASDisactivationReq(Map<String,Object> requestMap)
        {
            societa = getCompanyCode((String) requestMap.get('societa'),(String)requestMap.get('pod'));
            partner = (String)requestMap.get('partner');
            codFiscale = (String)requestMap.get('codFiscale');
            partitaIva = (String)requestMap.get('partitaIva');
            pod = (String)requestMap.get('pod');
            intestatario = '';
            servizioIp = (String)requestMap.get('servizioIp');
            versione = (String)requestMap.get('versione');
            dataCessazione = Date.today();
            nrContrattoIp = (String)requestMap.get('nrContrattoIp');
            statoPratica = (String)requestMap.get('statoPratica');
            keyServizio = (String)requestMap.get('keyServizio');
            dataDecorrenza = Date.today();
        }
    }

    /**
    * @description Class for activation specific fields
    * @author gabriele.rota@webresults.it | 2021-07-13 
    **/
    public class HDT_WRP_VasActivationReq extends HDT_WRP_VASReq{
        
        String contractAccountSap;
        Date dataAttivazione;
        Decimal nrRate;
        Decimal importo;
        Decimal importoIvaInclusa;
        Decimal scontoIvaInclusa;
        String indirizzoSpedizione;
        String city1;
        String postCode1;
        String region;
        String telefono;
        String mail;
        String perio;
        String modalitaFatturazione;
        Date dataDecorrenza;
        Date dataFirma;
        String vincoloPermanenza;
        Decimal durataServizioGg;
        Boolean isContCambioOfferta;
        String modalitaPagamento;
        String rfid;
        Boolean isVasStandAlone;
        Boolean isVasOmaggio;

        List<HDT_WRP_VASActivationReqItem> items;

        /**
        * @description Constructor with order
        * @author gabriele.rota@webresults.it | 2021-07-13 
        * @param currentOrder 
        **/
        public HDT_WRP_VASActivationReq(Order currentOrder) {
            super(currentOrder);

            OrderItem parentOrderItem;
            List<OrderItem> childOrderItems = new List<OrderItem>();
            items = new List<HDT_WRP_VASActivationReqItem>();
            for (OrderItem ordItem:currentOrder.OrderItems) {
                if (String.isBlank(ordItem.SBQQ__RequiredBy__c)) {
                    parentOrderItem = ordItem;
                    continue;
                }
                HDT_WRP_VASActivationReqItem reqItem = new HDT_WRP_VASActivationReqItem(ordItem);
                items.add(reqItem);
                childOrderItems.add(ordItem);
            }
            servizioIp = parentOrderItem.Product2.DescriptionSAP__c.abbreviate(30);
            contractAccountSap = currentOrder.ContractAccountCode__c;
            dataAttivazione = String.isNotBlank(currentOrder.VasServiceActivationDate__c?.format())? currentOrder.VasServiceActivationDate__c : Date.today();
            Decimal tempRate = parentOrderItem?.Product2?.NumberRateMonthly__c ;
            nrRate = tempRate!=null? tempRate : 0;
            
            Decimal totaleNoScontoIva = 0.0;
            Decimal totaleScontoIva = currentOrder.TotalAmount != null ? currentOrder.TotalAmount : 0.0;
            Decimal iva = 0.0;
            for(OrderItem item : childOrderItems)
            {
                totaleNoScontoIva += (item.ListPrice  * item.Quantity);
                if(currentOrder.TotalAmount == null)
                {
                    totaleScontoIva += (item.UnitPrice * item.Quantity);
                }
                if((Decimal)item.getSobject('Product2').get('IVA__c') != null && (Decimal)item.getSobject('Product2').get('IVA__c') != 0.0 && iva == 0.0)
                {
                    iva = (Decimal)item.getSobject('Product2').get('IVA__c');
                }
            }
            Decimal percentualIva = iva/100.0;
            totaleNoScontoIva += (totaleNoScontoIva * percentualIva);
            totaleScontoIva += (totaleScontoIva * percentualIva);
            importo = totaleNoScontoIva.setScale(2);
            importoIvaInclusa = totaleScontoIva.setScale(2);
            scontoIvaInclusa = (totaleNoScontoIva - totaleScontoIva).setScale(2);
            
            /*
            importo = currentOrder.SBQQ__Quote__r?.SBQQ__ListAmount__c;
            importoIvaInclusa = currentOrder.SBQQ__Quote__r?.ListAmountVAT__c;
            scontoIvaInclusa = currentOrder.SBQQ__Quote__r?.TotalDiscountAmountVAT__c;
            */
            List<String> strValues = new List<String>{
                currentOrder.ShippingStreetToponym__c,
                currentOrder.ShippingStreetName__c,
                currentOrder.ShippingStreetNumber__c,
                currentOrder.ShippingCity__c,
                currentOrder.ShippingPlace__c,
                currentOrder.ShippingPostalCode__c
            };
            indirizzoSpedizione = joinStringValues(strValues);

            city1 = currentOrder.ShippingCity__c;
            postCode1 = currentOrder.ShippingPostalCode__c;
            region = currentOrder.ShippingProvince__c;
            telefono = currentOrder.PhoneNumber__c;
            mail = currentOrder.ShippingMail__c;
            modalitaFatturazione = parentOrderItem?.VASBillingMode__c?.substring(0,1);
            dataDecorrenza = parentOrderItem?.VasActivationDate__c != null ? parentOrderItem?.VasActivationDate__c : parentOrderItem?.DelayEffectiveDate__c;
            dataFirma = currentOrder.SignedDate__c;
            durataServizioGg = parentOrderItem?.DurationDay__c;
            // if(currentOrder.CommercialProductLink__r.DurationDay__c > 0){
            //     dataCessazione = dataAttivazione.addDays((Integer)currentOrder.CommercialProductLink__r.DurationDay__c);
            // }else if(currentOrder.CommercialProductLink__r.DurationDayGas__c > 0){
            //     dataCessazione = dataAttivazione.addDays((Integer)currentOrder.CommercialProductLink__r.DurationDayGas__c);
            // }else{
            //     dataCessazione = Date.newInstance(3999, 12, 31);
            // }
            if(parentOrderItem.Product2.DurationVas__c != null && parentOrderItem.Product2.DurationVas__c > 0){
                dataCessazione = dataAttivazione.addDays((Integer)parentOrderItem.Product2.DurationVas__c);
            }
            else{
                dataCessazione = Date.newInstance(3999, 12, 31);
            }

            if(parentOrderItem.Product2.WaitingPeriod__c!= null && parentOrderItem.Product2.WaitingPeriod__c  > 0){
                dataDecorrenza = dataAttivazione.addDays((Integer)parentOrderItem.Product2.WaitingPeriod__c);
            }
            else{
                dataDecorrenza = dataAttivazione;
            }
            


            //modalitaPagamento = parentOrderItem?.PaymentMode__c;
            
            isVasStandAlone = (currentOrder.SBQQ__Quote__r?.SBQQ__PriceBook__r?.Name?.toUpperCase() == VAS_STANDALONE_PRICEBOOK);
            
            //perio = null
            //vincoloPermanenza = null
            //rfid = null

            //isContCambioOfferta = currentOrder.ContractReference__c ???
            isVasOmaggio = currentOrder?.CommercialProductLink__r?.FreeVas__c;
        }
    }

    /**
    * @description Class for activation request items (loop on order items)
    * @author gabriele.rota@webresults.it | 2021-07-13 
    **/
    public class HDT_WRP_VasActivationReqItem{
        String ItemProdotto;
        Decimal Quantita;
        Decimal PrezzoNetto;
        Decimal PrezzoNettoScontato;
        Decimal PercentualeIva;

        /**
        * @description Constructor with order item
        * @author gabriele.rota@webresults.it | 2021-07-13 
        * @param currentOrder 
        **/
        public HDT_WRP_VASActivationReqItem(OrderItem ordItem) {
            ItemProdotto = ordItem.Product2?.DescriptionSAP__c?.abbreviate(33)?.removeEnd('...');
            Quantita = ordItem.Quantity;
            PrezzoNetto = ordItem.ListPrice;
            PrezzoNettoScontato = ordItem.UnitPrice;
            PercentualeIva = ordItem.Product2.IVA__c != null ? ordItem.Product2.IVA__c : 0.0;
        }
    }
}