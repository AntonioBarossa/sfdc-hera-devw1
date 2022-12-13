/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 13/07/2021
* @description HDT_UTL_Dependencies – Classe di utilità per la gestione della sequenzializzazione dei processi
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_Dependencies {
    
    public static final String STATUS_BOZZA = 'Bozza';
    public static final String STATUS_LAVORAZIONE = 'In Lavorazione';
    public static final String STATUS_SEQUENZIALIZZATO = 'Sequenzializzato';

    private static final String PHASE_SEQUENZIALIZZATO = 'Sequenzializzato';

    private static final String MATCH_BILLING = 'Billing Profile';
    private static final String MATCH_ACCOUNT = 'Account';
    private static final String MATCH_SERVICE_POINT = 'Service Point';

    public static final String TIPOLOGY_SALES = 'Order';
    public static final String TIPOLOGY_POSTSALES = 'Case';

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @description metodo per la gestione del processo di sequenzializzazione
    * @date 13/07/2021
    * @param1 List<ServiceRequest> struttura oggetti tecnici da sequenzializzare
    * @param2 Map<Id, sObject> mappa degli oggetti con i vecchi valori
    * @param3 String tipology : tipologia process Case|Order
    */
    public static void processSequentializationBefore(Map<Id,SObject> newSObjectMap,Map<Id,SObject> oldSObjectMap, String tipology){
        List<ServiceRequest__c> incomingProcesses = new List<ServiceRequest__c>();
        Map<Id,Order> orders = new Map<Id,Order>();
        Map<Id,Case> cases = new Map<Id,Case>();
        List<String> dependenciesCheckCs = new List<String>();
        for(CS_DependecyPhaseCheck__c dependecyPhaseCheck : CS_DependecyPhaseCheck__c.getAll().values()){
            dependenciesCheckCs.add(dependecyPhaseCheck.Phase__c);
        }
        if(tipology.equalsIgnoreCase(TIPOLOGY_SALES)){
            for(Order order : (List<Order>)newSObjectMap.values()){
                Order oldOrder = (Order)oldSObjectMap.get(order.ID);
                if(!oldOrder.Phase__c.equalsIgnoreCase(order.Phase__c) && dependenciesCheckCs.contains(order.Phase__c)){
                    orders.put(order.ID, order);
                }
            }
            if(orders.size()>0){
                try{
                    List<ServiceRequest__c> srs = [SELECT ID, ProcessType__c, Order__c, Order__r.isTransition__c,Order__r.VASSubtype__c, Order__r.RecordTypeId, Order__r.OrderReference__c, Order__r.ContractReference__c, Order__r.OrderReference__r.ServicePoint__r.ServicePointCode__c, Order__r.ContractReference__r.ServicePoint__r.ServicePointCode__c, Type__c, ServicePointCode__c, Account__c, BillingProfile__c
                                    FROM ServiceRequest__c 
                                    WHERE Order__r.ID IN: orders.keySet()
                                    WITH SECURITY_ENFORCED];
                    for(ServiceRequest__c sr : srs){
                        Boolean isAnaConsTransition = orders.get(sr.Order__c).VasSubtype__c != null && orders.get(sr.Order__c).VasSubtype__c == 'Analisi Consumi' && orders.get(sr.Order__c).isTransition__c ? true:false;
                        sr.NextPhase__c = orders.get(sr.Order__c).Phase__c;
                        incomingProcesses.add(sr);
                    }
                }catch(Exception ex){
                    System.debug(LoggingLevel.ERROR, ex.getMessage());
                }
            }
        }else if(tipology.equalsIgnoreCase(TIPOLOGY_POSTSALES)){
            for(Case caseProcess : (list<Case>)newSObjectMap.values()){
                Case oldCase = (Case)oldSObjectMap.get(caseProcess.ID);
                if(!String.IsEmpty(oldCase.Phase__c)){
                    if(!oldCase.Phase__c.equalsIgnoreCase(caseProcess.Phase__c) && dependenciesCheckCs.contains(caseProcess.Phase__c)){
                        cases.put(caseProcess.ID, caseProcess);
                    }
                }
            }
            if(cases.size()>0){
                try{
                    List<ServiceRequest__c> srs = [SELECT ID, ProcessType__c, Case__c, Type__c, ServicePointCode__c, Account__c, BillingProfile__c
                                    FROM ServiceRequest__c 
                                    WHERE Case__r.ID IN: cases.keySet()
                                    WITH SECURITY_ENFORCED];
                    for(ServiceRequest__c sr : srs){
                        sr.NextPhase__c = cases.get(sr.Case__c).Phase__c;
                        incomingProcesses.add(sr);
                    }
                    
                }catch(Exception ex){
                    System.debug(LoggingLevel.ERROR, ex.getMessage());
                }
            }
        }
        
        if(incomingProcesses.size()>0){
            Map<String, List<SObject>> processesToUpdate = sequentialization(incomingProcesses);
            
            if(processesToUpdate.size()>0){
                updateProcesses(processesToUpdate.get('serviceRequest'));
    
                if(tipology.equalsIgnoreCase(TIPOLOGY_SALES)){
                    for(Order order : (List<Order>)processesToUpdate.get('order')){
                        String oldPhase = ((Order)newSObjectMap.get(order.ID)).Phase__c;
                        ((Order)newSObjectMap.get(order.ID)).Status = STATUS_SEQUENZIALIZZATO;
                        ((Order)newSObjectMap.get(order.ID)).Phase__c = PHASE_SEQUENZIALIZZATO;
                        /**@frpanico 2022-03-11
                         * Aggiunta scrittura PhaseStory__c 
                         * per tracciare passaggio di fase
                         */
                        DateTime nowDateTime = DateTime.now();
                        ((Order)newSObjectMap.get(order.ID)).PhaseStory__c = !String.isBlank(((Order)newSObjectMap.get(order.ID)).PhaseStory__c)
                        ? oldPhase+'@@'+PHASE_SEQUENZIALIZZATO+'@@'+nowDateTime.getTime()+'@@A||'+((Order)newSObjectMap.get(order.ID)).PhaseStory__c
                        : oldPhase+'@@'+PHASE_SEQUENZIALIZZATO+'@@'+nowDateTime.getTime()+'@@A||';
                    }
                }else  if(tipology.equalsIgnoreCase(TIPOLOGY_POSTSALES)){
                    for(Case casePr : (List<Case>)processesToUpdate.get('case')){
                        String oldPhase = ((Case)newSObjectMap.get(casePr.ID)).Phase__c;
                        ((Case)newSObjectMap.get(casePr.ID)).Status = STATUS_SEQUENZIALIZZATO;
                        ((Case)newSObjectMap.get(casePr.ID)).Phase__c = PHASE_SEQUENZIALIZZATO;
                        /**@frpanico 2022-03-11
                         * Aggiunta scrittura PhaseStory__c 
                         * per tracciare passaggio di fase
                         */
                        DateTime nowDateTime = DateTime.now();
                        ((Case)newSObjectMap.get(casePr.ID)).PhaseStory__c = !String.isBlank(((Case)newSObjectMap.get(casePr.ID)).PhaseStory__c)
                        ? oldPhase+'@@'+PHASE_SEQUENZIALIZZATO+'@@'+nowDateTime.getTime()+'@@A||'+((Case)newSObjectMap.get(casePr.ID)).PhaseStory__c
                        : oldPhase+'@@'+PHASE_SEQUENZIALIZZATO+'@@'+nowDateTime.getTime()+'@@A||';

                    }
                }
            }
        }
    }

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @description metodo per l'individuazione dei processi da sequnzializzare
    * @date 13/07/2021
    * @param1 List<ServiceRequest> struttura oggetti tecnici da sequenzializzare
    * @return Mappa dei processi da aggiornare
    */
    public static Map<String, List<SObject>> sequentialization(List<ServiceRequest__c> incomingProcesses){

        Map<String, List<SObject>> processesToUpdate = new Map<String, List<SObject>>();

        try {

            String conditions = 'WHERE ';
            Integer index = 0;
            for(ServiceRequest__c sr : incomingProcesses){
                index++;
                conditions += '(IncomingProcessType__c = \''+String.escapeSingleQuotes(sr.ProcessType__c)+'\' AND CheckingPhase__c = \''+String.escapeSingleQuotes(sr.NextPhase__c)+'\')';
                if(index < incomingProcesses.size()){
                    conditions += ' OR ';
                }
            }

            DependenciesMatrix__c[] dependencies = Database.query('SELECT Id, IncomingProcessType__c, BlockingProcessType__c, MatchingField__c '                                           
            + 'FROM DependenciesMatrix__c '
            + conditions 
            + ' WITH SECURITY_ENFORCED');

            Map<String,List<List<String>>> dependenciesMap = new Map<String,List<List<String>>>();
            for(DependenciesMatrix__c dependency : dependencies){
                if(dependenciesMap.containsKey(dependency.IncomingProcessType__c)){
                    dependenciesMap.get(dependency.IncomingProcessType__c).add(new List<String>{dependency.BlockingProcessType__c,dependency.MatchingField__c});
                }else{
                    List<List<String>> blockingMatches = new List<List<String>>();
                    blockingMatches.add(new List<String>{dependency.BlockingProcessType__c,dependency.MatchingField__c});
                    dependenciesMap.put(dependency.IncomingProcessType__c,blockingMatches);
                }
            }
            if(dependenciesMap.size()>0){
                processesToUpdate = getProcessesToUpdate(incomingProcesses, dependenciesMap);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
        return processesToUpdate;
    }

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @description metodo per la restituzione dell'elenco dei processi da sequnzializzare
    * @date 13/07/2021
    * @param1 List<ServiceRequest> struttura oggetti tecnici da sequenzializzare
    * @param2 Map<String,List<List<String>>> mappa delle dipendence
    * @return List<List<SObject>> Struttura dati processi da aggiornare
    */
    public static Map<String, List<SObject>> getProcessesToUpdate(List<ServiceRequest__c> incomingProcesses, Map<String,List<List<String>>> dependenciesMap){
        
        Map<String, List<SObject>> results = new Map<String, List<SObject>>();

        try {
            List<ServiceRequest__c> serviceRequestsToBeSequenced = new List<ServiceRequest__c>();
            List<Order> ordersToBeUpdated = new List<Order>();
            List<Case> casesToBeUpdated = new List<Case>();

            List<ServiceRequest__c> srBlockings = null;
            List<String> matchValueServicePoints = new List<String>();
            List<String> matchValueAccounts = new List<String>();
            List<String> matchValueBillings = new List<String>();
            List<String> matches = new List<String>();

            Map<String,String> incomingServicePoint = new Map<String, String>();

            for(ServiceRequest__c sr : incomingProcesses){
                String singleIncomingServicePoint = '';
                if(dependenciesMap.containsKey(sr.ProcessType__c)){
                    for(List<String> blockingMatches : dependenciesMap.get(sr.ProcessType__c)){
                        String blockingMatch = blockingMatches.get(1);
                        if(blockingMatch.equalsIgnoreCase(MATCH_SERVICE_POINT)){
                            singleIncomingServicePoint = (String)sr.ServicePointCode__c==null?(String)sr.Order__r.OrderReference__r.ServicePoint__r.ServicePointCode__c:(String)sr.ServicePointCode__c;
                            singleIncomingServicePoint = singleIncomingServicePoint==null?(String)sr.Order__r.ContractReference__r.ServicePoint__r.ServicePointCode__c:singleIncomingServicePoint;
                            //TARI non ha codice pod
                            singleIncomingServicePoint = singleIncomingServicePoint==null?(String)sr.Order__r.ServicePoint__c:singleIncomingServicePoint;
                            incomingServicePoint.put(sr.Id, singleIncomingServicePoint);
                            matchValueServicePoints.add(incomingServicePoint.get(sr.Id));
                        }else if(blockingMatch.equalsIgnoreCase(MATCH_ACCOUNT)){
                            matchValueAccounts.add(sr.Account__c);
                        }else if(blockingMatch.equalsIgnoreCase(MATCH_BILLING)){
                            matchValueBillings.add(sr.BillingProfile__c);
                        }
                        matches.add(blockingMatches[0]);
                    }
                }
            }
           
            try{
                srBlockings = (List<ServiceRequest__c>)Database.query('SELECT ID, Case__c, Order__c, Order__r.isTransition__c, Order__r.OrderReference__r.ServicePoint__r.ServicePointCode__c, Order__r.ContractReference__r.ServicePoint__r.ServicePointCode__c, Type__c, ProcessType__c, ServicePointCode__c, BillingProfile__c, Account__c '
                + 'FROM ServiceRequest__c '
                + 'WHERE (ServicePointCode__c IN :matchValueServicePoints OR Account__c IN :matchValueAccounts OR BillingProfile__c IN :matchValueBillings) AND '
                + 'Status__c = \''+String.escapeSingleQuotes(STATUS_LAVORAZIONE)+'\' AND '
                + 'ProcessType__c IN :matches '
                + 'WITH SECURITY_ENFORCED');

                String rtVas = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
                for(ServiceRequest__c sr : incomingProcesses){
                    Boolean valueToUpdate = true;
                    Boolean servicePoint = false;
                    Boolean account = false;
                    Boolean billing = false;

                    String blockingMatch = '';
                    List<String> bmatches = new List<String>();

                    if(dependenciesMap.containsKey(sr.ProcessType__c)){
                        for(List<String> blockingMatches : dependenciesMap.get(sr.ProcessType__c)){
                            blockingMatch = blockingMatches.get(1);
                            if(blockingMatch.equalsIgnoreCase(MATCH_SERVICE_POINT)){
                                servicePoint = true;
                            }else if(blockingMatch.equalsIgnoreCase(MATCH_ACCOUNT)){
                                account = true;
                            }else if(blockingMatch.equalsIgnoreCase(MATCH_BILLING)){
                                billing = true;
                            }
                            bmatches.add(blockingMatches[0]);
                        }
                    }
                    
                    for(ServiceRequest__c srBlocking : srBlockings){
                        Boolean match = false;
                        if(bmatches.contains(srBlocking.ProcessType__c)){
                            if(servicePoint){
                                String blockingServicePoint = (String)srBlocking.ServicePointCode__c==null?(String)srBlocking.Order__r.OrderReference__r.ServicePoint__r.ServicePointCode__c:(String)srBlocking.ServicePointCode__c;
                                blockingServicePoint = blockingServicePoint==null?(String)srBlocking.Order__r.ContractReference__r.ServicePoint__r.ServicePointCode__c:blockingServicePoint;
                                
                                if(incomingServicePoint.get(sr.Id) != null && (incomingServicePoint.get(sr.Id)).equalsIgnoreCase(blockingServicePoint)){
                                    match = true;
                                }
                            }else if(account){
                                if(((String)sr.Account__c).equalsIgnoreCase((String)srBlocking.Account__c)){
                                    match = true;
                                }
                            }else if(billing){
                                if(((String)sr.BillingProfile__c).equalsIgnoreCase((String)srBlocking.BillingProfile__c)){
                                    match = true;
                                }
                            }
                        }
                        if(match && sr.Id != srBlocking.Id){
                            if(sr.Type__c.equalsIgnoreCase(TIPOLOGY_POSTSALES)){
                                Case caseToUpdate = new Case(ID=sr.Case__c);
                                caseToUpdate.Status = STATUS_SEQUENZIALIZZATO;
                                caseToUpdate.Phase__c = PHASE_SEQUENZIALIZZATO;
                                if(valueToUpdate){
                                    casesToBeUpdated.add(caseToUpdate);
                                }
                            }else if(sr.Type__c.equalsIgnoreCase(TIPOLOGY_SALES)){
                                Order orderToUpdate = new Order(ID=sr.Order__c,RecordTypeId=sr.Order__r.RecordTypeId,isTransition__c=sr.Order__r.isTransition__c,OrderReference__c=sr.Order__r.OrderReference__c,ContractReference__c=sr.Order__r.ContractReference__c,VASSubtype__c = sr.Order__r.VASSubtype__c);
                                orderToUpdate.Status = STATUS_SEQUENZIALIZZATO;
                                orderToUpdate.Phase__c = PHASE_SEQUENZIALIZZATO;
                                String orderRecordType = orderToUpdate.RecordTypeId;
                                if(orderRecordType.equalsIgnoreCase(rtVas) && (orderToUpdate.OrderReference__c == null) && (orderToUpdate.VASSubtype__c == null || (orderToUpdate.VASSubtype__c != null && !orderToUpdate.VASSubtype__c.equalsIgnoreCase('Analisi Consumi'))) /*&& orderToUpdate.ContractReference__c == null)*/ && !(orderToUpdate.isTransition__c && srBlocking.Order__r.isTransition__c)){
                                    valueToUpdate = false;
                                }
                                
                                if(valueToUpdate){
                                    ordersToBeUpdated.add(orderToUpdate);
                                }
                                Boolean isAnalisiConsumi = (String)sr.getSobject('Order__r').get('VasSubtype__c') != null && ((String)sr.getSobject('Order__r').get('VasSubtype__c')).equalsIgnoreCase('Analisi Consumi')  && (Boolean)sr.getSobject('Order__r').get('isTransition__c') == true;
                                sr.NextPhase__c = isAnalisiConsumi ? 'Completata' : sr.NextPhase__c;
                            }
                            sr.DependOn__c = srBlocking.ID;
                            sr.Status__c = STATUS_SEQUENZIALIZZATO;
                            if(valueToUpdate){
                                serviceRequestsToBeSequenced.add(sr);
                            }

                            break;
                        }
                    }
                }
            }catch(Exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            }
            
            results.put('serviceRequest',serviceRequestsToBeSequenced);
            results.put('case',casesToBeUpdated);
            results.put('order',ordersToBeUpdated);

        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }

        return results;
    }

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @description metodo per l'aggiornamento dei processi da sequnzializzare
    * @date 13/07/2021
    * @param1 List<ServiceRequest__c> serviceRequestsToBeSequenced
    * @param2 List<Order> ordersToBeUpdated
    * @param3 List<Case> casesToBeUpdated
    */
    public static void updateProcesses(List<ServiceRequest__c> serviceRequestsToBeSequenced){
        
        Savepoint sp = Database.setSavePoint();
        
        try{
            if (ServiceRequest__c.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isUpdateable()&&
                Schema.sObjectType.ServiceRequest__c.fields.DependOn__c.isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.DependOn__c.isUpdateable()){
                
                update serviceRequestsToBeSequenced;
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            Database.rollback(sp);
        }
    }
}