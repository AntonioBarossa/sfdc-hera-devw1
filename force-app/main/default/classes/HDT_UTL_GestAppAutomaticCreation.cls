global inherited sharing class HDT_UTL_GestAppAutomaticCreation implements wrts_prcgvr.Interfaces_1_0.IApexAction{
    
    Map<String,Map<String,Boolean>> mapDistributorProcess = new Map<String,Map<String,Boolean>>
    { 'Subentro su GdM chiuso' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'Attivazione' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'Prima Attivazione' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'Nuovo impianto' => new Map<String,Boolean>{'InRete' => true},
    'Aggiunta attacco' => new Map<String,Boolean>{'InRete' => true},
    'Rimozione impianto' => new Map<String,Boolean>{'InRete' => true},
    'Modifica impianto' => new Map<String,Boolean>{'InRete' => true},
    'Ripristino fornitura interrotta' => new Map<String,Boolean>{'InRete' => true},
    'Spostamento contatore' => new Map<String,Boolean>{'InRete' => true},
    'Variazione portata' => new Map<String,Boolean>{'InRete' => true},
    'Riattivazione Fornitura' => new Map<String,Boolean>{'InRete' => true},
    'Chiusura contatore' => new Map<String,Boolean>{'InRete' => true,'Acegas' => true},
    'Verifica GdM' => new Map<String,Boolean>{'InRete' => true},
    'Verifica Pressione' => new Map<String,Boolean>{'InRete' => true},
    'Consegna Copia Chiave GdM' => new Map<String,Boolean>{'InRete' => true},
    'Sost. Contatore c/cliente' => new Map<String,Boolean>{'InRete' => true},
    'Verifica dati al DL' => new Map<String,Boolean>{'InRete' => true}

    };
    HDT_Qr_RecordType rcQr =  new  HDT_Qr_RecordType();
    HDT_SRV_ActivityCustom actSrv = new  HDT_SRV_ActivityCustom();
    global Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (sObject) argsMap.get('sender');
        String idObject = (String)obj.get('Id');
        HDT_QR_Order orderQr= new HDT_QR_Order();
        Order ord = orderQr.getRecordById(idObject);
        if('Gas'.equalsIgnoreCase(ord.ServicePoint__r.CommoditySector__c) && mapDistributorProcess.get(method) != null ){
            boolean isAtoa = mapDistributorProcess.get(method).get(ord.ServicePoint__r.distributor__r.name) != null ? true : false;
            id rec = rcQr.getRecordTypeIdByName('HDT_RT_DistributorAppointment');
            wrts_prcgvr__Activity__c w = new wrts_prcgvr__Activity__c();
            w.order__c = ord.id;
            w.Distributor__c = ord.servicePoint__r.distributor__c;
            w.account__c = ord.AccountId;
            w.contact__c = ord.Sale__r.SalesContact__c ;
            w.isAtoa__c = isAtoa;
            w.recordtypeid = rec;
            w.status__c = 'Creata';

            actSrv.createRecord(w);

        }

        return true;
    }
}
