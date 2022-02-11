public with sharing class HDT_LC_EditScartiComplessi {
    @AuraEnabled
    public static string getInitData(String recordId){
        Map<String,Object> responseMap = new Map<String,Object>();
        Boolean hasOwnership = true;
        try {
            wrts_prcgvr__Activity__c activity = (wrts_prcgvr__Activity__c)HDT_QR_GenericQuery.getGenericRecords('Id,Case__c, Type__c, OwnerId, Order__c,Order__r.ParentOrder__c,Order__r.ParentOrder__r.AccountId, Order__r.ParentOrder__r.Sale__c,Order__r.Sale__c, Order__r.AccountId,Order__r.ServicePoint__r.Account__c, Order__r.ServicePoint__r.CommoditySector__c,Order__r.RecordType.DeveloperName, Order__r.SwitchOutDate__c', 'wrts_prcgvr__Activity__c', 'Id =\''+recordId+'\'')[0];
            if(activity.OwnerId!= Userinfo.getUserId()){
                hasOwnership=false;
            }
            else{
                if (activity.Case__c != null){
                    responseMap.put('objectId',recordId);
                    responseMap.put('objectType','Case');
                }else if(activity.Order__c != null){
                    if(activity.Type__c!=null && activity.Type__c.equals('Busta Docusign non consegnata')){
                        responseMap.put('object',activity);
                        responseMap.put('objectType','wrts_prcgvr__Activity__c');
                    }
                    else {
                        setStep(activity);
                        responseMap.put('objectType','Order');
                        responseMap.put('object',activity.Order__r);
                    }
                }else{
                    throw new AuraHandledException('Attività Non Valida');
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Non è stata trovata l\'attività richiesta.');
        }

        if(!hasOwnership){
            throw new AuraHandledException('L\'attività può essere gestita solamente dall\'assegnatario');
        }
        return JSON.serialize(responseMap);
    }

    @AuraEnabled
    public static String resubmissionPractice(String orderId,String activityId, String processType){
        String response;
        String fase = 'Comunicazione verso Heroku';
        switch on processType {
            when  'Voltura' {
                fase = 'Documentazione Validata';
            }
            when 'VAS' {
                fase = 'Comunicazione Motore VAS';
            }
        }
        Order orderToUpdate = new Order(Id = orderId,Phase__c = fase);
        System.Savepoint sp = Database.setSavePoint();
        try {
            if (!HDT_UTL_Scarti.updateCloseDiscardActivity(activityId)){
                response = 'Impossibile chiudere l\'attività di scarto';
            } else if (!HDT_UTL_DatabaseService.updateSObject(orderToUpdate)){
                response = 'Errore nell\'aggiornamento della fase dell\'ordine.';
                Database.rollback(sp);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @TestVisible
    private static void setStep(wrts_prcgvr__Activity__c activity){
        Double step = null;
        Order ord = activity.Order__r;
        switch on (ord.RecordType.DeveloperName){
            when 'HDT_RT_SwitchInVolturaTecnica'{
                step = 11;
            }
            when 'HDT_RT_Attivazione','HDT_RT_AttivazioneConModifica','HDT_RT_ScontiBonus','HDT_RT_CambioOfferta',
                'HDT_RT_CambioUso','HDT_RT_ConnessioneConAttivazione','HDT_RT_TemporaneaNuovaAtt','HDT_RT_VAS'{
                step = 5;
            }
            when 'HDT_RT_Subentro'{
                step = setStepCheckAccount(ord, ord.ServicePoint__r, 5);
            }
            when 'HDT_RT_Voltura'{
                step = setStepCheckAccount(ord, ord.ServicePoint__r, 3);
            }
            when 'HDT_RT_VolturaConSwitch'{
                step = setStepForVoltureWithSwitch(ord.ServicePoint__r, ord.AccountId);
            }
            when 'HDT_RT_SwitchIn'{
                step = setStepSwitchIn(ord, ord.ServicePoint__r);
            }
        }
        
        if (!HDT_UTL_DatabaseService.updateSObject(new Order(Id =  activity.Order__c, Step__c = step))){
            throw new AuraHandledException('Errore Nell\'aggiornamento dell\'order');
        }
    }

    private static Double setStepCheckAccount(Order ord, ServicePoint__c serv,Double step){
        if (serv != null && serv.Account__c != ord.AccountId){
            return null;
        }
        return step;
    }

    @TestVisible
    private static Double setStepForVoltureWithSwitch(ServicePoint__c serv, Id accountId){
        Double step = 4;
        if (serv != null && serv.Account__c != accountId){
            step = null;
        }else if (serv != null && 'Energia Elettrica'.equalsIgnoreCase(serv.CommoditySector__c)){
            step = 3;
        }
        return step;
    }

    private static Double setStepSwitchIn(Order ord, ServicePoint__c serv){
        Double step = 5;
        if (ord.SwitchOutDate__c != null){
            step = 3;
        }else if (serv != null && 'Gas'.equalsIgnoreCase(serv.CommoditySector__c)){
            step = 4;
        }
        return step;
    }

    @InvocableMethod(label='Close Discard Activity')
    public static List<String> closeDiscardActivity(List<String> input){
        String response;
        Id activityId = (Id)input[0];
        if (!HDT_UTL_Scarti.updateCloseDiscardActivity(activityId)){
            response = 'Impossibile chiudere l\'attività di scarto';
        }
        return new List<String>{response};
    }
}