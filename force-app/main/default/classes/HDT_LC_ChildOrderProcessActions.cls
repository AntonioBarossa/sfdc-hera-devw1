/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 15/02/2021
 * @description HDT_LC_ChildOrderProcessActions.cls - Class that holds methods that are called from hdtChildOrderProcessActions.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
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
            when 'HDT_RT_Subentro' { // only for HDT_RT_Residenziale
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Documenti relativi alla Legge 80.
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
                Decimal serCost = getFixedFee(order.id, order.RecordType.DeveloperName);
                orderToUpdate.ServiceCost__c = serCost != null ? serCost.setScale(2) : null;
            }
            // Calculate Date @Picchiri 20/05/21
            when 'HDT_RT_SwitchIn' { // only for HDT_RT_SwitchIn
                List<Order> listOrd = new List<Order>{order};            
                Map<String,Boolean> mapAccountRes = HDT_UTL_SwtichInProcess.checkAccountOrderIsResidential(listOrd);
                //17/08/2021 - gabriele.rota@webresults.it - Aggiornamento calcolo Data Decorrenza
                orderToUpdate.IsActivationDeferred__c = order.IsActivationDeferred__c;

                try {       
                    if(order.SignedDate__c != null){                    
                        orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);  // Data di decorrenza
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
                    if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') { // @Picchiri Only for residential customer

                        // START Calculate Date @Picchiri 20/05/21 FOR RESIDENZIALE ACCOUNT                            
                        // START 1 Calcolo Data Max Ripensamento       
                        try { 
                            if(order.SignedDate__c != null && mapAccountRes.get(order.AccountId)){
                                orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(order);
                            }                                                            
                        } 
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data massima di ripensamento.');
                        }                                                                 
                        // END Calcolo Data Max Ripensamento               

                        // START 2 Calcolo data Invio richiesta al SII (Data di adempimento)    
                        if(order.SignedDate__c == null){
                            orderToUpdate.Status = 'In lavorazione';
                            orderToUpdate.Phase__c = 'Da Inviare' ;                        
                        }
            
                        try {    
                            if(order.SignedDate__c != null && order.ProcessType__c != 'Cambio Offerta'){                         
                                orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(order); 
                            }
                        }
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data di adempimento.');
                        }                            
                        // END Calcolo data Invio richiesta al SII (Data di adempimento)    
                        // END Calculate Date @Picchiri 20/05/21 FOR RESIDENZIALE ACCOUNT
    
                        if (order.VolturaThirdTrader__c == true) {
                            orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                        }
                        orderToUpdate.CIAccoutn__c = 'Richiesto';                        
                    }
                    else { // @Picchiri Only for not residential customer
     
                        // START Calculate Date @Picchiri 20/05/21 FOR NOT RESIDENZIALE ACCOUNT    
                        // START Calcolo data invio richiesta (Data adempimento).
                        try {   
                            if(order.SignedDate__c != null && order.ProcessType__c != 'Cambio Offerta'){                          
                                orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(order);
                            }
                        }
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data di adempimento.');
                        }                                     
                        // END Calcolo data invio richiesta (Data adempimento).
                    
                        // START 3 Calcolo Data Decorrenza (EffectiveDate__c) 
                        try {
                            if(order.SignedDate__c != null){
                                orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);   // Data di decorrenza
                            }                                                             
                        }
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data di decorrenza.');
                        }                       
                        // END Calcolo Data Decorrenza (EffectiveDate__c)    
                        // END Calculate Date @Picchiri 20/05/21 FOR NOT RESIDENZIALE ACCOUNT
        
                        if (order.VolturaThirdTrader__c) {
                            orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                        }    
                    }
                }

                //18/09/2021 gabriele.rota@webresults.it - Package B Attivazioni
                if (order.IsCloned__c) {
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                }
            }
            when 'HDT_RT_Attivazione' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Doc Legge 80.
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                    // Istanza 326.
                    orderToUpdate.Instance326__c = 'Richiesto';
                } else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    // Carta d’identità del legale rappresentante;
                    orderToUpdate.CILegalRepresentative__c = 'Richiesto';
                    // Istanza 326.
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
                Decimal serCost = getFixedFee(order.id, order.RecordType.DeveloperName);
                orderToUpdate.ServiceCost__c = serCost != null ? serCost.setScale(2) : null;
            }
            when 'HDT_RT_AttivazioneConModifica' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Documenti relativi alla Legge 80
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                    // Istanza 326
                    orderToUpdate.Instance326__c = 'Richiesto';
                    // Accettazione Preventivo rapido.
                    if('Rapido'.equalsIgnoreCase(order.QuotationType__c)){
                        orderToUpdate.QuickQuote__c = 'Richiesto';
                    }
                } else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    // Visura camerale
                    orderToUpdate.ChamberCommerceRegistration__c = 'Richiesto';
                    // Carta identità
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Accettazione preventivo rapido
                    if('Rapido'.equalsIgnoreCase(order.QuotationType__c)){
                        orderToUpdate.QuickQuote__c = 'Richiesto';
                    }
                    // Istanza 326
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
            }
            //EVERIS: Aggiunto caso Voltura/Voltura Con Switch
            when 'HDT_RT_Voltura', 'HDT_RT_VolturaConSwitch'{
                /* Document Validation */
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    /* Carta d’identità */
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    /* Documenti Legge 80 */
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
                else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    // Carta identità
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Documenti relativi alla Legge 80
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
                /* Effective Date Check */
                if(order.EffectiveDate__c < orderSrv.addBusinessDay(System.today(), 3) || order.EffectiveDate__c == null){
                    orderToUpdate.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);
                }
                if(currentOrder.CommodityFormula__c.equalsIgnoreCase('Energia Elettrica'))
                {
                /* If "Voltura Con Switch" and ExitingAccount "Reseller" the process goes to the phase "Esportazione VS Siebel" */
                    if(currentOrder.ContractReference__c != null && currentOrder.ProcessType__c == 'Voltura Con Switch')
                    {
                        contractReference = contractQr.getContractAccountCompanyOwner(currentOrder.ContractReference__c);
                    }
                    if(!String.isEmpty(contractReference.Id) && !contractReference.Account.CompanyOwner__c.equalsIgnoreCase('HERA COMM'))
                    {
                        orderToUpdate.Phase__c = 'Esportazione VS Siebel';
                    }
                /* Rates Check*/
                    Map<String,Object> rates = 
                        voltureChangeUtils.checkRates(
                            (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(currentOrder)),
                            (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(orderToUpdate))
                        );
                    for(String field : rates.keySet())
                    {
                        orderToUpdate.put(field, rates.get(field));
                    }
                /* Email Check */
                    if(currentOrder.Email__c != null && String.isEmpty(currentOrder.Email__c))
                    {
                        orderToUpdate.Email__c = emptyEmailDefault;
                    }    
                }
                
            }
            when 'HDT_RT_ConnessioneConAttivazione' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                    orderToUpdate.Instance326__c = 'Richiesto';
                } else {
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
            }
            when 'HDT_RT_TemporaneaNuovaAtt' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
            }when 'HDT_RT_CambioOfferta'{
                if(order.SignedDate__c != null){                    
                    HDT_UTL_SwtichInProcess.calculateCambioOffertaDate(order);  // Data di decorrenza
                }
            }
        }

        Boolean isVasProcess = order.RecordType.DeveloperName == 'HDT_RT_VAS';
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
                system.debug('******** '+diffObjectToUpdate);
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
        decimal fixedFeeExclVat;
        Order ord = new HDT_QR_Order().getRecordByOrderId(orderId)[0];  
        //for( HDT_FixedFeeTable__mdt meta : HDT_FixedFeeTable__mdt.getall().values() ){
        for( HDT_FixedFeeTable__mdt meta : [select Sottotipo__c, Value__c from HDT_FixedFeeTable__mdt] ){
            if(meta.Sottotipo__c==searchKey){
                fixedFeeExclVat=meta.Value__c;
                break;
            }
        } 
		system.debug(fixedFeeExclVat);
        String regex='(\\d*\\.?\\d*)\\%';
        if(String.isBlank(ord.vat__c) || fixedFeeExclVat==null){ return null;}
        Matcher matcher=Pattern.compile(regEx).matcher(ord.vat__c);
        decimal vatNumber=null;
        if(matcher.find()){
            vatNumber = Decimal.valueOf(matcher.group(1))*0.01;
        }else{
            return fixedFeeExclVat;
        }
        return fixedFeeExclVat==null ? null : fixedFeeExclVat*(1+vatNumber);
    }
}