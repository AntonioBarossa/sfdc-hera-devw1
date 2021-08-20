public inherited sharing class HDT_UTL_HandleTechnicalData {

    public ServicePoint__c sp;
//NON TOCCARE
    public void handleE154Flow(Map<String, String> mapRequestFields, Order ord){
        system.debug('flusso E154');
        if (!String.isBlank(mapRequestFields.get('IMP_PREV_DIST'))) {
            ord.EstimateAmount__c = Decimal.valueOf(mapRequestFields.get('IMP_PREV_DIST'));
        }
        if(!String.isBlank(mapRequestFields.get('DT_MAX_PREV'))){
            if(mapRequestFields.get('DT_MAX_PREV').getChars().size()==8){
                ord.ValidityDateEstimate__c=getExpireDate(mapRequestFields.get('DT_MAX_PREV'));
            }
        }
        if(!String.isBlank(mapRequestFields.get('NUMPREV'))){
            ord.QuotationNumber__c=mapRequestFields.get('NUMPREV');
        }
    }
//NON TOCCARE


    public void handleE150Flow(Map<String, String> mapRequestFields, Order sp){
        system.debug('flusso E150');
        if (!String.isBlank(mapRequestFields.get('PUNTODISPACCIAMENTO'))) {
            sp.EstimateAmount__c = mapRequestFields.get('PUNTODISPACCIAMENTO');
        }
        if (!String.isBlank(mapRequestFields.get('TIPO_MISURATORE'))) {
            ord.EstimateAmount__c = mapRequestFields.get('TIPO_MISURATORE');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_REGIME_2G'))) {
            ord.EstimateAmount__c = mapRequestFields.get('DATA_REGIME_2G');
        }
        if (!String.isBlank(mapRequestFields.get('TRATTAMENTO_DT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('TRATTAMENTO_DT');
        }
        if (!String.isBlank(mapRequestFields.get('K_ATT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('K_ATT');
        }
        if (!String.isBlank(mapRequestFields.get('K_REATT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('K_REATT');
        }
        if (!String.isBlank(mapRequestFields.get('K_POT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('K_POT');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS_ATTIVA_NEW'))) {
            ord.EstimateAmount__c = mapRequestFields.get('MATR_MIS_ATTIVA_NEW');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS_REATTIVA_NEW'))) {
            ord.EstimateAmount__c = mapRequestFields.get('MATR_MIS_REATTIVA_NEW');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS_POTENZA_NEW'))) {
            ord.EstimateAmount__c = mapRequestFields.get('MATR_MIS_POTENZA_NEW');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_INST_ATT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('DATA_INST_ATT');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_INST_REA'))) {
            sp.EstimateAmount__c = mapRequestFields.get('DATA_INST_REA');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_INST_POT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('DATA_INST_POT');
        }
        if (!String.isBlank(mapRequestFields.get('CIFRE_ATTIVA'))) {
            sp.EstimateAmount__c = mapRequestFields.get('CIFRE_ATTIVA');
        }
        if (!String.isBlank(mapRequestFields.get('CIFRE_REATTIVA'))) {
            sp.EstimateAmount__c = mapRequestFields.get('CIFRE_REATTIVA');
        }
        if (!String.isBlank(mapRequestFields.get('CIFRE_POT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('CIFRE_POT');
        }
        if (!String.isBlank(mapRequestFields.get('GRUPPO_MIS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('GRUPPO_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('FORFAIT'))) {
            ord.EstimateAmount__c = mapRequestFields.get('FORFAIT');
        }
        if (!String.isBlank(mapRequestFields.get('CODICE_TARIFFA'))) {
            ord.EstimateAmount__c = mapRequestFields.get('CODICE_TARIFFA');
        }
        if (!String.isBlank(mapRequestFields.get('SERV_TUTELA'))) {
            ord.EstimateAmount__c = mapRequestFields.get('SERV_TUTELA');
        }
        if (!String.isBlank(mapRequestFields.get('GRUPPO_MIS_DT'))) {
            ord.EstimateAmount__c = mapRequestFields.get('GRUPPO_MIS_DT');
        }        
    }

    public void handlE351Flow(Map<String, String> mapRequestFields, Order ord){
        system.debug('flusso 351');
        if (!String.isBlank(mapRequestFields.get('TRATTAMENTO_DT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('TRATTAMENTO_DT');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS'))) {
            ord.MeterSN__c = mapRequestFields.get('MATR_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_MIS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('N_CIFRE_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_CONV'))) {
            ord.EstimateAmount__c = mapRequestFields.get('MATR_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_CONV'))) {
            sp.EstimateAmount__c = mapRequestFields.get('N_CIFRE_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('COEFF_CORRETTIVO'))) {
            sp.EstimateAmount__c = mapRequestFields.get('COEFF_CORRETTIVO');
        }
        if (!String.isBlank(mapRequestFields.get('RACCOLTA'))) {
            sp.EstimateAmount__c = mapRequestFields.get('RACCOLTA');
        }
        if (!String.isBlank(mapRequestFields.get('VOL_ANNUO_SOST'))) {
            sp.EstimateAmount__c = mapRequestFields.get('VOL_ANNUO_SOST');
        }
        if (!String.isBlank(mapRequestFields.get('CLASSE_GRUPPO_MIS'))) {
            sp.MeterClass__c = mapRequestFields.get('CLASSE_GRUPPO_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('PRE_CONV'))) {
            sp.EstimateAmount__c = mapRequestFields.get('PRE_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('GRUPPO_MIS_INT'))) {
            sp.EstimateAmount__c = mapRequestFields.get('GRUPPO_MIS_INT');
        }
    }



    public void handlE300Flow(Map<String, String> mapRequestFields, Order ord){
        system.debug('flusso 300');
        if (!String.isBlank(mapRequestFields.get('MATR_MIS'))) {
            ord.EstimateAmount__c = mapRequestFields.get('MATR_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('TIPO_PDR'))) {
            ord.EstimateAmount__c = mapRequestFields.get('TIPO_PDR');
        }
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_MIS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('N_CIFRE_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('CLASSE_GRUPPO_MIS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('CLASSE_GRUPPO_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('ANNO_FABB_MIS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('ANNO_FABB_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('SEGN_MIS_AVVIO'))) {
            sp.EstimateAmount__c = mapRequestFields.get('SEGN_MIS_AVVIO');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_CONV'))) {
            ord.EstimateAmount__c = mapRequestFields.get('MATR_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_CONV'))) {
            sp.EstimateAmount__c = mapRequestFields.get('N_CIFRE_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('SEGN_CONV'))) {
            sp.EstimateAmount__c = mapRequestFields.get('SEGN_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('COEFF_CORRETTIVO'))) {
            sp.EstimateAmount__c = mapRequestFields.get('COEFF_CORRETTIVO');
        }
        if (!String.isBlank(mapRequestFields.get('ACC_MIS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('ACC_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('COD_PROF_PREL'))) {
            //Gestire caso CLASSE_PRELIEVO
            sp.EstimateAmount__c = mapRequestFields.get('COD_PROF_PREL');
        }
        if (!String.isBlank(mapRequestFields.get('COD_REMI'))) {
            ord.EstimateAmount__c = mapRequestFields.get('COD_REMI');
        }
        if (!String.isBlank(mapRequestFields.get('PRESS_MIS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('PRESS_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('MAX_PRELIEVO_ORA'))) {
            sp.EstimateAmount__c = mapRequestFields.get('MAX_PRELIEVO_ORA');
        }
        if (!String.isBlank(mapRequestFields.get('CONS_ANNUO'))) {
            sp.EstimateAmount__c = mapRequestFields.get('CONS_ANNUO');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_SCAD_DS'))) {
            sp.EstimateAmount__c = mapRequestFields.get('DATA_SCAD_DS');
        }
        if (!String.isBlank(mapRequestFields.get('BONUSGAS'))) {
            ord.EstimateAmount__c = mapRequestFields.get('BONUSGAS');
        }
        if (!String.isBlank(mapRequestFields.get('BONUS_INIZ'))) {
            ord.EstimateAmount__c = mapRequestFields.get('BONUS_INIZ');
        }
        if (!String.isBlank(mapRequestFields.get('BONUS_FINE'))) {
            ord.EstimateAmount__c = mapRequestFields.get('BONUS_FINE');
        }
        if (!String.isBlank(mapRequestFields.get('MESE_RIN'))) {
            ord.EstimateAmount__c = mapRequestFields.get('MESE_RIN');
        }
        if (!String.isBlank(mapRequestFields.get('TIPO_BONUS'))) {
            ord.EstimateAmount__c = mapRequestFields.get('TIPO_BONUS');
        }
    }

    private static Date getExpireDate(String expireDate){
        Integer yr = Integer.valueOf(expireDate.substring(0, 4));
        Integer mth = Integer.valueOf(expireDate.substring(4, 6));
        Integer dy = Integer.valueOf(expireDate.substring(6, 8));
        return Date.newInstance(yr, mth, dy);
    }

}
