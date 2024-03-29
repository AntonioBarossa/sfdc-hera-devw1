public with sharing class HDT_LC_EditScartiComplessi {
    @AuraEnabled
    public static string getInitData(String recordId){
        //Gestione Risottomissione Annullamento --> inserita nuovo elemento annullamento
        Map<String,Object> responseMap = new Map<String,Object>{'annullamento' => 'NO'};
        Boolean hasOwnership = true;
        try {
            wrts_prcgvr__Activity__c activity = (wrts_prcgvr__Activity__c)HDT_QR_GenericQuery.getGenericRecords('Id,Case__c, AnnulmentManagement__c, Type__c, isUserActivity__c, Order__c,Order__r.ParentOrder__c, Order__r.PrecheckResultSII__c, Order__r.ParentOrder__r.AccountId, Order__r.ParentOrder__r.Sale__c,Order__r.Sale__c, Order__r.AccountId,Order__r.ServicePoint__r.Account__c, Order__r.ServicePoint__r.CommoditySector__c,Order__r.RecordType.DeveloperName, Order__r.SwitchOutDate__c', 'wrts_prcgvr__Activity__c', 'Id =\''+recordId+'\'')[0];
            if(!activity.isUserActivity__c){
                hasOwnership=false;
            }
            else{
                if (activity.Case__c != null){
                    responseMap.put('objectId',recordId);
                    responseMap.put('objectType','Case');
                    //Gestione Risottomissione Annullamento
                    if (activity.AnnulmentManagement__c){
                        responseMap.put('annullamento','SI');
                        responseMap.put('recordId',activity.Case__c);
                    }
                }else if(activity.Order__c != null){
                    if(activity.Type__c!=null && activity.Type__c.equals('Busta Docusign non consegnata')){
                        responseMap.put('object',activity);
                        responseMap.put('objectType','wrts_prcgvr__Activity__c');
                    }
                    else {
                        //Gestione Risottomissione Annullamento
                        if (activity.AnnulmentManagement__c){
                            responseMap.put('annullamento','SI');
                            responseMap.put('recordId',activity.Order__c);
                        }else{
                            setStep(activity);
                        }
                        responseMap.put('objectType','Order');
                        responseMap.put('object',activity.Order__r);
                    }
                }else{
                    throw new AuraHandledException('Attività Non Valida');
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Non è stata trovata l\'attività richiesta.');
        }

        if(!hasOwnership){
            throw new AuraHandledException('L\'attività può essere gestita solamente dall\'assegnatario');
        }
        return JSON.serialize(responseMap);
    }

    @AuraEnabled
    public static String resubmissionPractice(Order ord,String activityId, Map<String,Object> lastStepData){
        /* Nel caso di KO precedente cliente (isTechnicalTransfer valorizzato a true) e fase Amm. Precheck KO SII
        * L' operatore non puo' premere direttamente risottometti pratica in quanto deve necessariamente
        * compilare i dati del precedente intestatario.
        * viene querato l'ordine (ad ogni step l'ordine viene aggiornato quindi si otterra' sempre l'istanza piu' recente)
        * e viene richiamato il metodo per il check della valorizzazione dei dati dell'intestatario
        */
        Order ordToUpdate = new Order(Id = ord.Id);
        if (lastStepData != null) {
            HDT_QR_ContentDocumentLink contDocLinkQr = new HDT_QR_ContentDocumentLink();
            for (String lastStepField : lastStepData.keySet()) {
                if (lastStepField == 'EffectiveDate__c') {
                    String dateString = String.valueOf(lastStepData.get(lastStepField));
                    ordToUpdate.put(lastStepField, date.valueOf(dateString));
                }
                else {
                    ordToUpdate.put(lastStepField, lastStepData.get(lastStepField));
                }
            }

            if ((ordToUpdate.VATfacilitationFlag__c != null && ordToUpdate.VATfacilitationFlag__c) || (ordToUpdate.FacilitationExcise__c != null && ordToUpdate.FacilitationExcise__c)) {
                List<ContentDocumentLink> docsIvaAccise = contDocLinkQr.getRecordsByEntityAndContentDocumentDescription(ord.Id, 'ivaAccise');

                if (docsIvaAccise.isEmpty()) {
                    throw new AuraHandledException('Caricare documento per iva e accise');
                }
            }
        }
        HDT_QR_VoltureChangeManager qrVlt = new HDT_QR_VoltureChangeManager();
        List<Order> orderCheck =  qrVlt.getOrderInfosById(ord.Id);
        if(!orderCheck.isEmpty() && orderCheck[0].IsTechnicalTransfer__c && 'Amm. Precheck KO SII'.equalsIgnoreCase(ord.Phase__c))
        {
            HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck trCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck();

            trCheck.firstName = String.isBlank(orderCheck[0].PreviousHolderFirstName__c) ? '' : orderCheck[0].PreviousHolderFirstName__c;
            trCheck.lastName = String.isBlank(orderCheck[0].PreviousHolderLastName__c) ? '' : orderCheck[0].PreviousHolderLastName__c;
            trCheck.fiscalCode = String.isBlank(orderCheck[0].PreviousHolderFiscalCode__c) ? '' : orderCheck[0].PreviousHolderFiscalCode__c;
            trCheck.vatNumber = String.isBlank(orderCheck[0].PreviousHolderVatNumber__c) ? '' : orderCheck[0].PreviousHolderVatNumber__c;
            trCheck.companyName = String.isBlank(orderCheck[0].PreviousHoldeCompanyName__c) ? '' : orderCheck[0].PreviousHoldeCompanyName__c;

            HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck check = HDT_LC_ChildOrderProcessDetails.checkTechnicalTransfer(trCheck);
            if(String.isNotBlank(check.result))
            {
                throw new AuraHandledException(check.message);
            }
        }
        String response;
        String fase = 'Comunicazione verso Heroku';
        switch on ord.ProcessType__c {
            when  'Voltura' {
                fase = 'Documentazione Validata';
            }
            when 'VAS' {
                fase = 'Comunicazione Motore VAS';
            }
            when 'Connessione con Attivazione'{
                /**
                 * For H2O Commodity check if Activity Type is Ammissibilità KO and if is created after the quote acceptance.
                 * If true, the correct phase to fire Esecuzione Lavori is Preventivo Accettato
                */
                Order ordConnessione = (Order)HDT_QR_GenericQuery.getGenericRecords('Id,Phase__c, PhaseStory__c,CommodityFormula__c', 'Order', 'Id =\''+ord.Id+'\'')[0];
                wrts_prcgvr__Activity__c activity = (wrts_prcgvr__Activity__c)HDT_QR_GenericQuery.getGenericRecords('Id,Type__c', 'wrts_prcgvr__Activity__c', 'Id =\''+activityId+'\'')[0];
                String phaseStory = ordConnessione?.PhaseStory__c;
                String commodity = ordConnessione?.CommodityFormula__c;
                String activityType = activity?.Type__c;
                if(String.isNotBlank(activityType) && String.isNotBlank(commodity) && String.isNotBlank(phaseStory) 
                    && commodity.equalsIgnoreCase('Acqua') && phaseStory.containsIgnoreCase('Preventivo Accettato') && activityType.equalsIgnoreCase('Ammissibilità KO')){
                    fase = 'Preventivo Accettato';
                }
            }
        }
        if ('Caricamento Siebel KO'.equalsIgnoreCase(ord.Phase__c)){
            fase = 'Esportazione VS Siebel';
        }
        ordToUpdate.Phase__c = fase;
        ordToUpdate.DiscardReason__c = null;
        ordToUpdate.HerokuPracticeCode__c = null;
        ordToUpdate.DistributorPracticeCode__c = null;
        System.Savepoint sp = Database.setSavePoint();
        try {
            if (!HDT_UTL_Scarti.updateCloseDiscardActivity(activityId)){
                response = 'Impossibile chiudere l\'attività di scarto';
            } else if (!HDT_UTL_DatabaseService.updateSObject(ordToUpdate)){
                response = 'Errore nell\'aggiornamento della fase dell\'ordine.';
                Database.rollback(sp);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @TestVisible
    private static void setStep(wrts_prcgvr__Activity__c activity){
        Double step = null;
        Order ord = activity.Order__r;
        switch on (ord.RecordType.DeveloperName){
            when 'HDT_RT_SwitchInVolturaTecnica'{
                step = 11;
            }
            when 'HDT_RT_Attivazione','HDT_RT_AttivazioneConModifica','HDT_RT_ScontiBonus','HDT_RT_CambioOfferta',
                'HDT_RT_CambioUso','HDT_RT_ConnessioneConAttivazione','HDT_RT_TemporaneaNuovaAtt','HDT_RT_VAS','HDT_RT_Subentro'{
                step = 5;
            }
            when 'HDT_RT_SubentroAmbiente', 'HDT_RT_AttivazioneAmbiente', 'HDT_RT_CambioTariffa', 
                'HDT_RT_AgevolazioniAmbiente', 'HDT_RT_ModificaTariffaRimozione'{
                step = 1;
            }
            when 'HDT_RT_Voltura'{
                step = 3;//setStepCheckAccount(ord, ord.ServicePoint__r, 3);
            }
            when 'HDT_RT_VolturaConSwitch'{
                step = setStepForVoltureWithSwitch(ord.ServicePoint__r, ord.AccountId);
                ord.PrecheckResultSII__c = 'KO'.equalsIgnoreCase(ord.PrecheckResultSII__c) ? '' : ord.PrecheckResultSII__c; 
            }
            when 'HDT_RT_SwitchIn'{
                step = setStepSwitchIn(ord, ord.ServicePoint__r);
            }
        }
        if (!HDT_UTL_DatabaseService.updateSObject(new Order(Id =  activity.Order__c, Step__c = step, PrecheckResultSII__c = ord.PrecheckResultSII__c))){
            throw new AuraHandledException('Errore Nell\'aggiornamento dell\'order');
        }
    }

    /* private static Double setStepCheckAccount(Order ord, ServicePoint__c serv,Double step){
        if (serv != null && serv.Account__c != null && serv.Account__c != ord.AccountId){
            return null;
        }
        return step;
    } */

    @TestVisible
    private static Double setStepForVoltureWithSwitch(ServicePoint__c serv, Id accountId){
        Double step = 4;
        /* if (serv != null && serv.Account__c != null && serv.Account__c != accountId){
            step = null;
        }else  */if (serv != null && 'Energia Elettrica'.equalsIgnoreCase(serv.CommoditySector__c)){
            step = 3;
        }
        return step;
    }

    private static Double setStepSwitchIn(Order ord, ServicePoint__c serv){
        Double step = 5;
        if (ord.SwitchOutDate__c != null){
            step = 3;
        }else if (serv != null && 'Gas'.equalsIgnoreCase(serv.CommoditySector__c)){
            step = 4;
        }
        return step;
    }

    @InvocableMethod(label='Close Discard Activity')
    public static List<String> closeDiscardActivity(List<String> input){
        String response;
        Id activityId = (Id)input[0];
        if (!HDT_UTL_Scarti.updateCloseDiscardActivity(activityId)){
            response = 'Impossibile chiudere l\'attività di scarto';
        }
        return new List<String>{response};
    }
}