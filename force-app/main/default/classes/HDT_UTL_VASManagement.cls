/**
 * @description       : Generating requests for activating/disactivating VAS
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-07-12
 * @last modified by  : gabriele.rota@webresults.it
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2021-07-12   gabriele.rota@webresults.it   Initial Version
**/
public with sharing class HDT_UTL_VASManagement {

    /**
    * @description Generates VAS activation request
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param orderId 
    * @return HDT_WRP_VASActivationReq 
    **/
    public static HDT_WRP_VASActivationReq getActivationRequest(Id orderId) {

        //getting request data
        Order currentOrder = [SELECT SalesCompany__c, ContractAccountCode__c, CustomerCode__c, CustomerFiscalCode__c, CustomerVATNumber__c,
            ServicePointCode__c, CustomerName__c, CustomerLastName__c, CommercialProduct__c, CommercialProductVersion__c, OrderNumber,
            VasServiceActivationDate__c, SBQQ__Quote__r.SBQQ__ListAmount__c,
            SBQQ__Quote__r.SBQQ__TotalCustomerDiscountAmount__c, ShippingStreetToponym__c, ShippingStreetName__c, ShippingStreetNumber__c,
            ShippingCity__c, ShippingPlace__c, ShippingPostalCode__c, PhoneNumber__c, ShippingMail__c, SignedDate__c,
            (SELECT Product2.Name, Quantity, PriceNet__c, PriceNetDiscounted__c, Percentage__c FROM OrderItems)
            FROM Order WHERE Id = :orderId];

        //building request
        HDT_WRP_VASActivationReq actReq = new HDT_WRP_VASActivationReq(currentOrder);

        return actReq;
    }

    /**
    * @description Generates VAS disactivation request
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param orderId 
    * @return HDT_WRP_VASActivationReq 
    **/
    public static HDT_WRP_VASDisactivationReq getDisactivationRequest(Id orderId) {

        //getting request data
        Order currentOrder = [SELECT SalesCompany__c, ContractAccountCode__c, CustomerCode__c, CustomerFiscalCode__c, CustomerVATNumber__c,
            ServicePointCode__c, CustomerName__c, CustomerLastName__c, CommercialProduct__c, CommercialProductVersion__c, OrderNumber,
            VasServiceActivationDate__c, SBQQ__Quote__r.SBQQ__ListAmount__c,
            SBQQ__Quote__r.SBQQ__TotalCustomerDiscountAmount__c, ShippingStreetToponym__c, ShippingStreetName__c, ShippingStreetNumber__c,
            ShippingCity__c, ShippingPlace__c, ShippingPostalCode__c, PhoneNumber__c, ShippingMail__c, SignedDate__c,
            (SELECT Product2.Name, Quantity, PriceNet__c, PriceNetDiscounted__c, Percentage__c FROM OrderItems)
            FROM Order WHERE Id = :orderId];

        //building request
        HDT_WRP_VASDisactivationReq disactReq = new HDT_WRP_VASDisactivationReq(currentOrder);

        return disactReq;
    }

    public virtual class HDT_WRP_VASReq{
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

        public HDT_WRP_VASReq(Order currentOrder) {
            societa = currentOrder.SalesCompany__c;
            partner = currentOrder.CustomerCode__c;
            codFiscale = currentOrder.CustomerFiscalCode__c;
            partitaIva = currentOrder.CustomerVATNumber__c;
            pod = currentOrder.ServicePointCode__c;
            intestatario = currentOrder.CustomerName__c+' '+currentOrder.CustomerLastName__c;
            servizioIp = currentOrder.CommercialProduct__c;
            versione = currentOrder.CommercialProductVersion__c;
            keyServizio = currentOrder.OrderNumber;
            //dataCessazione = ???;
        }
    }

    public class HDT_WRP_VASDisactivationReq extends HDT_WRP_VASReq{
        String nrContrattoIp;
        String numDocRif;
        String statoPratica;

        public HDT_WRP_VASDisactivationReq(Order currentOrder) {
            super(currentOrder);

            //TODO: adding fields mapping
        }
    }

    public class HDT_WRP_VASActivationReq extends HDT_WRP_VASReq{
        
        String contractAccountSap;
        Date dataAttivazione;
        Integer nrRate;
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
        Integer durataServizioGg;
        Boolean isContCambioOfferta;
        String modalitaPagamento;
        String rfid;
        Boolean isVasStandAlone;
        Boolean isVasOmaggio;

        List<HDT_WRP_VASActivationReqItem> items;

        public HDT_WRP_VASActivationReq(Order currentOrder) {
            super(currentOrder);

            contractAccountSap = currentOrder.ContractAccountCode__c;
            dataAttivazione = currentOrder.VasServiceActivationDate__c;

            //nrRate = Product2.NumberRateMonthly__c

            importo = currentOrder.SBQQ__Quote__r.SBQQ__ListAmount__c;
            importoIvaInclusa = currentOrder.SBQQ__Quote__r.SBQQ__ListAmount__c; //+IVA__c
            scontoIvaInclusa = currentOrder.SBQQ__Quote__r.SBQQ__TotalCustomerDiscountAmount__c; //+IVA__c

            indirizzoSpedizione = currentOrder.ShippingStreetToponym__c;
            indirizzoSpedizione += ' '+currentOrder.ShippingStreetName__c;
            indirizzoSpedizione += ' '+currentOrder.ShippingStreetNumber__c;
            indirizzoSpedizione += ' '+currentOrder.ShippingCity__c;
            indirizzoSpedizione += ' '+currentOrder.ShippingPlace__c;
            indirizzoSpedizione += ' '+currentOrder.ShippingPostalCode__c;

            city1 = currentOrder.ShippingCity__c;
            postCode1 = currentOrder.ShippingPostalCode__c;
            region = currentOrder.ShippingProvince__c;
            telefono = currentOrder.PhoneNumber__c;
            mail = currentOrder.ShippingMail__c;

            //perio = ???;
            //modalitaFatturazione = OrderItem.BillingMode__c

            //dataDecorrenza = OrderItem.VasActivationDate__c
        
            dataFirma = currentOrder.SignedDate__c;

            //vincoloPermanenza = FORSE OrderItem.DurationVas__c

            //durataServizioGg = OrderItem.DurationDay__c

            //isContCambioOfferta = currentOrder.ContractReference__c ???

            //modalitaPagamento = OrderItem.PaymentMode__c
            //rfid = ???
            //isVasStandAlone = ???
            //isVasOmaggio = ???

            items = new List<HDT_WRP_VASActivationReqItem>();
            for (OrderItem ordItem:currentOrder.OrderItems) {
                HDT_WRP_VASActivationReqItem reqItem = new HDT_WRP_VASActivationReqItem(ordItem);
                items.add(reqItem);
            }
        }
    }

    public class HDT_WRP_VASActivationReqItem{
        String ItemProdotto;
        Decimal Quantita;
        Decimal PrezzoNetto;
        Decimal PrezzoNettoScontato;
        Decimal PercentualeIva;

        public HDT_WRP_VASActivationReqItem(OrderItem ordItem) {
            ItemProdotto = ordItem.Product2.Name;
            Quantita = ordItem.Quantity;
            PrezzoNetto = ordItem.PriceNet__c;
            PrezzoNettoScontato = ordItem.PriceNetDiscounted__c;
            PercentualeIva = ordItem.Percentage__c;
        }
    }
}
