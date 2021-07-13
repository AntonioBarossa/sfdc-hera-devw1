public inherited sharing class HDT_TRH_SequenceRequest extends HDT_TRH_TriggerHandler{
    
    public override void afterUpdate(){
        
        List<String> incomingProcessTypes = new List<String>();
        Map<String,String> incomingProcessTypesMap = new Map<String,String>();
        
        for(SequenceRequest__c sr : Trigger.new){
            incomingProcessTypes.add(sr.ProcessType__c);
            incomingProcessTypesMap.push(sr.ServicePointCode__c,sr);
        }

        DependencyMatrix__c[] dependencies = [SELECT Id, IncomingProcessType__c, BlockingProcessType__c, MatchingField__c 
                                            FROM DependencyMatrix__c WHERE IncomingProcessType__c IN :processTypes 
                                            WITH SECURITY_ENFORCED];
        
        Map<String,List<String>> dependenciesMap = new Map<String,List<String>>();
        for(DependencyMatrix__c dependency : dependencies){
            if(dependenciesMap.containsKey(dependency.IncomingProcessType__c)){
                dependenciesMap.get(dependency.IncomingProcessType__c).add(dependency.BlockingProcessType__c);
            }else{
                dependenciesMap.put(dependency.IncomingProcessType__c,new List<String>{dependency.BlockingProcessType__c});
            }
        }

        List<SequenceRequest__c> sequenceRequestsToBeSequenced = new List<SequenceRequest__c>();
        List<Order> ordersToBeUpdated = new List<Order>();
        List<Case> casesToBeUpdated = new List<Case>();
        for(List<String> blockingdependencies : dependenciesMap.values()){
            
            ServiceRequest__c[] serviceRequests = [SELECT Id, ServicePointCode__c 
                                                 FROM ServiceRequest__c WHERE ProcessType__c IN :blockingdependencies AND Status = 'In Lavorazione'
                                                 WITH SECURITY_ENFORCED];
            
            for(ServiceRequest__c sr : serviceRequests){
                if(incomingProcessTypesMap.containsKey(sr.ServicePointCode__c)){
                    ServiceRequest__c srToBeSequenced = incomingProcessTypesMap.get(sr.ServicePointCode__c);
                    srToBeSequenced.Status__c = 'Sequenzializzato';
                    sequenceRequestsToBeSequenced.add(srToBeSequenced);
                    if(srToBeSequenced.Type__c.equalsIgnoreCase('Case')){
                        Case caseToUpdate = new Case(srToBeSequenced.Case__c);
                        caseToUpdate.Status = 'Sequenzializzato';
                        casesToBeUpdated.add(caseToUpdate);
                    }else if(srToBeSequenced.Type__c.equalsIgnoreCase('Order')){
                        Order orderToUpdate = new Order(srToBeSequenced.Order__c);
                        orderToUpdate.Status = 'Sequenzializzato';
                        ordersToBeUpdated.add(orderToUpdate);
                    }
                }
            }
        }
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

                update sequenceRequestsToBeSequenced;
                update casesToBeUpdated;
                update ordersToBeUpdated;
            }
        }catch(Exception ex){
            Database.rollback(sp);
        }
    }
}
