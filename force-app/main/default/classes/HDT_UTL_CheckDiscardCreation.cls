global with sharing class HDT_UTL_CheckDiscardCreation implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {
    global HDT_UTL_CheckDiscardCreation() {}

    global boolean evaluate(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        String method = (String) argsMap.get('method');
        
        SObject record = (SObject) argsMap.get('record');
		
		//c'è annullamento automatico a partire dal singolo scarto, per singolo processo, per singolo cluster
        //non si riescono a passare tutte queste info tramite method, servirebbero una marea di method
        //non sembra esserci un modo per passare i dati tramite "parametri" alla action
        //l'unica via, per ora, sembra quella di mettere il nome del template nel method. ES: 'checkActivityCreation___CBS_ATT006__AMMISSIBILITA_KO'
        //di conseguenza lo switch è poco funzionale, perchè bisognerebbe scrivere n righe per quanti template vengono rigchiesti... è anche poco manutenibile
        //dinamicamente, con substring, si vede il prefisso (checkActivityCreation) e poi si estrae il nome del template dalle parentesi tonde
		boolean activityCreationOutcome;
        try{
            activityCreationOutcome = HDT_UTL_Scarti.checkActivityCreation((Id)record.get('Id'), method);
        } catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
        }
		
		return activityCreationOutcome;
    }
}