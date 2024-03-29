@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_GestAppAutomaticCreation implements wrts_prcgvr.Interfaces_1_0.IApexAction{
    private HDT_SRV_AppointmentAgenda agendaSrv = new HDT_SRV_AppointmentAgenda();
    /* Map<String,Map<String,Boolean>> mapDistributorProcess = new Map<String,Map<String,Boolean>>
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

    }; */
    HDT_Qr_RecordType rcQr =  new  HDT_Qr_RecordType();
    HDT_SRV_ActivityCustom actSrv = new  HDT_SRV_ActivityCustom();
    global Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (sObject) argsMap.get('sender');
        String idObject = (String)obj.get('Id');
        //HDT_QR_Order orderQr= new HDT_QR_Order();
        //List<Order> ordList = [Select id,SalesCompanyCode__c, Sale__r.SalesContact__c,Sale__r.SalesContact__r.FiscalCode__c,Sale__r.SalesContact__r.VATNumber__c, servicePoint__c,AccountId,ServicePoint__r.CommoditySector__c,ServicePoint__r.distributor__r.name from order where id =:idObject WITH SECURITY_ENFORCED];
        HDT_QR_Order orderQr = new HDT_QR_Order();
        Order ord = orderQr.getRecordById(idObject);
        HDT_AppointmentSetting__mdt conf = HDT_UTL_AppointmentSetting.getAtoaFlag(method, ord.ServicePoint__r.distributor__r.name, ord.ServicePoint__r.CommoditySector__c, ord.SalesCompanyCode__c);
        if(conf != null){
            id rec = rcQr.getRecordTypeIdByName('HDT_RT_DistributorAppointment');
            wrts_prcgvr__Activity__c w = new wrts_prcgvr__Activity__c();
            w.order__c = ord.id;
            w.Distributor__c = ord.servicePoint__r.distributor__c;
            w.servicePoint__c = ord.ServicePoint__c;
            w.account__c = ord.AccountId;
            w.contact__c = ord.Sale__r.SalesContact__c ;
            w.isAtoa__c = conf.Flag__c;
            w.recordtypeid = rec;
            w.wrts_prcgvr__Status__c = 'Creata';
            agendaSrv.setContactData(w, ord.Sale__r.SalesContact__r);
            actSrv.createRecord(w);

        }
        /**@frpanico 2022-04-04
         * All'ammOk per la prima attivazione
         * e' necessario richiamare il servizio26
         * Non essendo possibile inserire due action apex
         * nella stessa configurazione di transizione viene inserito
         * Viene richiamato il metodo per chiamare il Servizio26
         */
        if(ord.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_Attivazione') 
            || ord.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_Subentro'))
        {
            Map<String,Object> argsMapService = new Map<String,Object>();
            argsMapService.put('sender',obj);
            argsMapService.put('method','service26');
            HDT_SRV_VoltureChangeManager voltureChangeSrv = new HDT_SRV_VoltureChangeManager();
            voltureChangeSrv.checkCallServiceTwentySix(argsMapService);
        }
        return true;
    }
}
