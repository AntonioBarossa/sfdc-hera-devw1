/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 13/07/2021
* @description HDT_UTL_Dependencies – Classe di utilità per la gestione della sequenzializzazione dei processi
*/
public inherited sharing class HDT_UTL_Dependencies {
    
    public static final String STATUS_BOZZA = 'Bozza';
    public static final String STATUS_LAVORAZIONE = 'In Lavorazione';
    public static final String STATUS_SEQUENZIALIZZATO = 'Sequenzializzato';

    private static final String PHASE_SEQUENZIALIZZATO = 'In sequenzializzazione';

    private static final String MATCH_BILLING = 'Billing Profile';
    private static final String MATCH_ACCOUNT = 'Account';
    private static final String MATCH_SERVICE_POINT = 'Service Point';

    public static final String TIPOLOGY_SALES = 'Order';
    public static final String TIPOLOGY_POSTSALES = 'Case';

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 13/07/2021
    * @param1 List<ServiceRequest> struttura oggetti tecnici da sequenzializzare
    * @param2 Map<Id, sObject> mappa degli oggetti con i vecchi valori
    * @param3 String tipology : tipologia process Case|Order
    * @return void
    */
    public static void processSequentializationBefore(Map<Id,SObject> newSObjectMap,Map<Id,SObject> oldSObjectMap, String tipology){
        List<ServiceRequest__c> incomingProcesses = new List<ServiceRequest__c>();
        List<String> dependenciesCheckCS = new List<String>();
        for(CS_DependecyPhaseCheck__c dependecyPhaseCheck : CS_DependecyPhaseCheck__c.getAll().values()){
            dependenciesCheckCS.add(dependecyPhaseCheck.Phase__c);
        }
        if(tipology.equalsIgnoreCase(TIPOLOGY_SALES)){
            System.debug('------------------------ORDER');
            for(Order order : (List<Order>)newSObjectMap.values()){
                Order oldOrder = (Order)oldSObjectMap.get(order.ID);
                if(!oldOrder.Phase__c.equalsIgnoreCase(order.Phase__c) && dependenciesCheckCS.contains(order.Phase__c)){
                    try{
                        ServiceRequest__c sr = [SELECT ID, ProcessType__c, Order__c, Type__c, ServicePointCode__c, Account__c, BillingProfile__c
                                        FROM ServiceRequest__c 
                                        WHERE Order__r.ID=: order.ID
                                        WITH SECURITY_ENFORCED LIMIT 1];
                        sr.NextPhase__c = order.Phase__c;
                        incomingProcesses.add(sr);
                        
                    }catch(Exception ex){
                        System.debug(ex.getMessage());
                    }
                }
            }
        }else if(tipology.equalsIgnoreCase(TIPOLOGY_POSTSALES)){
            System.debug('------------------------CASE');
            for(Case caseProcess : (list<Case>)newSObjectMap.values()){
                Case oldCase = (Case)oldSObjectMap.get(caseProcess.ID);
                if(!oldCase.Phase__c.equalsIgnoreCase(caseProcess.Phase__c)){//&& AGGIUNGERE CONTROLLO SE caseProcess.Phase__c IN CS
                    try{
                        ServiceRequest__c sr = [SELECT ID, ProcessType__c, Case__c, Type__c, ServicePointCode__c, Account__c, BillingProfile__c
                                        FROM ServiceRequest__c 
                                        WHERE Case__r.ID=: caseProcess.ID
                                        WITH SECURITY_ENFORCED LIMIT 1];
                        sr.NextPhase__c = caseProcess.Phase__c;
                        incomingProcesses.add(sr);
                        
                    }catch(Exception ex){
                        System.debug(ex.getMessage());
                    }
                }
            }
        }
        
        if(incomingProcesses.size()>0){
            Map<String, List<SObject>> processesToUpdate = sequentialization(incomingProcesses);
            
            if(processesToUpdate.size()>0){
                updateProcesses(processesToUpdate.get('serviceRequest'));
    
                if(tipology.equalsIgnoreCase(TIPOLOGY_SALES)){
                    for(Order order : (List<Order>)processesToUpdate.get('order')){
                        ((Order)newSObjectMap.get(order.ID)).Status = STATUS_SEQUENZIALIZZATO;
                        ((Order)newSObjectMap.get(order.ID)).Phase__c = PHASE_SEQUENZIALIZZATO;
                    }
                }else  if(tipology.equalsIgnoreCase(TIPOLOGY_POSTSALES)){
                    for(Case casePr : (List<Case>)processesToUpdate.get('case')){
                        ((Case)newSObjectMap.get(casePr.ID)).Status = STATUS_SEQUENZIALIZZATO;
                        ((Case)newSObjectMap.get(casePr.ID)).Phase__c = PHASE_SEQUENZIALIZZATO;
                    }
                }
                System.debug(newSObjectMap);
                System.debug('--------------------ARRIVATO1');
            }
        }
    }

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 13/07/2021
    * @param1 List<ServiceRequest> struttura oggetti tecnici da sequenzializzare
    * @return void
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

            String queryDependenciesMatrix = 'SELECT Id, IncomingProcessType__c, BlockingProcessType__c, MatchingField__c '                                           
                        + 'FROM DependenciesMatrix__c '
                        + conditions 
                        + ' WITH SECURITY_ENFORCED';

            DependenciesMatrix__c[] dependencies = Database.query(queryDependenciesMatrix);

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
            System.debug(ex.getMessage());
        }
        return processesToUpdate;
    }

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
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

            for(ServiceRequest__c sr : incomingProcesses){
                if(dependenciesMap.containsKey(sr.ProcessType__c)){
                    for(List<String> blockingMatches : dependenciesMap.get(sr.ProcessType__c)){
                        String blockingMatch = blockingMatches.get(1);
                        ServiceRequest__c srBlocking = null;
                        String matchField = null;
                        String matchValue = null;

                        if(blockingMatch.equalsIgnoreCase(MATCH_SERVICE_POINT)){
                            matchField = 'ServicePointCode__c';
                            matchValue = sr.ServicePointCode__c;
                        }else if(blockingMatch.equalsIgnoreCase(MATCH_ACCOUNT)){
                            matchField = 'Account__c';
                            matchValue = sr.Account__c;
                        }else if(blockingMatch.equalsIgnoreCase(MATCH_BILLING)){
                            matchField = 'BillingProfile__c';
                            matchValue = sr.BillingProfile__c;
                        }
                        String queryServiceRequest = 'SELECT ID, Case__c, Order__c, Type__c '
                                    + 'FROM ServiceRequest__c '
                                    + 'WHERE '+String.escapeSingleQuotes(matchField)+' = \''+String.escapeSingleQuotes(matchValue)+'\' AND '
                                    + 'Status__c = \''+String.escapeSingleQuotes(STATUS_LAVORAZIONE)+'\' AND '
                                    + 'ProcessType__c = \''+String.escapeSingleQuotes(blockingMatches[0])+'\' '
                                    + 'WITH SECURITY_ENFORCED LIMIT 1';
                        try{
                            srBlocking = (ServiceRequest__c)Database.query(queryServiceRequest);
                            if(sr.Type__c.equalsIgnoreCase(TIPOLOGY_POSTSALES)){
                                Case caseToUpdate = new Case(ID=sr.Case__c);
                                caseToUpdate.Status = STATUS_SEQUENZIALIZZATO;
                                caseToUpdate.Phase__c = PHASE_SEQUENZIALIZZATO;
                                casesToBeUpdated.add(caseToUpdate);
                            }else if(sr.Type__c.equalsIgnoreCase(TIPOLOGY_SALES)){
                                Order orderToUpdate = new Order(ID=sr.Order__c);
                                orderToUpdate.Status = STATUS_SEQUENZIALIZZATO;
                                orderToUpdate.Phase__c = PHASE_SEQUENZIALIZZATO;
                                ordersToBeUpdated.add(orderToUpdate);
                            }
                            sr.DependOn__c = srBlocking.ID;
                            sr.Status__c = STATUS_SEQUENZIALIZZATO;
                            serviceRequestsToBeSequenced.add(sr);
                        }catch(Exception ex){
                            System.debug(ex.getMessage());
                        }
                        
                    }
                }
            }
            
            results.put('serviceRequest',serviceRequestsToBeSequenced);
            results.put('case',casesToBeUpdated);
            results.put('order',ordersToBeUpdated);

        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        return results;
    }

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 13/07/2021
    * @param1 List<ServiceRequest__c> serviceRequestsToBeSequenced
    * @param2 List<Order> ordersToBeUpdated
    * @param3 List<Case> casesToBeUpdated
    * @return void
    */
    public static void updateProcesses(List<ServiceRequest__c> serviceRequestsToBeSequenced){
        
        Savepoint sp = Database.setSavePoint();
        
        try{
            if (ServiceRequest__c.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isUpdateable()){
                
                update serviceRequestsToBeSequenced;
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
            Database.rollback(sp);
        }
    }
}