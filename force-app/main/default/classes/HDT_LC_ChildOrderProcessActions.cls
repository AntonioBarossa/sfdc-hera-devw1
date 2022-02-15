/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 15/02/2021
 * @description HDT_LC_ChildOrderProcessActions.cls - Class that holds methods that are called from hdtChildOrderProcessActions.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveParameterList, PMD.NcssMethodCount')
public inherited sharing class HDT_LC_ChildOrderProcessActions {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_ServicePoint servicePointSrv= new HDT_SRV_ServicePoint();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_ContentDocumentLink contDocLinkQr = new HDT_QR_ContentDocumentLink();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtils = new HDT_UTL_VoltureChangeUtilities();
    private static String emptyEmailDefault = 'mailnondisponibile@acquirenteunico.it';

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 15/02/2021
     * @description Execute child order process save actions
     * @param order
     * @param lastStepData
     */
    @AuraEnabled
    public static void save(Order order, Map<String,Object> lastStepData){

        /**@frpanico 25/10/2021
         * Get Current Order to perform cross check with the "orderToUpdate"
         */
        Order currentOrder = orderQr.getRecordById(order.Id);
        Order orderToUpdate = new Order();
        Contract contractReference = new Contract();
        orderToUpdate.Id = order.Id;
        orderToUpdate.Status = 'In lavorazione';
        //EVERIS: Aggiunto caso Voltura
        orderToUpdate.Phase__c = 'Da Inviare'; 
        orderToUpdate.Step__c = 20;
        orderToUpdate.WizardCompletedDate__c = Date.today();
        
        /**@frpanico 25/10/2021
         * Spostato in alto la sezione di codice in cui vengono inseriti i dati dell'ultimo step
         */
       if (lastStepData != null) {
            for (String lastStepField : lastStepData.keySet()) {
                if (lastStepField == 'EffectiveDate__c') {
                    String dateString = String.valueOf(lastStepData.get(lastStepField));
                    orderToUpdate.put(lastStepField, date.valueOf(dateString));
                }
                else {
                    orderToUpdate.put(lastStepField, lastStepData.get(lastStepField));
                }
            }

            if (orderToUpdate.VATfacilitationFlag__c || orderToUpdate.FacilitationExcise__c) {
                List<ContentDocumentLink> docsIvaAccise = contDocLinkQr.getRecordsByEntityAndContentDocumentDescription(order.Id, 'ivaAccise');

                if (docsIvaAccise.isEmpty()) {
                    throw new AuraHandledException('Caricare documento per iva e accise');
                }
            }
        }

        switch on order.RecordType.DeveloperName {
            when 'HDT_RT_Subentro' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
                Decimal serCost = getFixedFee(order.id, order.RecordType.DeveloperName);
                orderToUpdate.ServiceCost__c = serCost != null ? serCost.setScale(2) : null;
            }
            when 'HDT_RT_SwitchIn' {

                List<Order> listOrd = new List<Order>{order};
                Map<String,Boolean> mapAccountRes = HDT_UTL_SwtichInProcess.checkAccountOrderIsResidential(listOrd);
                orderToUpdate.IsActivationDeferred__c = order.IsActivationDeferred__c;

                try {       
                    if(order.SignedDate__c != null){                    
                        orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);
                    }
                }
                catch (Exception e) { 
                    throw new AuraHandledException('Dati incompleti o errati per la generazione della data di decorrenza.');
                }
                
                if (order.ProcessType__c == 'Switch in Fittizio') {
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                }
                if (order.ProcessType__c == 'Switch in Ripristinatorio') {
                    orderToUpdate.DateSentToSII__c = Date.today();
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                }
                else {
                    if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
  
                        try { 
                            if(order.SignedDate__c != null && mapAccountRes.get(order.AccountId)){
                                orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(order);
                            }                                                            
                        } 
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data massima di ripensamento.');
                        }                                                                 

                        if(order.SignedDate__c == null){
                            orderToUpdate.Status = 'In lavorazione';
                            orderToUpdate.Phase__c = 'Da Inviare' ;                        
                        }
            
                        try {    
                            if(order.SignedDate__c != null && !order.ProcessType__c.contains('Cambio Offerta')){                         
                                orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(order); 
                            }
                        }
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data di adempimento.');
                        }                            
    
                        if (order.VolturaThirdTrader__c == true) {
                            orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                        }
                        orderToUpdate.CIAccoutn__c = 'Richiesto';                        
                    }
                    else {
                        
                        try {   
                            if(order.SignedDate__c != null && !order.ProcessType__c.contains('Cambio Offerta')){                          
                                orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(order);
                            }
                        }
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data di adempimento.');
                        }
                        try {
                            if(order.SignedDate__c != null){
                                orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);
                            }                                                             
                        }
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data di decorrenza.');
                        }        
                        if (order.VolturaThirdTrader__c) {
                            orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                        }    
                    }
                }

                if (order.IsCloned__c) {
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                }
            }
            when 'HDT_RT_Attivazione' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
                else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    orderToUpdate.CILegalRepresentative__c = 'Richiesto';
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
                Decimal serCost = getFixedFee(order.id, order.RecordType.DeveloperName);
                orderToUpdate.ServiceCost__c = serCost != null ? serCost.setScale(2) : null;
            }
            when 'HDT_RT_AttivazioneConModifica' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                    orderToUpdate.Instance326__c = 'Richiesto';
                    if('Rapido'.equalsIgnoreCase(order.QuotationType__c)){
                        orderToUpdate.QuickQuote__c = 'Richiesto';
                    }
                }
                else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    orderToUpdate.ChamberCommerceRegistration__c = 'Richiesto';
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    if('Rapido'.equalsIgnoreCase(order.QuotationType__c)){
                        orderToUpdate.QuickQuote__c = 'Richiesto';
                    }
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
            }
            when 'HDT_RT_Voltura', 'HDT_RT_VolturaConSwitch'{
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
                else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
                if(order.EffectiveDate__c < orderSrv.addBusinessDay(System.today(), 3) || order.EffectiveDate__c == null){
                    orderToUpdate.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);
                }
                if(currentOrder.CommodityFormula__c.equalsIgnoreCase('Energia Elettrica')){
                    if(currentOrder.ContractReference__c != null && currentOrder.ProcessType__c == 'Voltura Con Switch'){
                        contractReference = contractQr.getContractAccountCompanyOwner(currentOrder.ContractReference__c);
                    }
                    if(!String.isEmpty(contractReference.Id) && !contractReference.Account.CompanyOwner__c.equalsIgnoreCase('HERA COMM')){
                        orderToUpdate.Phase__c = 'Esportazione VS Siebel';
                    }
                    Map<String,Object> rates = voltureChangeUtils.checkRates(
                        (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(currentOrder)), 
                        (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(orderToUpdate))
                    );
                    for(String field : rates.keySet()){
                        orderToUpdate.put(field, rates.get(field));
                    }
                    if(currentOrder.Email__c != null && String.isEmpty(currentOrder.Email__c)){
                        orderToUpdate.Email__c = emptyEmailDefault;
                    }    
                }                
            }
            when 'HDT_RT_ConnessioneConAttivazione' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
                else {
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
            }
            when 'HDT_RT_TemporaneaNuovaAtt' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
            }
            when 'HDT_RT_CambioOfferta'{
                if(order.SignedDate__c != null){                    
                    HDT_UTL_SwtichInProcess.calculateCambioOffertaDate(order);  // Data di decorrenza
                }
            }
            /*when 'HDT_RT_CambioOfferta' {
                
                String dateToCalculate = '';
                List<Order> listOrd = new List<Order>{order};
                Map<String,Boolean> mapAccountRes = HDT_UTL_SwtichInProcess.checkAccountOrderIsResidential(listOrd);

                try {
                    if(order.SignedDate__c != null){      
                        dateToCalculate = 'di decorrenza.';
                        orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);
                    } 
                    if(mapAccountRes.get(order.AccountId)){
                        dateToCalculate = 'massima di ripensamento.';
                        orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(order);
                    }
                }
                catch (Exception e) { 
                    throw new AuraHandledException('Dati incompleti o errati per la generazione della data ' +dateToCalculate);
                }             
            }*/
        }

        List<ComfortQualityCall__c> comfortQualityList = new List<ComfortQualityCall__c>();

        if (order.RecordType.DeveloperName == 'HDT_RT_VAS') {
            comfortQualityList = HDT_QR_ComfortQualityCall.getRecordByOrderParamsVas(order);
        }
        else {
            comfortQualityList = HDT_QR_ComfortQualityCall.getRecordByOrderParams(order);
        }

        if (!comfortQualityList.isEmpty()) {

            ComfortQualityCall__c comforQualityRes = new ComfortQualityCall__c();
            orderToUpdate.QualityCall__c = true;
            List<Order> orderChildComfort = orderQr.getChildOrdersByParentId(order.ParentOrder__c);

            if(orderChildComfort.size() > 1){ //if more than 1 child group activity comfort/quality by Parent
                orderToUpdate.QualityCallUnique__c = true;
            }

            if (comfortQualityList.size() > 1) {
                for (ComfortQualityCall__c cqc : comfortQualityList) {
                    if(cqc.ComfortEnabled__c && cqc.ComfortSignatureMethod__c == order.SignatureMethod__c && cqc.ComfortDocSendingChannel__c == order.DocSendingMethod__c){
                        comforQualityRes = cqc;
                        break;
                    }
                    else if (cqc.QualityEnabled__c && cqc.QualitySignatureMethod__c == order.SignatureMethod__c) {
                        comforQualityRes = cqc;
                        break;
                    }
                }
            }
            else {
                comforQualityRes = comfortQualityList[0];
            }

            if (comforQualityRes.ComfortEnabled__c) {
                orderToUpdate.ComfortCallDaysDue__c = comforQualityRes.DaysComfort__c;
                orderToUpdate.DateComfortCall__c = Date.today();
            }
        }

        /* Commentata in attesa di configurazione PC Manager
        if(currentOrder.CreditCheckInProgress__c && String.isBlank(currentOrder.IncomingCreditCheckResult__c) && String.isBlank(currentOrder.OutgoingCreditCheckResult__c)){
            orderToUpdate.Phase__c = 'Attesa Credit Check';
        }
        else if(!String.isBlank(currentOrder.IncomingCreditCheckResult__c) || !String.isBlank(currentOrder.OutgoingCreditCheckResult__c)){
            orderToUpdate.CreditCheckInProgress__c = false;
            if(currentOrder.IncomingCreditCheckResult__c.containsIgnoreCase('KO') || currentOrder.OutgoingCreditCheckResult__c.containsIgnoreCase('KO')){
                orderToUpdate.Phase__c = 'Credit Check KO';
            }
        } */

        orderSrv.updateRecord(orderToUpdate);
        if(orderToUpdate.FacilitationExcise__c == true || orderToUpdate.VATfacilitationFlag__c == true){
            HDT_LC_ChildOrderProcessDetails.createActivityAccise(orderToUpdate.FacilitationExcise__c,orderToUpdate.VATfacilitationFlag__c,orderToUpdate.id,orderToUpdate.accountid);
        }

        if (order.ParentOrder__r.Status == 'Draft') {
            // order parent status = in lavorazione, phase = in lavorazione
            String status = 'In lavorazione';
            String phase = 'In lavorazione';

            if (order.ProcessType__c == 'Switch in Ripristinatorio') {
                phase = 'Documentazione Gestita';
                status = 'Completed';
            }

            Order orderParentToUpdate = new Order(
                Id = order.ParentOrder__c,
                Status = status,
                Phase__c = phase
            );

            orderSrv.updateRecord(orderParentToUpdate);
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 17/02/2021
     * @param objectApiName
     * @param objectToUpdate
     * @description Save child order as draft
     */
    @AuraEnabled
    public static void saveDraft(String objectApiName, SObject objectToUpdate){
        
        if (objectToUpdate != null) {
            switch on objectApiName {
                when  'Account'{
                    accountSrv.updateRecord((Account)objectToUpdate);
                }
                when 'Order' {
                    orderSrv.updateRecord((Order)objectToUpdate);
                }
                when 'ServicePoint__c' {
                    servicePointSrv.updateRecord((ServicePoint__c)objectToUpdate);
                }
                when 'BillingProfile__c' {
                    billingProfileSrv.updateRecord((BillingProfile__c)objectToUpdate);
                }
            }
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 17/02/2021
     * @param objectApiName
     * @param objectToUpdate
     * @param diffObjectApiName
     * @param diffObjectToUpdate
     * @description Save child order as draft with diff fields
     */
    @AuraEnabled
    public static void saveDraft(String objectApiName, SObject objectToUpdate, String diffObjectApiName, SObject diffObjectToUpdate){
        
        switch on objectApiName {
            when  'Account'{
                accountSrv.updateRecord((Account)objectToUpdate);
            }
            when 'Order' {
                //EVERIS: customization for 'Voltura/Cambio Contatore Non Registrato'
                Order draftOrder = (Order)objectToUpdate;
                if(draftOrder.NotRegisteredMeterCase__c != null && draftOrder.NotRegisteredMeterCase__c == true){
                    draftOrder.Phase__c = 'Sospeso';
                }
                orderSrv.updateRecord(draftOrder);
            }
            when 'ServicePoint__c' {
                servicePointSrv.updateRecord((ServicePoint__c)objectToUpdate);
            }
            when 'BillingProfile__c' {
                billingProfileSrv.updateRecord((BillingProfile__c)objectToUpdate);
            }
        }

        switch on diffObjectApiName {
            when  'Account'{
                accountSrv.updateRecord((Account)diffObjectToUpdate);
            }
            when 'Order' {
                orderSrv.updateRecord((Order)diffObjectToUpdate);
            }
            when 'ServicePoint__c' {
                servicePointSrv.updateRecord((ServicePoint__c)diffObjectToUpdate);
            }
            when 'BillingProfile__c' {
                billingProfileSrv.updateRecord((BillingProfile__c)diffObjectToUpdate);
            }
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 17/02/2021
     * @param order
     * @param cancellationReason
     * @description Execute child order process cancel actions
     */
    @AuraEnabled
    public static void cancel(Order order, String cancellationReason){
        orderSrv.updateRecord(new Order(
            Id = order.Id,
            Status = 'Annullato', //Chiuso
            Phase__c = 'Annullato',
            CancellationReason__c = cancellationReason
        ));
    }


    /**
     * @author Federico de Felice (federico.defelice@webresults.it)
     * @date 14/07/2021
     * @param orderId
     * @param searchKey
     * @return Decimal
     * @description Execute child order process cancel actions
     */
    @TestVisible
    private static Decimal getFixedFee(Id orderId, String searchKey){

        String regex = '(\\d*\\.?\\d*)\\%';
        Decimal fixedFeeExclVat;
        Decimal vatNumber = null;
        Order ord = new HDT_QR_Order().getRecordByOrderId(orderId)[0];  

        for(HDT_FixedFeeTable__mdt meta : [SELECT Sottotipo__c, Value__c FROM HDT_FixedFeeTable__mdt WITH SECURITY_ENFORCED]){
            if(meta.Sottotipo__c==searchKey){
                fixedFeeExclVat=meta.Value__c;
                break;
            }
        }

        if(String.isBlank(ord.vat__c) || fixedFeeExclVat==null){
            return null;
        }

        Matcher matcher=Pattern.compile(regEx).matcher(ord.vat__c);

        if(matcher.find()){
            vatNumber = Decimal.valueOf(matcher.group(1))*0.01;
        }
        else{
            return fixedFeeExclVat;
        }
        return fixedFeeExclVat == null ? null : fixedFeeExclVat*(1+vatNumber);
    }
}