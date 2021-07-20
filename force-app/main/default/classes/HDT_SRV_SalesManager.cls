/*
 * File: HDT_SRV_SalesManager.cls
 * Project: HERA
 * File Created: Monday, 19th July 2021 12:00:40 pm
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 */

global inherited sharing class HDT_SRV_SalesManager implements wrts_prcgvr.Interfaces_1_0.IApexAction {
    
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        system.debug(json.serialize(args));
        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        Id objectId = (Id) sender.get('Id');

        

        switch on method{
            when 'activation'{
                system.enqueueJob(new HDT_QBL_AsycnronousCallout(
                        objectId, 'activation'
                    )
                );
            }
            when 'deactivation'{
                system.enqueueJob(new HDT_QBL_AsycnronousCallout(
                        objectId, 'deactivation'
                    )
                );
            }
            when 'updatePhase'{
                system.enqueueJob(new HDT_QBL_AsycnronousUpdate(
                    objectId, 'Comunicazione Motore VAS'
                    )
                );
                
            }
        }


        
        return null;
    }


    public class HDT_QBL_AsycnronousCallout implements Queueable, Database.AllowsCallouts{
        private Id sobjectId{get;set;}
        private String method{get;set;}

        public HDT_QBL_AsycnronousCallout(){}
        public HDT_QBL_AsycnronousCallout(Id sobjectId, String method){
            this.sobjectId=sobjectId;
            this.method = method;
        }
        public HDT_QBL_AsycnronousCallout(String sobjectId, String method){
            this((Id) sobjectId, method);
        }

        public void execute(QueueableContext context){
            HDT_WS_Response res;
            String newPhase;

            switch on method{
                when 'activation'{
                    res = HDT_WS_MotoreVas.activationCallout(sobjectId);
                    if(res.statusCode==200 || res.statusCode==201){
                        newPhase='Comunicazione verso Motore VAS OK';
                    }else{
                        newPhase='Comunicazione verso Motore VAS KO';
                    }
                }
                when 'deactivation'{
                    res = HDT_WS_MotoreVas.deactivationCallout(sobjectId);
                }
            }

            system.debug('***HDT_QBL_AsycnronousCallout'+res);

            //do UpdatePhase

            if(String.isNotBlank(newPhase)){ 
                new HDT_QBL_AsycnronousUpdate().asyncronousUpdate(SobjectId, newPhase);
            }

        }
    }
    
    public class HDT_QBL_AsycnronousUpdate implements Queueable {
        private Id sobjectId{get;set;}
        private String newPhase{get;set;}
        

        public HDT_QBL_AsycnronousUpdate(){}
        public HDT_QBL_AsycnronousUpdate(Id sobjectId, String newPhase){
            this.sobjectId=sobjectId;
            this.newPhase = newPhase;
        }
        public HDT_QBL_AsycnronousUpdate(String sobjectId, String newPhase){
            this((Id) sobjectId, newPhase);
        }

        public void execute(QueueableContext context){
            asyncronousUpdate(sobjectId, newPhase);
        }
        
        public void asyncronousUpdate(Id SobjectId, String newPhase){
            Sobject sender = (SObject) new Order();
            sender.put('Id', SobjectId);
            sender.put('Phase__c', newPhase);
            Database.Update(sender);
        }
    }

    

}
