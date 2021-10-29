global inherited sharing class HDT_UTL_GestAppAutomaticCreation implements wrts_prcgvr.Interfaces_1_0.IApexAction{
    
    Map<String,Map<String,Boolean>> mapDistributorProcess = new Map<String,Map<String,Boolean>>
    { 'SubentrosuGdMchiuso' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'Attivazione' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'PrimaAttivazione' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'Nuovoimpianto' => new Map<String,Boolean>{'InRete' => true},
    'Aggiuntaattacco' => new Map<String,Boolean>{'InRete' => true},
    'Rimozioneimpianto' => new Map<String,Boolean>{'InRete' => true},
    'Modificaimpianto' => new Map<String,Boolean>{'InRete' => true},
    'Ripristinoforniturainterrotta' => new Map<String,Boolean>{'InRete' => true},
    'Spostamentocontatore' => new Map<String,Boolean>{'InRete' => true},
    'Variazioneportata' => new Map<String,Boolean>{'InRete' => true},
    'RiattivazioneFornitura' => new Map<String,Boolean>{'InRete' => true},
    'Chiusuracontatore' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'VerificaGdM' => new Map<String,Boolean>{'InRete' => true},
    'VerificaPressione' => new Map<String,Boolean>{'InRete' => true},
    'ConsegnaCopiaChiaveGdM' => new Map<String,Boolean>{'InRete' => true},
    'Sost.Contatorec/cliente' => new Map<String,Boolean>{'InRete' => true},
    'VerificadatialDL' => new Map<String,Boolean>{'InRete' => true}

    };
    HDT_Qr_RecordType rcQr =  new  HDT_Qr_RecordType();
    HDT_SRV_ActivityCustom actSrv = new  HDT_SRV_ActivityCustom();
    global Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (sObject) argsMap.get('sender');
        String idObject = (String)obj.get('Id');
        //HDT_QR_Order orderQr= new HDT_QR_Order();
        List<Order> ordList = [Select id,Sale__r.SalesContact__c,servicePoint__c,AccountId,ServicePoint__r.CommoditySector__c,ServicePoint__r.distributor__r.name from order where id =:idObject WITH SECURITY_ENFORCED];
        if(ordList != null && !ordList.isEmpty()){
            Order ord = ordList[0];
            if('Gas'.equalsIgnoreCase(ord.ServicePoint__r.CommoditySector__c) && mapDistributorProcess.get(method) != null ){
                boolean isAtoa = mapDistributorProcess.get(method).get(ord.ServicePoint__r.distributor__r.name) != null ? true : false;
                id rec = rcQr.getRecordTypeIdByName('HDT_RT_DistributorAppointment');
                wrts_prcgvr__Activity__c w = new wrts_prcgvr__Activity__c();
                w.order__c = ord.id;
                w.Distributor__c = ord.servicePoint__r.distributor__c;
                w.servicePoint__c = ord.ServicePoint__c;
                w.account__c = ord.AccountId;
                w.contact__c = ord.Sale__r.SalesContact__c ;
                w.isAtoa__c = isAtoa;
                w.recordtypeid = rec;
                w.status__c = 'Creata';

                actSrv.createRecord(w);

            }
        }

        return true;
    }
}
