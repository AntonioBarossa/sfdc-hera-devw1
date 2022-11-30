/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/01/2021
* @description Apex controller for hdtSaleVas.js component
* @history Keltin Mesonjesi – 19/01/2021 – Created class
*/
public inherited sharing class HDT_LC_SaleVas {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action logic
     * @param selectedOption
     * @param order
     * @param contract
     * @param supplyCity
     * @param accountId
     * @param sale
     */
    @AuraEnabled
    public static void confirmAction(String selectedOption, Order order, Contract contract, String supplyCity, String accountId, Sale__c sale){
        sale = saleQr.getRecordById(sale.id, 'AgencyCode__c,CommercialId__c ,Account__c,Account__r.Category__c,Account__r.CustomerMarking__c,Agency__c,Account__r.CompanyOwner__c,Channel__c,FriendCode__c,CampaignCode__c,CreatedBy__c,SalesCompany__c,Campaign__c,Name, Campaign__r.CampaignEligibilityGroup__c');
        switch on selectedOption {
            when  'Ordini in corso'{
                handleActiveOrderConfirm(order, supplyCity, sale);
            }
            when 'Contratti Attivi'{
                handleActiveContractConfirm(contract, supplyCity, sale);
            }
            when 'VAS stand alone'{
                handleVasStandAloneConfirm(supplyCity, accountId, sale);
            } 
            
        }
    }

    /**
     * @description transitionCheck
     * @param salesId
     * @return Boolean
     */
    @AuraEnabled
    public static boolean transitionCheck(String salesId){
        Sale__c sal = saleQr.getRecordById(salesid,'id,isTransition__c,Account__r.Category__c,Account__r.CompanyOwner__c');
        boolean check = true;
        //HDT_UTL_Sales.isTransitionNoUp()
        //System.debug('*****MAVUOIANNA:'+ transitionlist);
        //ServicePoint__c sa = new ServicePoint__c(SupplyProvince__c = 'AQ');
        wrapReturn wrpRes = new wrapReturn();

        if(HDT_UTL_Sales.isTransitionNoUp(sal)){
            check = false;
            wrpRes.messRes = 'transitorio';
        }

        wrpRes.res = check;

        System.debug('*****VUOIANNA2:' + check);
        return check;
    }

    /**
     * @description transitionCheckNew
     * @param salesId
     * @param comune
     * @param tipologia
     * @return wrapReturn
     */
    @AuraEnabled
    public static wrapReturn transitionCheckNew(String salesId,String comune,string tipologia){
        Sale__c sal = saleQr.getRecordById(salesid,'id,isTransition__c,Account__r.Category__c,Account__r.CompanyOwner__c,Account__r.CustomerMarking__c');
        boolean check = true;
        //HDT_UTL_Sales.isTransitionNoUp()
        //System.debug('*****MAVUOIANNA:'+ transitionlist);
        //ServicePoint__c sa = new ServicePoint__c(SupplyProvince__c = 'AQ');
        String com = comune.toUpperCase();
        wrapReturn wrpRes = new wrapReturn();
        if(tipologia == 'VAS stand alone'){
            List<City__c> listCity = HDT_QR_City.getRecordByComune(com);
            if(listCity != null && !listCity.isEmpty() && listCity[0].Province__c != null){
                String provin = listCity[0].Province__c;
                Set<String> stabbedData = new Set<String>{'AQ', 'CH', 'PE', 'TE', 'AN', 'AP', 'FM', 'MC', 'PU'};//province abbruzzo e marche
                if(!stabbedData.contains(provin)){
                    check = false;
                    wrpRes.messRes = 'transitorio';
                }
            }
            else{
                check = false;
                wrpRes.messRes = 'city';
            }
        }
        if(HDT_UTL_Sales.isTransitionVas(com, sal) ){
            check = false;
            wrpRes.messRes = 'transitorio';

            String result = '';
            String regex = '^D[0-9] - .*';
            Pattern regexPattern = Pattern.compile(regex);
            if( regexPattern.matcher(sal.Account__r.CustomerMarking__c).matches() ){
                check = false;
                wrpRes.messRes = 'AccountMigratoTransitorio';
            }
        }
        wrpRes.res = check;
        System.debug('*****VUOIANNA2:' + check);
        return wrpRes;
    }

    /**
     * @description wrapReturn
     */
    public class wrapReturn{
        @AuraEnabled public boolean res = true;
        /**
        * @description messRes
        */
        @AuraEnabled public string messRes {get;set;}
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get list of active orders based on accountId when 'Ordini in corso' is selected
     * @param accountId
     * @return List<Order>
     */
    @AuraEnabled
    public static List<Order> getOrdersList(String accountId){
        //Orders with status "Draft" or "In Lavorazione"
        orderSrv.checkReadAccess('Name,AccountId,OrderNumber,Status,ServicePoint__c,ServicePoint__r.ServicePointCode__c,SupplyAddress__c');
        return orderQr.getRecordsForVasSelection(accountId);
    }

    /**
     * @description getOrdersListNotActive
     * @param accountId
     * @return List<Order>
     */
    @AuraEnabled
    public static List<Order> getOrdersListNotActive(String accountId){
        //Orders with status "Draft" or "In Lavorazione"
        orderSrv.checkReadAccess('Name,AccountId,OrderNumber,Status,ServicePoint__c,ServicePoint__r.ServicePointCode__c,SupplyAddress__c');
        return orderQr.getRecordsNotActivated(accountId);
    }
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get list of active contracts based on accountId when 'Contratti Attivi' is selected
     * @param accountId
     * @return List<Contact>
     */
    @AuraEnabled
    public static List<Contract> getContractsList(String accountId){
        //Contracts with status "Activated"
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,Status');
        return contractQr.getActiveRecordsByAccountId(accountId);
    }


    /**
     * @author Federico de Felice (federico.defelice@webresults.it)
     * @description Get list of active contracts based on accountId when 'Contratti Attivi' is selected
     * @param accountId
     * @return List<Contact>
     */
    @AuraEnabled
    public static List<Contract> getTempNuovaAttivazContracts(String accountId){
        //Contracts with status "Activated"
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,Status');
        return contractQr.getTempNewActivationContractsByAccountId(accountId);
    }

    /**
    * @description Getting list of Orders/Assets/Subscription
    * @author gabriele.rota@webresults.it | 2021-07-21 
    * @param searchString 
    * @param key 
    * @return List<SObject> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<SObject> getFornitura(String searchString, String key){
        List<SObject> records = new List<SObject>();
        system.debug('searchString '+searchString);
        system.debug('key '+key);

        switch on key {
            when 'ORDERS_IN_PROGRESS_VAS'{
                records = [SELECT Type, OrderNumber, ProcessType__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SupplyAddress__c
                    FROM Order
                    WHERE RecordType.DeveloperName='HDT_RT_VAS' AND Status='In Lavorazione' AND SBQQ__Quote__r.IsVAS__c = true
                    AND SBQQ__Quote__r.AmendmentAllowed__c != true AND AccountId=:searchString WITH SECURITY_ENFORCED];
            }
            when 'ORDERS_ELE'{
                records = [SELECT Type, OrderNumber, ProcessType__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SupplyAddress__c
                    FROM Order
                    WHERE CommodityFormula__c='Energia Elettrica' AND AccountId=:searchString WITH SECURITY_ENFORCED];
            }
            when 'CONTRACT_BONUS_COMM'{
                records = [Select id,SapContractCode__c,ContractNumber,ServicePoint__r.SupplyAddress__c,ServicePoint__r.ServicePointCode__c From Contract where AccountId =:searchString WITH SECURITY_ENFORCED];
            }
            //Disattivazione VAS - START
            when 'ASSETS_ACTIVATED'{
                Map<Id,Asset> recordMap = new Map<Id,Asset>([SELECT Name, SerialNumber, InstallDate, Contact.Name, Product2.Name,Contract__r.SAPContractCode__c
                    FROM Asset WHERE DigitalAssetStatus='Attivo' AND SBQQ__RootAsset__c=null AND AccountId=:searchString WITH SECURITY_ENFORCED]);
                
                //removing assets which already have a deactivation Case
                List<Case> assetsCases = [SELECT AssetId FROM Case WHERE Status NOT IN ('Bozza', 'Closed') AND Type='Disattivazione VAS'
                    AND AssetId IN :recordMap.keySet() WITH SECURITY_ENFORCED];
                for (Case assetCase:assetsCases) {
                    recordMap.remove(assetCase.AssetId);
                }
                records = recordMap.values();
            }
            when 'SUBS_ANALISI_CONSUMI'{ 
                Map<Id,SBQQ__Subscription__c> recordMap = new Map<Id,SBQQ__Subscription__c>([SELECT SBQQ__Product__r.Name,SBQQ__Contract__r.SAPContractCode__c,
                    SBQQ__Contract__r.ContractNumber,
                    SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c, SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c
                    FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Family='VAS Fatturabili' AND IsMigrated__c = false AND SBQQ__Account__c=:searchString WITH SECURITY_ENFORCED]);

                //removing subscriptions which already have a deactivation Case
                List<Case> subsCases = [SELECT Subscription__c FROM Case WHERE Phase__c NOT IN ('Annullato','Bozza Annullata') AND Type='Disattivazione VAS'
                    AND Subscription__c IN :recordMap.keySet() WITH SECURITY_ENFORCED];
                for (Case subCase:subsCases) {
                    recordMap.remove(subCase.Subscription__c);
                }
                records = recordMap.values();
            }
            when 'SUBS_ANALISI_CONSUMI_RENEW'{ 
                Map<Id,SBQQ__Subscription__c> recordMap = new Map<Id,SBQQ__Subscription__c>([SELECT SBQQ__Product__r.Name,SBQQ__Contract__r.SAPContractCode__c,
                    SBQQ__Contract__r.ContractNumber,
                    SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c, SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c
                    FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Family='VAS Fatturabili'AND IsMigrated__c = false AND SBQQ__SubscriptionType__c = 'Renewable' AND SBQQ__Account__c=:searchString WITH SECURITY_ENFORCED]);

                //removing subscriptions which already have a deactivation Case
                List<Case> subsCases = [SELECT Subscription__c FROM Case WHERE Phase__c NOT IN ('Annullato','Bozza Annullata') AND Type='Disattivazione VAS'
                    AND Subscription__c IN :recordMap.keySet() WITH SECURITY_ENFORCED];
                for (Case subCase:subsCases) {
                    recordMap.remove(subCase.Subscription__c);
                }
                records = recordMap.values();
            }
            when 'SUBS_VAS_SERVIZIO'{ 
                Map<Id,SBQQ__Subscription__c> recordMap = new Map<Id,SBQQ__Subscription__c>([SELECT SBQQ__Product__r.Name, SBQQ__Contract__r.ContractNumber,
                    SBQQ__Contract__r.SAPContractCode__c, SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c, SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c
                    FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Family='VAS Servizio' AND IsMigrated__c = false AND SBQQ__Account__c=:searchString WITH SECURITY_ENFORCED]);

                //removing subscriptions which already have a deactivation Case
                List<Case> subsCases = [SELECT Subscription__c FROM Case WHERE Phase__c NOT IN ('Annullato','Bozza Annullata') AND Type='Disattivazione VAS'
                    AND Subscription__c IN :recordMap.keySet() WITH SECURITY_ENFORCED];
                for (Case subCase:subsCases) {
                    recordMap.remove(subCase.Subscription__c);
                }
                records = recordMap.values();
            }
            when 'SUBS_VAS_SERVIZIO_RENEW'{ 
                Map<Id,SBQQ__Subscription__c> recordMap = new Map<Id,SBQQ__Subscription__c>([SELECT SBQQ__Product__r.Name, SBQQ__Contract__r.ContractNumber,
                    SBQQ__Contract__r.SAPContractCode__c, SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c, SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c
                    FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Family='VAS Servizio' AND SBQQ__Product__r.Renewable__c = true AND SBQQ__Account__c=:searchString WITH SECURITY_ENFORCED]);

                //removing subscriptions which already have a deactivation Case
                List<Case> subsCases = [SELECT Subscription__c FROM Case WHERE Phase__c NOT IN ('Annullato','Bozza Annullata') AND Type='Disattivazione VAS'
                    AND Subscription__c IN :recordMap.keySet() WITH SECURITY_ENFORCED];
                for (Case subCase:subsCases) {
                    recordMap.remove(subCase.Subscription__c);
                }
                records = recordMap.values();
            }
            //Disattivazione VAS - END
            //Segnalazioni VAS - START
            when 'CONTRACTS_VAS'{ 
                Set<Id> contractIds = new Set<Id>();
                Set<Id> servicePointIds = new Set<Id>();
                List<SObject> sobjList = new List<SObject>();
                // for(Order o : [SELECT ContractReference__c, ServicePoint__c FROM Order WHERE (RecordType.DeveloperName='HDT_RT_VAS' OR RecordType.DeveloperName='HDT_RT_ScontiBonus') AND AccountId=:searchString AND (ContractReference__c!=null OR ServicePoint__c!= null) WITH SECURITY_ENFORCED]){
                //     contractIds.add(o.ContractReference__c);
                //     servicePointIds.add(o.ServicePoint__c);
                // }
                // records = [SELECT ContractNumber, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SupplyAddress__c FROM Contract
                //     WHERE (Id IN :contractIds OR ServicePoint__c IN :servicePointIds) AND Status!='Cessato' WITH SECURITY_ENFORCED];
                sobjList.addAll([SELECT Id, SBQQ__Contract__c, SBQQ__Contract__r.Status, SBQQ__Contract__r.ContractNumber, SBQQ__Contract__r.ServicePoint__c, 
                 SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c, SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c
                 FROM SBQQ__Subscription__c WHERE SBQQ__Account__c = :searchString AND (VasPracticeCode__c != null OR SBQQ__Product__r.Family='VAS Fatturabili') AND SBQQ__Contract__r.Status IN ('Attivo','Cessato')]);
                sobjList.addAll([SELECT Id, Contract__c, Contract__r.Status, Contract__r.ContractNumber, Contract__r.ServicePoint__c,
                Contract__r.ServicePoint__r.ServicePointCode__c, Contract__r.ServicePoint__r.SupplyAddress__c
                 FROM Asset WHERE AccountId = :searchString AND VasPracticeCode__c != null AND Contract__r.Status IN ('Attivo','Cessato')]);
                for(SObject sobj : sobjList)
                {
                    String sobjName = sobj.getSObjectType().getDescribe().getName();
                    String contractId = '';
                    if(sobjName.equalsIgnoreCase('SBQQ__Subscription__c'))
                    {
                        contractId = (String)sobj.get('SBQQ__Contract__c');
                    }
                    if(sobjName.equalsIgnoreCase('Asset'))
                    {
                        contractId = (String)sobj.get('Contract__c');
                    }
                    if(!contractIds.contains(contractId))
                    {
                        contractIds.add(contractId);
                    }
                }
                 
                records = [SELECT Id, SAPContractCode__c,Status, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SupplyAddress__c FROM Contract WHERE ID IN :contractIds WITH SECURITY_ENFORCED];

            }
            when 'SUBS_FROM_CONTRACT'{ 
                records = [SELECT Name, SBQQ__ProductName__c
                    FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c=:searchString and SBQQ__Product__r.Family like 'VAS%'
                    WITH SECURITY_ENFORCED];
            }
            when 'ASSETS_FROM_CONTRACT'{
                records = [SELECT Name, Product2.Name
                    FROM Asset WHERE Contract__c=:searchString and Product2.Family like 'VAS%'
                    WITH SECURITY_ENFORCED];
            }
            //Segnalazioni VAS - END
            when 'CONTRACT_ELE_ACTIVE'{
                records = [SELECT ContractNumber, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SupplyAddress__c
                    FROM Contract WHERE Status IN ('Attivo','Activated') AND AccountId=:searchString
                    AND (ServicePoint__r.CommoditySector__c='Energia Elettrica' OR SBQQ__Order__r.ServicePoint__r.CommoditySector__c='Energia Elettrica')
                    WITH SECURITY_ENFORCED];
            }
            //Generiche Tari
            when 'RICHIESTA_SERVIZIO_ASSOCIATA'{

                records.addAll([SELECT OrderNumber, ProcessType__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SupplyAddress__c
                FROM Order
                WHERE ServicePoint__c =:searchString 
                AND AccountId IN (SELECT Account__c FROM ServicePoint__c WHERE Id =:searchString)
                WITH SECURITY_ENFORCED
                ]);
                records.addAll(
                    [SELECT Type, CaseNumber, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SupplyAddress__c
                    FROM Case
                    WHERE  ServicePoint__c =:searchString
                    AND RecordTypeId!=:Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_GenericheTari').getRecordTypeId()
                    AND AccountId IN (SELECT Account__c FROM ServicePoint__c WHERE Id =:searchString)
                    WITH SECURITY_ENFORCED
                    ]
                );
            }
            when 'RIMOZIONE_AGEVOLAZIONE'{
                Set<Id> contrIds = new Set<Id>();
                List<AggregateResult> results = [
                    Select SBQQ__Contract__c 
                    From SBQQ__Subscription__c 
                    WHERE  
                        SBQQ__Contract__r.Status = 'Attivo' AND SBQQ__Account__c=:searchString 
                        AND SBQQ__Contract__r.ServicePoint__r.CommoditySector__c='Ambiente'
                    WITH SECURITY_ENFORCED
                    Group by SBQQ__Contract__c 
                    HAVING Count(Id)>1
                ];
                for(AggregateResult res : results){
                    contrIds.add((Id) res.get('SBQQ__Contract__c'));
                }
                records = [ Select id,SapContractCode__c,ContractNumber,ServicePoint__r.SupplyAddress__c,ServicePoint__r.ServicePointCode__c From Contract where Id IN :contrIds WITH SECURITY_ENFORCED];
            }
        }
        return records;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get map with lists of active contracts and orders
     * @param accountId
     * @return Map<String,List<SObject>>
     */
    @AuraEnabled
    public static Map<String,List<SObject>> getContractsAndOrdersMap(String accountId){

        Map<String,List<SObject>> mapOfLists = new Map<String,List<SObject>>();
        
        List<Contract> contractsList = new List<Contract>();
        contractsList = getContractsList(accountId);
        mapOfLists.put('contractsList', contractsList);

        List<Order> ordersList = new List<Order>();
        ordersList = getOrdersList(accountId);
        mapOfLists.put('ordersList', ordersList);

        return mapOfLists;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check for duplicated contract/order reference in current sale
     * @param saleId
     * @param objectId (OrderReference__c/ContractReference__c)
     * @param type (contract or order)
     * @return Boolean
     */
    private static Boolean isDuplicated(String saleId, String objectId, String type) {

        List<SBQQ__Quote__c> resultsList = new List<SBQQ__Quote__c>();

        switch on type {
            when 'contract' {
                resultsList = quoteQr.getQuotesBySaleAndContractReference(saleId, objectId);
            }
            when 'order' {
                resultsList = quoteQr.getQuotesBySaleAndOrderReference(saleId, objectId);
            }
        }

        return !resultsList.isEmpty();
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action for 'Ordini in corso'
     * @param order
     * @param supplyCity
     * @param sale
     */
    public static void handleActiveOrderConfirm(Order order, String supplyCity, Sale__c sale){
        /**@frpanico 13/01/2022
         * Aggiunta gestione transitorio
         */
        if (order.Id == null) {
            throw new AuraHandledException('Devi scegliere un ordine!');
        }

        if (isDuplicated(sale.Id, order.Id, 'order')) {
            throw new AuraHandledException('La quote con il riferimento di questo ordine esiste già!');
        }
        List<Sale__c> currentSale = [SELECT Id, IsTransition__c FROM Sale__c WHERE Id = :sale.Id];
        String pdrCode = order.ServicePoint__r.ServicePointCode__c;
        pdrCode = String.isBlank(pdrCode)? '' : ' '+pdrCode;

        Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
            Sale__c = sale.Id,
            Name = opportunitySrv.generateName(sale) + ' VAS'+pdrCode,
            CloseDate = Date.today().addDays(30),
            StageName = 'Proposal',
            AccountId = order.AccountId
        ));

        /**@frpanico 09/02/2022
         * Inserimento puntamento
         * al contratto
         */
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
            Sale__c = sale.Id,
            OrderReference__c = order.Id,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Account__c = sale.Account__c,
            SBQQ__Primary__c = true,
            Agency__c = sale.Agency__c,
            Market__c = order.Market__c,
            Channel__c = sale.Channel__c,
            FriendCode__c = sale.FriendCode__c,
            CampaignCode__c = sale.CampaignCode__c,
            CreatedBy__c = sale.CreatedBy__c,
            SupplyCity__c = null, //to do (other logic to get SupplyCity)
            SalesCompany__c = order.SalesCompany__c,
            Campaign__c = sale.Campaign__c,
            IsVAS__c = true,
            IsBillableVas__c = false,
            IsTransition__c = currentSale[0].IsTransition__c,
            SBQQ__PricebookId__c = checkCommodityOrder(order.Id) == 'HDT_RT_Ele' ? getPricebookId('VAS ELE') : getPricebookId('VAS GAS'),
            AgencyCode__c = sale.AgencyCode__c,
            CommercialId__c = sale.CommercialId__c,
            CampaignEleggibilityGroup__c = sale.Campaign__r.CampaignEligibilityGroup__c != null ? sale.Campaign__r.CampaignEligibilityGroup__c : null 

        );

        if(order.ContractReference__c != null)
        {
            newQuote.ContractReference__c = order.ContractReference__c;
        }

        newQuote = quoteSrv.createRecord(newQuote);

        newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;

        opportunitySrv.updateRecord(newOpportunity);
    }

    @AuraEnabled
    public static String handleNotMigratedContract(String contract, Sale__c sale){
        system.debug('contract --> '+contract);
        system.debug('sale --> '+sale);
        system.debug('PUNTO 1');
        sale = saleQr.getRecordById(sale.id, 'AgencyCode__c,CommercialId__c ,Account__c,Account__r.Category__c,Account__r.CustomerMarking__c,Agency__c,Account__r.CompanyOwner__c,Channel__c,FriendCode__c,CampaignCode__c,CreatedBy__c,SalesCompany__c,Campaign__c,Name, Campaign__r.CampaignEligibilityGroup__c');
        //REQUEST
        String result = '';
        // HDT_WS_ArricchimentoDatiTemp arricchimentoDati = new HDT_WS_ArricchimentoDatiTemp();
        HDT_SRV_DataEnrichmentPostSales dataEnrichmentPostSales = new HDT_SRV_DataEnrichmentPostSales(); 
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> posizioniList = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();

        system.debug('PUNTO 2');
        String resPosizioni = HDT_WS_ArricchimentoDatiTemp.submitRequest('',contract);
        String dataCessazioneString = '';
        String commodity = '';
        String mercato = '';
        String venditore = '';
        String sellerCompany = '';
        Date dataCessazione = null;

        system.debug('PUNTO 3');


        if(resPosizioni != null && resPosizioni != ''){

            system.debug('PUNTO 4');

            posizioniList = (List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>)
            JSON.deserialize(resPosizioni, List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>.class);
            // posizioniList = (List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>) JSON.deserialize(resPosizioni, HDT_WS_ArricchimentoDatiTemp.class);
            system.debug('PUNTO 5');
            for(HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione : posizioniList){
                if(posizione.campo == 'DATACESSAZIONE'){
                    system.debug('PUNTO 6');
                    dataCessazioneString = posizione.valore;
                }
                if(posizione.campo == 'DESCRCOMM'){
                    system.debug('PUNTO 6.1');
                    commodity = posizione.valore;
                }
                if(posizione.campo == 'MERCATO'){
                    system.debug('PUNTO 6.1');
                    mercato = posizione.valore;
                    mercato = mercato.substring(0, 1).toUpperCase() + mercato.substring(1).toLowerCase();
                    system.debug('mercato --> '+mercato);

                }
                if(posizione.campo == 'VENDITORE'){
                    system.debug('PUNTO 6.1');
                    venditore = posizione.valore;
                }
            }

            List<HDT_MatriceSocietaVendita__mdt> matriceList = [SELECT SalesCompanyCode__c, SellerCompany__c FROM HDT_MatriceSocietaVendita__mdt WHERE SalesCompanyCode__c =: venditore WITH SECURITY_ENFORCED LIMIT 1];
            if(!matriceList.isEmpty()){
                sellerCompany = matriceList[0].SellerCompany__c;
            }
            else{
                sellerCompany = null;
            }
            
            system.debug('PUNTO 7');
            if(dataCessazioneString != null && dataCessazioneString != ''){
                system.debug('PUNTO 8');
                dataCessazione = dataEnrichmentPostSales.getDateFromString(dataCessazioneString);
            }
            system.debug('PUNTO 9');
            if(dataCessazione != null && dataCessazione > System.today()){
                system.debug('PUNTO 10');

                // if (order.Id == null) {
                //     system.debug('PUNTO 11');
                //     throw new AuraHandledException('Devi scegliere un ordine!');
                // }
                //system.debug('PUNTO 12');
                // if (isDuplicated(sale.Id, order.Id, 'order')) {
                //     system.debug('PUNTO 13');
                //     throw new AuraHandledException('La quote con il riferimento di questo ordine esiste già!');
                // }
                // String pdrCode = order.ServicePoint__r.ServicePointCode__c;
                String pdrCode = '';
                pdrCode = String.isBlank(pdrCode)? '' : ' '+pdrCode;
                system.debug('PUNTO 15');
                //CREAZIONE OPPORTUNITY E QUOTE
                Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
                    Sale__c = sale.Id,
                    Name = opportunitySrv.generateName(sale) + ' VAS'+pdrCode,
                    CloseDate = Date.today().addDays(30),
                    StageName = 'Proposal',
                    // AccountId = order.AccountId
                    AccountId = sale.Account__c
                ));
                SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
                Sale__c = sale.Id,
                //OrderReference__c = order.Id,
                SBQQ__Opportunity2__c = newOpportunity.Id,
                SBQQ__Account__c = sale.Account__c,
                SBQQ__Primary__c = true,
                Agency__c = sale.Agency__c,
                // Market__c = order.Market__c,
                Market__c = mercato,
                Channel__c = sale.Channel__c,
                FriendCode__c = sale.FriendCode__c,
                CampaignCode__c = sale.CampaignCode__c,
                CreatedBy__c = sale.CreatedBy__c,
                SupplyCity__c = null, //to do (other logic to get SupplyCity)
                // SalesCompany__c = order.SalesCompany__c,
                SalesCompany__c = sellerCompany,
                Campaign__c = sale.Campaign__c,
                IsVAS__c = true,
                IsBillableVas__c = false,
                IsTransition__c = true,
                SBQQ__PricebookId__c = commodity == 'Energia Elettrica' ? getPricebookId('VAS ELE') : commodity == 'Gas' ? getPricebookId('VAS GAS') : null,
                AgencyCode__c = sale.AgencyCode__c,
                CommercialId__c = sale.CommercialId__c,
                SapContractCode__c = contract,
                CampaignEleggibilityGroup__c = sale.Campaign__r.CampaignEligibilityGroup__c != null ? sale.Campaign__r.CampaignEligibilityGroup__c : null
                );
                // if(order.ContractReference__c != null)
                // {
                //     newQuote.ContractReference__c = order.ContractReference__c;
                // }
                newQuote = quoteSrv.createRecord(newQuote);
                newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;
                opportunitySrv.updateRecord(newOpportunity);
                sale.isTransition__c = true;
                HDT_UTL_DatabaseService.updateSObject(sale);
                result = 'Success';
                return result;
            }
            else{
                system.debug('PUNTO 23');
                result = 'Errore Data Cessazione';
                return result;
            }
        }
        else{
            system.debug('PUNTO 24');
            result = 'Errore Contratto Assente';
            return result;
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action for 'Contratti Attivi'
     * @param contract
     * @param supplyCity
     * @param sale
     */
    public static void handleActiveContractConfirm(Contract contract, String supplyCity, Sale__c sale){
        
        if (contract.Id == null) {
            throw new AuraHandledException('Devi scegliere un contrato!');
        }

        if (isDuplicated(sale.Id, contract.Id, 'contract')) {
            throw new AuraHandledException('La quote con il riferimento di questo contrato esiste già!');
        }
        String pdrCode = contract.ServicePoint__r.ServicePointCode__c;
        pdrCode = String.isBlank(pdrCode)? '' : ' '+pdrCode;

        System.debug('Sale: AgencyCode__c :' + sale.AgencyCode__c);
        System.debug('Sale: CommercialId__c :' + sale.CommercialId__c);

        Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
            Sale__c = sale.Id,
            Name = opportunitySrv.generateName(sale) + ' VAS'+pdrCode,
            CloseDate = Date.today().addDays(30),
            StageName = 'Proposal',
            AccountId = contract.AccountId
        ));

        SBQQ__Quote__c newQuote = quoteSrv.createRecord(new SBQQ__Quote__c(
            Sale__c = sale.Id,
            ContractReference__c = contract.Id,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Account__c = sale.Account__c,
            SBQQ__Primary__c = true,
            Agency__c = sale.Agency__c,
            Market__c = 'Libero',
            Channel__c = sale.Channel__c,
            FriendCode__c = sale.FriendCode__c,
            CampaignCode__c = sale.CampaignCode__c,
            CreatedBy__c = sale.CreatedBy__c,
            SalesCompany__c = contract?.ServicePoint__r?.Vendor__c,
            Campaign__c = sale.Campaign__c,
            SupplyCity__c = null, //to do (other logic to get supplyCity)
            IsVAS__c = true,
            IsBillableVas__c = false,
            SBQQ__PricebookId__c = checkCommodityContract(contract.Id) == 'HDT_RT_Ele' ? getPricebookId('VAS ELE') : getPricebookId('VAS GAS'),
            AgencyCode__c = sale.AgencyCode__c,
            CommercialId__c = sale.CommercialId__c,
            CampaignEleggibilityGroup__c = sale.Campaign__r.CampaignEligibilityGroup__c != null ? sale.Campaign__r.CampaignEligibilityGroup__c : null
        ));

        newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;

        opportunitySrv.updateRecord(newOpportunity);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action for "VAS Stand Alone" option
     * @param supplyCity
     * @param accountId
     * @param sale
     */
    public static void handleVasStandAloneConfirm(String supplyCity, String accountId, Sale__c sale){
        
        if (supplyCity == '') {
            throw new AuraHandledException('Devi compilare il comune!');
        }

        Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
            Sale__c = sale.Id,
            Name = opportunitySrv.generateName(sale) + ' VAS',
            CloseDate = Date.today().addDays(30),
            StageName = 'Proposal',
            AccountId = accountId
        ));

        SBQQ__Quote__c newQuote = quoteSrv.createRecord(new SBQQ__Quote__c(
            Sale__c = sale.Id,
            SBQQ__Opportunity2__c = newOpportunity.Id,
            SBQQ__Account__c = accountId,
            SBQQ__Primary__c = true,
            SupplyCity__c = supplyCity,
            Agency__c = sale.Agency__c,
            Market__c = 'Libero',
            Channel__c = sale.Channel__c,
            FriendCode__c = sale.FriendCode__c,
            CampaignCode__c = sale.CampaignCode__c,
            CreatedBy__c = sale.CreatedBy__c,
            SalesCompany__c = 'Hera Comm S.p.A.',
            IsVAS__c = true,
            IsBillableVas__c = false,
            SBQQ__PricebookId__c = getPricebookId('VAS Standalone'),
            AgencyCode__c = sale.AgencyCode__c,
            CommercialId__c = sale.CommercialId__c,
            CampaignEleggibilityGroup__c = sale.Campaign__r.CampaignEligibilityGroup__c != null ? sale.Campaign__r.CampaignEligibilityGroup__c : null
        ));

        newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;

        opportunitySrv.updateRecord(newOpportunity);
    }

    private static String getPricebookId(String pricebookName) {
        List<Pricebook2> pricebook = HDT_QR_PriceBook.getRecordByName(pricebookName);

        String result = '';

        if(!pricebook.isEmpty()) {
            result = pricebook[0].Id;
        } else {
            result = null;
        }

        return result;
    }

    private static String checkCommodityContract(String contractId) {

        List<Contract> contracts = contractQr.getRecordById(contractId);

        return contracts[0].ServicePoint__r.RecordType.DeveloperName;

    }

    private static String checkCommodityOrder(String orderId) {

        Order order = orderQr.getRecordById(orderId);

        return order.ServicePoint__r.RecordType.DeveloperName;

    }
}