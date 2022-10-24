/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@protonmail.ch)
 * @date 12/03/2021
 * @description HDT_UTL_OrderProcess Class
 * @history Keltin Mesonjesi – 12/03/2021 – Created Class
 * 
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount, PMD.ExcessiveParameterList, PMD.AvoidDeeplyNestedIfStmts')
public inherited sharing  class HDT_UTL_OrderProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_UTL_CommunicationLog commUtl = new HDT_UTL_CommunicationLog();
    private static HDT_SRV_CommunicationLog commSrv = new HDT_SRV_CommunicationLog();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    @SuppressWarnings('PMD.AvoidDebugStatements') 
    public static void updateServicePointToComplete(List<Order> orderOld,List<Order> orderNew){
        try{
            Map<String,order> mapOrderOld = new Map<String,Order>();
            set<String> listServiceId = new Set<String>();
            for(Order o : orderOld){
                mapOrderOld.put(o.id,o);
            }
            for(Order oNew : orderNew){
                if(oNew.servicePoint__c != null && oNew.phase__c == 'Completata' && mapOrderOld.get(oNew.id).phase__c != 'Completata'){
                    listServiceId.add(oNew.servicePoint__c);
                }
            }
            if(listServiceId != null && !listServiceId.isEmpty()){
                HDT_UTL_ServicePoint.updateServicePointImplantAndSupplytype(listServiceId);
            }
        }
        catch(Exception e){
            system.debug(Logginglevel.Debug, e);
        }
    }

    public static List<Order> updateChildOrderIvr(Map<String,Order> oldMap, Map<String,Order> newMap) {
        List<String> orderParentList = new List<String>();
        List<Order> childrenToUpdate = new List<Order>();
        for(Order ord : newMap.values()) {
            if(oldMap.get(ord.id).MethodSignedAccepted__c == null && ord.MethodSignedAccepted__c == 'IVR' && ord.SignedDate__c != null) {
                orderParentList.add(ord.Id);
            }
        }
        if(!orderParentList.isEmpty()){
            List<order> childOrder = orderQr.getChildOrdersByParentIds(orderParentList);
            for(Order child : childOrder){
                Order ord = new Order();
                ord.id = child.id;
                ord.SignedDate__c = newMap.get(child.ParentOrder__c).SignedDate__c;
                ord.MethodSignedAccepted__c = 'IVR';
                ord.ProcessType__c=child.ProcessType__c;
                if (ord.ProcessType__c == 'Subentro Ele' || ord.ProcessType__c == 'Cambio Offerta Gas' || ord.ProcessType__c == 'Cambio Offerta Ele' || ord.ProcessType__c == 'Aggiunta Sconti o Bonus VAS Ele' || ord.ProcessType__c == 'Aggiunta Sconti o Bonus VAS Gas') {
                    ord.Phase__c = 'Comunicazione verso Heroku';
                    childrenToUpdate.add(ord);
                } else if(ord.ProcessType__c == 'Switch in Ele' || ord.ProcessType__c == 'Switch in Gas') {
                    if (ord.WaiverRightAfterthought__c == 'No' && ord.WizardCompletedDate__c.daysBetween(Date.today()) > 14 ) {
                        ord.Phase__c = 'In attesa tempi ripensamento';
                    } else {
                        ord.Phase__c = 'Comunicazione verso Heroku';
                    }
                    childrenToUpdate.add(ord);
                }
            }
        }
        return childrenToUpdate;
    }

    public static void checkSatisfationIndex(Map<Id,SObject> newMap, Map<Id,SObject> oldMap) {
        List<Account> accountsToUpdate = new List<Account>();
        for(Order newOrder : (List<Order>) newMap.values()) {
            if(((Order) oldMap.get(newOrder.Id)).PraxidiaOverrallSatisfaction__c != newOrder.PraxidiaOverrallSatisfaction__c) {
                accountsToUpdate.add(new Account(
                    Id = newOrder.AccountId,
                    SatisfactionIndexCtrl__c = newOrder.PraxidiaOverrallSatisfaction__c,
                    PraxidiaUpdateDate__c = newOrder.PraxidiaDateOutcome__c  
                ));
            }
        }

        accountSrv.updateRecords(accountsToUpdate);
    }

    /**
     * @description salesProcessManagementBefore
     * @param newOrderList
     * @param oldOrderList
     */
    public static void salesProcessManagementBefore(list<Order> newOrderList,List<Order> oldOrderList){

        /*Transitorio
        */
        Map<String,Order> mapOrder = new Map<String,Order>();
        for(Order o: oldOrderList){
            mapOrder.put(o.Id, o);
        }

        HDT_QR_RecordType recordTypeQr = new HDT_QR_RecordType();
        String rtCambioOfferta = recordTypeQr.getRecordTypeIdByName('HDT_RT_CambioOfferta', 'Order');

        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agentCodeIsMonitoringList();

        Map<String,Order> mapParentOrder = new Map<String,Order>();
        List<String> ordParentsIds = new List<String>();
        for (Order ord : newOrderList) {
            Order oldOrder= mapOrder.get(ord.Id);
            if(ord.Phase__c!=oldOrder.Phase__c 
            && oldOrder.Phase__c != 'In attesa di quality call'
            && ord.Phase__c == 'Quality Call OK'
            && ord.ParentOrder__c != null){
                ordParentsIds.add(ord.ParentOrder__c);
            }
        }
        if(!ordParentsIds.isEmpty()){
            List<Order> orderPadreDocs = orderQr.getParentOrderDocs(ordParentsIds);
            for (Order ordPadre : orderPadreDocs) {
                mapParentOrder.put(ordPadre.Id, ordPadre);
            }
        }

        for (Order order : newOrderList) {
            Order oldOrder= mapOrder.get(order.Id);
            if(order.Phase__c!=oldOrder.Phase__c
            &&
            /**@frpanico 28/12/2021 
             * La Voltura parte in "Documentazione Validata" per voltura accettata
             * E in "Voltura Rifiutata" per voltura rifiutata ma solo Gas
            */
            (order.Phase__c=='Comunicazione Verso Heroku'
            || 
                (
                    (order.ProcessType__c != null && order.ProcessType__c.equalsIgnoreCase('Voltura'))
                    && (order.Phase__c.equalsIgnoreCase('Documentazione Validata') 
                        || ((order.Commodity__c != null && order.Commodity__c.equalsIgnoreCase('Gas')) && order.Phase__c.equalsIgnoreCase('Voltura Rifiutata')))
                )
            || order.Phase__c == 'Comunicazione Motore VAS'
            || order.Phase__c == 'Quality Call OK'
            )
            &&order.isTransition__c==true){
                String newPhase = 'Esportazione VS Siebel';
                String newPhaseStory = String.isBlank(order.PhaseStory__c) ?  '' : order.PhaseStory__c;
                DateTime nowDateTime = DateTime.now();
                order.PhaseStory__c =  order.Phase__c+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+ newPhaseStory;
                order.Phase__c = newPhase;
            }

            //19/08/2021 gabriele.rota@webresults.it - Calcolo Data Decorrenza Cambio Offerta
            if (order.RecordTypeId==rtCambioOfferta && order.EffectiveDate__c==null) {
                Date refDate = (order.ContractSigned__c)?order.WizardCompletedDate__c:order.SignedDate__c;
                if (refDate!=null) {
                    order.EffectiveDate__c = refDate.toStartOfMonth().addMonths(1);
                }
            }

            String phaseStory = order.PhaseStory__c;
            if(order.Phase__c!=oldOrder.Phase__c 
                && oldOrder.Phase__c == 'Documentazione validata' 
                && (order.Phase__c == 'Comunicazione Verso Heroku' || order.Phase__c == 'Comunicazione Motore VAS' || order.Phase__c == 'In attesa tempi di ripensamento' || order.Phase__c == 'Esportazione VS Siebel')
                && order.QualityCall__c
                && isMonitoringList.contains(order.CommercialId__c)
                && !phaseStory.contains('Quality Call OK')
                && order.ComfortCallDaysDue__c == null){
                    if(String.isNotBlank(order.VasSubtype__c) && order.VasSubtype__c.equalsIgnoreCase('Analisi Consumi')){
                        //nothing to update
                    }else{
                        String newPhase = 'In attesa di quality call';
                        order.Phase__c = newPhase;
                        DateTime nowDateTime = DateTime.now();
                        order.PhaseStory__c = oldOrder.Phase__c+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder.PhaseStory__c;
                    }
                
            }
            /**@frpanico 07/03/2022
             * Aggiunta quality monitoraggio per voltura
             */
            if(order.Phase__c != oldOrder.Phase__c 
                && order.ProcessType__c == 'Voltura' 
                && (oldOrder.Phase__c == 'In attesa validazione' || oldOrder.Phase__c == 'Accettazione Voltura')
                && (order.Phase__c == 'Documentazione Validata') 
                && isMonitoringList.contains(order.CommercialId__c) 
                && !phaseStory.contains('Quality Call OK')
                && order.ComfortCallDaysDue__c == null)
            {
                String newPhase = 'In attesa di quality call';
                order.Phase__c = newPhase;
                DateTime nowDateTime = DateTime.now();
                order.PhaseStory__c = oldOrder.Phase__c+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder.PhaseStory__c;
            }
            /**@frpanico 04/02/2022
             * Aggiunta gestione per
             * Comfort Call
             * Inserito caso transitorio
             */
            if(order.Phase__c != oldOrder.Phase__c
            && oldOrder.Phase__c == 'Documentazione validata' 
            && (order.Phase__c == 'Comunicazione Verso Heroku' || order.Phase__c == 'Comunicazione Motore VAS' || order.Phase__c == 'Esportazione VS Siebel')
            && order.ComfortCallDaysDue__c != null
            )
            {
                String newPhase = 'In attesa conferma cliente';
                DateTime nowDateTime = DateTime.now();
                order.Phase__c = newPhase;
                order.PhaseStory__c =  oldOrder.Phase__c+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder.PhaseStory__c;
            }
            /**@frpanico 07/03/2022
             * Aggiunta comfort per voltura
             * Inserito caso transitorio
             */
            if(order.Phase__c != oldOrder.Phase__c && order.ProcessType__c == 'Voltura' && oldOrder.Phase__c == 'In attesa validazione' && (order.Phase__c == 'Documentazione Validata' || order.Phase__c == 'Esportazione VS Siebel') && order.ComfortCallDaysDue__c != null )
            {
                String newPhase = 'In attesa conferma cliente';
                DateTime nowDateTime = DateTime.now();
                order.Phase__c = newPhase;
                order.PhaseStory__c =  oldOrder.Phase__c+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder.PhaseStory__c;
            }

            if(order.Phase__c!=oldOrder.Phase__c 
                && oldOrder.Phase__c == 'In attesa di quality call' 
                && order.Phase__c == 'Quality Call OK'
                ){
                String newPhase = (order.ProcessType__c == 'Voltura' || order.ProcessType__c == 'VAS') ? 'Documentazione Validata' : 'Comunicazione Verso Heroku';
                order.Phase__c = newPhase;
                DateTime nowDateTime = DateTime.now();
                order.PhaseStory__c = 'Quality Call OK'+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||' +  oldOrder.Phase__c+'@@'+'Quality Call OK'+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder.PhaseStory__c;
            }

            if (order.Phase__c!=oldOrder.Phase__c 
                && order.ProcessType__c != 'Voltura'
                && oldOrder.Phase__c != 'In attesa di quality call'
                && order.Phase__c == 'Quality Call OK'
                /*&& isMonitoringList.contains(order.CommercialId__c)*/) {

                    String newPhase = (HDT_LC_OrderDossierWizardActions.checkRequiredDocs(order) && HDT_LC_OrderDossierWizardActions.checkRequiredDocs(mapParentOrder.get(order.ParentOrder__c))) ? 'Comunicazione verso Heroku' : 'In attesa validazione';
                    order.Phase__c = newPhase;
                    DateTime nowDateTime = DateTime.now();
                    order.PhaseStory__c = oldOrder.Phase__c+'@@'+'Quality Call OK'+'@@'+nowDateTime.getTime()+'@@A||'+ 'Quality Call OK'+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||' +oldOrder.PhaseStory__c;
            }
        }        
    }
    /**
    * @author NTTDATA
    * @date 16/02/2022
    * @description Calculate Order Date Like Sii or Effective Date
    * @param List<Order> newOrdersList - List<Order>
    * @param List<Order> oldOrdersList - List<Order>
    * @return void
    */
    public static void calculateOrderDate(List<Order> newOrdersList,List<Order> oldOrdersList){
        Map<String,Order> orderMapOld = new Map<String,Order>();
        List<Order> orderDateList = new List<Order>();
        List<String> orderParentIds = new List<String>();
        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for(Order newOrder : newOrdersList){
            Order oldOrder = orderMapOld.get(newOrder.Id);
            String oldValue = oldOrder.Phase__c;
            String newValue = newOrder.Phase__c;
            Date oldDate = oldOrder.SignedDate__c;
            Date newDate = newOrder.SignedDate__c;
            if((String.isNotBlank(oldValue) && String.isNotBlank(newValue) &&
                !newValue.equalsIgnoreCase(oldValue) && 
                newOrder.ParentOrder__c == null && 
                newOrder.Phase__c == 'Documentazione Gestita' &&
                (!newOrder.Channel__c.equalsIgnoreCase('Teleselling Outbound') ||
                newOrder.Channel__c.equalsIgnoreCase('Teleselling Outbound') && newOrder.SignatureMethod__c.equalsIgnoreCase('Contratto già firmato'))
                )
            || (newOrder.ParentOrder__c == null && (oldDate == null && newDate != null) || (oldDate != null && newDate != null && oldDate != newDate))
            ){
                orderParentIds.add(newOrder.Id);
            }
        }
        if(!orderParentIds.isEmpty()){
            List<Order> childOrders = orderQr.getChildOrdersForDateCalculation(orderParentIds);
            List<Order> childOrdersToWork = new List<Order>();
            List<Order> onlySignedDateUpdate = new List<Order>();
            for(Order singleOrder : childOrders){
                Boolean changeDate = false;
                if(singleOrder.SignedDate__c == null){
                    changeDate=true;
                    singleOrder.SignedDate__c = Date.today();
                }
                if (changeDate && ('VAS'.equalsIgnoreCase(singleOrder.ProcessType__c) || String.isBlank(singleOrder.ProcessType__c))){
                    onlySignedDateUpdate.add(singleOrder);
                    continue;
                }
                childOrdersToWork.add(singleOrder);
            }
            childOrders = null;
            HDT_UTL_ProcessDateManager.calculateOrderProcessDate(childOrdersToWork);
            if(!onlySignedDateUpdate.isEmpty()){
                childOrdersToWork.addAll(onlySignedDateUpdate);
            }
            if (!childOrdersToWork.isEmpty()) {
                HDT_UTL_DatabaseService.updateSObject(childOrdersToWork);
            }
        }
    }

    /**
     * @description orderPhaseManagementAfterUpdate
     * @param newOrdersList
     * @param oldOrdersList
     */
    public static void orderPhaseManagementAfterUpdate(List<Order> newOrdersList, List<Order> oldOrdersList) {

        Map<String,Order> orderMapNewToOld = new Map<String,Order>();
        Map<String,Order> orderMapOld = new Map<String,Order>();
        Map<String,Order> orderMapNew = new Map<String,Order>();
        List<String> olistd = new List<String>();

        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
            olistd.add(newOrder.id);
           	orderMapNew.put(newOrder.id,newOrder);
            if(orderMapOld.get(newOrder.id)!= null){
                orderMapNewToOld.put(newOrder.id,orderMapOld.get(newOrder.id));
            }
        }
        set<Order> filtered = new set<Order>();
        List<String> ordersParent = new List<String>();
        List<Order> ordersFullList2 = orderQr.getRecordsByIds(olistd);

//**** AGGIUNTA Validazione Documentale LG 2009 FF */
        List<Order> ordersFullList = HDT_UTL_Sales.validationActivityPhaseTransition(ordersFullList2);
        for(Order o : ordersFullList2){
            if (o.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && (o.Phase__c == 'Documentazione Gestita' || o.DocumentPackage__c == 'Validato')) {
                ordersParent.add(o.id);
            }
            if(o.phase__c == 'Documentazione Validata'){
                filtered.add(o);
            }
        }
        if(!ordersParent.isEmpty()){
            List<Order> childOrders = orderQr.getChildOrdersByParentIds(ordersParent);
            List<Order> childOrdersDocValid = new List<Order>();
            for(Order myOrder : childOrders){
                if(myOrder.phase__c == 'Documentazione Validata'){
                    filtered.add(myOrder);
                }

                if (myOrder.Phase__c == 'In attesa validazione'  && myOrder.DateComfortCall__c == null) {
                    childOrdersDocValid.add(new Order(
                        Id = myOrder.Id,
                        phase__c = HDT_LC_OrderDossierWizardActions.checkRequiredDocs(myOrder) ? 'Documentazione Validata': 'In attesa validazione'
                    ));
                }
                /**@frpanico 07/02/2022
                 * Aggiunta gestione per
                 * Vocal Order + Comfort
                 */
                if (myOrder.Phase__c == 'Da Inviare' && myOrder.ParentOrder__r.Phase__c.equalsIgnoreCase('Documentazione Gestita')) {
                    Boolean isNotVoltureAcceptanceWorked = String.isNotBlank(myOrder.PhaseStory__c) 
                                                            && (myOrder.PhaseStory__c.containsIgnoreCase('Attesa Credit Check')
                                                            || myOrder.PhaseStory__c.containsIgnoreCase('Credit Check KO'))
                                                            && myOrder.PhaseStory__c.containsIgnoreCase('Accettazione Voltura') ? false : true; 

                    String newPhase = (myOrder.ProcessType__c == 'Voltura') && isNotVoltureAcceptanceWorked && !myOrder.Commodity__c.containsIgnoreCase('Acqua')? 'Accettazione Voltura': HDT_LC_OrderDossierWizardActions.checkRequiredDocs(myOrder) ? 'Documentazione Validata': 'In attesa validazione';
                    newPhase = myOrder.ProcessType__c == 'Voltura - Subentro Scarico produttivo'? 'In attesa esito SAP' : newPhase;

                    childOrdersDocValid.add(new Order(
                        Id = myOrder.Id,
                    // phase__c = 'In attesa validazione'
                        phase__c = newPhase
                    ));
                        
                }
            }
            if(ordersFullList != null && !ordersFullList.isEmpty()){
                childOrdersDocValid.addAll(ordersFullList);
            }
            List<Order> ivrChildren = updateChildOrderIvr(orderMapOld, orderMapNew);
            if(ivrChildren != null && !ivrChildren.isEmpty()){
                childOrdersDocValid.addAll(ivrChildren);
            }
            if (!childOrdersDocValid.isEmpty()) {
                orderSrv.updateRecords(childOrdersDocValid);
            }
            /**@frpanico 03/03/2022
             * Nel caso in cui il trigger gira sull'order padre
             * il codice dalla riga 320 alla rgia 337 non funziona
             * in quanto l'order figlio ancora non è stato aggiornato
             * nella fase Documentazione validata.
             * La gestione degli order figli è stata spostata
             * alla riga 345
             */
            /*List<Order> ordersHeroku = new List<Order>();
            List<Order> ordersSiebel = new List<Order>();

            for(Order o:filtered){
                if(o.sale__r.isTransition__c==true){
                    ordersSiebel.add(o);
                }else{
                    ordersHeroku.add(o);
                }
            }
            Map<Id, String> vasOrdersToUpdate = 
                updateChildOrdersPhase(ordersSiebel,'Documentazione Validata', 'Esportazione VS Siebel ','Documentazione Validata','Esportazione VS Siebel ');
            vasOrdersToUpdate.putAll(
                updateChildOrdersPhase(ordersHeroku, 'Documentazione Validata', 'Comunicazione verso Heroku','Documentazione Validata','Comunicazione Motore VAS')
            );
            if(!vasOrdersToUpdate.isEmpty()){
                system.enqueueJob(new HDT_UTL_PrClickDoubleTransaction.HDT_QBL_BulkUpdate(vasOrdersToUpdate));
            }
            */
        }
        /**@frpanico 03/03/2022
         * Nel caso il trigger giri sugli order figli
         * viene gestito l'avanzamento di fase
         * da Documentazione Validata alla fase successiva
         */
        if(!filtered.isEmpty())
        {
            List<Order> ordersHeroku = new List<Order>();
            List<Order> ordersSiebel = new List<Order>();
            List<Order> ordersNonEnergy = new List<Order>();
            for(Order o:filtered){
                if(o.sale__r.isTransition__c==true){
                    ordersSiebel.add(o);
                }
                /* Gli ordini Ambiente ed Acqua hanno la necessita' di avere il BP e il CA prima di poter essere inviati verso Heroku
                * e' stata percio' introdotta una fase intermedia "Creazione BP-CA" per permettere la chiamata verso SAP per la registrazione
                * delle due entita' e aggiornarle con i relativi codici
                * Update 2022-10-10 logica non risulta essere necessaria per la commodity ambiente
                */
                else if(o.Commodity__c.equalsIgnoreCase('Acqua') /*|| o.Commodity__c.equalsIgnoreCase('Ambiente')*/)
                {
                    ordersNonEnergy.add(o);
                }
                else{
                    ordersHeroku.add(o);
                }
            }
            Map<Id, String> vasOrdersToUpdate = 
                updateChildOrdersPhase(ordersSiebel,'Documentazione Validata', 'Esportazione VS Siebel ','Documentazione Validata','Esportazione VS Siebel ');
            vasOrdersToUpdate.putAll(
                updateChildOrdersPhase(ordersHeroku, 'Documentazione Validata', 'Comunicazione verso Heroku','Documentazione Validata','Comunicazione Motore VAS')
            );
            vasOrdersToUpdate.putAll(
                updateChildOrdersPhase(ordersNonEnergy, 'Documentazione Validata', 'Creazione BP-CA','Documentazione Validata','Comunicazione Motore VAS')
            );
            if(!vasOrdersToUpdate.isEmpty()){
                system.enqueueJob(new HDT_UTL_PrClickDoubleTransaction.HDT_QBL_BulkUpdate(vasOrdersToUpdate));
            }
        }
        insertLogForOrderChangedPhase(orderMapOld,orderMapNew);
    }
	
    private static void insertLogForOrderChangedPhase(Map<String,Order> orderMapOld, Map<String,Order> orderMapNew){
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Map<String,String> mapOrdToContact = new map<String,String>();
        HDT_QR_RecordType myRecordTypeQr = new HDT_QR_RecordType();
        String recordtypeParentId = myRecordTypeQr.getRecordTypeIdByName('HDT_RT_OrderDossier', 'Order');
        for (Order o : orderMapNew.values()){
            mapOrdToContact.put(o.id,o.contact__c);
        }
        Map<String,Contact> mapContact = new Map<String,Contact>(contactQr.getRecordsById(mapOrdToContact.values()));
        for(String ord : orderMapOld.keyset()){
           order oldOrd =  orderMapOld.get(ord);
           if(orderMapNew.get(ord) != null){
               order newOrd = orderMapNew.get(ord);
               if(oldOrd.phase__c != newOrd.Phase__c && newOrd.recordtypeid != recordtypeParentId){
                   String st = newOrd.Status;
                   if('annullato'.equalsIgnoreCase(st)){
                       st = 'Chiuso';
                   }
                   Contact c = null;
                   if(mapContact.get(newOrd.Contact__c) != null){
                       c = mapContact.get(newOrd.Contact__c);
                   }
                   commList.add(commUTL.instanceCommunicationLog('Attivazioni',newOrd.ProcessType__c,newOrd.Phase__c,st,newOrd.CancellationReason__c,newOrd.Id,'',newOrd.Contact__c,newOrd.AccountId,c != null ? c.company__c : 'ND',newOrd.CompanyOwner__c));
               }
           }
        }
        if(commList != null && !commList.isEmpty()){
            commSRV.createRecords(commList);
        }
    }

    
/**
    * @author NTTDATA
    * @date 16/02/2022
    * @description Recalculate Order Date after KO or After Quality Call Confirm
    * @param List<Order> newOrdersList - List<Order>
    * @param List<Order> oldOrdersList - List<Order>
    * @return void
    */
    public static void recalculateOrderDateAfterKo(List<Order> newOrdersList, List<Order> oldOrdersList){
        Map<String,Order> mapOldOrder = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> activityMap = new Map<String,wrts_prcgvr__Activity__c>();
        List<Order> newOrdersListRecalc = new List<Order>();
        List<Order> newOrdersListComfort = new List<Order>();
        for(Order oldOrder : oldOrdersList) {
            mapOldOrder.put(oldOrder.id,oldOrder);
        }
        /**@frpanico 2022-05-10
         * Aggiunta query sulle activity di Precheck KO
         * Nel caso in cui la data di massimo ripensamento
         * sia maggiore (strettamente) alla data chiusura activity
         * Non si devono ricalcolare le date
         */
        for(wrts_prcgvr__Activity__c a : [SELECT Id,ActivityEndTime__c, Order__c FROM wrts_prcgvr__Activity__c WHERE Order__c IN :mapOldOrder.keySet() AND Type__c LIKE '%Precheck%' AND ActivityEndTime__c != NULL WITH SECURITY_ENFORCED])
        {
            activityMap.put(a.Order__c, a);
        }
        for (Order newOrder : newOrdersList) {
            Order oldOrder = mapOldOrder.get(newOrder.id);
            if(oldOrder != null){
                if( newOrder.DocumentalProcessType__c != null
                    && newOrder.SignedDate__c != null
                    && (newOrder.DocumentalProcessType__c.equalsIgnoreCase('Switch In') 
                        || newOrder.DocumentalProcessType__c.containsIgnoreCase('Voltura')
                        || newOrder.DocumentalProcessType__c.equalsIgnoreCase('Voltura con Switch'))
                ){
                    if(!activityMap.isEmpty() && newOrder.DocumentalProcessType__c.equalsIgnoreCase('Switch In') 
                        && oldOrder.MaxAfterthoughtDate__c != null && oldOrder.MaxAfterthoughtDate__c > activityMap.get(oldOrder.Id).ActivityEndTime__c)
                    {
                        continue;
                    }
                    if((oldOrder.Phase__c == 'Comunicazione verso Heroku KO' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        ||(oldOrder.Phase__c == 'Amm. Precheck KO SII' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        || (oldOrder.Phase__c == 'Ammissibilità KO' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        || (oldOrder.Phase__c == 'Ammissibilità KO' && newOrder.Phase__c == 'Documentazione Validata')
                        || (oldOrder.Phase__c == 'Accettazione Voltura' && newOrder.Phase__c == 'Documentazione Validata')
                        || (oldOrder.Phase__c == 'Esito OK da SII' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        /**@frpanico 2022-04-28 Aggiunto ricalcolo date per Switch clonato */
                        || (oldOrder.Phase__c == 'Bozza' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        /**@frpanico 2022-05-23 Aggiunto caso transitorio */
                        || (oldOrder.Phase__c == 'Caricamento Siebel KO' && newOrder.Phase__c == 'Esportazione VS Siebel')
                        || (oldOrder.IncomingCreditCheckResult__c == 'KO' && newOrder.IncomingCreditCheckResult__c == 'OK')
                        /**@af inserito per ricalcolo al documenti Validati */
                        || (oldOrder.Phase__c == 'In attesa validazione' && newOrder.Phase__c == 'Documentazione Validata')
                    ){
                        if(newOrder.DocumentalProcessType__c.equalsIgnoreCase('Switch In')){
                            if((newOrder.Phase__c == 'Documentazione Validata' || newOrder.Phase__c == 'Esportazione VS Siebel') && Date.today() <= newOrder.DateSentToSII__c){
                                continue;
                            }else{
                                newOrder.DateSentToSII__c = Date.today();
                                String category = newOrder.CustomerCategory__c;
                                if('Famiglie'.equalsIgnoreCase(category) || newOrder.RecessNotice__c == 0){
                                    newOrdersListRecalc.add(newOrder);
                                }
                            }
                        }else {
                            newOrder.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);
                        }
                    }else if(
                            (oldOrder.ConfirmCustomerContract__c == null || (oldOrder.ConfirmCustomerContract__c != null && oldOrder.ConfirmCustomerContract__c != newOrder.ConfirmCustomerContract__c)) 
                            && (newOrder.ConfirmCustomerContract__c == 'Comfort call' || newOrder.ConfirmCustomerContract__c == 'Web' ||newOrder.ConfirmCustomerContract__c == 'IVR')
                        ){
                        newOrdersListComfort.add(newOrder);
                    }
                }
            }
        }
        if(!newOrdersListRecalc.isEmpty()){
            HDT_UTL_ProcessDateManager.setEffectiveDate(newOrdersListRecalc);
        }
        if(!newOrdersListComfort.isEmpty()){
            HDT_UTL_ProcessDateManager.calculateOrderProcessDate(newOrdersListComfort);
        }
    }
    // START @Picchiri HRADTR-77 Calcolo Date 01.06.21
    /**
     * @description Ricalcolo delle date
     * @param newOrdersList
     * @param oldOrdersList
     */
    public static void orderCalulateDateUpdate(List<Order> newOrdersList, List<Order> oldOrdersList) { 
        List<Order> orderList = new List<Order>();                        
        Map<String,Boolean> mapAccountRes = HDT_UTL_SwtichInProcess.checkAccountOrderIsResidential(newOrdersList);
        //IsSequanzialized__c
        Map<String,Order> mapOldOrder = new Map<String,Order>();
        for (Order oldOrder : oldOrdersList) {
            mapOldOrder.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
            Boolean ricalculateDate = false;
            //for (Order oldOrder : oldOrdersList) {
            Order oldOrder = mapOldOrder.get(newOrder.id);
            if(oldOrder != null){
                if(newOrder.id == oldOrder.id 
                    && newOrder.Status == 'In Lavorazione'
                    && newOrder.ProcessType__c != null
                    && newOrder.SignedDate__c != null
                    && (newOrder.ProcessType__c.contains('Switch in') || newOrder.ProcessType__c.contains('Cambio Offerta'))
                    && ( (newOrder.SignedDate__c != oldOrder.SignedDate__c && newOrder.WizardCompletedDate__c != null)
                        ||(oldOrder.Phase__c == 'Comunicazione verso Heroku KO' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        ||(oldOrder.Phase__c == 'Amm. Precheck KO SII' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        || (oldOrder.Phase__c == 'Ammissibilità KO' && newOrder.Phase__c == 'Comunicazione verso Heroku')
                        || (oldOrder.IncomingCreditCheckResult__c == 'KO' && newOrder.IncomingCreditCheckResult__c == 'OK')
                        || (oldOrder.IsSequanzialized__c == true && newOrder.IsSequanzialized__c == false)
                    )
                ){
                    ricalculateDate = true;
                }
                
                if(ricalculateDate == true){
                    Order orderToUpdate = new Order();
                    orderToUpdate.id = newOrder.Id;
                    if(mapAccountRes.get(newOrder.AccountId)){                                        
                        orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(newOrder);       
                    }
                    if(!newOrder.ProcessType__c.contains('Cambio Offerta')){
                        orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(newOrder);
                    }                             
                    orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(newOrder); // Data di decorrenza
                    orderList.add(orderToUpdate);                    
                }                                   
            }
        }
        
        if(!orderList.isEmpty()){
            orderSrv.updateRecords(orderList);
        }        

    }
    // END @Picchiri HRADTR-77 Calcolo Date 01.06.21
    @TestVisible
    private static List<String> getParentOrders(List<Order> newOrdersList, List<Order> oldOrdersList, Map<String,Order> orderMapNewToOld){
        List<String> orderIds = new List<String>();
        for (Order newOrder : newOrdersList) {
            orderIds.add(newOrder.Id);
        }

        List<String> orderIdsToReturn = new List<String>();

        orderSrv.checkReadAccess('RecordType.DeveloperName, Phase__c');
        List<Order> ordersFullList = orderQr.getRecordsByIds(orderIds);

        // List<Order> ordersToUpdateContract = new List<Order>();

        for (Order order : ordersFullList) {
            if (order.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && order.Phase__c == 'Documentazione Gestita') {
                orderIdsToReturn.add(order.Id);
            }
        }
        return orderIdsToReturn;
    }
    @TestVisible
    private static List<Order> getParentOrders2(List<Order> newOrdersList, List<Order> oldOrdersList, Map<String,Order> orderMapNewToOld){
        List<String> orderIds = new List<String>();
        for (Order newOrder : newOrdersList) {
            orderIds.add(newOrder.Id);
        }

        List<Order> orderIdsToReturn = new List<Order>();

        orderSrv.checkReadAccess('RecordType.DeveloperName, Phase__c');
        List<Order> ordersFullList = orderQr.getRecordsByIds(orderIds);

        // List<Order> ordersToUpdateContract = new List<Order>();

        for (Order order : ordersFullList) {
            if (order.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && order.Phase__c == 'Documentazione Gestita') {
                orderIdsToReturn.add(order);
            }
        }
        return orderIdsToReturn;
    }
    
    @TestVisible
    private static void updateChildOrdersPhase(List<String> parentOrderIds, String currentPhase, String newPhase) {
        
        List<Order> childOrdersToUpdate = new List<Order>();
        
        orderSrv.checkReadAccess('Phase__c');
        List<Order> childOrders = orderQr.getChildOrdersByParentIds(parentOrderIds);
    
        for (Order childOrder : childOrders) {
            //@frpanico 06/09/2021 added voltura condition
            if (childOrder.Phase__c == currentPhase && childOrder.ProcessType__c != 'Voltura') {  
            
                Order orderToUpdate = new Order(
                    Id = childOrder.Id,
                    Phase__c = newPhase
                );
                childOrdersToUpdate.add(orderToUpdate);
            }
        }

        orderSrv.updateRecords(childOrdersToUpdate);
    }

    @TestVisible
    private static Map<Id, String> updateChildOrdersPhase(List<Order> parentOrderIds, String currentPhase, String newPhase,String currentVasPhase,String newVasPhase) {

        List<Order> childOrdersToUpdate = new List<Order>();
        Map<Id, String> vasOrdersToUpdate = new Map<Id, String>();//id->newPhase
        
        orderSrv.checkReadAccess('Phase__c');
        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agentCodeIsMonitoringList();
        Order notManagedOrder = new Order();
        Boolean isNotManaged = false;
        /* Temporanea Nuova Attivazione */
        for(Order childOrder : parentOrderIds)
        {
            if(childOrder.recordType.Developername == 'HDT_RT_TemporaneaNuovaAtt')
            {
                notManagedOrder = childOrder;
                break;
            }
        }
        if(notManagedOrder != null)
        {
            isNotManaged = isNotManaged(notManagedOrder);
        }
        for (Order childOrder : parentOrderIds) {
            /* Gestione VAS */
            if(childOrder.recordType.Developername == 'HDT_RT_VAS' && childOrder.Phase__c == currentPhase){
                String phase = HDT_UTL_VasManagement.updateVasPhase( newVasPhase, childOrder );
                Order orderToUpdate = new Order(
                    Id = childOrder.Id,
                    Phase__c = phase
                );
                childOrdersToUpdate.add(orderToUpdate);
                // Order orderToUpdate = new Order(Id = childOrder.Id, Phase__c = newVasPhase);
                // childOrdersToUpdate.add(orderToUpdate);
            } else if (childOrder.recordType.Developername == 'HDT_RT_TemporaneaNuovaAtt' && isNotManaged ) {
                if (childOrder.Phase__c == currentPhase ) {
                            Order orderToUpdate = new Order(
                                Id = childOrder.Id,
                                    Phase__c = 'Pratica non gestita per il DL'
                            );
                            childOrdersToUpdate.add(orderToUpdate);
                        }
            }
            else{
                /* Gestione Transitorio */
                if('Esportazione VS Siebel ' == newPhase){
                    if (childOrder.Phase__c == currentPhase) {
                        Order orderToUpdate = new Order(
                            Id = childOrder.Id,
                                Phase__c = newPhase,
                                isTransition__c = childOrder.isTransition__c
                        );
                        childOrdersToUpdate.add(orderToUpdate);
                    }
                }
                else{
                    if (childOrder.Phase__c == currentPhase
                        //@frpanico 06/09/2021 added voltura condition
                        /* Solo la voltura Energy deve rimanere nella fase Documentazione Validata, per il non energy deve procedere verso Creazione BP-CA */
                        && (childOrder.ProcessType__c != 'Voltura')
                        && childOrder.ImplantType__c != '1107-Colonnetta' ) {
                        Order orderToUpdate = new Order(
                            Id = childOrder.Id,
                                Phase__c = newPhase
                        );
                        childOrdersToUpdate.add(orderToUpdate);
                    }
                }
            }
        }
        orderSrv.updateRecords(childOrdersToUpdate);
        return vasOrdersToUpdate;
    }

    
    private static Boolean isNotManaged( Order ord ){

        Integer count = [SELECT count() FROM HDT_AdminServiceDispatcher__mdt 
                            WHERE DistributorCode__c =:ord.DistributorCode__c 
                            AND   Commodity__c =:ord.Commodity__c 
                            AND   ServiceCode__c =:ord.ProcessCode__c
                            AND   Type__c =:ord.ProcessType__c
                            AND   Active__c = true
                            WITH SECURITY_ENFORCED];

        return ( count == 0 );

    }

    @TestVisible
    private static void updateChildOrdersPhaseChild(List<String> parentOrderIds, String currentPhase, String newPhase,String currentVasPhase,String newVasPhase) {
        
        List<Order> childOrdersToUpdate = new List<Order>();

        orderSrv.checkReadAccess('Phase__c');
        List<Order> childOrders = orderQr.getChildOrdersByParentIds(parentOrderIds);

        for (Order childOrder : childOrders) {
            if(childOrder.recordType.Developername == 'HDT_RT_VAS'){
                if (childOrder.Phase__c == currentVasPhase) {
                    Order orderToUpdate = new Order(
                        Id = childOrder.Id,
                        Phase__c = newVasPhase
                    );
                    childOrdersToUpdate.add(orderToUpdate);
                }
            }
            else{
                if('Esportazione VS Siebel' == newPhase){
                    if (childOrder.Phase__c == currentPhase) {
                        Order orderToUpdate = new Order(
                            Id = childOrder.Id,
                            Phase__c = newPhase,
                            isTransition__c = childOrder.isTransition__c
                        );
                    childOrdersToUpdate.add(orderToUpdate);
                    }
                }
            }
        }
        orderSrv.updateRecords(childOrdersToUpdate);
    }

    /**
     * @description updatePhase
     * @param newOrdersList
     * @param oldOrdersList
     * @return List<Order>
     */
    public static List<Order> updatePhase(List<Order> newOrdersList, List<Order> oldOrdersList) {

        Id bonusScontiRtId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ScontiBonus').getRecordTypeId();
        Map<String,Order> orderMapOld = new Map<String,Order>();

        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
            if(orderMapOld.get(newOrder.id)!= null){
                Order old= orderMapOld.get(newOrder.id);
                if(newOrder.TecnicalPhase__c != null && newOrder.TecnicalPhase__c == old.TecnicalPhase__c && 
                    (  newOrder.Phase__c == 'Voltura Rifiutata' 
                    || newOrder.Phase__c == 'Documentazione Validata'
                    || newOrder.Phase__c=='Comunicazione verso Heroku' 
                    || newOrder.Phase__c=='Ripensamento - Da inviare' 
                    || newOrder.Phase__c=='Annullamento - Da inviare' 
                    || newOrder.Phase__c=='Preventivo Accettato' 
                    || newOrder.Phase__c=='Comunicazione Motore VAS' 
                    || newOrder.Phase__c=='Documentazione da firmare'
                    || newOrder.Phase__c=='Ammissibilità OK'
                    || newOrder.Phase__c=='Creazione BP-CA')){
                    newOrder.Phase__c = newOrder.TecnicalPhase__c;
                    newOrder.TecnicalPhase__c = null;
                }
                if ('Completata'.equalsIgnoreCase(newOrder.Phase__c)&& newOrder.Status.equalsIgnoreCase('Activated') && !newOrder.SBQQ__Contracted__c && !old.SBQQ__Contracted__c && newOrder.recordTypeId!=bonusScontiRtId ) { //Fabiana 15/09/2021 //Sandy 05/10 Flusso Bonus e Sconti richiede chiusura e contracted in due transazioni distinte
                    if(!newOrder.isTransition__c)
                    {
                        newOrder.SBQQ__Contracted__c=true; 
                    }
                }
            }           
        }
        return newOrdersList;
    }

      /**
     * @description 
     * HRDTR-00_HRAWRM-638
     **/
    public static void overturningFields(List<Order> oldList, List<Order> listOrder ){

        Map<Id, Sobject> mapObjToUpdate = new Map<Id, Sobject>();
        Map<String,Order> mapOld = new Map<String,Order>();

        for(Order old : oldList){ 
            mapOld.put(old.id,old);
        }
        for (Order temp : listOrder) {
            if(mapOld.get(temp.id).phase__c != 'Completata' && temp.Phase__c == 'Completata' && temp.Status.equalsIgnoreCase('Activated')){
                if ( String.isNotBlank(String.valueOf(temp.ServicePoint__c))) {
                    ServicePoint__c sp=new ServicePoint__c(id=temp.ServicePoint__c);
                    sp.supplytype__c = temp.ServicePoint__r.supplytypeTemp__c;
                    sp.implantType__c = temp.ServicePoint__r.implantTypeTemp__c;  
                    if (String.isNotBlank(temp.SAPImplantCode__c)) {
                        sp.SAPImplantCode__c= temp.SapImplantCode__c; 
                    }  
                    sp.account__c = temp.AccountId;
                    mapObjToUpdate.put(sp.Id, sp);
                }
            }
        }
        if(!mapObjToUpdate.values().isEmpty()){
            update  mapObjToUpdate.values();
        }
    }

    /**
     * @description  FIX METODO DEFELICE
     * @param newOrdersMap
     * @param oldOrdersMap
     **/
    public static void creditCheckManager2(Map<Id,SObject>  newOrdersMap, Map<Id,SObject> oldOrdersMap) {
        Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();
        Map<String,List<Order>> orderMapNew = new Map<String,List<Order>>();
        List<Order> orderListOldCustomer = new List<Order>();                        
        List<Order> orderListNewCustomer = new List<Order>();   
        List<Order> orderListcreditCheckPhaseManager = new List<Order>();
        List<Id> orderParentList = new List<Id>();                        

        for (Order newOrder : (List<Order>) newOrdersMap.values()) {
            Order oldOrder = (Order) oldOrdersMap.get(newOrder.id); 
            String recordTypeName = rtMap.get(newOrder.RecordTypeId).getDeveloperName();
            //Modifica necessaria, perchè delle volte il credit check arriva prima dell'aggiornamento del recordtype dell'order e trovandolo ancora in record type default non crea l'activity
            if(checkRecordTypeForCreditCheck(recordTypeName, newOrder)
            || ('HDT_RT_Default'.equalsIgnoreCase(recordTypeName) && 
                    (('KO'.equalsIgnoreCase(newOrder.IncomingCreditCheckResult__c) && !newOrder.IncomingCreditCheckResult__c.equalsIgnoreCase(oldOrder.IncomingCreditCheckResult__c))
                    || (('KO'.equalsIgnoreCase(newOrder.OutgoingCreditCheckResult__c) && !newOrder.OutgoingCreditCheckResult__c.equalsIgnoreCase(oldOrder.OutgoingCreditCheckResult__c))))
                )
            ){                             
                if (newOrder.CreditCheckDescription__c != null && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c) {    
                    /* 
                    @ealpi: Da analisi non mi risultano casi in cui bisogna creare l'activity se l'ordine cambia la CreditCheckDescription__c ma rimane in KO
                    è stato quindi cambiato l'if, perchè in conflitto con il KO cvp che viene gestito in sincrono ma che contemporaneamente potrebbe essere inviato 
                    in asincrono.
                    if(newOrder.OutgoingCreditCheckResult__c == 'KO' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){
                    */
                    if('KO'.equalsIgnoreCase(newOrder.OutgoingCreditCheckResult__c) && !newOrder.OutgoingCreditCheckResult__c.equalsIgnoreCase(oldOrder.OutgoingCreditCheckResult__c)){                            
                        orderListOldCustomer.add(newOrder);
                    }
                    /* 
                    @ealpi: vedi precedente commento
                    if(newOrder.IncomingCreditCheckResult__c == 'KO' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){ */
                    if('KO'.equalsIgnoreCase(newOrder.IncomingCreditCheckResult__c) && !newOrder.IncomingCreditCheckResult__c.equalsIgnoreCase(oldOrder.IncomingCreditCheckResult__c)){
                        orderListNewCustomer.add(newOrder);
                    }                                      
                }
                if((oldOrder.IncomingCreditCheckResult__c!=null && oldOrder.IncomingCreditCheckResult__c.contains('KO')) && (newOrder.IncomingCreditCheckResult__c != null && newOrder.IncomingCreditCheckResult__c.contains('OK'))){
                    orderListcreditCheckPhaseManager.add(newOrder);
                }
                //Gestione Documentazione Gestita
                if ('Da Inviare'.equalsIgnoreCase(newOrder.Phase__c) && !newOrder.Phase__c.equalsIgnoreCase(oldOrder.Phase__c) && !orderParentList.contains(newOrder.ParentOrder__c)){
                    orderParentList.add(newOrder.ParentOrder__c);
                }
            }
        }

        if (!orderListOldCustomer.isEmpty() || !orderListNewCustomer.isEmpty()){
            orderMapNew.put('oldCustomer',orderListOldCustomer);
            orderMapNew.put('newCustomer',orderListNewCustomer); 
        }
          
        
        if(!orderMapNew.isEmpty()){
            HDT_UTL_ActivityCustomProcess.createActivityForCreditCheck(orderMapNew);
        }        
        if(!orderListcreditCheckPhaseManager.isEmpty()){
            creditCheckPhaseManager(orderListcreditCheckPhaseManager);                     
        }   
        
        if (!orderParentList.isEmpty()){
            List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platformEventToPublish = new List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>();
            for (Order o : [SELECT id,Description FROM Order WHERE Id IN :orderParentList AND Phase__c = 'Documentazione Gestita' WITH SECURITY_ENFORCED]){
                o.Description = String.isBlank(o.Description) ? 'Aggiornato Post Credit Check' : '';
                HDT_PEV_VoltureChangeManagerUpdateSObj__e item = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
                item.SerializedSobj__c = JSON.serialize(o);
                platformEventToPublish.add(item);
            }
            if (!platformEventToPublish.isEmpty()){
                Eventbus.publish(platformEventToPublish);
            }
        }
    }        

    public static Boolean checkRecordTypeForCreditCheck(String recordTypeName, Order newOrder){
        return ((recordTypeName == 'HDT_RT_VAS' && newOrder.OrderReferenceNumber == null && newOrder.ContractReference__c == null && !'Analisi consumi'.equalsIgnoreCase(newOrder.VasSubtype__c)) || recordTypeName == 'HDT_RT_Voltura' || recordTypeName == 'HDT_RT_Attivazione' || recordTypeName == 'HDT_RT_VolturaConSwitch' || recordTypeName == 'HDT_RT_Subentro' || recordTypeName == 'HDT_RT_AttivazioneConModifica' || recordTypeName == 'HDT_RT_SwitchIn' || recordTypeName == 'HDT_RT_ConnessioneConAttivazione' || recordTypeName == 'HDT_RT_TemporaneaNuovaAtt');
    }
    /**
     * @description  @Picchiri 16.06.21 chiamata Mulesoft // Lista di ordini per nuovo cliente dove si è ricevuto un ok dopo un ko
     * @param orderList
     **/
    public static void creditCheckPhaseManager(List<Order> orderList){ 

        Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();        
        List<Order> orderListToUpdate = new List<Order>();
        Map<Id,Order> mapIdToTotalOrder = new Map<Id,Order>();
        Map<Id,Order> mapIdToOrderUpdate = new Map<Id,Order>();
        //Map<Id,Order> mapIdToOrderClean = new Map<Id,Order>();        
        Set<Id> orderSetId = new Set<Id>();
        List<wrts_prcgvr__Activity__c> actListToUpdate = new List<wrts_prcgvr__Activity__c>();
        //List<wrts_prcgvr__Activity__c> actListToRecheck = new List<wrts_prcgvr__Activity__c>();
        Map<Id,wrts_prcgvr__Activity__c> mapIdOrderToActivity = new Map<Id,wrts_prcgvr__Activity__c>();

        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agentCodeIsMonitoringList();

        for(Order orderToUpdate : orderList){
            mapIdToTotalOrder.put(orderToUpdate.id,orderToUpdate);
            String recordTypeName = rtMap.get(orderToUpdate.RecordTypeId).getDeveloperName();

            if(orderToUpdate.ParentOrder__r.Phase__c == 'Documentazione Gestita' && (orderToUpdate.Phase__c == 'Documentazione Validata' || orderToUpdate.Phase__c == 'Documentazione da inviare' )){
                if(orderToUpdate.recordType.Developername != 'HDT_RT_VAS'
                    && !orderToUpdate.QualityCall__c
                    && !isMonitoringList.contains(orderToUpdate.CommercialId__c)){
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }
                else{
                    orderToUpdate.Phase__c = 'Comunicazione Motore VAS';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }
            }

            //if((recordTypeName == 'HDT_RT_VAS' && orderToUpdate.OrderReferenceNumber != null && orderToUpdate.ContractReference__c != null) || recordTypeName == 'HDT_RT_Voltura' || recordTypeName == 'HDT_RT_Subentro' || recordTypeName == 'HDT_RT_AttivazioneConModifica' || recordTypeName == 'HDT_RT_SwitchIn' || recordTypeName == 'HDT_RT_ConnessioneConAttivazione' || recordTypeName == 'HDT_RT_TemporaneaNuovaAtt'){         
            if(checkRecordTypeForCreditCheck(recordTypeName, orderToUpdate)){             
                if((orderToUpdate.IncomingCreditCheckResult__c != null && orderToUpdate.IncomingCreditCheckResult__c == 'OK') || (orderToUpdate.OutgoingCreditCheckResult__c != null && orderToUpdate.OutgoingCreditCheckResult__c == 'OK')){
                    orderSetId.add(orderToUpdate.id);
                }                
            }
        }   

        // recuperare l'activity per questi ordini
        // Le activity sull'ordine potrebbero essere più di una. Bisogna prendere quella con record type "credit check ko" e wrts_prcgvr__Status__c "creata" e CreditCheckReason__c contiene  "Cattivo pagatore"
        if(!orderSetId.isEmpty()){
            List<wrts_prcgvr__Activity__c> actList = HDT_QR_ActivityCustom.getActivityListCrediCheck(orderSetId);
            for(wrts_prcgvr__Activity__c act : actList){
                mapIdOrderToActivity.put(act.Order__c,act);
            }
            
            for(Order ord : orderList){
                if (!'Credit Check Forzato dall\'operatore'.equalsIgnoreCase(ord.CreditCheckDescription__c)){
                    wrts_prcgvr__Activity__c actToUpdate = mapIdOrderToActivity.get(ord.Id);
                    actToUpdate.CreditCheckResolutionReason__c = ord.CreditCheckDescription__c;
                    actToUpdate.CreditCheckReason__c = ord.CreditCheckDescription__c;
                    actToUpdate.CreditCheckResults__c = ord.IncomingCreditCheckResult__c;
                    actToUpdate.wrts_prcgvr__Status__c = 'KO Risolto';
                    actListToUpdate.add(actToUpdate);
                }
                
                /*if(ord.CreditCheckDescription__c.contains('Saldo debito cattivo pagatore') && actToUpdate.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_CreditCheckKO')){
                    mapIdToOrderClean.put(ord.id,ord);                
                }    
                if(ord.CreditCheckDescription__c.contains('Saldo debito cattivo pagatore') || ord.OutgoingCreditCheckResult__c != null){                
                    actListToRecheck.add(actToUpdate);
                }*/
            }
            if (!actListToUpdate.isEmpty()){
                HDT_UTL_ActivityCustomProcess.updateCreditCheckActivity(actListToUpdate);
            }
        }
        // sbiancare l'esito ( IncomingCreditCheckResult__c / CreditCheckDescription__c) su order e reinviare la chiamata 
        /*if(!mapIdToOrderClean.isEmpty()){
            mapIdToOrderUpdate = cleanCreditCheckOnOrder(mapIdToOrderClean,mapIdToTotalOrder);             
        }
        if(!mapIdToOrderUpdate.isEmpty()){
            orderSrv.updateRecords(mapIdToOrderUpdate.values());
            //update  mapIdToOrderUpdate.values();                    
        }
        // reinviare la chiamata        
        if(!actListToRecheck.isEmpty()){
            HDT_UTL_ActivityCustomProcess.recheckCreditCheck(actListToRecheck);
        }*/
    }

    /**
     * @description  @Picchiri sbiancamento esito e causale credit check all'interno dell'ordine. Per risottomissione credit check
     * @param mapIdToOrderClean
     * @param mapIdToOrderUpdate
     * @return Map<Id,Order>
     **/
    /* public static Map<Id,Order> cleanCreditCheckOnOrder(Map<Id,Order> mapIdToOrderClean,Map<Id,Order> mapIdToOrderUpdate) {
        Map<Id,Order> mapIdToOrderUpdateTmp = new Map<Id,Order>();

        for(Order ord : mapIdToOrderUpdate.values()){
            Order orderTmp = new Order();
            orderTmp.id = ord.id;
            orderTmp.IncomingCreditCheckResult__c = '';
            orderTmp.OutgoingCreditCheckResult__c = '';
            orderTmp.CreditCheckDescription__c = '';
            mapIdToOrderUpdateTmp.put(ord.id,orderTmp);

        }

        return mapIdToOrderUpdateTmp;    
    } */
    // FINE @Picchiri Credit check Date 15.06.21

    public static void updatePhaseForFirm(List<Order> newListOrder){
        /*@frpanico 15/12/2021
        * DM Voltura - Aggiunta gestione ritorno da Docusign
        * per la Voltura Con Switch Ele nel caso di firma OTP
        */
        for(Order order: newListOrder)
        {
            if(order.ProcessType__c != null && order.ProcessType__c.equalsIgnoreCase('Voltura Con Switch')
                && order.Commodity__c != null && order.Commodity__c.equalsIgnoreCase('Energia Elettrica')
                && order.SignatureMethod__c != null && order.SignatureMethod__c.containsIgnoreCase('OTP'))
            {
                /**@frpanico 15/12/2021
                 * Aggiunto controllo su Tecnical Phase 
                 * Per non far girare al secondo passaggio il metodo
                 * Verificato che la callout viene innescata
                 */
                if(order.DocumentalPhase__c != null && order.DocumentalPhase__c.equalsIgnoreCase('Plico firmato') && order.Phase__c != null && order.Phase__c.equalsIgnoreCase('In Attesa Legge 80') && order.TecnicalPhase__c == null)
                {
                    order.Phase__c = 'Comunicazione verso Heroku';
                }
            }
            else if(order.Phase__c != null && order.phase__c.equalsIgnoreCase('Documentazione da firmare') && order.DocumentalPhase__c !=null && order.DocumentalPhase__c.containsIgnoreCase('Plico firmato')){
                    if((order.Sale__r.Channel__c == 'Agenzie' || order.Sale__r.Channel__c == 'Business Agent') && (order.SignatureMethod__c == 'OTP Remoto' || order.SignatureMethod__c == 'OTP Coopresenza' )){
                        order.TecnicalPhase__c = 'Documentazione da Validare';
                        //listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                        //childToUpdate.add(ord);
                    }
                    else{
                        order.TecnicalPhase__c = 'Documentazione Gestita';
                        // ord.status = 'Activated';
                        order.SignedDate__c = date.today();
                        //childToUpdate.add(ord);
                    }
            }
        }
    }

    @SuppressWarnings('PMD.AvoidDebugStatements') 
    public static Boolean manageCancellationProcess(List<Order> orderList, Map<Id,SObject> orderOldMapd){
		Order orderNew = orderList[0];
		Order orderOld = (Order) Trigger.oldMap.get(orderNew.Id);
		String newPhase = orderNew.Phase__c;
		String oldPhase = orderOld.Phase__c;
        DateTime nowDateTime = DateTime.now();
		if(String.isNotBlank(newPhase) && String.isNotBlank(oldPhase) && newPhase != oldPhase){
            //@frpanico closes open activities on "Annullato" or "Ripensato"
            if(newPhase.equalsIgnoreCase('Annullato') || newPhase.equalsIgnoreCase('Ripensato') || newPhase.equalsIgnoreCase('Annullamento per Switch-out') || newPhase.containsIgnoreCase('Annullamento SII'))
            {                
                List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
                try
                {
                    activities = orderQr.getOpenActivitiesByOrderId(orderNew.Id);
                    List<wrts_prcgvr__Activity__c> activitiesToUpdate = new List<wrts_prcgvr__Activity__c>();
                    for(wrts_prcgvr__Activity__c activity : activities)
                    {
                        if (!'Eseguire Gestione Manuale SAP'.equalsIgnoreCase(activity.Type__c)){
                            activity.wrts_prcgvr__Status__c = 'Annullata';
                            activitiesToUpdate.add(activity);
                        }
                    }
                    if (!activitiesToUpdate.isEmpty()){
                        HDT_UTL_DatabaseService.updateSObject(activitiesToUpdate);
                    }
                }
                catch(Exception e)
                {
                    if (String.isNotBlank(e.getMessage()) && e.getMessage().containsIgnoreCase('Questo utente non dispone dei permessi per l\'activity CreditCheckKO')){
                        orderNew.addError('Non è possibile annullare l\'ordine perchè è presente un\'attività di credit check ancora aperta e non si dispone dei permessi per poterla lavorare.');
                    }
                    System.debug(Logginglevel.Debug, 'Exception: ' + e.getMessage() + '. At Line: ' + e.getLineNumber());
                }
                if(orderNew.ProcessType__c != null && 
                    (orderNew.ProcessType__c.equalsIgnoreCase('Voltura') ||  orderNew.ProcessType__c.containsIgnoreCase('Cambio Offerta'))
                    )
                {
                    Case nonReqContract = new Case();
                    HDT_QR_Case caseQr = new HDT_QR_Case(); 
                    nonReqContract = caseQr.getNonReqContrOrder(orderNew.Id);
                    if(!(String.isBlank(nonReqContract.Id)))
                    {
                        nonReqContract.Phase__c = 'Completata';
                        HDT_UTL_DatabaseService.updateSObject(nonReqContract);
                    }
                    if ( orderNew.ProcessType__c.equalsIgnoreCase('Voltura') ){
                        System.enqueueJob( new HDT_QBL_VoltureChangeManager(orderNew,'S0') );
                    }
                }
            }
            if(newPhase.containsIgnoreCase('Annullato') || newPhase.equalsIgnoreCase('Ripensato') || newPhase.equalsIgnoreCase('Annullamento per Switch-out'))
            {
                if((orderNew.VasStatus__c == null || (orderNew.VasStatus__c != null  && !orderNew.VasStatus__c.equalsIgnoreCase('ANNUL PER RIPENS'))) && !'Activated'.equalsIgnoreCase(orderNew.StatusCode))
                {
                    orderNew.Status = 'Annullato';
                }
            }
            /**@frpanico 22/10/2021
             * Si entra nello skip soltanto se la fase di partenza non e' di annullamento
             * Dunque non sono previste activity
             * update: 2022-03-07
             * Introdotto skip quando arriva il Ripensato KO
             */
			if((newPhase.indexOf('Annullamento') > -1 /*|| newPhase.indexOf('Annullamento') == -1*/) || newPhase.containsIgnoreCase('Annullato') || newPhase.indexOf('Ripensamento') > -1 || newPhase.indexOf('Ripensato') > -1){
                if((oldPhase.indexOf('Annullamento - ') == -1 && oldPhase.indexOf('Ripensamento - ') == -1)
                    || newPhase.containsIgnoreCase('Annullato') || newPhase.indexOf('Ripensato') > -1)
                {
				    orderNew.PhaseStory__c = !String.isBlank(orderNew.PhaseStory__c) 
                        ? oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c
                        : oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||';
                    return true;
                }
                //Gestione Risottomissione Annullamento
                if ((oldPhase.equalsIgnoreCase('Annullamento - Ammissibilità KO') || oldPhase.equalsIgnoreCase('Annullamento - Esito KO da DL/SII')) && newPhase.equalsIgnoreCase('Annullamento - Da Inviare')){
                    orderNew.PhaseStory__c = !String.isBlank(orderNew.PhaseStory__c) 
                        ? oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c
                        : oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||';
                    return true;
                }
                return false;
            /**@frpanico 22/10/2021
             * Si entra nello skip soltanto se la fase di arrivo non e' di annullamento
             * Dunque non sono previste activity
             * update 2022-03-07
             * Introdotto Skip quando si esce da Ripensato KO
             */
			}else if(oldPhase.indexOf('Annullamento - ') > -1 || oldPhase.indexOf('Ripensamento - ') > -1 || oldPhase.indexOf('Ripensato')>-1){
                orderNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c;
				return true;
			}

		}
		return false;
	}
        
    /**
     * @description  updateServiceRequest
     * @param newOrdersList
     * @param oldOrdersList
     **/
    public static void updateServiceRequest(List<Order> newOrdersList, List<Order> oldOrdersList){
        Map<String,Order> mapOrder = new Map<String,Order>();
        Map<String,String> orderStatuses= new Map<String,String>();
        List<ServiceRequest__c> sReqToUpdate= new List<ServiceRequest__c>();
        Set<Id> orderIds= new Set<Id>();
        for(Order o: oldOrdersList){
            mapOrder.put(o.id, o);
        }
        for (Order ord: newOrdersList){
            Order oldOrder= mapOrder.get(ord.id);
            
            if(ord.Status != oldOrder.Status ){
                orderIds.add(ord.Id);
                orderStatuses.put(ord.Id, ord.Status);
            }
        }
        if(!orderIds.isEmpty()){
            List<ServiceRequest__c> srvRequests = HDT_QR_ServiceRequest.getServiceRequestByOrderCaseIds(orderIds, 'Order__c');
            List<ServiceRequest__c> srvRequestsToDelete = new List<ServiceRequest__c>();
            for(ServiceRequest__c s: srvRequests){
                // ServiceRequest__c sReq = new ServiceRequest__c(Id= s.Id);
                s.Status__c= HDT_UTL_MatrixCompatibility.getStatus(orderStatuses.get(s.Order__c), 'Order');
                if( s.Status__c.equalsIgnoreCase('Chiuso') || s.Status__c.equalsIgnoreCase('Annullato') ){
                    s.OwnerId = UserInfo.getUserId();
                    srvRequestsToDelete.add(s);
                } else {
                    sReqToUpdate.add(s);
                }
            }
            if (!srvRequestsToDelete.isEmpty()){
                HDT_SRV_ServiceRequest.updateRecord(srvRequestsToDelete);
                HDT_SRV_ServiceRequest.deleteRecord(srvRequestsToDelete);
            }
            HDT_SRV_ServiceRequest.updateRecord(sReqToUpdate);
        }
    }

    public static void checkCreditProcessStatus(List<Sobject> newOrdersListObj, Map<Id,Sobject> oldOrdersMapObj){
        List<Order> newOrdersList = (List<Order>)newOrdersListObj;
        Map<Id,Order> oldOrdersMap = (Map<Id,Order>)oldOrdersMapObj;
        Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();
        Set<Id> ordersId = new Set<Id>();
        //Set<Id> contractReferences = new Set<Id>();
        //Boolean enableQueryContracts = false;
        for(Order o : newOrdersList){
            String recordTypeName = rtMap.get(o.RecordTypeId).getDeveloperName();
            String oldCreditCheckDescription = String.isNotBlank(oldOrdersMap.get(o.Id).CreditCheckDescription__c) ? oldOrdersMap.get(o.Id).CreditCheckDescription__c : '';
            if(checkRecordTypeForCreditCheck(recordTypeName, o) && (
                (o.IncomingCreditCheckResult__c != oldOrdersMap.get(o.Id).IncomingCreditCheckResult__c && !'Saldo debito cattivo pagatore'.equalsIgnoreCase(o.CreditCheckDescription__c))
                || ('OK'.equalsIgnoreCase(o.IncomingCreditCheckResult__c) && !oldCreditCheckDescription.equalsIgnoreCase(o.CreditCheckDescription__c) && 'Saldo debito cattivo pagatore'.equalsIgnoreCase(oldCreditCheckDescription))
                || o.OutgoingCreditCheckResult__c != oldOrdersMap.get(o.id).OutgoingCreditCheckResult__c)
            ){
                if('Attesa Credit Check'.equalsIgnoreCase(o.Phase__c) || 'Credit Check KO'.equalsIgnoreCase(o.Phase__c) || o.IsMassive__c){
                    ordersId.add(o.Id);
                    /* if('HDT_RT_Voltura'.equalsIgnoreCase(recordTypeName) || 'HDT_RT_VolturaConSwitch'.equalsIgnoreCase(recordTypeName)){
                        enableQueryContracts = true;
                    } */ 
                }                               
            }
        }
        if(!ordersId.isEmpty()){
            Map<Id, Order> currentOrders = new Map<Id, Order>([SELECT Id, RecordTypeId, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, CreditCheckInProgress__c, Phase__c, ProcessType__c, CommodityFormula__c, IsCloned__c, SignedDate__c, RecordType.DeveloperName, ContractReference__c FROM Order WHERE Id IN: ordersId ]);
            /* Map<Id,Contract> contracts = new Map<Id, Contract>();
            if(enableQueryContracts){
                for(Order o : newOrdersList){
                    contractReferences.add(o.ContractReference__c);
                }

                contracts = new Map<Id, Contract>([SELECT Id, Account.CompanyOwner__c FROM Contract WHERE Id IN :contractReferences]);
            } */
            for(Order o : newOrdersList){
                String recordTypeName = rtMap.get(o.RecordTypeId).getDeveloperName();
                String oldCreditCheckDescription = String.isNotBlank(oldOrdersMap.get(o.Id).CreditCheckDescription__c) ? oldOrdersMap.get(o.Id).CreditCheckDescription__c : '';
                if(checkRecordTypeForCreditCheck(recordTypeName, o) 
                && (
                    o.IncomingCreditCheckResult__c != oldOrdersMap.get(o.Id).IncomingCreditCheckResult__c
                    || ('OK'.equalsIgnoreCase(o.IncomingCreditCheckResult__c) && !oldCreditCheckDescription.equalsIgnoreCase(o.CreditCheckDescription__c) && 'Saldo debito cattivo pagatore'.equalsIgnoreCase(oldCreditCheckDescription)) 
                    || o.OutgoingCreditCheckResult__c != oldOrdersMap.get(o.id).OutgoingCreditCheckResult__c
                    )
                ){
                    if('Attesa Credit Check'.equalsIgnoreCase(o.Phase__c) || 'Credit Check KO'.equalsIgnoreCase(o.Phase__c) || o.IsMassive__c){
                        if((String.isNotBlank(o.IncomingCreditCheckResult__c) && o.IncomingCreditCheckResult__c.containsIgnoreCase('KO')) || (String.isNotBlank(o.OutgoingCreditCheckResult__c) && o.OutgoingCreditCheckResult__c.containsIgnoreCase('KO'))){
                            o.Phase__c = 'Credit Check KO';
                        }
                        else if((String.isNotBlank(o.IncomingCreditCheckResult__c) && o.IncomingCreditCheckResult__c.containsIgnoreCase('OK')) || (String.isNotBlank(o.OutgoingCreditCheckResult__c) && o.OutgoingCreditCheckResult__c.containsIgnoreCase('OK'))){
                            o.Phase__c = 'Da Inviare'; 
                            Order currentOrder = currentOrders.get(o.Id);
                            switch on currentOrder.RecordType.DeveloperName {
                                when 'HDT_RT_SwitchIn'{
                                    if (o.ProcessType__c == 'Switch in Fittizio') {
                                        o.Phase__c = 'Comunicazione verso Heroku';
                                    }   
                                    if (o.ProcessType__c == 'Switch in Ripristinatorio') {
                                        o.Phase__c = 'Comunicazione verso Heroku';
                                    }
                                    else if(o.SignedDate__c == null){
                                        o.Phase__c = 'Da Inviare' ;                        
                                    }
                                    if (o.IsCloned__c) {
                                        o.Phase__c = 'Comunicazione verso Heroku';
                                    }
                                }
                                /* 
                                when 'HDT_RT_Voltura', 'HDT_RT_VolturaConSwitch'{
                                    //if(o.CommodityFormula__c.equalsIgnoreCase('Energia Elettrica') && !String.isEmpty(contracts.get(o.ContractReference__c).Id) && !contracts.get(o.ContractReference__c).Account.CompanyOwner__c.equalsIgnoreCase('HERA COMM')){
                                    if(o.isTransition__c){
                                        o.Phase__c = 'Esportazione VS Siebel';
                                    }
                                } */
                            }
                            if(o.IsMassive__c){
                                if('HDT_RT_Voltura'.equalsIgnoreCase(currentOrder.RecordType.DeveloperName)){
                                    o.Phase__c = 'Documentazione Validata';
                                }else {
                                    o.Phase__c = 'Comunicazione verso Heroku';
                                }
                            }
                        }
                    }
                }
            }       
        }
    }
    //EVERIS Gestione Scarto Transitorio
    public static Boolean transitorySiebelManagement(List<SObject> newOrderList,Map<Id,SObject> oldOrderMap){
        Boolean response = false;
        Map<Id,String> newActivityObjectRelatedMap = new Map<Id,String>();
        DateTime nowDateTime = DateTime.now();
        for (Order newOrder : (List<Order>) newOrderList){
            String newPhase = newOrder.Phase__c;
            String oldPhase = ((Order)oldOrderMap.get(newOrder.Id)).Phase__c;
            if (String.isNotEmpty(newPhase) && !newPhase.equalsIgnoreCase(oldPhase) && ('Caricamento Siebel OK'.equalsIgnoreCase(newPhase) || 'Caricamento Siebel KO'.equalsIgnoreCase(newPhase)) && 'In Corso caricamento Siebel'.equalsIgnoreCase(oldPhase)){
                newOrder.PhaseStory__c = !String.isBlank(newOrder.PhaseStory__c) 
                        ? oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+newOrder.PhaseStory__c
                        : oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||';
                response = true;
                if ('Caricamento Siebel KO'.equalsIgnoreCase(newPhase)){
                    newActivityObjectRelatedMap.put(newOrder.Id,newOrder.DiscardReason__c);
                }
            }
            /**@frpanico 2022-03-11
             * Aggiunta gestione rientro 
             * Pratica Gestita
             * per pratiche a transitorio
             */
            Set<String> finalStatuses = new Set<String>{'Annullato','KO definitivo','Pratica gestita','KO gestito','Eliminato','KO','Pratica rifiutata','Chiuso'};
            if(String.isNotEmpty((String)newOrder.get('SiebelStatus__c'))&&(finalStatuses.contains((String)newOrder.get('SiebelStatus__c'))))
            {
                response = true;
            }
        }
        if (response && !newActivityObjectRelatedMap.isEmpty()){
            HDT_UTL_Scarti.createActivityForKoSiebel(newActivityObjectRelatedMap);
        }
        return response;
    }
    /**@frpanico 2022-03-10
     * Gestione Aggiornamento in Completata
     * Alla ricezione del Pratica Gestita
     * Sblocco Pratica Vas/Bonus associata
     */
    public static void transitoryPhaseManagement(List<SObject> newOrderList, Map<Id,SObject> oldOrderMap)
    {
        Id bonusScontiRtId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ScontiBonus').getRecordTypeId();
        Id vasRtId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
        Id defaultRtId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Default').getRecordTypeId();
        List<ServiceRequest__c> serviceRequestToDelete = new List<ServiceRequest__c>();
        Set<Id> orderIds = new Set<Id>();
        //fix 915259C
        //Set<Id> parentOrderIds = new Set<Id>();
        Set<Id> quoteOrderIds = new Set<Id>();
        Set<Id> orderReferenceIds = new Set<Id>();
        Map<Id,Id> orderQuoteMap = new Map<Id,Id>();
        //fine fix 915259C
        Map<Id,String> mapVasPhase = new Map<Id,String>();
        Map<Id,String> mapVasStatus = new Map<Id,String>();
        Set<String> negativeOutcomes = new Set<String>{'Annullato','KO definitivo','Eliminato','KO','Pratica rifiutata','KO gestito'};
        Set<String> positiveOutcomes = new Set<String>{'Pratica gestita','Chiuso'};
        for(Order newOrder : (List<Order>) newOrderList)
        {
            String oldPhase = newOrder.Phase__c;
            Order oldOrder = (Order) oldOrderMap.get(newOrder.Id);
            DateTime nowDateTime = DateTime.now();
            if(String.isNotEmpty((String)newOrder.get('SiebelStatus__c'))
                && (oldOrder.SiebelStatus__c == null || !(((String)newOrder.get('SiebelStatus__c')).equalsIgnoreCase((String)oldOrder.get('SiebelStatus__c')))))
            {
                String newPhase = positiveOutcomes.contains((String)newOrder.get('SiebelStatus__c'))
                    ? 'Completata'
                    : negativeOutcomes.contains((String)newOrder.get('SiebelStatus__c')) 
                        ? 'Annullato'
                        : '';
                String status = positiveOutcomes.contains((String)newOrder.get('SiebelStatus__c'))
                ? 'Activated'
                : negativeOutcomes.contains((String)newOrder.get('SiebelStatus__c'))
                    ? 'Annullato'
                    : '';
                String vasPhase = positiveOutcomes.contains((String)newOrder.get('SiebelStatus__c'))
                ? 'Esportazione VS Siebel'
                : negativeOutcomes.contains((String)newOrder.get('SiebelStatus__c'))
                    ? 'Annullato'
                    : '';
                String vasStatus = positiveOutcomes.contains((String)newOrder.get('SiebelStatus__c'))
                ? 'In Lavorazione'
                : negativeOutcomes.contains((String)newOrder.get('SiebelStatus__c'))
                    ? 'Annullato' 
                    : '';
                //fix 915259C
                /* mapVasPhase.put(newOrder.ParentOrder__c, vasPhase);
                mapVasStatus.put(newOrder.ParentOrder__c, vasStatus); */
                mapVasPhase.put(newOrder.SBQQ__Quote__c, vasPhase);
                mapVasStatus.put(newOrder.SBQQ__Quote__c, vasStatus);
                orderQuoteMap.put(newOrder.Id, newOrder.SBQQ__Quote__c);
                //fine fix 915259C
                /* Update Fase e Status */
                if(!String.isEmpty(newPhase))
                {
                    newOrder.Phase__c = newPhase;
                    newOrder.Status = status;
                    newOrder.PhaseStory__c = !String.isBlank(newOrder.PhaseStory__c) 
                    ? oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+newOrder.PhaseStory__c
                    : oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||';
                    /* Contracted */
                    /* if ('Completata'.equalsIgnoreCase(newOrder.Phase__c)&& newOrder.Status.equalsIgnoreCase('Activated') && !newOrder.SBQQ__Contracted__c && !oldOrder.SBQQ__Contracted__c && newOrder.recordTypeId!=bonusScontiRtId ) 
                    { 
                        newOrder.SBQQ__Contracted__c=true; 
                    } */      
                    if(!orderIds.contains(newOrder.Id))
                    {
                        orderIds.add(newOrder.Id);
                        //fix 915259C
                        //parentOrderIds.add(newOrder.ParentOrder__c);
                    }
                    if (newOrder.RecordTypeId != bonusScontiRtId && newOrder.RecordTypeId != vasRtId){
                        quoteOrderIds.add(newOrder.SBQQ__Quote__c);
                        orderReferenceIds.add(newOrder.Id);
                    }
                }
            }
        }
        if(!orderIds.isEmpty())
        {

            if(!mapVasPhase.isEmpty())
            {
                List<ServiceRequest__c> serviceRequests = HDT_QR_ServiceRequest.getTransitoryServiceRequest(orderIds,orderReferenceIds,quoteOrderIds);
                List<Order> vasScontiOrders = new List<Order>();
                for(ServiceRequest__c sr : serviceRequests)
                {
                    /* Check if the sr.Order__c is contained in "Pratica Gestita"/"Annullato" Order */
                    if(orderIds.contains(sr.Order__c))
                    {
                        serviceRequestToDelete.add(sr);
                        continue;
                    }
                    /* If sr.NextPhase__c == null and sr.Order__c is not contained in orderIds
                    * No action needed
                    */
                    if(sr.NextPhase__c == null)
                    {
                        continue;
                    }
                    //fix 915259C
                    if ((sr.Order__r.RecordTypeId != vasRtId && sr.Order__r.RecordTypeId != bonusScontiRtId && (sr.Order__r.RecordTypeId != defaultRtId || !sr.Order__r.isBillableVas__c))
                        ||(sr.Order__r.OrderReference__c != null && !orderQuoteMap.containsKey(sr.Order__r.OrderReference__c))){
                        continue;
                    }
                    Id keyId = sr.Order__r.OrderReference__c != null ? orderQuoteMap.get(sr.Order__r.OrderReference__c) : sr.Order__r.SBQQ__Quote__c;
                    Order orderVas = new Order();
                    orderVas.Id = sr.Order__c;
                    if(mapVasPhase.get(keyId).equalsIgnoreCase('Annullato'))
                    {
                        orderVas.Phase__c = mapVasPhase.get(keyId);
                        orderVas.Status = mapVasStatus.get(keyId);
                        vasScontiOrders.add(orderVas);
                        serviceRequestToDelete.add(sr);
                    }
                    else if(sr.NextPhase__c.equalsIgnoreCase('Completata'))
                    {
                        orderVas.Phase__c = sr.NextPhase__c;
                        orderVas.Status = 'Activated';
                        vasScontiOrders.add(orderVas);
                        serviceRequestToDelete.add(sr);
                    }
                    else
                    {
                        orderVas.Phase__c = sr.NextPhase__c;
                        orderVas.Status = mapVasStatus.get(keyId);
                        vasScontiOrders.add(orderVas);
                    }
                }
                /* Delete Service Request */
                if(!serviceRequestToDelete.isEmpty())
                {
                    HDT_SRV_ServiceRequest.deleteRecord(serviceRequestToDelete);
                }
                /* Update related ScontiBonus/VAS */
                if(!vasScontiOrders.isEmpty())
                {
                    updateFutureList(JSON.serialize(vasScontiOrders));
                }
            }
        }
    }
    @future
    private static void updateFutureList(String serializedList)
    {
        List<SObject> sobjList = (List<SObject>)JSON.deserialize(serializedList, List<SObject>.class);
        HDT_UTL_DatabaseService.updateSObject(sobjList);
    }
}