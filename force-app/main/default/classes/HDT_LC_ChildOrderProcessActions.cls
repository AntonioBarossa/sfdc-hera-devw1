/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 15/02/2021
 * @description HDT_LC_ChildOrderProcessActions.cls - Class that holds methods that are called from hdtChildOrderProcessActions.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ChildOrderProcessActions {
    
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_ServicePoint servicePointSrv= new HDT_SRV_ServicePoint();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 15/02/2021
     * @param Order order
     * @description Execute child order process save actions
     */
    @AuraEnabled
    public static void save(Order order){

        Order orderToUpdate = new Order();
        orderToUpdate.Id = order.Id;
        orderToUpdate.Status = 'In lavorazione';
        //EVERIS: Aggiunto caso Voltura
        orderToUpdate.Phase__c = order.RecordType.DeveloperName == 'HDT_RT_Voltura' ? 'Accettazione Voltura' : 'Da Inviare'; 
        orderToUpdate.Step__c = 20;
        orderToUpdate.WizardCompletedDate__c = Date.today();
        
        switch on order.RecordType.DeveloperName {
            when 'HDT_RT_Subentro' { // only for HDT_RT_Residenziale
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Documenti relativi alla Legge 80.
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                }
            }
            // Calculate Date @Picchiri 20/05/21
            when 'HDT_RT_SwitchIn' { // only for HDT_RT_SwitchIn   
                system.debug('HDT_LC_ChildOrderProcessActions - save - HDT_RT_SwitchIn order : ' + JSON.serializepretty(order));             
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') { // @Picchiri Only for residential customer

                    // START Calculate Date @Picchiri 20/05/21 FOR RESIDENZIALE ACCOUNT
                        
                        // START 1 Calcolo Data Max Ripensamento                                                
                        orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(order);
                        // END Calcolo Data Max Ripensamento               

                        // START 2 Calcolo data Invio richiesta al SII (Data di adempimento)    
                        if(order.SignedDate__c == null){
                            orderToUpdate.Status = 'In lavorazione';
                            orderToUpdate.Phase__c = 'In attesa validazione' ;                        
                        }
            
                        orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(order);
                        // END Calcolo data Invio richiesta al SII (Data di adempimento)

                        // START Calcolo data inizio (Data attivazione contratto) - indicata solo nel documento di Fabiana
                        //orderToUpdate.ActivatedDate = HDT_UTL_SwtichInProcess.getActivatedDate(order);
                        // END Calcolo data inizio (Data attivazione contratto)

                        // START 3 Calcolo Data Decorrenza (EffectiveDate__c)                         
                        orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);
                        // END Calcolo Data Decorrenza (EffectiveDate__c) 

                    // END Calculate Date @Picchiri 20/05/21 FOR RESIDENZIALE ACCOUNT

                    // Carta d’identità;
                    // orderToUpdate.CIAccoutn__c = 'Richiesto';

                    if (order.VolturaThirdTrader__c) {
                        orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                    }
                    
                } else { // @Picchiri Only for not residential customer
 
                    // START Calculate Date @Picchiri 20/05/21 FOR NOT RESIDENZIALE ACCOUNT

                        // START Calcolo data invio richiesta (Data adempimento).
                        orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(order);                                        
                        // END Calcolo data invio richiesta (Data adempimento).

                        // START Calcolo data inizio (Data attivazione contratto) - indicata solo nel documento di Fabiana
                        //orderToUpdate.ActivatedDate = HDT_UTL_SwtichInProcess.getActivatedDate(order);                                              
                        // END Calcolo data inizio (Data attivazione contratto)
                    
                        // START 3 Calcolo Data Decorrenza (EffectiveDate__c) 
                        orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(order);                        
                        // END Calcolo Data Decorrenza (EffectiveDate__c)   

                    // END Calculate Date @Picchiri 20/05/21 FOR NOT RESIDENZIALE ACCOUNT

                    //orderToUpdate.DateSentToSII__c = Date.today();

                    if (order.VolturaThirdTrader__c) {
                        orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                    }

                    // orderToUpdate.CILegalRepresentative__c = 'Richiesto';
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
                    orderToUpdate.QuickQuote__c = 'Richiesto';
                } else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    // Visura camerale
                    orderToUpdate.ChamberCommerceRegistration__c = 'Richiesto';
                    // Carta identità
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Accettazione preventivo rapido
                    orderToUpdate.QuickQuote__c = 'Richiesto';
                    // Istanza 326
                    orderToUpdate.Instance326__c = 'Richiesto';
                }
            }
            //EVERIS: Aggiunto caso Voltura
            when 'HDT_RT_Voltura'{
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Documenti relativi alla Legge 80
                    orderToUpdate.DocumentLow80__c = 'Richiesto';
                    // Istanza 326
                    orderToUpdate.Instance326__c = 'Richiesto';
                    // Accettazione Preventivo rapido.
                    //orderToUpdate.QuickQuote__c = 'Richiesto';
                    orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                } else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    // Visura camerale
                    orderToUpdate.ChamberCommerceRegistration__c = 'Richiesto';
                    // Carta identità
                    orderToUpdate.CIAccoutn__c = 'Richiesto';
                    // Accettazione preventivo rapido
                    //orderToUpdate.QuickQuote__c = 'Richiesto';
                    // Istanza 326
                    orderToUpdate.Instance326__c = 'Richiesto';
                    orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                }
                if(order.RetroactiveDate__c != null){
                    order.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);
                }
            }
        }

        system.debug('HDT_LC_ChildOrderProcessActions - save: ' + orderToUpdate);
        orderSrv.updateRecord(orderToUpdate);

        if (order.ParentOrder__r.Status == 'Draft') {
            // order parent status = in lavorazione, phase = in lavorazione
            Order orderParentToUpdate = new Order(
                Id = order.ParentOrder__c,
                Status = 'In lavorazione',
                Phase__c = 'In lavorazione'
            );

            orderSrv.updateRecord(orderParentToUpdate);
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 17/02/2021
     * @param String objectApiName
     * @param SObject objectToUpdate
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
     * @param String objectApiName
     * @param SObject objectToUpdate
     * @param String diffObjectApiName
     * @param SObject diffObjectToUpdate
     * @description Save child order as draft with diff fields
     */
    @AuraEnabled
    public static void saveDraft(String objectApiName, SObject objectToUpdate, String diffObjectApiName, SObject diffObjectToUpdate){
        
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
     * @param Order order
     * @param String cancellationReason
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
}