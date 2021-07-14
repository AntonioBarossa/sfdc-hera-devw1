public inherited sharing class HDT_UTL_Dependencies {
    
    private static final String STATUS_BOZZA = 'In Bozza';
    private static final String STATUS_LAVORAZIONE = 'In Lavorazione';
    private static final String STATUS_SEQUENZIALIZZATO = 'Sequenzializzato';

    private static final String PHASE_SEQUENZIALIZZATO = 'Sequenzializzato';

    private static final String MATCH_BILLING = 'Billing Profile';
    private static final String MATCH_ACCOUNT = 'Account';
    private static final String MATCH_SERVICE_POINT = 'Service Point';

    private static final String TIPOLOGY_SALES = 'Order';
    private static final String TIPOLOGY_POSTSALES = 'Case';

    public static void sequentialization(List<ServiceRequest__c> incomingProcesses){
        String conditions = 'WHERE ';
        Integer index = 0;
        for(ServiceRequest__c sr : incomingProcesses){
            index++;
            conditions += '(IncomingProcessType__c = '+sr.ProcessType__c+' AND CheckingPhase__c = '+sr.NextPhase__c+')';
            if(index < incomingProcesses.size()){
                conditions += ' OR ';
            }
        }

        String queryDependenciesMatrix = 'SELECT Id, IncomingProcessType__c, BlockingProcessType__c, MatchingField__c '                                           
                    + 'FROM DependenciesMatrix__c '
                    + String.escapeSingleQuotes(conditions) 
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

        List<List<SObject>> processesToUpdate = getProcessesToUpdate(incomingProcesses, dependenciesMap);
        if(processesToUpdate.size()>0){
            updateProcesses(processesToUpdate.get(0),processesToUpdate.get(1),processesToUpdate.get(2));
        }
        
    }

    public static List<List<SObject>> getProcessesToUpdate(List<ServiceRequest__c> incomingProcesses, Map<String,List<List<String>>> dependenciesMap){
        
        List<List<SObject>> results = new List<List<SObject>>();

        try {
            List<ServiceRequest__c> serviceRequestsToBeSequenced = new List<ServiceRequest__c>();
            List<Order> ordersToBeUpdated = new List<Order>();
            List<Case> casesToBeUpdated = new List<Case>();

            for(ServiceRequest__c sr : incomingProcesses){
                if(dependenciesMap.containsKey(sr.ProcessType__c)){
                    for(List<String> blockingMatches : dependenciesMap.get(sr.ProcessType__c)){
                        
                        ServiceRequest__c srBlocking = null;
                        String matchField = null;
                        String matchValue = null;

                        if(blockingMatches[1].equalsIgnoreCase(MATCH_SERVICE_POINT)){
                            matchField = 'ServicePointCodeFormula__c';
                            matchValue = sr.ServicePointCodeFormula__c;
                        }else if(blockingMatches[1].equalsIgnoreCase(MATCH_ACCOUNT)){
                            matchField = 'Account__c';
                            matchValue = sr.Account__c;
                        }else if(blockingMatches[1].equalsIgnoreCase(MATCH_BILLING)){
                            matchField = 'BillingProfile__c';
                            matchValue = sr.BillingProfile__c;
                        }
                        String queryServiceRequest = 'SELECT ID, Case__c, Order__c, Tipologia__c '
                                    + 'FROM ServiceRequest__c '
                                    + 'WHERE '+String.escapeSingleQuotes(matchField)+' = '+String.escapeSingleQuotes(matchValue)+' AND '
                                    + 'Status__c = '+String.escapeSingleQuotes(STATUS_LAVORAZIONE)+' AND '
                                    + 'ProcessType__c = '+String.escapeSingleQuotes(blockingMatches[0])+' '
                                    + 'LIMIT 1  WITH SECURITY_ENFORCED';

                        try{
                            srBlocking = (ServiceRequest__c)Database.query(queryServiceRequest);
                            
                            if(sr.Tipologia__c.equalsIgnoreCase(TIPOLOGY_POSTSALES)){
                                Case caseToUpdate = sr.Case__c;
                                caseToUpdate.Status = STATUS_SEQUENZIALIZZATO;
                                caseToUpdate.Phase__c = PHASE_SEQUENZIALIZZATO;
                                casesToBeUpdated.add(caseToUpdate);
                            }else if(sr.Tipologia__c.equalsIgnoreCase(TIPOLOGY_SALES)){
                                Order orderToUpdate = sr.Order__c;
                                orderToUpdate.Status = STATUS_SEQUENZIALIZZATO;
                                orderToUpdate.Phase__c = PHASE_SEQUENZIALIZZATO;
                                ordersToBeUpdated.add(orderToUpdate);
                            }
                            // sr.DependOn__c = srBlocking;
                            sr.Status__c = STATUS_SEQUENZIALIZZATO;
                            serviceRequestsToBeSequenced.add(sr);
                        }catch(Exception ex){
                            System.debug(ex.getMessage());
                        }
                        
                    }
                }
            }
            
            results.add(0,serviceRequestsToBeSequenced);
            results.add(1,casesToBeUpdated);
            results.add(2,ordersToBeUpdated);

        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        return results;
    }

    public static void updateProcesses(List<ServiceRequest__c> serviceRequestsToBeSequenced, List<Order> ordersToBeUpdated, List<Case> casesToBeUpdated){
        
        Savepoint sp = Database.setSavePoint();
        
        try{
            if (ServiceRequest__c.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isUpdateable()&&
                Order.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.Order.fields.Status.isAccessible()&&
                Schema.sObjectType.Order.fields.Status.isUpdateable()&&
                Case.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.Case.fields.Status.isAccessible()&&
                Schema.sObjectType.Case.fields.Status.isUpdateable()){

                update serviceRequestsToBeSequenced;
                update casesToBeUpdated;
                update ordersToBeUpdated;
            }
        }catch(Exception ex){
            Database.rollback(sp);
        }
    }
}
