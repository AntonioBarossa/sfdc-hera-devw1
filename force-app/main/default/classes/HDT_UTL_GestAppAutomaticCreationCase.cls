@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_GestAppAutomaticCreationCase implements wrts_prcgvr.Interfaces_1_0.IApexAction{
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
    'ConsegnaCopia Chiave GdM' => new Map<String,Boolean>{'InRete' => true},
    'Sost.Contatorec/cliente' => new Map<String,Boolean>{'InRete' => true},
    'VerificadatialDL' => new Map<String,Boolean>{'InRete' => true}

    }; */
   // HDT_QT_RecordType rcQr =  new  HDT_QT_RecordType();

    global Object execute(Object args) {
        HDT_Qr_RecordType rcQr =  new  HDT_Qr_RecordType();
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (sObject) argsMap.get('sender');
        String idObject = (String)obj.get('Id');
        HDT_QR_Case caseQr= new HDT_QR_Case();
        HDT_SRV_ActivityCustom actSrv = new  HDT_SRV_ActivityCustom();
        Case ca = CaseQr.getRecordById(idObject);
        HDT_AppointmentSetting__mdt conf = HDT_UTL_AppointmentSetting.getAtoaFlag(method, ca.ServicePoint__r.distributor__r.name, ca.ServicePoint__r.CommoditySector__c, ca.SalesCompanyCode__c);
        if (conf != null){
            id rec = rcQr.getRecordTypeIdByName('HDT_RT_DistributorAppointment');
            wrts_prcgvr__Activity__c w = new wrts_prcgvr__Activity__c();
            w.case__c = ca.id;
            w.Distributor__c = ca.servicePoint__r.distributor__c;
            w.account__c = ca.AccountId;
            w.Contact__c = ca.ContactId;
            w.isAtoa__c = conf.Flag__c;
            w.recordtypeid = rec;
            w.wrts_prcgvr__Status__c = 'Creata';
            w.ServicePoint__c = ca.ServicePoint__c;
            agendaSrv.setContactData(w, ca.Contact);
            actSrv.createRecord(w);

        }

        return true;
    }
}
