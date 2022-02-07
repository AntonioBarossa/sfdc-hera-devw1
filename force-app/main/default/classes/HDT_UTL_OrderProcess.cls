/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@protonmail.ch)
 * @date 12/03/2021
 * @description HDT_UTL_OrderProcess Class
 * @history Keltin Mesonjesi – 12/03/2021 – Created Class
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
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

        List<order> childOrder = orderQr.getChildOrdersByParentIds(orderParentList);
        for(Order child : childOrder){
            Order ord = new Order();
            ord.id = child.id;
            ord.SignedDate__c = newMap.get(child.ParentOrder__c).SignedDate__c;
            ord.MethodSignedAccepted__c = 'IVR';
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


        //19/08/2021 gabriele.rota@webresults.it - Calcolo Data Decorrenza Cambio Offerta
        HDT_QR_RecordType recordTypeQr = new HDT_QR_RecordType();
        String rtCambioOfferta = recordTypeQr.getRecordTypeIdByName('HDT_RT_CambioOfferta');

        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();

        Map<String,Order> mapParentOrder = new Map<String,Order>();
        List<String> ordParentsIds = new List<String>();
        for (Order ord : newOrderList) {
            ordParentsIds.add(ord.ParentOrder__c);
        }
        List<Order> orderPadreDocs = orderQr.getParentOrderDocs(ordParentsIds);
        for (Order ordPadre : orderPadreDocs) {
            mapParentOrder.put(ordPadre.Id, ordPadre);
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
            )
            &&order.isTransition__c==true){
                order.Phase__c='Esportazione VS Siebel';
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
                && order.Phase__c == 'Comunicazione Verso Heroku'
                && order.QualityCall__c
                && isMonitoringList.contains(order.AgencyCode__c)
                && !phaseStory.contains('Quality Call OK')){
                String newPhase = 'In attesa di quality call';
                order.Phase__c = newPhase;
                DateTime nowDateTime = DateTime.now();
                order.PhaseStory__c = oldOrder.Phase__c+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder.PhaseStory__c;
            }
            /**@frpanico 04/02/2022
             * Aggiunta gestione per
             * Comfort Call
             */
            if(order.Phase__c != oldOrder.Phase__c
            && oldOrder.Phase__c == 'Documentazione validata' 
            && order.Phase__c == 'Comunicazione Verso Heroku'
            && order.ComfortCallDaysDue__c != null
            )
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
                String newPhase = 'Comunicazione Verso Heroku';
                order.Phase__c = newPhase;
                DateTime nowDateTime = DateTime.now();
                order.PhaseStory__c = oldOrder.Phase__c+'@@'+'Quality Call OK'+'@@'+nowDateTime.getTime()+'@@A||'+ 'Quality Call OK'+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||' +oldOrder.PhaseStory__c;
            }

            if (order.Phase__c!=oldOrder.Phase__c 
                && oldOrder.Phase__c != 'In attesa di quality call'
                && order.Phase__c == 'Quality Call OK'
                && isMonitoringList.contains(order.AgencyCode__c)) {

                    String newPhase = (HDT_LC_OrderDossierWizardActions.checkRequiredDocs(order) && HDT_LC_OrderDossierWizardActions.checkRequiredDocs(mapParentOrder.get(order.ParentOrder__c))) ? 'Comunicazione verso Heroku' : 'In attesa validazione';
                    order.Phase__c = newPhase;
                    DateTime nowDateTime = DateTime.now();
                    order.PhaseStory__c = oldOrder.Phase__c+'@@'+'Quality Call OK'+'@@'+nowDateTime.getTime()+'@@A||'+ 'Quality Call OK'+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||' +oldOrder.PhaseStory__c;
            }

        }
        
    }   
     
    // public static void salesProcessManagementAfter(list<Order> newOrderList,List<Order> oldOrderList){
        
    // }
    
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
   /*     for (Order newOrder : newOrdersList) {
            for (Order oldOrder : oldOrdersList) {
                if (newOrder.Id == oldOrder.Id) {
                    orderMapNewToOld.put(newOrder.Id, oldOrder);
                }
            }
        }*/
        
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
        //List<String> orderList = getParentOrders(newOrdersList, oldOrdersList, orderMapNewToOld);
        List<String> ordersParent = new List<String>();//getParentOrders2(newOrdersList, oldOrdersList, orderMapNewToOld);
        List<Order> ordersFullList2 = orderQr.getRecordsByIds(olistd);
        // List<String> onlyString = new List<String>();
        // List<Order> ordersQualityOkUpdate = new List<Order>();

//**** AGGIUNTA Validazione Documentale LG 2009 FF */
        List<Order> ordersFullList = HDT_UTL_Sales.validationActivityPhaseTransition(ordersFullList2);
        for(Order o : ordersFullList2){
            if (o.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && (o.Phase__c == 'Documentazione Gestita' || o.DocumentPackage__c == 'Validato')) {
                ordersParent.add(o.id);
            }
            if(o.phase__c == 'Documentazione Validata'){
                filtered.add(o);
            }
            // if (o.Phase__c == 'Quality Call OK') {
            //     ordersQualityOkUpdate.add(new Order(
            //         Id = o.Id,
            //         Phase__c = HDT_LC_OrderDossierWizardActions.checkRequiredDocs(o) ? 'Comunicazione verso Heroku' : 'In attesa validazione'
            //     ));
            // }
            //onlyString.add(o.id);
        }
        List<Order> childOrders = orderQr.getChildOrdersByParentIds(ordersParent);
        //set<Order> filtered = new set<Order>();
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
            if (myOrder.Phase__c == 'Da Inviare' && myOrder.ParentOrder__r.Phase__c.equalsIgnoreCase('Registrazione  da validare')) {
                childOrdersDocValid.add(new Order(
                    Id = myOrder.Id,
                   // phase__c = 'In attesa validazione'
                    phase__c = HDT_LC_OrderDossierWizardActions.checkRequiredDocs(myOrder) ? 'Documentazione Validata': 'In attesa validazione'
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
        
        // if (!ordersQualityOkUpdate.isEmpty()) {
        //     orderSrv.updateRecords(ordersQualityOkUpdate);
        // }
        
        List<Order> ordersHeroku = new List<Order>();
        List<Order> ordersSiebel = new List<Order>();

       // List<Order> childOrders = orderQr.getChildOrdersByParentIds(parentOrderIds);


        for(Order o:filtered){
            if(o.sale__r.isTransition__c==true){
                ordersSiebel.add(o);
            }else{
                ordersHeroku.add(o);
            }
        }
        //List<id> docVali = filterByRecordTypeAndPhase(orderList,)
        Map<Id, String> vasOrdersToUpdate = 
            updateChildOrdersPhase(ordersSiebel,'Documentazione Validata', 'Esportazione VS Siebel ','Documentazione Validata','Esportazione VS Siebel ');
        vasOrdersToUpdate.putAll(
            updateChildOrdersPhase(ordersHeroku, 'Documentazione Validata', 'Comunicazione verso Heroku','Documentazione Validata','Comunicazione Motore VAS')
        );
        /*if(ordersFullList != null && !ordersFullList.isEmpty()){
          
        }*/
        if(!vasOrdersToUpdate.isEmpty()){
            system.enqueueJob(new HDT_UTL_PrClickDoubleTransaction.HDT_QBL_BulkUpdate(vasOrdersToUpdate));
        }
        insertLogForOrderChangedPhase(orderMapOld,orderMapNew);
    }
	
    private static void insertLogForOrderChangedPhase(Map<String,Order> orderMapOld, Map<String,Order> orderMapNew){
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Map<String,String> mapOrdToContact = new map<String,String>();
        HDT_QR_RecordType myRecordTypeQr = new HDT_QR_RecordType();
        String recordtypeParentId = myRecordTypeQr.getRecordTypeIdByName('HDT_RT_OrderDossier');
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
                    && (newOrder.ProcessType__c.contains('Switch in') || newOrder.ProcessType__c == 'Cambio Offerta')
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
                        //orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(newOrder);            
                        //orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(newOrder);            
                    }
                    if(newOrder.ProcessType__c != 'Cambio Offerta'){ // Solo per Cambio Offerta
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

            // if (order.RecordType.DeveloperName != 'HDT_RT_OrderDossier' && order.Status == 'Chiuso' && orderMapNewToOld.get(order.Id) != null && orderMapNewToOld.get(order.Id).Status != 'Chiuso') {
            //     ordersToUpdateContract.add(new Order(
            //         Id = order.Id,
            //         SBQQ__Contracted__c = true
            //     ));
            // }
        }
        // system.debug('****ordersToUpdateContract: ' + ordersToUpdateContract);
        // orderSrv.updateRecords(ordersToUpdateContract);

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

            // if (order.RecordType.DeveloperName != 'HDT_RT_OrderDossier' && order.Status == 'Chiuso' && orderMapNewToOld.get(order.Id) != null && orderMapNewToOld.get(order.Id).Status != 'Chiuso') {
            //     ordersToUpdateContract.add(new Order(
            //         Id = order.Id,
            //         SBQQ__Contracted__c = true
            //     ));
            // }
        }
        // system.debug('****ordersToUpdateContract: ' + ordersToUpdateContract);
        // orderSrv.updateRecords(ordersToUpdateContract);

        return orderIdsToReturn;
    }

    // @Future
    // public static void updateContractedTrue(){

    // }
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
        //List<Order> childOrders = orderQr.getChildOrdersByParentIds(parentOrderIds);
        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
        for (Order childOrder : parentOrderIds) {
            if(childOrder.recordType.Developername == 'HDT_RT_VAS'){
                //for vas i need a bulk update on a queueable
                if (childOrder.Phase__c == currentVasPhase) {
                    String phaseVas = childOrder.VASType__c?.equals('VAS Servizio')? 'Sequenzializzato' : newVasPhase;
                    /*Order orderToUpdate = new Order(
                        Id = childOrder.Id,
                        Phase__c = newVasPhase
                    );
                    childOrdersToUpdate.add(orderToUpdate);*/
                    vasOrdersToUpdate.put(childOrder.Id, phaseVas);
                }
            } else if (childOrder.recordType.Developername == 'HDT_RT_TemporaneaNuovaAtt' && childOrder.DistributorFormula__c == 'AMGA UDINE-10R0000032') {
                //MODIFICARE IN ATTESA DI SVILUPPO MATRICE, TEMPORANEA ATTIVAZIONE FABIANA BUG 18/09/21
                //Valore distributore STABBATO  
                if (childOrder.Phase__c == currentPhase
                        && !childOrder.QualityCall__c
                        && !isMonitoringList.contains(childOrder.AgencyCode__c)
                        && childOrder.ProcessType__c != 'Voltura' ) {
                            Order orderToUpdate = new Order(
                                Id = childOrder.Id,
                                    Phase__c = 'Pratica non gestita per il DL'
                            );
                            childOrdersToUpdate.add(orderToUpdate);
                        }
            }
            else{
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
                        // && !childOrder.QualityCall__c
                        // && !isMonitoringList.contains(childOrder.AgencyCode__c)
                        //@frpanico 06/09/2021 added voltura condition
                        && childOrder.ProcessType__c != 'Voltura' ) {
                        Order orderToUpdate = new Order(
                            Id = childOrder.Id,
                                Phase__c = newPhase
                               // isTransition__c = childOrder.isTransition__c
                        );
                        childOrdersToUpdate.add(orderToUpdate);
                    }
                }
            }
        }
        orderSrv.updateRecords(childOrdersToUpdate);
        return vasOrdersToUpdate;
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
        // List<Order> ordersToUpdate = new List<Order>();        
        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
            if(orderMapOld.get(newOrder.id)!= null){
                Order old= orderMapOld.get(newOrder.id);
                if(newOrder.TecnicalPhase__c != null && newOrder.TecnicalPhase__c == old.TecnicalPhase__c && 
                    (/*Eversi aggiunta fase*/newOrder.Phase__c == 'Voltura Rifiutata' 
                    || newOrder.Phase__c == 'Documentazione Validata'/*Eversi aggiunta fase*/ 
                    || newOrder.Phase__c=='Comunicazione verso Heroku' 
                    || newOrder.Phase__c=='Ripensamento - Da inviare' 
                    || newOrder.Phase__c=='Annullamento - Da inviare' 
                    || newOrder.Phase__c=='Preventivo Accettato' 
                    || newOrder.Phase__c=='Comunicazione Motore VAS' 
                    || newOrder.Phase__c=='Documentazione da firmare'
                    || newOrder.Phase__c=='Ammissibilità OK')){
                    newOrder.Phase__c = newOrder.TecnicalPhase__c;
                    newOrder.TecnicalPhase__c = null;
                }
                if ('Completata'.equalsIgnoreCase(newOrder.Phase__c)&& !newOrder.SBQQ__Contracted__c && !old.SBQQ__Contracted__c && newOrder.recordTypeId!=bonusScontiRtId ) { //Fabiana 15/09/2021 //Sandy 05/10 Flusso Bonus e Sconti richiede chiusura e contracted in due transazioni distinte
                    newOrder.SBQQ__Contracted__c=true; 
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
            if(mapOld.get(temp.id).phase__c != 'Completata' && temp.Phase__c == 'Completata'){
                if ( String.isNotBlank(String.valueOf(temp.ServicePoint__c))) {
                    ServicePoint__c sp=new ServicePoint__c(id=temp.ServicePoint__c);
                    sp.supplytype__c = temp.ServicePoint__r.supplytypeTemp__c;
                    sp.implantType__c = temp.ServicePoint__r.implantTypeTemp__c;    
                    // sp.Account__c=temp.AccountId;
                    sp.SAPImplantCode__c=temp.SapImplantCode__c; 
                    sp.account__c = temp.AccountId;
                        //listObjToUpdate.add(sp);
                    mapObjToUpdate.put(sp.Id, sp);
                }
                /**@frpanico 01/02/2022
                 * Commentata errata operativita'
                 * Sovrascrive il codice CA con il codice contratto
                 */
                /*
                if (String.isNotBlank( String.valueOf( temp.BillingProfile__c))) {
                    if (String.isNotBlank((temp.SapContractCode__c) )) {    
                        BillingProfile__c bill=new BillingProfile__c(id=temp.BillingProfile__c ,ContractAccountCode__c=temp.SapContractCode__c);
                        //listObjToUpdate.add(bill);
                        mapObjToUpdate.put(bill.id, bill);
                    }
                }
                */
            }
        }
        if(!mapObjToUpdate.values().isEmpty()){
            update  mapObjToUpdate.values();
        }

    }
    // START @Picchiri Credit check Date 04.06.21
    // Viene invocata da una modifica lato ordine
    // In questo metodo viene invocata la classe per la creazione della Activiti del Credit Check Entanti (Nuovo cliente) e Uscenti (Vecchio cliente)
    /*public static void creditCheckManager(List<Order> newOrdersList, List<Order> oldOrdersList) {
        system.debug('start creditCheckManager');
        Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();
        Map<String,List<Order>> orderMapNew = new Map<String,List<Order>>();
        List<Order> orderListOldCustomer = new List<Order>();                        
        List<Order> orderListNewCustomer = new List<Order>();   
        List<Order> orderListcreditCheckPhaseManager = new List<Order>();                        
        List<Order> orderList = new List<Order>();                                

        for (Integer i = 0; i<newOrdersList.size(); i++) {
            Order newOrder = newOrdersList[i];
            Order oldOrder = oldOrdersList[i]; 
            String recordTypeName = rtMap.get(newOrder.RecordTypeId).getDeveloperName();
            system.debug('recordTypeName -->  : ' + recordTypeName);  
            if((recordTypeName == 'HDT_RT_VAS' && newOrder.OrderReferenceNumber == null && newOrder.ContractReference__c == null) || recordTypeName == 'HDT_RT_Voltura' || recordTypeName == 'HDT_RT_Subentro' || recordTypeName == 'HDT_RT_AttivazioneConModifica' || recordTypeName == 'HDT_RT_SwitchIn' || recordTypeName == 'HDT_RT_ConnessioneConAttivazione' || recordTypeName == 'HDT_RT_TemporaneaNuovaAtt'){                             
                system.debug('xxx 1 ---->');
                if (newOrder.CreditCheckDescription__c != null && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c) {    
                    system.debug('xxx 2 ---->');
                    if(newOrder.OutgoingCreditCheckResult__c == 'KO' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){                        
                        system.debug('xxx 3 ---->');
                        orderListOldCustomer.add(newOrder);
                    }
                    if(newOrder.IncomingCreditCheckResult__c == 'KO' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){                        
                        system.debug('xxx 4 ---->');
                        orderListNewCustomer.add(newOrder);
                    }                                      
                }
                if((oldOrder.IncomingCreditCheckResult__c!=null && oldOrder.IncomingCreditCheckResult__c.contains('KO')) && (newOrder.IncomingCreditCheckResult__c != null && newOrder.IncomingCreditCheckResult__c.contains('OK'))){
                    orderListcreditCheckPhaseManager.add(newOrder);
                }
            }

        }

        orderMapNew.put('oldCustomer',orderListOldCustomer);
        orderMapNew.put('newCustomer',orderListNewCustomer);   
        
        system.debug('gestioneEsitiCreditCheck trigger --> orderMapNew : ' + JSON.serializePretty(orderMapNew));
        
        if(!orderMapNew.isEmpty()){
            HDT_UTL_ActivityCustomProcess.createActivityForCreditCheck(orderMapNew);
        }
        
        if(!orderListcreditCheckPhaseManager.isEmpty()){
            system.debug('creditCheckPhaseManager ----> : ' + JSON.serializePretty(orderListcreditCheckPhaseManager));
            creditCheckPhaseManager(orderListcreditCheckPhaseManager);                     
        }        
    }*/        
    // FINE @Picchiri Credit check Date 04.06.21



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
        // List<Order> orderList = new List<Order>();                                

        for (Order newOrder : (List<Order>) newOrdersMap.values()) {
            Order oldOrder = (Order) oldOrdersMap.get(newOrder.id); 
            String recordTypeName = rtMap.get(newOrder.RecordTypeId).getDeveloperName();
            if((recordTypeName == 'HDT_RT_VAS' && newOrder.OrderReferenceNumber == null && newOrder.ContractReference__c == null) || recordTypeName == 'HDT_RT_Voltura' || recordTypeName == 'HDT_RT_Subentro' || recordTypeName == 'HDT_RT_AttivazioneConModifica' || recordTypeName == 'HDT_RT_SwitchIn' || recordTypeName == 'HDT_RT_ConnessioneConAttivazione' || recordTypeName == 'HDT_RT_TemporaneaNuovaAtt'){                             
                if (newOrder.CreditCheckDescription__c != null && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c) {    
                    if(newOrder.OutgoingCreditCheckResult__c == 'KO' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){                        
                        orderListOldCustomer.add(newOrder);
                    }
                    if(newOrder.IncomingCreditCheckResult__c == 'KO' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){                        
                        orderListNewCustomer.add(newOrder);
                    }                                      
                }
                if((oldOrder.IncomingCreditCheckResult__c!=null && oldOrder.IncomingCreditCheckResult__c.contains('KO')) && (newOrder.IncomingCreditCheckResult__c != null && newOrder.IncomingCreditCheckResult__c.contains('OK'))){
                    orderListcreditCheckPhaseManager.add(newOrder);
                }
            }

        }

        orderMapNew.put('oldCustomer',orderListOldCustomer);
        orderMapNew.put('newCustomer',orderListNewCustomer);   
        
        
        if(!orderMapNew.isEmpty()){
            HDT_UTL_ActivityCustomProcess.createActivityForCreditCheck(orderMapNew);
        }
        
        if(!orderListcreditCheckPhaseManager.isEmpty()){
            creditCheckPhaseManager(orderListcreditCheckPhaseManager);                     
        }        
    }        
    // FINE @Picchiri Credit check Date 04.06.21

    /**
     * @description  @Picchiri 16.06.21 chiamata Mulesoft // Lista di ordini per nuovo cliente dove si è ricevuto un ok dopo un ko
     * @param orderList
     **/
    public static void creditCheckPhaseManager(List<Order> orderList){ 

        Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();        
        List<Order> orderListToUpdate = new List<Order>();
        Map<Id,Order> mapIdToTotalOrder = new Map<Id,Order>();
        Map<Id,Order> mapIdToOrderUpdate = new Map<Id,Order>();
        Map<Id,Order> mapIdToOrderClean = new Map<Id,Order>();        
        Set<Id> orderSetId = new Set<Id>();
        List<wrts_prcgvr__Activity__c> actListToUpdate = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> actListToRecheck = new List<wrts_prcgvr__Activity__c>();
        Map<Id,wrts_prcgvr__Activity__c> mapIdOrderToActivity = new Map<Id,wrts_prcgvr__Activity__c>();

        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();

        for(Order orderToUpdate : orderList){
            mapIdToTotalOrder.put(orderToUpdate.id,orderToUpdate);
            String recordTypeName = rtMap.get(orderToUpdate.RecordTypeId).getDeveloperName();

            if(orderToUpdate.ParentOrder__r.Phase__c == 'Documentazione Gestita' && (orderToUpdate.Phase__c == 'Documentazione Validata' || orderToUpdate.Phase__c == 'Documentazione da inviare' )){
                if(orderToUpdate.recordType.Developername != 'HDT_RT_VAS'
                    && !orderToUpdate.QualityCall__c
                    && !isMonitoringList.contains(orderToUpdate.AgencyCode__c)){
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }else{
                    orderToUpdate.Phase__c = 'Comunicazione Motore VAS';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }
            }

            if((recordTypeName == 'HDT_RT_VAS' && orderToUpdate.OrderReferenceNumber != null && orderToUpdate.ContractReference__c != null) || recordTypeName == 'HDT_RT_Voltura' || recordTypeName == 'HDT_RT_Subentro' || recordTypeName == 'HDT_RT_AttivazioneConModifica' || recordTypeName == 'HDT_RT_SwitchIn' || recordTypeName == 'HDT_RT_ConnessioneConAttivazione' || recordTypeName == 'HDT_RT_TemporaneaNuovaAtt'){             
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

                wrts_prcgvr__Activity__c actToUpdate = mapIdOrderToActivity.get(ord.Id);
                actToUpdate.CreditCheckResolutionReason__c = ord.CreditCheckDescription__c;
                actToUpdate.CreditCheckReason__c = ord.CreditCheckDescription__c;
                actToUpdate.CreditCheckResults__c = ord.IncomingCreditCheckResult__c;
                actToUpdate.wrts_prcgvr__Status__c = 'KO Risolto';
                actListToUpdate.add(actToUpdate);
                
                if(ord.CreditCheckDescription__c.contains('Saldo debito cattivo pagatore')){
                    mapIdToOrderClean.put(ord.id,ord);                
                }
    
                if(ord.CreditCheckDescription__c.contains('Saldo debito cattivo pagatore') || ord.OutgoingCreditCheckResult__c != null){                
                    actListToRecheck.add(actToUpdate);
                }
            }
            HDT_UTL_ActivityCustomProcess.updateCreditCheckActivity(actListToUpdate);
    
        }

        // sbiancare l'esito ( IncomingCreditCheckResult__c / CreditCheckDescription__c) su order e reinviare la chiamata 
        if(!mapIdToOrderClean.isEmpty()){
            mapIdToOrderUpdate = cleanCreditCheckOnOrder(mapIdToOrderClean,mapIdToTotalOrder);             
        }
        
        
        if(!mapIdToOrderUpdate.isEmpty()){
            update  mapIdToOrderUpdate.values();                    
        }             

        // reinviare la chiamata        
        if(!actListToRecheck.isEmpty()){
            HDT_UTL_ActivityCustomProcess.recheckCreditCheck(actListToRecheck);
        }
        
        
    }

    /**
     * @description  @Picchiri sbiancamento esito e causale credit check all'interno dell'ordine. Per risottomissione credit check
     * @param mapIdToOrderClean
     * @param mapIdToOrderUpdate
     * @return Map<Id,Order>
     **/
    public static Map<Id,Order> cleanCreditCheckOnOrder(Map<Id,Order> mapIdToOrderClean,Map<Id,Order> mapIdToOrderUpdate) {
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
    }
    // FINE @Picchiri Credit check Date 15.06.21

    public static void updatePhaseForFirm(List<Order> newListOrder)
    {
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
                if(order.DocumentalPhase__c != null && order.DocumentalPhase__c.equalsIgnoreCase('Plico firmato') 
                    && order.Phase__c != null && order.Phase__c.equalsIgnoreCase('In Attesa Legge 80')
                    && order.TecnicalPhase__c == null)
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
                    for(wrts_prcgvr__Activity__c activity : activities)
                    {
                        activity.wrts_prcgvr__Status__c = 'Chiusa';
                    }
                    HDT_UTL_DatabaseService.updateSObject(activities);
                }
                catch(Exception e)
                {
                    System.debug(Logginglevel.Debug, 'Exception: ' + e.getMessage() + '. At Line: ' + e.getLineNumber());
                }
                if(orderNew.ProcessType__c != null && 
                    (orderNew.ProcessType__c.containsIgnoreCase('Volutra') ||  orderNew.ProcessType__c.containsIgnoreCase('Cambio Offerta'))
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
                }
            }
            if(newPhase.containsIgnoreCase('Annullato') || newPhase.equalsIgnoreCase('Ripensato') || newPhase.equalsIgnoreCase('Annullamento per Switch-out'))
            {
                orderNew.Status = 'Annullato';
            }
            /**@frpanico 22/10/2021
             * Si entra nello skip soltanto se la fase di partenza non e' di annullamento
             * Dunque non sono previste activity
             */
			if(newPhase.indexOf('Annullamento') > -1 || newPhase.containsIgnoreCase('Annullato') || newPhase.indexOf('Ripensamento') > -1 || newPhase.equalsIgnoreCase('Ripensato')){
                if((oldPhase.indexOf('Annullamento - ') == -1 && oldPhase.indexOf('Ripensamento - ') == -1)
                    || newPhase.containsIgnoreCase('Annullato') || newPhase.equalsIgnoreCase('Ripensato'))
                {
				    orderNew.PhaseStory__c = !String.isBlank(orderNew.PhaseStory__c) 
                        ? oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c
                        : oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||';
                    return true;
                }
                return false;
            /**@frpanico 22/10/2021
             * Si entra nello skip soltanto se la fase di arrivo non e' di annullamento
             * Dunque non sono previste activity
             */
			}else if(oldPhase.indexOf('Annullamento - ') > -1 || oldPhase.indexOf('Ripensamento - ') > -1){
                orderNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c;
				return true;
			}

		}
		return false;
	}

    // // @Picchiri sbiancamento esito e causale credit check all'interno dell'ordine. 
    // // Per risottomissione credit check
    // public static void cleanCreditCheckOnOrder(List<Id> listOrderId) {
    //     List<Order> listOrderToUpdate = orderQr.getRecordsByIds(listOrderId);
    //     for (Order order : listOrderToUpdate) {
    //         order.IncomingCreditCheckResult__c = '';
    //         order.OutgoingCreditCheckResult__c = '';	
    //         order.CreditCheckDescription__c	 = '';
    //     }
    //     if(!listOrderToUpdate.isEmpty()){
    //         update listOrderToUpdate;
    //     }
    
    // }
    // // FINE @Picchiri Credit check Date 15.06.21
        
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
            List<ServiceRequest__c> srvRequests = HDT_QR_ServiceRequest.getServiceRequestByOrderCaseIds(orderIds, 'Order__c');
            List<ServiceRequest__c> srvRequestsToDelete = new List<ServiceRequest__c>();
            for(ServiceRequest__c s: srvRequests){
                // ServiceRequest__c sReq = new ServiceRequest__c(Id= s.Id);
                s.Status__c= HDT_UTL_MatrixCompatibility.getStatus(orderStatuses.get(s.Order__c), 'Order');
                if( s.Status__c == 'Activated' || s.Status__c == 'Annullato' ){
                    srvRequestsToDelete.add(s);
                } else {
                    sReqToUpdate.add(s);
                }
            }
            if (!srvRequestsToDelete.isEmpty()){
                HDT_SRV_ServiceRequest.deleteRecord(srvRequestsToDelete);
            }
            HDT_SRV_ServiceRequest.updateRecord(sReqToUpdate);
        }

}