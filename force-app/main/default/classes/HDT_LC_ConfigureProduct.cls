/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_LC_ConfigureProduct.cls - Class that holds methods that are called from hdtConfigureProduct.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ConfigureProduct {
    
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_Opportunity opportunityQr = new HDT_QR_Opportunity();
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_SRV_ActivityCustom actSrv = new HDT_SRV_ActivityCustom();
    private static HDT_QR_Recordtype rctype = new HDT_QR_Recordtype();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 18/11/2020
     * @description Get SBQQ__Quote__c and SBQQ__QuoteLine__c records to fill table
     * @param String Sale.Id
     * @return List<Map<String,List<SObject>>>
     */
    @AuraEnabled
    public static List<Map<String,List<SObject>>> getQuotes(String saleId){

        List<Map<String,List<SObject>>> resultsList = new List<Map<String,List<SObject>>>();

        quoteSrv.checkReadAccess('Name,SBQQ__Opportunity2__r.Name,SBQQ__Type__c,AmendmentAllowed__c,ContractReference__c');
        quoteLineSrv.checkReadAccess('Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,BillingProfile__c,BillingProfile__r.Name,AmendmentAllowed__c,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name');

        List<SBQQ__Quote__c> quoteList = quoteQr.getActiveRecords(saleId);
        List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQr.getRecordsBySale(saleId);

        resultsList = quoteLineSrv.groupRecordsByQuote(quoteList, quoteLineList);

        return resultsList;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 19/11/2020
     * @description Cancel SBQQ__Quote__c record by changing its status (Status=”Annullata”) and related Opportunity (StageName= “Chiusa/Annullata”)
     * @param String quoteId
     * @param String opportunityId
     * @param String cancellationReason
     */
    /**@frpanico 03/02/2022
     * Aggiunto update IsTransition = false
     * sull'oggetto Sale__c
     * Ottimizzata le dml
     */
    @AuraEnabled
    public static void cancelQuote(String quoteId, String opportunityId, String cancellationReason){
        
        List<SObject> sobjsToUpdate = new List<SObject>();
        Sale__c sale = new Sale__c();

        SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(
            Id = quoteId,
            CancellationReason__c = cancellationReason
        );

        switch on cancellationReason {
            when  'Errata operativita'{
                quoteToUpdate.SBQQ__Status__c = 'Cancelled';
            }
            when 'Volonta cliente'{
                quoteToUpdate.SBQQ__Status__c = 'Rejected';
            }
        }

        Opportunity opp = opportunityQr.getRecordById(opportunityId);

        Opportunity oppToUpdate = new Opportunity(
            Id = opportunityId,
            StageName = 'Closed Lost'
        );
        
        sale.Id = opp.Sale__c;
        sale.IsTransition__c = false;
        /* IsTransition a false sulla vendita va messo solo ed esclusivamente se non vi sono altre quote con IsTransition a true*/
        List<SBQQ__Quote__c> otherQuotes = [SELECT Id, IsTransition__c FROM SBQQ__Quote__c WHERE Id != :opp.SBQQ__PrimaryQuote__c AND Sale__c = :opp.Sale__c AND SBQQ__Status__c NOT IN ('Cancelled','Rejected') AND  IsTransition__c = true WITH SECURITY_ENFORCED];
        if(!otherQuotes.isEmpty())
        {
            sale.IsTransition__c = true;
        }
        sobjsToUpdate.add(quoteToUpdate);
        sobjsToUpdate.add(oppToUpdate);
        sobjsToUpdate.add(sale);

        HDT_UTL_DatabaseService.updateSObject(sobjsToUpdate);
        /*
        quoteSrv.updateRecord(quoteToUpdate);
        opportunitySrv.updateRecord(oppToUpdate);
        */
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Check if all Quotes have QuoteLines configured
     * @param Sale__c sale
     */
    public static void checkQuotesHaveQuoteLines(Sale__c sale){
        //all quotes should have quotelines
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,ServicePoint__c');
        List<SBQQ__QuoteLine__c> quoteLinesActive = quoteLineQr.getActiveRecords(sale.Id);

        quoteSrv.checkReadAccess('Name,SBQQ__Opportunity2__r.Name,SBQQ__Type__c,SBQQ__Status__c,SBQQ__Ordered__c,SBQQ__LineItemsGrouped__c,SBQQ__OrderByQuoteLineGroup__c');
        List<SBQQ__Quote__c> quotesActive = quoteQr.getActiveRecords(sale.Id);

        Set<String> quotesWithQuoteLines = new Set<String>();
        for (SBQQ__QuoteLine__c quoteLineActive : quoteLinesActive) {
            quotesWithQuoteLines.add(quoteLineActive.SBQQ__Quote__c);
        }

        List<String> quotesWithoutQuoteLines = new List<String>();

        for (SBQQ__Quote__c quoteActive : quotesActive) {
            if (!quotesWithQuoteLines.contains(quoteActive.Id)) {
                quotesWithoutQuoteLines.add(quoteActive.Name);
            }
        }

        if (!quotesWithoutQuoteLines.isEmpty()) {
            throw new AuraHandledException('Attenzione Non hai configurato i prodotti per le seguenti quote ' + String.join(quotesWithoutQuoteLines, ','));
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Check if all QuoteLines have Service Points associated
     * @param Sale__c sale
     */
    public static void checkServicePointAssocs(Sale__c sale){
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c');
        List<SBQQ__QuoteLine__c> quoteLinePods = quoteLineQr.getActiveRecordsBySaleIdAndProductPod(sale.Id);

        List<String> quoteLinePodsWithoutServicePoints = new List<String>();

        for (SBQQ__QuoteLine__c quoteLinePod : quoteLinePods) {
            if (quoteLinePod.ServicePoint__c == null) {
                quoteLinePodsWithoutServicePoints.add(quoteLinePod.Name);
            }
        }

        //part 1 - check if all ql have sp assoc
        if (!quoteLinePodsWithoutServicePoints.isEmpty()) {
            throw new AuraHandledException('Attenzione ai QLI - ' + String.join(quoteLinePodsWithoutServicePoints, ',') + ' non risulta associato nessun service point');
        }

        //part2 - check if quotes have enough sp assoc
        saleServiceItemSrv.checkReadAccess('Opportunity__c,Opportunity__r.Sale__c,Opportunity__r.Name,Opportunity__r.CreatedDate,Quote__c,Quote__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName,ServicePoint__r.SupplyCity__c');
        List<SaleServiceItem__c> saleServiceItems = saleServiceItemQr.getActiveRecordsBySaleId(sale.Id);

        system.debug(loggingLevel.DEBUG,'keltin saleServiceItems: ' + saleServiceItems);
        system.debug(loggingLevel.DEBUG,'keltin saleServiceItems size: ' + saleServiceItems.size());
        system.debug(loggingLevel.DEBUG,'keltin quoteLinePods: ' + quoteLinePods);
        system.debug(loggingLevel.DEBUG,'keltin quoteLinePods size: ' + quoteLinePods.size());
        /**@frpanico 18/02/2022
         * Se la quote è legata ad un Vas o quote di Amend
         * Non c'è nessuna quoteLine Pod/Pdr
         */
        if (!quoteLinePods.isEmpty() && quoteLinePods.size() != saleServiceItems.size()) {
            throw new AuraHandledException('Configurare i prodotti per tutti i Service Point!');
        }

        //part3 - check duplicated service point assoc
        checkDuplicatedServicePointAssocs(quoteLinePods);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Check if Service Points are not associated twice
     * @param List<SBQQ__QuoteLine__c> quoteLinePods
     */
    public static void checkDuplicatedServicePointAssocs(List<SBQQ__QuoteLine__c> quoteLinePods){

        Set<String> encounteredServicePoints = new Set<String>();
        Set<String> duplicateServicePoints = new Set<String>();
        /* Modificato da ServicePointCOde__c a controllo su ServicePoint__c in quanto Acqua e Ambiente non hanno il codice punto */
        for (SBQQ__QuoteLine__c quoteLinePod : quoteLinePods) {
            if(encounteredServicePoints.contains(quoteLinePod.ServicePoint__c)){
                duplicateServicePoints.add(quoteLinePod.ServicePoint__c);
            }else{
                encounteredServicePoints.add(quoteLinePod.ServicePoint__c);
            }
        }

        List<String> duplicateServicePointsList = new List<String>(duplicateServicePoints);

        if (!duplicateServicePointsList.isEmpty()) {
            throw new AuraHandledException('Attenzione i Punti di fornitura '+String.join(duplicateServicePointsList, ',')+' sonno stati abbinati a più offerte');
        }

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Perform all check validations on next event
     * @param Sale__c sale
     */
    public static void performChecks(Sale__c sale){
        checkQuotesHaveQuoteLines(sale);
        checkServicePointAssocs(sale);
    }

    private static void updateQuotesOnNext(String saleId){
        List<SBQQ__Quote__c> quotes = quoteQr.getActiveRecords(saleId);
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();

        for (SBQQ__Quote__c q : quotes) {
            quotesToUpdate.add(
                new SBQQ__Quote__c(
                    Id = q.Id,
                    SBQQ__SubscriptionTerm__c = 1200,
                    SBQQ__StartDate__c = System.today()
                )
            );
        }

        quoteSrv.updateRecords(quotesToUpdate);
    }

    // Create an amendment context
    private with sharing class HDT_WRP_AmendmentContext {
        public Boolean returnOnlyQuoteId;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Amend contract
     * @param String contractId
     * @return (SBQQ__Quote__c) JSON.deserialize(quoteJSON, SBQQ__Quote__c.class)
     */
    @AuraEnabled
    public static SBQQ__Quote__c amendContract(String contractId){

        HDT_WRP_AmendmentContext context = new HDT_WRP_AmendmentContext();
        context.returnOnlyQuoteId = true;
        String contextJson = JSON.serialize(context);
        System.debug('contextJson: ' + contextJson);

        String quoteJson = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, contextJson);
        System.debug('amendContract: ' + quoteJson);
        return (SBQQ__Quote__c) JSON.deserialize(quoteJson, SBQQ__Quote__c.class);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale on previous (modifica)
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSalePrevious(Sale__c sale){
        saleSrv.updateRecord(sale);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale on next (avanti)
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSaleNext(Sale__c sale){
        performChecks(sale);
        updateQuotesOnNext(sale.Id);
        checkRateCategory(sale.Id);
        saleSrv.updateRecord(sale);
    }

    @AuraEnabled
    public static void checkRateCategory( id saleId ){

        List<sbqq__quoteline__c> qlList = [SELECT ServicePoint__c, ServicePoint__r.RateCategory__c, SBQQ__Product__r.service__c, SBQQ__Product__c, SBQQ__ProductFamily__c, SBQQ__ProductName__c, SBQQ__ProductCode__c 
                                            FROM sbqq__quoteline__c 
                                            WHERE sbqq__Quote__r.Sale__c = :saleId AND SBQQ__Product__r.service__c ='Acqua' WITH SECURITY_ENFORCED ];
        for( sbqq__quoteline__c ql: qlList ){
            if( ql.ServicePoint__r.RateCategory__c != null && 'ACAUNOPOT0'.equalsIgnoreCase(ql.SBQQ__ProductCode__c) && ql.SBQQ__ProductCode__c != ql.ServicePoint__r.RateCategory__c ){
                throw new AuraHandledException('Errore sulla RateCategory');
            }
        }
 
    }

    /***
     * Nuovo Metodo VALIDO SOLO PER H20 che applica sulle quote line afferenti a contratti attivi sui quali si sta cambiando solo l'offerta (a parità di intestatario)
     * il billing profile associato al contratto
    */
    public static void applyBillingProfileAsIs(Sale__c sale, List<SBQQ__QuoteLine__c> quoteLinesActive ){

        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c quoteLine : quoteLinesActive){

            if('Attivo'.equalsIgnoreCase(quoteLine.SBQQ__Quote__r.ContractReference__r.Status) && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__c == quoteLine.SBQQ__Quote__r.ContractReference__r.AccountId &&
                'Acqua'.equalsIgnoreCase(quoteLine.ServicePoint__r.CommoditySector__c) &&
                quoteLine.SBQQ__RequiredBy__c != null)
            {
                quoteLine.SBQQ__RequiredBy__r.BillingProfile__c = quoteLine.SBQQ__Quote__r?.ContractReference__r?.BillingProfile__c;
                quoteLinesToUpdate.add(quoteLine.SBQQ__RequiredBy__r);
            }
        }

        if(!quoteLinesToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(quoteLinesToUpdate);
        }

    }

    @AuraEnabled
    public static wrapReturnValidity checkApprovedProduct(Sale__c sale){
        list<String> listId = new List<String>();
        list<String> idToCreateActivity = new List<String>();
        map<String,boolean> checkIsPresent = new Map<string,boolean>();
        wrapReturnValidity resp = new wrapReturnValidity();
        resp.wrapCheck = true;
        resp.responseError = '';
        // Boolean hasPermission = FeatureManagement.checkPermission('HDT_CP_SuperUserCPQ');
        Map<String,wrts_prcgvr__Activity__c> orderLineActivity = new Map<String,wrts_prcgvr__Activity__c>();
        List<SBQQ__QuoteLine__c> quoteLinesActive = quoteLineQr.getActiveRecords(sale.Id);

        applyBillingProfileAsIs( sale, quoteLinesActive );

        if( !isSwitchInRipristinatorio(sale, quoteLinesActive ) ){
            for(SBQQ__QuoteLine__c line : quoteLinesActive){
                if(line.SBQQ__Product__c != null && line.SBQQ__Product__r.Status__c == 'Scaduta' ){//line.SBQQ__Product__r.EndDate__c < date.today()){
                    listId.add(line.id);                //segna i SBQQ__QuoteLine__c "Scaduti"
                    checkIsPresent.put(line.id,true);
                }
            }
        }
        if(!listId.isEmpty()){ //per i SBQQ__QuoteLine__c Scaduti
            List<wrts_prcgvr__Activity__c> listActivity = HDT_QR_ActivityCustom.getRecordByOrderLine(listId);
            System.debug('*****DEBUGActivity:' + listActivity);
            Set<String> quoteToUpdateId = new Set<String>();
            List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
            for(wrts_prcgvr__Activity__c a : listActivity){
                orderLineActivity.put(a.QuoteLine__c,a);
            }
            System.debug('*****DEBUGActivity2:' + orderLineActivity);
            for(SBQQ__QuoteLine__c line : quoteLinesActive){
                if(checkIsPresent.get(line.id)!= null){
                    if(orderLineActivity.get(line.id) != null){ //"if" not needed???
                        System.debug('*****DEBUGActivityDENTROIF:' + line);
                        if(orderLineActivity.get(line.id) != null &&  orderLineActivity.get(line.id).approved__c != 'Si'){
                            resp.responseError += (resp.responseError == '' ? line.sbqq__product__r.Name : ',' + line.sbqq__product__r.Name);
                            resp.wrapCheck = false;
                        }
                    }
                    else{
                        System.debug('*****DEBUGActivityDENTROELSE:' + line);
                        resp.responseError += (resp.responseError == '' ? line.sbqq__product__r.Name : ',' + line.sbqq__product__r.Name);
                        idToCreateActivity.add(line.id);
                        quoteToUpdateId.add(line.sbqq__quote__c);
                        resp.wrapCheck = false;
                    }
                 }
            }
            if(idToCreateActivity != null && !idToCreateActivity.isEmpty()){
                Id recTypeId= null;
                RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
                if(rc !=null){
                    recTypeId= rc.Id;
                }
                List<wrts_prcgvr__Activity__c> listActivityToCreate = new List<wrts_prcgvr__Activity__c>();
                for(String s : idToCreateActivity){
                    listActivityToCreate.add(new wrts_prcgvr__Activity__c(QuoteLine__c=s, RecordTypeId= recTypeId, Type__c= 'Approvazione Offerte',Account__c=sale.Account__r.Id,Sale__c=sale.id,wrts_prcgvr__Status__c='Aperta'));
                }
                for(String s : quoteToUpdateId){
                    quoteToUpdate.add(new SBQQ__Quote__C(id=s,SBQQ__Status__c='In Revisione'));
                }
                System.debug('listActivityToCreate : ' + listActivityToCreate);
                actSrv.createRecord(listActivityToCreate);
                quoteSrv.updateRecords(quoteToUpdate);
            }
        }else{
            return resp;
        }
        
        return resp;
    }
    @testVisible
    public static Boolean isSwitchInRipristinatorio(Sale__c sale, List<SBQQ__QuoteLine__c> quoteLinesActive ){
        //List<SBQQ__Quote__c> quotes = [SELECT AmendmentAllowed__c, AllowChangeUse__c FROM SBQQ__Quote__c WHERE Sale__c =:sale.Id WITH SECURITY_ENFORCED];
        List<SaleServiceItem__c> salSerItems = [SELECT ServicePoint__c, ServicePoint__r.ServicePointCode__c, 
                                                       Quote__r.SBQQ__Account__c, Quote__r.AmendmentAllowed__c, Quote__r.AllowChangeUse__c, Quote__r.ContractReference__c
                                                FROM SaleServiceItem__c 
                                                WHERE Quote__r.sale__c =:sale.Id 
                                                WITH SECURITY_ENFORCED];
        Boolean result = false;
        List<wrts_prcgvr__Activity__c> activityList = new List<wrts_prcgvr__Activity__c>();
        if ( !salSerItems.isEmpty() && salSerItems[0].ServicePoint__c != null) {
            activityList = HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePointNotStatus('Gestione Switch in Ripristinatorio', 'Completed', salSerItems[0].Quote__r.SBQQ__Account__c, salSerItems[0].ServicePoint__r.ServicePointCode__c);
        }
        if (!activityList.isEmpty()
            && !salSerItems[0].Quote__r.AmendmentAllowed__c 
            && !salSerItems[0].Quote__r.AllowChangeUse__c  
            && !isCambioOfferta(salSerItems[0], quoteLinesActive)) {
                result = true;
        }
        return result;
    }

    public static Boolean isCambioOfferta(SaleServiceItem__c salSerItems, List<SBQQ__QuoteLine__c> quoteLinesActive ){
        //getRecordsByOrderIdFilteredPdrPod
        Boolean isOffertaCommerciale=false;
        for (SBQQ__QuoteLine__c quoteLines : quoteLinesActive) {
            if( quoteLines.SBQQ__Product__r.Name == 'PDR' || quoteLines.SBQQ__Product__r.Name == 'POD' ){
                isOffertaCommerciale=true;
            }
        }
        Boolean result = isOffertaCommerciale && !salSerItems.Quote__r.AllowChangeUse__c && salSerItems.Quote__r.ContractReference__c != null && !salSerItems.Quote__r.AmendmentAllowed__c;
        return result;
    }

    public class wrapReturnValidity{
        @AuraEnabled public boolean wrapCheck {get;set;} 
        @AuraEnabled public string responseError {get;set;}
    }
}