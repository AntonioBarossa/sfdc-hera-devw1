/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 15/02/2021
 * @description HDT_LC_ChildOrderProcessActions.cls - Class that holds methods that are called from hdtChildOrderProcessActions.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveParameterList, PMD.NcssMethodCount,PMD.AvoidDebugStatements')
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
                    if(currentOrder.SupplyType__c.equalsIgnoreCase('Domestico') || currentOrder.SupplyType__c.equalsIgnoreCase('A-Domestico'))
                    {
                        orderToUpdate.DocumentLow80__c = 'Richiesto';
                    }
                    //orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
                Decimal serCost = getFixedFee(order.id, order.RecordType.DeveloperName);
                orderToUpdate.ServiceCost__c = serCost != null ? serCost.setScale(2) : null;
            }
            when 'HDT_RT_SwitchIn' {

                List<Order> listOrd = new List<Order>{order};
                //Map<String,Boolean> mapAccountRes = HDT_UTL_SwtichInProcess.checkAccountOrderIsResidential(listOrd);
                //orderToUpdate.IsActivationDeferred__c = order.IsActivationDeferred__c;

                /*try {       
                    if(order.SignedDate__c != null){                    
                        orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);
                    }
                }
                catch (Exception e) { 
                    throw new AuraHandledException('Dati incompleti o errati per la generazione della data di decorrenza.');
                }*/
                
                /*if (order.ProcessType__c == 'Switch in Fittizio') {
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                }*/
                if (order.ProcessType__c == 'Switch in Ripristinatorio') {
                    orderToUpdate.DateSentToSII__c = Date.today();
                    orderToUpdate.EffectiveDate__c = Date.today();
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                }
                else {
                    if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
  
                        /*try { 
                            if(order.SignedDate__c != null && mapAccountRes.get(order.AccountId)){
                                orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(order);
                            }                                                            
                        } 
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data massima di ripensamento.');
                        }         */                                                        

                        if(order.SignedDate__c == null){
                            orderToUpdate.Status = 'In lavorazione';
                            orderToUpdate.Phase__c = 'Da Inviare' ;                        
                        }
                        /*
                        try {    
                            if(order.SignedDate__c != null && !order.ProcessType__c.contains('Cambio Offerta')){                         
                                orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(order); 
                            }
                        }
                        catch (Exception e) { 
                            throw new AuraHandledException('Dati incompleti o errati per la generazione della data di adempimento.');
                        }                            
                        */
                        if (order.VolturaThirdTrader__c == true) {
                            orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                        }
                        orderToUpdate.CIAccoutn__c = 'Richiesto';                        
                    }
                    else {
                       /* 
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
                        }       */ 
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
                    //orderToUpdate.DocumentLow80__c = 'Richiesto';
                    if(currentOrder.SupplyType__c.equalsIgnoreCase('Domestico') || currentOrder.SupplyType__c.equalsIgnoreCase('A-Domestico'))
                    {
                        orderToUpdate.DocumentLow80__c = 'Richiesto';
                    }
                    if(((String)currentOrder.get('Commodity__c')).equalsIgnoreCase('Energia Elettrica'))
                    {
                        orderToUpdate.Instance326__c = 'Richiesto';
                    }
                }
                else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    orderToUpdate.CILegalRepresentative__c = 'Richiesto';
                    if(((String)currentOrder.get('Commodity__c')).equalsIgnoreCase('Energia Elettrica'))
                    {
                        orderToUpdate.Instance326__c = 'Richiesto';
                    }
                }
                Decimal serCost = getFixedFee(order.id, order.RecordType.DeveloperName);
                orderToUpdate.ServiceCost__c = serCost != null ? serCost.setScale(2) : null;
            }
            when 'HDT_RT_AttivazioneConModifica' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    if(currentOrder.SupplyType__c.equalsIgnoreCase('Domestico') || currentOrder.SupplyType__c.equalsIgnoreCase('A-Domestico'))
                    {
                        orderToUpdate.DocumentLow80__c = 'Richiesto';
                    }
                    //orderToUpdate.DocumentLow80__c = 'Richiesto';
                    if(((String)currentOrder.get('Commodity__c')).equalsIgnoreCase('Energia Elettrica'))
                    {
                        orderToUpdate.Instance326__c = 'Richiesto';
                    }
                    if('Rapido'.equalsIgnoreCase(order.QuotationType__c)){
                        orderToUpdate.QuickQuote__c = 'Richiesto';
                    }
                }
                else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    //orderToUpdate.ChamberCommerceRegistration__c = 'Richiesto'; @frpanico 2022-04-01 rimosso a seguito di richiesta BSN durante UAT
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    if('Rapido'.equalsIgnoreCase(order.QuotationType__c)){
                        orderToUpdate.QuickQuote__c = 'Richiesto';
                    }
                    if(((String)currentOrder.get('Commodity__c')).equalsIgnoreCase('Energia Elettrica'))
                    {
                        orderToUpdate.Instance326__c = 'Richiesto';
                    }
                }
            }
            when 'HDT_RT_Voltura', 'HDT_RT_VolturaConSwitch'{
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    /**@frpanico 2022-04-27
                     * Il documento di legge 80 va richiesto
                     * Solo per forniture domestiche
                     */
                    if(currentOrder.SupplyType__c.equalsIgnoreCase('Domestico') || currentOrder.SupplyType__c.equalsIgnoreCase('A-Domestico'))
                    {
                        orderToUpdate.DocumentLow80__c = 'Richiesto';
                    }
                }
                else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                }
                if(currentOrder.EffectiveDate__c < orderSrv.addBusinessDay(System.today(), 3) || currentOrder.EffectiveDate__c == null){
                    orderToUpdate.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);
                }
                if(currentOrder.CommodityFormula__c.equalsIgnoreCase('Energia Elettrica')){
                    if(currentOrder.ContractReference__c != null && currentOrder.ProcessType__c == 'Voltura Con Switch'){
                        contractReference = contractQr.getContractAccountCompanyOwner(currentOrder.ContractReference__c);
                    }
                    if(!String.isEmpty(contractReference.Id) && !contractReference.Account.CompanyOwner__c.equalsIgnoreCase('HERA COMM')){
                        orderToUpdate.Phase__c = 'Esportazione VS Siebel';
                    }
                }
                /**@frpanico 2022-27-05
                 * Gestione campi mancanti integrazione
                 */
                if(currentOrder.Email__c == null || String.isEmpty(currentOrder.Email__c)){
                    orderToUpdate.Email__c = emptyEmailDefault;
                }    
                if(currentOrder.PhoneNumber__c == null || String.isEmpty(currentOrder.PhoneNumber__c))
                {
                    orderToUpdate.PhoneNumber__c = currentOrder.Contact__r.MobilePhone != null ||String.isNotBlank(currentOrder.Contact__r.MobilePhone) 
                        ? currentOrder.Contact__r.MobilePhone  
                        : currentOrder.Contact__r.Phone != null || String.isNotBlank(currentOrder.Contact__r.MobilePhone)
                            ? currentOrder.Contact__r.Phone
                            : '123';
                }
                Map<String,Object> rates = voltureChangeUtils.checkRates(
                    (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(currentOrder)), 
                    (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(orderToUpdate))
                );
                for(String field : rates.keySet()){
                    orderToUpdate.put(field, rates.get(field));
                }
                //AF inserito per ribaltare campi da Reading__c a Order
                if(currentOrder.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Gas') && currentOrder.Subprocess__c != null && currentOrder.Subprocess__c.equalsIgnoreCase('Con Autolettura')){
                    HDT_QR_SelfReadings qrReading = new HDT_QR_SelfReadings();
                    try {
                        Reading__c selfRead = qrReading.getReading('Order',currentOrder.Id,'Gas','ReadingValueMeter__c,ReadingDate__c,ReadingSerialNumberCorrector__c,ReadingValueCorrector__c');
                        orderToUpdate.ReadingValueMeter__c = selfRead.ReadingValueMeter__c;
                        orderToUpdate.ReadingValueCorrector__c = selfRead.ReadingValueCorrector__c;
                        orderToUpdate.ReadingSerialNumberCorrector__c = selfRead.ReadingSerialNumberCorrector__c;
                        orderToUpdate.ReadingCustomerDate__c = selfRead.ReadingDate__c;
                    } catch (Exception ex) {
                        //no record
                    }
                }                
            }
            when 'HDT_RT_ConnessioneConAttivazione' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    if(currentOrder.SupplyType__c.equalsIgnoreCase('Domestico') || currentOrder.SupplyType__c.equalsIgnoreCase('A-Domestico'))
                    {
                        orderToUpdate.DocumentLow80__c = 'Richiesto';
                    }
                    //orderToUpdate.DocumentLow80__c = 'Richiesto';
                    if(((String)currentOrder.get('Commodity__c')).equalsIgnoreCase('Energia Elettrica'))
                    {
                        orderToUpdate.Instance326__c = 'Richiesto';
                    }
                }
                else {
                    if(((String)currentOrder.get('Commodity__c')).equalsIgnoreCase('Energia Elettrica'))
                    {
                        orderToUpdate.Instance326__c = 'Richiesto';
                    }
                }
            }
            when 'HDT_RT_TemporaneaNuovaAtt' {
                orderToUpdate.CIAccoutn__c = 'Richiesto';
            }
            when 'HDT_RT_CambioOfferta'{
                if(order.SignedDate__c != null){                    
                    HDT_UTL_SwtichInProcess.calculateCambioOffertaDate(order);  // Data di decorrenza
                }
            }
            when 'HDT_RT_VAS'
            {
                if(currentOrder.VASSubtype__c != null && currentOrder.VASSubtype__c.equalsIgnoreCase('Analisi Consumi'))
                {
                    orderToUpdate.ProcessCode__c = currentOrder.Commodity__c.equalsIgnoreCase('Energia Elettrica') ? 'VCE' : 'VCG';
                    /* 2022-11-10 Inserito avanzamento di fase per casistica Analisi Consumi legato a Switch In Ripristinatorio */
                    if(currentOrder.ParentOrder__c != null && currentOrder.ParentOrder__r.Phase__c != null && currentOrder.ParentOrder__r.Phase__c.equalsIgnoreCase('Documentazione Gestita'))
                    {
                        orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                    }
                }

                if ('VAS Fatturabili'.equalsIgnoreCase(currentOrder.VASType__c) && String.isBlank(currentOrder.CommercialProductCode__c) && 'Analisi Consumi'.equalsIgnoreCase(currentOrder.CommercialProduct__c)&& 'Energia Elettrica'.equalsIgnoreCase(currentOrder.CommodityFormula__c)){
                        setVasProductField(orderToUpdate, currentOrder);
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

        /*if(order.SignatureMethod__c.containsIgnoreCase('OTP'))
        {
            orderToUpdate.CIAccoutn__c = '';
        }*/
        if(order.SignatureMethod__c != null && order.SignatureMethod__c.containsIgnoreCase('Contratto già firmato'))
        {
            orderToUpdate.CIAccoutn__c = '';
            orderToUpdate.QuickQuote__c = '';
            orderToUpdate.Instance326__c = '';
            orderToUpdate.DocumentLow80__c = '';
            orderToUpdate.DocumentPackage__c = '';
        }


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


        if(!String.isBlank(currentOrder.IncomingCreditCheckResult__c) || !String.isBlank(currentOrder.OutgoingCreditCheckResult__c)){
            /**@frpanico 17/02/2022
             * Aggiunto il null check 
             * l'Or nella condizioni di sopra puo comunque
             * far incorrere in una NullException
             */
            if((!String.isBlank(currentOrder.IncomingCreditCheckResult__c) && currentOrder.IncomingCreditCheckResult__c.containsIgnoreCase('KO')) 
                || (!String.isBlank(currentOrder.OutgoingCreditCheckResult__c) && currentOrder.OutgoingCreditCheckResult__c.containsIgnoreCase('KO'))){
                orderToUpdate.Phase__c = 'Credit Check KO';
            }
        }

        string exciseEle;
        if( order.RecordType.DeveloperName.contains('HDT_RT_CambioUso') ){
            exciseEle = String.isBlank(orderToUpdate.ExciseEle__c)? currentOrder.ExciseEle__c:orderToUpdate.ExciseEle__c;
            if( order.RecordType.DeveloperName.contains('HDT_RT_CambioUso') && !HDT_UTL_ServicePoint.checkTaxesCoerence( currentOrder.SupplyType__c, exciseEle ) ){                          
                throw new AuraHandledException('Dati incompleti o non coerenti.');
            }
        }
        if(order.RecordType.DeveloperName!= 'HDT_RT_VAS' && order.RecordType.DeveloperName!= 'HDT_RT_ScontiBonus' && currentOrder.CommodityFormula__c.equalsIgnoreCase('Gas'))
        {
            String exciseGas = String.isBlank(orderToUpdate.ExciseGAS__c) ? currentOrder.ExciseGAS__c : orderToUpdate.ExciseGAS__c;
            exciseGas = exciseGas.substringBetween('Cod. ', ')');
            Map<String,Object> inputFieldMap = new Map<String,Object>();
            inputFieldMap.put('CategoriaCliente',currentOrder.CustomerCategory__c);
            inputFieldMap.put('TipoFornitura',currentOrder.SupplyType__c);
            inputFieldMap.put('TipoImpianto',currentOrder.ImplantType__c);
            inputFieldMap.put('Servizio',currentOrder.CommodityFormula__c);
            inputFieldMap.put('ProfiloPrelievo',currentOrder.WithdrawalClass__c);
            inputFieldMap.put('CategoriaUso',currentOrder.UseCategory__c);
            inputFieldMap.put('Imposta',exciseGas);
            if(!HDT_SRV_FieldCoerenceServicePoint.checkCoerence(inputFieldMap))
            {
                throw new AuraHandledException('Attenzione. Deve esserci coerenza nella compilazione dei seguenti campi: Tipologia Fornitura Cliente, Categoria Cliente, Tipo Impianto,Classe Profilo Prelievo, Categoria uso,Imposte');
            }
        }
        /**@frpanico 2022-04-06
         * Valorizzazione IVA Documentale
         * A partire dall'iva presente
         * Sull'order
         */

        String vat = String.isBlank(orderToUpdate.VAT__c) ? currentOrder.VAT__c : currentOrder.VAT__c;
        if(!String.isEmpty(vat))
        {
            String vatCode = vat.subStringBetween('Cod. ',')');
            List<PicklistEntry> entryList = 
                ((SObject) (Type.forName('Schema.Order').newInstance())).getSobjectType().getDescribe().fields.getMap().get('DocumentalVat__c').getDescribe().getPicklistValues();
            for(PicklistEntry entry : entryList)
            {
                if(entry.getValue().containsIgnoreCase(vatCode + '%')){
                    continue;
                }
                if(entry.getValue().containsIgnoreCase(vatCode)){
                    orderToUpdate.DocumentalVat__c = entry.getValue();
                    break;
                }
            }

        }
        /**@frpanico 2022-03-25
         * Valorizzazione campo
         * FlagServizio26 a 'Y'
         * Nel caso in cui vi sia un
         * OrderItem di bonus
         */
        if(!order.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_VAS') && !order.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_ScontiBonus'))
        {
            List<OrderItem> childOrderItems = [SELECT Id 
            FROM OrderItem 
            WHERE OrderId = :order.Id 
            AND SBQQ__RequiredBy__c != NULL
            AND ProductFamily__c != 'Punto Fornitura'
            WITH SECURITY_ENFORCED];

            if(!childOrderItems.isEmpty())
            {
                orderToUpdate.FlagServizio26__c = 'Y';
            }
        }

        /**2022-07-14 903758C --> Valorizzazione CF se PIVA valorizzata e CF Vuoto */
        if( currentOrder.Account.VATNumber__c != null && String.isNotBlank(currentOrder.Account.VATNumber__c) && currentOrder.Account.FiscalCode__c == null)
        {
            orderToUpdate.CustomerFiscalCode__c = currentOrder.Account.VATNumber__c;
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

    private static void setVasProductField(Order ordToUpdate,Order originalOrder){
        Id contractId = originalOrder.ContractReference__c;
        Id servicePointId = originalOrder.ServicePoint__c;
        Id parentOrderId = originalOrder.ParentOrder__c;
        try{
            if(String.isNotBlank(contractId)){
                HDT_QR_Contract qrContract = new HDT_QR_Contract();
                SBQQ__Subscription__c subscription = qrContract.getSubscriptionFromContract(contractId);
                if(subscription != null){
                    ordToUpdate.CommercialProduct__c = subscription.SBQQ__ProductName__c;
                    ordToUpdate.CommercialProductCode__c = subscription.ProductCode__c;
                    ordToUpdate.CommercialProductVersion__c = subscription.VersionFormula__c;
                }
            }else if(String.isNotBlank(servicePointId) && String.isNotBlank(parentOrderId)) {
                HDT_QR_OrderItem qrOrderItems = new HDT_QR_OrderItem();
                OrderItem orderItem = qrOrderItems.getOfferActivationItem(parentOrderId,servicePointId);
                if(orderItem != null){
                    ordToUpdate.CommercialProduct__c = orderItem.Product2.Name;
                    ordToUpdate.CommercialProductCode__c = orderItem.Product2.ProductCode;
                    ordToUpdate.CommercialProductVersion__c = orderItem.Product2.Version__c;            
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.INFO, 'setVasProductField : ' + e.getMessage());
        }
        
    }
}