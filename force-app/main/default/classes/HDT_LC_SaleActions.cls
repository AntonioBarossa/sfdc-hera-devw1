/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 14/12/2020updateCampaignMembersStatus
* @description Apex controller for hdtSaleActions.js component
* @history Keltin Mesonjesi – 14/12/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleActions {
    
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_QR_Opportunity opportunityQr = new HDT_QR_Opportunity();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_QuoteLineGroup quoteLineGroupSrv = new HDT_SRV_QuoteLineGroup();
    private static HDT_SRV_QuoteProcess quoteProcessSrv = new HDT_SRV_QuoteProcess();
    private static HDT_QR_QuoteProcess quoteProcessQr = new HDT_QR_QuoteProcess();
    private static HDT_QR_AccountContactRelation accountContactRelationQr = new HDT_QR_AccountContactRelation();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Save sale as draft
     * @param sale
     */
    @AuraEnabled
    public static void saveDraft(Sale__c sale){
        saleSrv.updateRecord(sale);
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 24-09-2021 
    * @param primaryQlSconto 
    * @param allQlSconto 
    **/
    private static void reassignQlSconti(List<SBQQ__QuoteLine__c> primaryQlSconto,  List<SBQQ__QuoteLine__c> allQlSconto){
        Map<id, SBQQ__QuoteLine__c> mapOfferToPrimary = new Map<id, SBQQ__QuoteLine__c>();
        list<SBQQ__QuoteLine__c> listToUpdate = new list<SBQQ__QuoteLine__c>();
        Map<id, SBQQ__QuoteLine__c> mapPrimaryQlSconto= new Map<id, SBQQ__QuoteLine__c>( primaryQlSconto );
        set<Id> idsPrimary = mapPrimaryQlSconto.keySet();

        for(SBQQ__QuoteLine__c ql : primaryQlSconto ){
            mapOfferToPrimary.put(ql.SBQQ__RequiredBy__c, ql);
        }
        for(SBQQ__QuoteLine__c ql : allQlSconto ){
            SBQQ__QuoteLine__c qlUp = new SBQQ__QuoteLine__c(Id=ql.Id);
            if(!(idsPrimary.contains(ql.id) || idsPrimary.contains(ql.SBQQ__RequiredBy__c))){
                qlUp.SBQQ__RequiredBy__c= mapOfferToPrimary.get(ql.SBQQ__RequiredBy__c)?.Id;
                listToUpdate.add(qlUp);
            }else if(ql.SBQQ__RequiredBy__r?.BillingProfile__c!=null){
                qlUp.BillingProfile__c=ql.SBQQ__RequiredBy__r?.BillingProfile__c;
                mapPrimaryQlSconto.get(ql.Id).BillingProfile__c=ql.SBQQ__RequiredBy__r?.BillingProfile__c;
                listToUpdate.add(qlUp);
            }
        }
        system.debug('ivaste');
        system.debug(json.serialize(listToUpdate));
        if(!listToUpdate.isEmpty()){
            //quoteLineSrv.updateRecords(listToUpdate);//We should Bypass Field security for this test
            update listToUpdate;
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Save sale
     * @param sale
     * @param campaignMemberId
     */
    @AuraEnabled
    public static void save(Sale__c sale, String campaignMemberId){

        Id campaignElegibilityGroup = (sale.Campaign__c != null && sale.Campaign__r.CampaignEligibilityGroup__c != null) ? sale.Campaign__r.CampaignEligibilityGroup__c : null;
        String campaignChannel = (sale.Campaign__c != null && sale.Campaign__r.Channel__c != null) ? sale.Campaign__r.Channel__c : null;
        
        List<SObject> sobjToUpdate = new List<SObject>();
        
        HDT_UTL_SaleActions.HDT_WRP_SaleActions quoteLinesGrouped = new HDT_UTL_SaleActions.HDT_WRP_SaleActions();
        quoteLinesGrouped = HDT_UTL_SaleActions.groupQuoteLines(sale.Id);

        if(String.isNotBlank(quoteLinesGrouped.errorMessage))
        {
            throw new AuraHandledException(quoteLinesGrouped.errorMessage);
        }

        /*
        List<SBQQ__QuoteLine__c> quoteLinesListToUpdate = new List<SBQQ__QuoteLine__c>();

        //1 - Check if QuoteLines have BillingProfiles associated
        quoteLineSrv.checkReadAccess('Name,BillingProfile__c,SBQQ__Quote__c');
        List<SBQQ__QuoteLine__c> quoteLinesList = quoteLineQr.getRecordsBySaleFilteredPaymentMethodNotNull(sale.Id);
        List<SBQQ__QuoteLine__c> quoteLinesListForBillingCheck = quoteLineQr.getRecordsBySaleForBillingCheck(sale.Id);
        quoteLinesListForBillingCheck.addAll(quoteLineQr.getRecordsBySaleFilteredPaymentMethodforVas(sale.Id));

        List<SBQQ__QuoteLine__c> allQlSconto = quoteLineQr.getRecordsBySaleFilteredFamilyBonus(sale.Id);
        List<SBQQ__QuoteLine__c> primaryQlSconto=HDT_LC_ApplyBillingProfileModal.getBonusPerOffer(allQlSconto);
        quoteLinesList.addAll(primaryQlSconto);
        reassignQlSconti(primaryQlSconto, allQlSconto);

        
        List<SBQQ__QuoteLine__c> quoteLinePrimary = new List<SBQQ__QuoteLine__c>();
        List<String> quoteLinesWithoutBilling = new List<String>();

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesListForBillingCheck) {
            if (quoteLine.BillingProfile__c == null) {
                quoteLinesWithoutBilling.add(quoteLine.Name);
            }
        }

        if (!quoteLinesWithoutBilling.isEmpty()) {
            throw new AuraHandledException('Attenzione! Ai bundle “' + String.join(quoteLinesWithoutBilling, ',') +'” non è stato associato un Metodo di Pagamento');
        }

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesList) {
            if (quoteLine.BillingProfile__c != null) {
                quoteLinePrimary.add(quoteLine);
            }
        }

        system.debug('***quoteLinePrimary: ' + quoteLinePrimary);
        
        */
        //2 - Update Opportunity stage
        //opportunitySrv.checkReadAccess('StageName');



        List<Opportunity> opps = opportunityQr.getRecordsBySaleFilterStageName(sale.Id, 'StageName, CampaignEleggibilityGroup__c', 'Negotiation');
        
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
            opp.CampaignEleggibilityGroup__c = campaignElegibilityGroup;
            sobjToUpdate.add(opp);
        }
        
        //3 - Update SBQQ__Quote
        //quoteSrv.checkReadAccess('SBQQ__Status__c,SBQQ__Ordered__c,SBQQ__LineItemsGrouped__c,SBQQ__OrderByQuoteLineGroup__c');
        List<SBQQ__Quote__c> quoteList = quoteQr.getRecordsForSaleSaveEvent(sale.Id); //quotes that have a status of not rejected

        /**@frpanico check for activities
         * Caricamento Manuale Siebel
        */
        Boolean ordered = true;
        Integer currentStep = 4;
        if(sale.isTransition__c)
        {
            String regex = '^D[0-9] - .*';
            Pattern regexPattern = Pattern.compile(regex);
            List<Sale__c> transitionSale = [SELECT Id, IsTransition__c, Account__c, Account__r.CustomerMarking__c FROM Sale__c WHERE Id = :sale.Id WITH SECURITY_ENFORCED];
            if(!transitionSale.isEmpty() && regexPattern.matcher(transitionSale[0].Account__r.CustomerMarking__c).matches())
            {
                ordered = false;
                currentStep = 50;
                HDT_LC_SaleServiceContainer.siebelLoadingActivity(transitionSale[0].Id, transitionSale[0].Account__c, 'Sale__c');
            }
        }
        for (SBQQ__Quote__c quote : quoteList) {
            quote.SBQQ__Status__c = 'Chiusa';
            quote.SBQQ__Ordered__c = ordered;
            quote.SBQQ__LineItemsGrouped__c = true;
            quote.SBQQ__OrderByQuoteLineGroup__c = true;
            quote.CancellationReason__c = null;
            quote.CampaignEleggibilityGroup__c = campaignElegibilityGroup;
            sobjToUpdate.add(quote);
        }

        //system.debug('quoteList: ' + quoteList);

        //4 - Update Sale
        Sale__c saleToUpdate = new Sale__c(Id = sale.Id, Status__c = 'Attiva', CampaignEleggibilityGroup__c = campaignElegibilityGroup, isTransition__c = sale.isTransition__c, CurrentStep__c = currentStep);

        //5 - SBQQ__QuoteLineGroup__c
        //Creazione di un QuoteLineGroup per ogni QuoteLine principale.
        //Associazione su ogni QuoteLineGroup del record configurato su SBQQ__QuoteProcess__c
        //Map<String,SBQQ__QuoteLineGroup__c> mapLineGroup = new Map<String,SBQQ__QuoteLineGroup__c>();

        //quoteProcessSrv.checkReadAccess('SBQQ__Default__c,SBQQ__GuidedOnly__c,SBQQ__ProductAutoSelected__c,SBQQ__ProductConfigurationInitializer__c,SBQQ__ProductSearchExecutor__c,SBQQ__SortOrder__c,Name');
        /*
        List<SBQQ__QuoteProcess__c> quoteProcessList = quoteProcessQr.getProcessForGroupAssoc();
        system.debug('quoteProcessList '+quoteProcessList.size());
        for (SBQQ__QuoteLine__c quoteLine : quoteLinePrimary) {
            SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
                SBQQ__Account__c = sale.Account__c,
                Name = quoteLine.Name + ' Group',
                SBQQ__Quote__c = quoteLine.SBQQ__Quote__c,
                SBQQ__QuoteProcess__c = quoteProcessList[0].Id
            );

            mapLineGroup.put(quoteLine.Id, quoteLineGroup);

        }

        //6 - SBQQ__QuoteLine__c
        //SBQQ__Group: Valorizzazione con l’id Gruppo di riferimento
        quoteLineGroupSrv.createRecords(mapLineGroup.values()); //create QuoteLineGroups to update group id in quoteLine

        List<SBQQ__QuoteLine__c> allQuoteLines = quoteLineQr.getRecordsBySale(sale.Id);
        
        String groupToAssign = null;

        system.debug('***mapLineGroup: ' + json.serialize(mapLineGroup));

        for(SBQQ__QuoteLine__c quoteLine : allQuoteLines){
            // quoteLine.SBQQ__Group__c = mapLineGroup.get(quoteLine.Id).Id;

            if (quoteLine.BillingProfile__c != null) {
                system.debug('quoteLine with problem: ' + quoteLine);
                groupToAssign = mapLineGroup.get(quoteLine.Id)?.Id;

                // if(quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.BillingProfile__c != null){
                //     groupToAssign = mapLineGroup.get(quoteLine.SBQQ__RequiredBy__c).Id;
                // }
                // else if(quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null){
                //     groupToAssign = mapLineGroup.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c).Id;
                // } else {
                //     groupToAssign = mapLineGroup.get(quoteLine.Id).Id;
                // }
            }
            else {
                if(quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.BillingProfile__c != null){
                    groupToAssign = mapLineGroup.get(quoteLine.SBQQ__RequiredBy__c).Id;
                }
                else{
                    if(quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null){
                        groupToAssign = mapLineGroup.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c).Id;
                    }
                }
            }

            SBQQ__QuoteLine__c quoteLineToUpdate = new SBQQ__QuoteLine__c(
                Id = quoteLine.Id,
                SBQQ__Group__c = groupToAssign
            );

            quoteLinesListToUpdate.add(quoteLineToUpdate);
        }
        */
        //if(sale.Id=='a3I3N00000042c6UAA') throw new AuraHandledException('Mio test');
        if(!String.isBlank(campaignMemberId)){
            CampaignMember cm = new CampaignMember();
            cm.Id = campaignMemberId;
            saleToUpdate.CampaignMemberId__c = campaignMemberId;
            saleToUpdate.Campaign__c = [SELECT Id, CampaignId FROM CampaignMember WHERE Id =: campaignMemberId WITH SECURITY_ENFORCED LIMIT 1].CampaignId;
        }

        //system.debug('***salesTransition ->: ' + saleToUpdate.isTransition__c);
        if(saleToUpdate.isTransition__c!= null && saleToUpdate.isTransition__c){
            Account account = new Account(Id = sale.Account__c, Segment__c = 'ZCOD-DA CODIFICARE');
            sobjToUpdate.add(account);
            //accountSrv.updateRecord(account);
        }

        sobjToUpdate.add(saleToUpdate);
        
        HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
        //7 - Execute actions
        /*
        opportunitySrv.updateRecords(opps);
        saleSrv.updateRecord(saleToUpdate);
        quoteLineSrv.updateRecords(quoteLinesListToUpdate);
        quoteSrv.updateRecords(quoteList);
        */
        //update campaignMember Status
        // if (string.isNotBlank(campaignMemberId)) {
        //     CampaignMember myCampaignMember = [select id, Campaign.PositiveOutcomeDefaultStatus__c  from CampaignMember where Id = :campaignMemberId WITH SECURITY_ENFORCED];   
        //     String myStatus = myCampaignMember.Campaign.PositiveOutcomeDefaultStatus__c;
        //     system.debug('CampaignMember-MyStatus --> '+ myStatus);
        //     HDT_LC_CampaignsController.updateCampaignMemberStatus(campaignMemberId, myStatus);
        // }

        

        

        //update campaignMember siblings Status a 'Non Proposto Auto'
        List<String> accountIds = new List<String>();
        accountIds.add(sale.Account__c);
        List<CampaignMember> siblingMembers = HDT_QR_CampaignMember.getSiblingMembersByAccountId(accountIds, campaignChannel);
        List<String> campaignMembersIdList = new List<String>(new Map<String, CampaignMember>(siblingMembers).keySet());
        if (campaignMembersIdList.size()>0) {
            HDT_LC_CampaignsController.updateCampaignMembersStatus(campaignMembersIdList, 'Non Proposto Auto');
        }

        /**@frpanico 17/01/2022
         * Nel caso in cui l'account:
         * Non abbia il Codice Cliente
         * Se la vendita non e' a transitorio
         * Se la marcatura non e' "D*-"
         * Viene cambiata la marcatura in "D*-".
         * In ogni caso, se l'account non ha il Codice Cliente
         * viene chiamato il servizio di Crea BP/CA
         */
        Boolean searchToUse = true;
        for(SBQQ__Quote__c q : quoteList){
            if(q.SBQQ__Pricebook__r.Name.equalsIgnoreCase('Vas Standalone')){
                searchToUse = false;
                break;
            }
        }

        System.enqueueJob(new HDT_QBL_BpCaRequest( accountContactRelationQr.getCreateBpCa( accountIds[0] ), sale.Id, searchToUse ) );

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Save sale backup
     * @param sale
     */
    @AuraEnabled
    public static void saveBackup(Sale__c sale){
        
        //1 - Check if QuoteLines have BillingProfiles associated
        quoteLineSrv.checkReadAccess('Name,BillingProfile__c,SBQQ__Quote__c');
        List<SBQQ__QuoteLine__c> quoteLinesList = quoteLineQr.getRecordsBySaleFilteredPaymentMethodNotNull(sale.Id);
        List<SBQQ__QuoteLine__c> quoteLinesListToUpdate = new List<SBQQ__QuoteLine__c>();

        List<String> quoteLinesWithoutBilling = new List<String>();

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesList) {
            if (quoteLine.BillingProfile__c == null) {
                quoteLinesWithoutBilling.add(quoteLine.Name);
            }
        }
        
        if (!quoteLinesWithoutBilling.isEmpty()) {
            throw new AuraHandledException('Attenzione! Ai bundle “' + String.join(quoteLinesWithoutBilling, ',') +'” non è stato associato un Metodo di Pagamento');
        }

        //2 - Update Opportunity stage
        opportunitySrv.checkReadAccess('StageName');
        List<Opportunity> opps = opportunityQr.getRecordsBySaleFilterStageName(sale.Id, 'StageName', 'Proposal');
        
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
        }
        
        //3 - Update SBQQ__Quote
        quoteSrv.checkReadAccess('SBQQ__Status__c,SBQQ__Ordered__c,SBQQ__LineItemsGrouped__c,SBQQ__OrderByQuoteLineGroup__c');
        List<SBQQ__Quote__c> quoteList = quoteQr.getRecordsForSaleSaveEvent(sale.Id); //quotes that have a status of not rejected

        for (SBQQ__Quote__c quote : quoteList) {
            quote.SBQQ__Status__c = 'Accepted';
            quote.SBQQ__Ordered__c = true;
            quote.SBQQ__LineItemsGrouped__c = true;
            quote.SBQQ__OrderByQuoteLineGroup__c = true;
        }

        system.debug('quoteList: ' + quoteList);

        //4 - Update Sale
        Sale__c saleToUpdate = new Sale__c(Id = sale.Id, Status__c = 'Attiva');

        //5 - SBQQ__QuoteLineGroup__c
        //Creazione di un QuoteLineGroup per ogni QuoteLine principale.
        //Associazione su ogni QuoteLineGroup del record configurato su SBQQ__QuoteProcess__c
        Map<String,SBQQ__QuoteLineGroup__c> mapLineGroup = new Map<String,SBQQ__QuoteLineGroup__c>();

        quoteProcessSrv.checkReadAccess('SBQQ__Default__c,SBQQ__GuidedOnly__c,SBQQ__ProductAutoSelected__c,SBQQ__ProductConfigurationInitializer__c,SBQQ__ProductSearchExecutor__c,SBQQ__SortOrder__c,Name');
        List<SBQQ__QuoteProcess__c> quoteProcessList = quoteProcessQr.getProcessForGroupAssoc();

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesList) {
            SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
                SBQQ__Account__c = sale.Account__c,
                Name = quoteLine.Name + ' Group',
                SBQQ__Quote__c = quoteLine.SBQQ__Quote__c,
                SBQQ__QuoteProcess__c = quoteProcessList[0].Id
            );

            mapLineGroup.put(quoteLine.Id, quoteLineGroup);

        }

        //6 - SBQQ__QuoteLine__c
        //SBQQ__Group: Valorizzazione con l’id Gruppo di riferimento
        quoteLineGroupSrv.createRecords(mapLineGroup.values()); //create QuoteLineGroups to update group id in quoteLine

        List<SBQQ__QuoteLine__c> allQuoteLines = quoteLineQr.getRecordsBySale(sale.Id);
        
        String groupToAssign = null;

        for(SBQQ__QuoteLine__c quoteLine : allQuoteLines){
            // system.debug(mapLineGroup.get(quoteLine.Id).Id);
            // quoteLine.SBQQ__Group__c = mapLineGroup.get(quoteLine.Id).Id;

            if (quoteLine.SBQQ__RequiredBy__c == null) {
                groupToAssign = mapLineGroup.get(quoteLine.Id).Id;
            }
            else {
                if (mapLineGroup.get(quoteLine.SBQQ__RequiredBy__c) == null) {
                    groupToAssign = mapLineGroup.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c).Id;
                } else {
                    groupToAssign = mapLineGroup.get(quoteLine.SBQQ__RequiredBy__c).Id;
                }
            }

            SBQQ__QuoteLine__c quoteLineToUpdate = new SBQQ__QuoteLine__c(
                Id = quoteLine.Id,
                SBQQ__Group__c = groupToAssign
            );

            quoteLinesListToUpdate.add(quoteLineToUpdate);
        }

        //7 - Execute actions
        opportunitySrv.updateRecords(opps);
        saleSrv.updateRecord(saleToUpdate);
        quoteLineSrv.updateRecords(quoteLinesListToUpdate);
        quoteSrv.updateRecords(quoteList);
    }
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Cancel sale
     * @param sale
     * @param cancellationReason
     */
    @AuraEnabled
    public static void cancel(Sale__c sale, String cancellationReason){
        
        //1 - Update sale
        Sale__c saleToUpdate = new Sale__c(Id = sale.Id, Status__c = 'Annullata', CancellationReason__c = cancellationReason);

        //2- Update Opportunity
        opportunitySrv.checkReadAccess('StageName');
        List<Opportunity> opps = opportunityQr.getRecordsBySaleFilterStageName(sale.Id, 'StageName', 'Proposal');
        
        if (!opps.isEmpty()) {
            for (Opportunity opp : opps) {
                opp.StageName = 'Closed Lost';
            }
        }

        //3 - Update Quotes
        quoteSrv.checkReadAccess('SBQQ__Status__c');
        List<SBQQ__Quote__c> quoteList = quoteQr.getRecordsForSaleCancelEvent(sale.Id); //quotes that have a status of not rejected

        if (!quoteList.isEmpty()) {
            for (SBQQ__Quote__c quote : quoteList) {
                quote.SBQQ__Status__c = 'Rifiutata';
            }
        }

        //4 - Excecute actions
        saleSrv.updateRecord(saleToUpdate);

        if (!opps.isEmpty()) {
            opportunitySrv.updateRecords(opps);
        }

        if (!quoteList.isEmpty()) {
            quoteSrv.updateRecords(quoteList);
        }

    }
}