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
        orderToUpdate.Phase__c = 'Da Inviare';
        orderToUpdate.Step__c = 20;
        //COMMENTATO POICHE' CAMPI NON DISPONIBILI SULLA NOSTRA ORG
        /*orderToUpdate.WizardCompletedDate__c = Date.today();
        
        switch on order.RecordType.DeveloperName {
            when 'HDT_RT_Subentro' { // only for HDT_RT_Residenziale
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    //orderToUpdate.CiCliente__c = 'Richiesto';
                    // Documenti relativi alla Legge 80.
                    //orderToUpdate.DocLegge80__c = 'Richiesto';
                }
            }
            when 'HDT_RT_SwitchIn' { // only for HDT_RT_SwitchIn
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    orderToUpdate.CiCliente__c = 'Richiesto';

                    if (order.VolturaThirdTrader__c) {
                        orderToUpdate.AutorizationVolturaThirdTrader__c = 'Richiesto';
                    }

                    if (order.WaiverRightAfterthought__c == 'Si') {
                        orderToUpdate.DateSentToSII__c = Date.today();
                    } else {
                        orderToUpdate.MaxAfterthoughtDate__c = Date.today();
                    }

                } else {
                    orderToUpdate.DateSentToSII__c = Date.today();
                }
            }
            when 'HDT_RT_Attivazione' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    //orderToUpdate.CiCliente__c = 'Richiesto';
                    // Doc Legge 80.
                    //orderToUpdate.DocLegge80__c = 'Richiesto';
                    // Istanza 326.
                    //orderToUpdate.Istanza326__c = 'Richiesto';
                } else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    // Carta d’identità del legale rappresentante;
                    //orderToUpdate.CiRappresentateLegale__c = 'Richiesto';
                    // Istanza 326.
                    //orderToUpdate.Istanza326__c = 'Richiesto';
                }
            }
            when 'HDT_RT_AttivazioneConModifica' {
                if (order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale') {
                    // Carta d’identità;
                    //orderToUpdate.CiCliente__c = 'Richiesto';
                    // Documenti relativi alla Legge 80
                    //orderToUpdate.DocLegge80__c = 'Richiesto';
                    // Istanza 326
                    //orderToUpdate.Istanza326__c = 'Richiesto';
                    // Accettazione Preventivo rapido.
                    //orderToUpdate.PreventivoRapido__c = 'Richiesto';
                } else if (order.Account.RecordType.DeveloperName == 'HDT_RT_Business') {
                    // Visura camerale
                    //orderToUpdate.VisuraCamerale__c = 'Richiesto';
                    // Carta identità
                    //orderToUpdate.CiCliente__c = 'Richiesto';
                    // Accettazione preventivo rapido
                    //orderToUpdate.PreventivoRapido__c = 'Richiesto';
                    // Istanza 326
                    //orderToUpdate.Istanza326__c = 'Richiesto';
                }
            }
        }*/

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
            Status = 'Annullato',
            Phase__c = 'Annullato'/*, COMMENTATO POICHE' CAMPO NON PRESENTE NELLA NOSTRA ORG
            CancellationReason__c = cancellationReason*/
        ));
    }
}
