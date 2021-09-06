public inherited sharing  class HDT_UTL_OrderProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_UTL_CommunicationLog commUtl = new HDT_UTL_CommunicationLog();
    private static HDT_SRV_CommunicationLog commSrv = new HDT_SRV_CommunicationLog();

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
        update accountsToUpdate;
    }

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


        for (Order order : newOrderList) {
            Order oldOrder= mapOrder.get(order.Id);
            if(order.Phase__c!=oldOrder.Phase__c&&order.Phase__c=='Comunicazione Verso Heroku'&&order.isTransition__c==true){
                order.Phase__c='Esportazione VS Siebel';
            }


            //19/08/2021 gabriele.rota@webresults.it - Calcolo Data Decorrenza Cambio Offerta
            if (order.RecordTypeId==rtCambioOfferta && order.EffectiveDate__c==null) {
                Date refDate = (order.ContractSigned__c)?order.WizardCompletedDate__c:order.SignedDate__c;
                if (refDate!=null) {
                    order.EffectiveDate__c = refDate.toStartOfMonth().addMonths(1);
                }
            }

            if(order.Phase__c!=oldOrder.Phase__c 
                && oldOrder.Phase__c == 'Documentazione validata' 
                && order.Phase__c == 'Comunicazione Verso Heroku'
                && order.QualityCall__c
                && isMonitoringList.contains(order.AgencyCode__c)){
                String newPhase = 'In attesa di quality call';
                order.Phase__c = newPhase;
                DateTime nowDateTime = DateTime.now();
                order.PhaseStory__c = oldOrder.Phase__c+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder.PhaseStory__c;
            }


        }
        
    }   
     
    public static void salesProcessManagementAfter(list<Order> newOrderList,List<Order> oldOrderList){
        
    }

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
        List<Order> ordersFullList = orderQr.getRecordsByIds(olistd);
        List<String> onlyString = new List<String>();
        List<Order> ordersQualityOkUpdate = new List<Order>();
        for(Order o : ordersFullList){
            if (o.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && o.Phase__c == 'Documentazione Gestita') {
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
        for(Order o1 : childOrders){
            if(o1.phase__c == 'Documentazione Validata'){
                filtered.add(o1);
            }

            if (o1.Phase__c == 'In attesa validazione') {
                childOrdersDocValid.add(new Order(
                    Id = o1.Id,
                    phase__c = HDT_LC_OrderDossierWizardActions.checkRequiredDocs(o1) ? 'Documentazione Validata': 'In attesa validazione'
                ));
            }

            if (o1.Phase__c == 'Da Inviare') {
                childOrdersDocValid.add(new Order(
                    Id = o1.Id,
                    phase__c = 'In attesa validazione'
                ));
            }
        }

        if (!childOrdersDocValid.isEmpty()) {
            orderSrv.updateRecords(childOrdersDocValid);
        }
        
        if (!ordersQualityOkUpdate.isEmpty()) {
            orderSrv.updateRecords(ordersQualityOkUpdate);
        }
        
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
        updateChildOrdersPhase(ordersSiebel,'Documentazione Validata', 'Esportazione VS Siebel ','Documentazione Validata','Comunicazione Motore VAS');

        updateChildOrdersPhase(ordersHeroku, 'Documentazione Validata', 'Comunicazione verso Heroku','Documentazione Validata','Comunicazione Motore VAS');
		insertLogForOrderChangedPhase(orderMapOld,orderMapNew);
    }
	
    private static void insertLogForOrderChangedPhase(Map<String,Order> orderMapOld, Map<String,Order> orderMapNew){
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Map<String,String> mapOrdToContact = new map<String,String>();
        HDT_QR_RecordType recordtypeQR = new HDT_QR_RecordType();
        String recordtypeParentId = recordtypeQR.getRecordTypeIdByName('HDT_RT_OrderDossier');
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
                   System.debug('**************Eccolo:' + c);
                   commList.add(commUTL.instanceCommunicationLog('Attivazioni',newOrd.ProcessType__c,newOrd.Phase__c,st,newOrd.CancellationReason__c,newOrd.Id,'',newOrd.Contact__c,newOrd.AccountId,c != null ? c.company__c : 'ND',newOrd.CompanyOwner__c));
               }
           }
        }
        if(commList != null && !commList.isEmpty()){
            commSRV.createRecords(commList);
        }
    }

    // START @Picchiri HRADTR-77 Calcolo Date 01.06.21
    // Ricalcolo delle date
    public static void orderCalulateDateUpdate(List<Order> newOrdersList, List<Order> oldOrdersList) { 
        system.debug('Ricalcolo delle date da Trigger sugli ordini --> newOrdersList : ' + JSON.serializePretty(newOrdersList));
        system.debug('Ricalcolo delle date da Trigger sugli ordini --> oldOrdersList : ' + JSON.serializePretty(oldOrdersList));
        List<Order> orderList = new List<Order>();                        

        Boolean ricalculateDate = false;
        //IsSequanzialized__c
        for (Order newOrder : newOrdersList) {
            for (Order oldOrder : oldOrdersList) {

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
                    system.debug('Esecuzione ricalcolo delle date');
                    Order orderToUpdate = new Order();
                    orderToUpdate.id = newOrder.Id;                                        
                    orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(newOrder);            
                    
                    if(newOrder.ProcessType__c != 'Cambio Offerta'){ // Solo per Cambio Offerta
                        orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(newOrder);
                    }                             
                    orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(newOrder); // Data di decorrenza
                    orderList.add(orderToUpdate);                    
                }                                   
            }
        }
        
        if(!orderList.isEmpty()){
            update orderList;
        }        

    }
    // END @Picchiri HRADTR-77 Calcolo Date 01.06.21
    
    private static List<String> getParentOrders(List<Order> newOrdersList, List<Order> oldOrdersList, Map<String,Order> orderMapNewToOld){
        List<String> orderIds = new List<String>();
        for (Order newOrder : newOrdersList) {
            orderIds.add(newOrder.Id);
        }

        List<String> orderIdsToReturn = new List<String>();

        orderSrv.checkReadAccess('RecordType.DeveloperName, Phase__c');
        List<Order> ordersFullList = orderQr.getRecordsByIds(orderIds);

        List<Order> ordersToUpdateContract = new List<Order>();

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

    private static List<Order> getParentOrders2(List<Order> newOrdersList, List<Order> oldOrdersList, Map<String,Order> orderMapNewToOld){
        List<String> orderIds = new List<String>();
        for (Order newOrder : newOrdersList) {
            orderIds.add(newOrder.Id);
        }

        List<Order> orderIdsToReturn = new List<Order>();

        orderSrv.checkReadAccess('RecordType.DeveloperName, Phase__c');
        List<Order> ordersFullList = orderQr.getRecordsByIds(orderIds);

        List<Order> ordersToUpdateContract = new List<Order>();

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
    private static void updateChildOrdersPhase(List<Order> parentOrderIds, String currentPhase, String newPhase,String currentVasPhase,String newVasPhase) {
        
        List<Order> childOrdersToUpdate = new List<Order>();
        
        orderSrv.checkReadAccess('Phase__c');
        //List<Order> childOrders = orderQr.getChildOrdersByParentIds(parentOrderIds);
        System.debug('***********1');
        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
        for (Order childOrder : parentOrderIds) {
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
                if('Esportazione VS Siebel ' == newPhase){
                    System.debug('***********2');
                    if (childOrder.Phase__c == currentPhase) {
                        System.debug('***********3');
                        Order orderToUpdate = new Order(
                            Id = childOrder.Id,
                                Phase__c = newPhase,
                                isTransition__c = childOrder.isTransition__c
                        );
                        childOrdersToUpdate.add(orderToUpdate);
                    }
                }
                else{
                    System.debug('***********4');
                    if (childOrder.Phase__c == currentPhase
                        && !childOrder.QualityCall__c
                        && !isMonitoringList.contains(childOrder.AgencyCode__c)
                        //@frpanico 06/09/2021 added voltura condition
                        && childOrder.ProcessType__c != 'Voltura' ) {
                        System.debug('***********5');
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
    }
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
    public static List<Order> updatePhase(List<Order> newOrdersList, List<Order> oldOrdersList) {
        Map<String,Order> orderMapOld = new Map<String,Order>();
        List<Order> ordersToUpdate = new List<Order>();        
        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
            if(orderMapOld.get(newOrder.id)!= null){
                Order old= orderMapOld.get(newOrder.id);
                if(newOrder.TecnicalPhase__c != null && newOrder.TecnicalPhase__c == old.TecnicalPhase__c && 
                    (/*Eversi aggiunta fase*/newOrder.Phase__c == 'Voltura Rifiutata' || newOrder.Phase__c == 'Documentazione Validata'/*Eversi aggiunta fase*/ || newOrder.Phase__c=='Comunicazione verso Heroku' || newOrder.Phase__c=='Ripensamento - Da inviare' || newOrder.Phase__c=='Annullamento - Da inviare' || newOrder.Phase__c=='Preventivo Accettato')){
                    newOrder.Phase__c = newOrder.TecnicalPhase__c;
                    newOrder.TecnicalPhase__c = null;
                }
            }
            if ('Completata'.equalsIgnoreCase(newOrder.Phase__c)&& !newOrder.SBQQ__Contracted__c) {
                newOrder.SBQQ__Contracted__c=true; 
            }
        }
        return newOrdersList;
    }
   
    // START @Picchiri Credit check Date 04.06.21
    // Viene invocata da una modifica lato ordine
    // In questo metodo viene invocata la classe per la creazione della Activiti del Credit Check Entanti (Nuovo cliente) e Uscenti (Vecchio cliente)
    public static void creditCheckManager(List<Order> newOrdersList, List<Order> oldOrdersList) {
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
    }        
    // FINE @Picchiri Credit check Date 04.06.21

    // @Picchiri 16.06.21 chiamata Mulesoft // Lista di ordini per nuovo cliente dove si è ricevuto un ok dopo un ko
    public static void creditCheckPhaseManager(List<Order> orderList){ 

        Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();        
        system.debug('Start creditCheckPhaseManager');
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
                system.debug('YYY 1 --->');
                if(orderToUpdate.recordType.Developername != 'HDT_RT_VAS'
                    && !orderToUpdate.QualityCall__c
                    && !isMonitoringList.contains(orderToUpdate.AgencyCode__c)){
                    system.debug('YYY 2 --->');
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }else{
                    system.debug('YYY 3 --->');
                    orderToUpdate.Phase__c = 'Comunicazione Motore VAS';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }
            }

            if((recordTypeName == 'HDT_RT_VAS' && orderToUpdate.OrderReferenceNumber != null && orderToUpdate.ContractReference__c != null) || recordTypeName == 'HDT_RT_Voltura' || recordTypeName == 'HDT_RT_Subentro' || recordTypeName == 'HDT_RT_AttivazioneConModifica' || recordTypeName == 'HDT_RT_SwitchIn' || recordTypeName == 'HDT_RT_ConnessioneConAttivazione' || recordTypeName == 'HDT_RT_TemporaneaNuovaAtt'){             
                system.debug('YYY 4 --->');
                if((orderToUpdate.IncomingCreditCheckResult__c != null && orderToUpdate.IncomingCreditCheckResult__c == 'OK') || (orderToUpdate.OutgoingCreditCheckResult__c != null && orderToUpdate.OutgoingCreditCheckResult__c == 'OK')){
                    system.debug('YYY 5 --->');
                    orderSetId.add(orderToUpdate.id);
                }                
            }
        }   

        // recuperare l'activity per questi ordini
        // Le activity sull'ordine potrebbero essere più di una. Bisogna prendere quella con record type "credit check ko" e Status__c "creata" e CreditCheckReason__c contiene  "Cattivo pagatore"
        if(!orderSetId.isEmpty()){
            system.debug('YYY 6 --->');
            List<wrts_prcgvr__Activity__c> actList = HDT_QR_ActivityCustom.getActivityListCrediCheck(orderSetId);
            for(wrts_prcgvr__Activity__c act : actList){
                mapIdOrderToActivity.put(act.Order__c,act);
            }

            for(Order ord : orderList){
            
                wrts_prcgvr__Activity__c actToUpdate = mapIdOrderToActivity.get(ord.Id);
                actToUpdate.CreditCheckResolutionReason__c = ord.CreditCheckDescription__c;
                actToUpdate.CreditCheckReason__c = ord.CreditCheckDescription__c;
                actToUpdate.CreditCheckResults__c = ord.IncomingCreditCheckResult__c;
                actToUpdate.Status__c = 'KO Risolto';
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
            system.debug('YYY 7 --->');
            mapIdToOrderUpdate = cleanCreditCheckOnOrder(mapIdToOrderClean,mapIdToTotalOrder);             
        }
        
        
        if(!mapIdToOrderUpdate.isEmpty()){
            system.debug('YYY 8 --->');
            update  mapIdToOrderUpdate.values();                    
        }             

        // reinviare la chiamata        
        if(!actListToRecheck.isEmpty()){
            system.debug('YYY 9 --->' + JSON.serializePretty(actListToRecheck));
            HDT_UTL_ActivityCustomProcess.recheckCreditCheck(actListToRecheck);
        }
        
        
    }

    // @Picchiri sbiancamento esito e causale credit check all'interno dell'ordine. 
    // Per risottomissione credit check
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

    public static Boolean manageCancellationProcess(List<Order> orderList, Map<Id,SObject> orderOldMapd){
		Order orderNew = orderList[0];
		Order orderOld = (Order) Trigger.oldMap.get(orderNew.Id);
		String newPhase = orderNew.Phase__c;
		String oldPhase = orderOld.Phase__c;
        DateTime nowDateTime = DateTime.now();
		if(String.isNotBlank(newPhase) && String.isNotBlank(oldPhase) && newPhase != oldPhase){
			if(newPhase.indexOf('Annullamento') > -1 || newPhase.equalsIgnoreCase('Annullato') || newPhase.indexOf('Ripensamento') > -1 || newPhase.equalsIgnoreCase('Ripensato')){
				orderNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c;
                return true;
			}else if(oldPhase.indexOf('Annullamento - ') > -1 || oldPhase.indexOf('Ripensamento - ') > -1){
                orderNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c;
				return true;
			}
            if(orderNew.Cluster__c.equalsIgnoreCase('Volutra')){
                Case nonReqContract = new Case();
                HDT_QR_Case caseQr = new HDT_QR_Case(); 
                nonReqContract = caseQr.getNonReqContrOrder(orderNew.Id);
                if(!(String.isBlank(nonReqContract.Id))){
                    nonReqContract.Phase__c = 'Completata';
                    HDT_UTL_DatabaseService.updateSObject(nonReqContract);
                }
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
            for(ServiceRequest__c s: srvRequests){
                ServiceRequest__c sReq = new ServiceRequest__c(Id= s.Id);
                s.Status__c= HDT_UTL_MatrixCompatibility.getStatus(orderStatuses.get(s.Order__c), 'Order');
                sReqToUpdate.add(s);
            }
            HDT_SRV_ServiceRequest.updateRecord(sReqToUpdate);
        }

}