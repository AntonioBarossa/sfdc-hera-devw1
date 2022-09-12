/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 04/12/2020
* @description HDT_LC_ApplyBillingProfileModal – Back-end controller for hdtApplyBillingProfileModal.js lwc component
* @history Keltin Mesonjesi – 04/12/2020 – Created class
*/
public inherited sharing class HDT_LC_ApplyBillingProfileModal {
    
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 04/12/2020
    * @description Get SBQQ__QuoteLine__c based on payment method
    * @param String saleId
    * @param String paymentMethod
    * @return Map<String, List<SBQQ__QuoteLine__c>>
    */
    @AuraEnabled
    public static Map<String, List<SBQQ__QuoteLine__c>> getQuoteLineBundle(String saleId, String paymentMethod, String sendingBillMode){
        System.debug('saleId: ' + saleId);
        System.debug('paymentMethod: ' + paymentMethod);
        System.debug('sendingBillMode: ' + sendingBillMode);

        quoteLineSrv.checkReadAccess('SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name');

        List<SBQQ__QuoteLine__c> listPodPdr = quoteLineQr.getRecordsBySaleFilteredPaymentMethodPodPdr(saleId, paymentMethod, sendingBillMode);
        System.debug('query result pod/pdr: ' + listPodPdr);
        
        
        List<SBQQ__QuoteLine__c> listVas = quoteLineQr.getRecordsBySaleFilteredPaymentMethodforVas(saleId,true);
        List<SBQQ__QuoteLine__c> listWastePoint = quoteLineQr.getRecordsBySaleFilteredPaymentMethodPodPdr(saleId, '', '');
        System.debug('query result vas: ' + listVas);
        
        //***2809 LG disattivato per problemi visibilita */
        //List<SBQQ__QuoteLine__c> listBonus =   quoteLineQr.getRecordsBySaleFilteredFamilyBonus(saleId);
        //system.debug('query result sconti: '+listBonus );
        //listBonus = getBonusPerOffer(listBonus);
        List<SBQQ__QuoteLine__c> listBonus = new List<SBQQ__QuoteLine__c>();
        /****** */
        List<SBQQ__QuoteLine__c> listVasCambioOfferta = quoteLineQr.getQuoteLinesWithCambioOfferta(saleId);
        System.debug('query result listVasCambioOfferta: ' + listVasCambioOfferta);

        Map<String, List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        if(listWastePoint!=null && !listWastePoint.isEmpty()){
            listPodPdr.addAll(listWastePoint);
        }
        quoteLineMap.put('listPodPdr', listPodPdr);
        quoteLineMap.put('listVas', listVas);
        quoteLineMap.put('listVasCambioOfferta', listVasCambioOfferta);
        quoteLineMap.put('listBonus', listBonus);

        return quoteLineMap;
    }

    public static List<SBQQ__QuoteLine__c> getBonusPerOffer(List<SBQQ__QuoteLine__c> allBonus){
        Map<id, SBQQ__QuoteLine__c> aQuoteLinePerOffer = new Map<id, SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c line : allBonus ){
            if(!aQuoteLinePerOffer.containsKey(line.SBQQ__RequiredBy__c)){
                aQuoteLinePerOffer.put(line.SBQQ__RequiredBy__c, line);
            }
        }
        return aQuoteLinePerOffer.values();
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 04/12/2020
    * @description Update SBQQ__QuoteLine__c BillingProfile__C
    * @param List<SObject> quoteLinesToUpdate
    * @param String billingProfileId
    */
    @AuraEnabled
    public static void updateQuoteLinesBillingProfile(String quoteLinesToUpdate, String billingProfileId){

        List<SObject> sobjToUpdate = new List<SObject>();

        List<HDT_WRP_QuoteLineWrp> quoteLinesWrp = (List<HDT_WRP_QuoteLineWrp>) JSON.deserialize(quoteLinesToUpdate, List<HDT_WRP_QuoteLineWrp>.class);

        for(HDT_WRP_QuoteLineWrp singleWrp : quoteLinesWrp)
        {
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.Id = singleWrp.Id;
            quoteLine.BillingProfile__c = billingProfileId;
            sobjToUpdate.add(quoteLine);
            if(singleWrp.isDueThirtyDays.equalsIgnoreCase('Si'))
            {
                BillingProfile__c billingProfile = new BillingProfile__c();
                billingProfile.id = billingProfileId;
                billingProfile.IsThirtyDaysDue__c = 'Si';
                sobjToUpdate.add(billingProfile);
            }
        }
        if(!sobjToUpdate.isEmpty())
        {
            HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
        }

        /*


        //get only ids from selected quoteLines
        Set<String> quoteLineIdsSet = (new Map<String,SObject>(quoteLinesToUpdate)).keySet().clone();

        List<String> quoteLineIdsList = new List<String>();
        quoteLineIdsList.addAll(quoteLineIdsSet);

        //get only ids from analisiConsumi quotelines
        // List<SBQQ__QuoteLine__c> analisiConsumiList = quoteLineQr.getQuoteLineAnalisiConsumi(quoteLineIdsList);

        // if (!analisiConsumiList.isEmpty()) {
        //     Set<String> quoteLineAnalisiConsumiIdsSet = (new Map<String,SObject>(analisiConsumiList)).keySet().clone();
        //     quoteLineIdsList.addAll(quoteLineAnalisiConsumiIdsSet);
        // }
        
        //update billing profile on all retrieved quoteLines
        List<SBQQ__QuoteLine__c> quoteLineListUpdate = new List<SBQQ__QuoteLine__c>();

        for (String quoteLineId : quoteLineIdsList) {
            SBQQ__QuoteLine__c quoteLineUpdate = new SBQQ__QuoteLine__c(
                Id = quoteLineId,
                BillingProfile__c = billingProfileId
            );
            quoteLineListUpdate.add(quoteLineUpdate);
        }

        quoteLineSrv.updateRecords(quoteLineListUpdate);
        */
    }

    /**@frpanico 2022-08-05
     * Il metodo ritorna le quoteline che sono elegibili per applicare il CA selezionato
     * Il metodo prende in input una mappa per permettere l'estensione degli input
     * Gli input al momento utilizzati sono
     * saleId - Id della vendita
     * selectedBillingProfile - Billing Profile Selezionato
     */
    @AuraEnabled
    public static string getEligibleQuoteLinesToApply(Map<String, Object> inputs)
    {

        String saleId = (String) inputs.get('saleId');
        BillingProfile__c selectedBillingProfile = (BillingProfile__c) JSON.deserialize((String)inputs.get('selectedBillingProfile'), BillingProfile__c.class);
        String paymentMethod = selectedBillingProfile.get('PaymentMethod__c') != null ? (String) selectedBillingProfile.get('PaymentMethod__c') : '';
        String sendingBillMode = selectedBillingProfile.get('BillSendingMethod__c') != null ? (String) selectedBillingProfile.get('BillSendingMethod__c') : '';
        //String invoicingCity = selectedBillingProfile.get('InvoicingCity__c') != null ? (String) selectedBillingProfile.get('InvoicingCity__c') : '';
        Boolean isDueThirtyDays = selectedBillingProfile.get('IsThirtyDaysDue__c') != null && ((String)selectedBillingProfile.get('IsThirtyDaysDue__c')).equalsIgnoreCase('Si');
        List<SBQQ__QuoteLine__c> quoteLineWater = new List<SBQQ__QuoteLine__c>();
        //List<SBQQ__QuoteLine__c> quoteLineWaste = new List<SBQQ__QuoteLine__c>();
        List<HDT_WRP_QuoteLineWrp> quoteLineToApply = new List<HDT_WRP_QuoteLineWrp>();
        /* La query recupera tutte le quotline "child" associate alle quote create */
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name,SBQQ__Product__r.Name, SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Name,
        SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Name,  SBQQ__ProductFamily__c,
        SBQQ__RequiredBy__r.BillingProfile__c, SBQQ__RequiredBy__r.BillingProfile__r.Name,
        ServicePoint__c,ServicePoint__r.ServicePointCode__c, ServicePoint__r.CommoditySector__c, ServicePoint__r.ATO__c,
        SBQQ__Quote__r.ContractReference__c, SBQQ__Quote__r.AllowChangeUse__c, SBQQ__Quote__r.AmendmentAllowed__c,SBQQ__Quote__r.ContractReference__r.BillingProfile__c
        FROM SBQQ__QuoteLine__c
        WHERE SBQQ__Quote__r.Sale__c = :saleId
        AND 
        (
            (
            SBQQ__Product__r.Name IN ('POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente')
            AND ( SBQQ__RequiredBy__r.PaymentMode__c = :paymentMethod  OR SBQQ__RequiredBy__r.PaymentMode__c = NULL)
            AND ( SBQQ__RequiredBy__r.SendingBillMode__c = :sendingBillMode OR SBQQ__RequiredBy__r.SendingBillMode__c = NULL)
            )
            OR
            (
                (
                    (SBQQ__Quote__r.ContractReference__c = null OR SBQQ__Quote__r.OrderReference__c = null) 
                    OR 
                    (SBQQ__Quote__r.ContractReference__c != null 
                    AND (SBQQ__Quote__r.AllowChangeUse__c = null OR SBQQ__Quote__r.AllowChangeUse__c = false)
                    AND (SBQQ__Quote__r.AmendmentAllowed__c = null OR SBQQ__Quote__r.AmendmentAllowed__c = false)
                    )
                )
            AND SBQQ__Product__r.Name NOT IN ('POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente')
            AND SBQQ__ProductFamily__c IN('VAS Fatturabili','VAS Prodotto','VAS Servizio')
         )
        )
        AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected') 
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate ASC];

        
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {

            if(quoteLine.SBQQ__Product__r.Name.equalsIgnoreCase('Punto Fornitura Acqua'))
            {
                quoteLineWater.add(quoteLine);
                continue;
            }
            quoteLineToApply.add(new HDT_WRP_QuoteLineWrp(quoteLine));
        }

        /**Logica per acqua
         * Si controlla l'ATO della quoteLine
         * Se non e' pari ad ATO1 o ATO9 viene controllato il campo 'Scadenza 30 gg' sul BillingProfile se e' a 'Si' la QL non e' selezionabile
         * Se e' pari ad ATO1 o ATO9 viene impostato un flag sull'oggetto di ritorno in modo che all'applicazione venga impostato a 'Si' il campo 'Scandeza 30 gg'
         */
        if(!quoteLineWater.isEmpty())
        {
            for(SBQQ__QuoteLine__c quoteLine : quoteLineWater)
            {
                if(quoteLine.ServicePoint__c == null)
                {
                    continue;
                }
                String ato = quoteLine.ServicePoint__r.ATO__c != null ? quoteLine.ServicePoint__r.ATO__c : '';
                Boolean isAtoOneAtoNine = ato.containsIgnoreCase('ATO1') || ato.containsIgnoreCase('ATO9');
                if(isAtoOneAtoNine && !isDueThirtyDays)
                {
                    HDT_WRP_QuoteLineWrp singleApply = new HDT_WRP_QuoteLineWrp(quoteLine);
                    singleApply.isDueThirtyDays = 'Si';
                    continue;
                }
                if(isAtoOneAtoNine && isDueThirtyDays)
                {
                    quoteLineToApply.add(new HDT_WRP_QuoteLineWrp(quoteLine));
                    continue;
                }
                if(!isAtoOneAtoNine && !isDueThirtyDays)
                {
                    quoteLineToApply.add(new HDT_WRP_QuoteLineWrp(quoteLine));
                    continue;
                }

            }
        }

        return JSON.serialize(quoteLineToApply);
    }


    class HDT_WRP_QuoteLineWrp
    {
        public HDT_WRP_QuoteLineWrp(SBQQ__QuoteLine__c quoteLine)
        {
            Boolean isVas = quoteLine.SBQQ__ProductFamily__c.containsIgnoreCase('Vas') || quoteLine.SBQQ__ProductFamily__c.equalsIgnoreCase('Analisi Consumi');

            this.id = isVas ? quoteLine.Id : quoteLine.SBQQ__RequiredBy__c != null ? quoteLine.SBQQ__RequiredBy__c : quoteLine.Id;
            this.name = isVas ? quoteLine.Name : quoteLine.SBQQ__RequiredBy__c != null ? quoteLine.SBQQ__RequiredBy__r.Name : quoteLine.Name;
            this.billingProfileName = quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.BillingProfile__c != null ? quoteLine.SBQQ__RequiredBy__r.BillingProfile__r.Name : '';
            this.pod = quoteLine.ServicePoint__c != null && quoteLine.ServicePoint__r.ServicePointCode__c != null ? quoteLine.ServicePoint__r.ServicePointCode__c : '';
            this.productName = isVas ? quoteLine.SBQQ__Product__r.Name : quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.SBQQ__Product__c != null ? quoteLine.SBQQ__RequiredBy__r.SBQQ__Product__r.Name : '';
            this.isDueThirtyDays = '';
            this.isCambioOfferta = quoteLine.SBQQ__Quote__r.ContractReference__c != null && (quoteLine.SBQQ__Quote__r.AllowChangeUse__c == null || !quoteLine.SBQQ__Quote__r.AllowChangeUse__c) && (quoteLine.SBQQ__Quote__r.AmendmentAllowed__c == null || !quoteLine.SBQQ__Quote__r.AmendmentAllowed__c);
            this.previousBillingProfile = quoteLine.SBQQ__Quote__r.ContractReference__c != null && quoteLine.SBQQ__Quote__r.ContractReference__r.BillingProfile__c != null ? quoteLine.SBQQ__Quote__r.ContractReference__r.BillingProfile__r.Name : ''; 
        }
        public HDT_WRP_QuoteLineWrp()
        {
            this.id = '';
            this.name = '';
            this.billingProfileName = '';
            this.pod = '';
            this.productName = '';
            this.isDueThirtyDays = '';
            this.isCambioOfferta = false;
            this.previousBillingProfile = '';
            
        }
        public string id {get; set;}
        public String name {get; set;}
        public String billingProfileName {get; set;}
        public String pod {get; set;}
        public String productName {get; set;}
        public String isDueThirtyDays {get; set;}
        public Boolean isCambioOfferta {get; set;}
        public String previousBillingProfile {get; set;}
    }   

}