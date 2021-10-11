public inherited sharing class HDT_UTL_HandleTechnicalData {

    public ServicePoint__c sp;
    private HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
//NON TOCCARE
    public void handleE154Flow(Map<String, String> mapRequestFields, Order ord){
        system.debug('flusso E154');
        if (!String.isBlank(mapRequestFields.get('IMP_PREV_DIST'))) {
            ord.EstimateAmount__c = Decimal.valueOf(mapRequestFields.get('IMP_PREV_DIST'));
            ord.QuotationType__c = 'Analitico';
        }
        if(!String.isBlank(mapRequestFields.get('DT_MAX_PREV'))){
            if(mapRequestFields.get('DT_MAX_PREV').getChars().size()==8){
                ord.ValidityDateEstimate__c=getExpireDate(mapRequestFields.get('DT_MAX_PREV'));
            }
        }
        if(!String.isBlank(mapRequestFields.get('NUMPREV'))){
            ord.QuotationNumber__c=mapRequestFields.get('NUMPREV');
        }

        //HRAWRM-471
        if(!String.isBlank(mapRequestFields.get('TEMP_ES_PREV'))) {
            ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
        }
    }
//NON TOCCARE


    public void handleE150Flow(Map<String, String> mapRequestFields, Order ord){
        system.debug('flusso E150');
        if (!String.isBlank(mapRequestFields.get('PUNTODISPACCIAMENTO'))) {
            sp.DispatchingPoint__c = mapRequestFields.get('PUNTODISPACCIAMENTO');
        }
        if (!String.isBlank(mapRequestFields.get('TIPO_MISURATORE'))) {
            sp.CorrectorType__c = mapRequestFields.get('TIPO_MISURATORE');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_REGIME_2G'))) {
            sp.RegimeDate2G__c = mapRequestFields.get('DATA_REGIME_2G');
        }
        if (!String.isBlank(mapRequestFields.get('TRATTAMENTO_DT'))) {
            sp.DistributorTreatment__c = mapRequestFields.get('TRATTAMENTO_DT');
        }
        if (!String.isBlank(mapRequestFields.get('K_ATT'))) {
            sp.kActive__c = mapRequestFields.get('K_ATT');
        }
        if (!String.isBlank(mapRequestFields.get('K_REATT'))) {
            sp.kReactive__c = mapRequestFields.get('K_REATT');
        }
        if (!String.isBlank(mapRequestFields.get('K_POT'))) {
            sp.kPower__c = mapRequestFields.get('K_POT');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS_ATTIVA_NEW'))) {
            sp.MeterActiveSN__c = mapRequestFields.get('MATR_MIS_ATTIVA_NEW');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS_REATTIVA_NEW'))) {
            sp.MeterReactiveSN__c = mapRequestFields.get('MATR_MIS_REATTIVA_NEW');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS_POTENZA_NEW'))) {
            sp.MeterPowerSN__c = mapRequestFields.get('MATR_MIS_POTENZA_NEW');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_INST_ATT'))) {
            sp.InstallationDateActive__c = mapRequestFields.get('DATA_INST_ATT');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_INST_REA'))) {
            sp.InstallationDateReactive__c = mapRequestFields.get('DATA_INST_REA');
        }
        if (!String.isBlank(mapRequestFields.get('DATA_INST_POT'))) {
            sp.InstallationDatePower__c = mapRequestFields.get('DATA_INST_POT');
        }
        if (!String.isBlank(mapRequestFields.get('CIFRE_ATTIVA'))) {
            sp.DigitNumberActive__c = mapRequestFields.get('CIFRE_ATTIVA');
        }
        if (!String.isBlank(mapRequestFields.get('CIFRE_REATTIVA'))) {
            sp.DigitNumberReactive__c = mapRequestFields.get('CIFRE_REATTIVA');
        }
        if (!String.isBlank(mapRequestFields.get('CIFRE_POT'))) {
            sp.DigitNumberPower__c = mapRequestFields.get('CIFRE_POT');
        }
        if (!String.isBlank(mapRequestFields.get('GRUPPO_MIS'))) {
            sp.MeterGroup__c = mapRequestFields.get('GRUPPO_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('FORFAIT'))) {
            sp.Forfait__c = mapRequestFields.get('FORFAIT');
        }
        if (!String.isBlank(mapRequestFields.get('CODICE_TARIFFA'))) {
            ord.FareCode__c = mapRequestFields.get('CODICE_TARIFFA');
        }
        if (!String.isBlank(mapRequestFields.get('SERV_TUTELA'))) {
            sp.MarketTypeCode__c = mapRequestFields.get('SERV_TUTELA');
        }
        if (!String.isBlank(mapRequestFields.get('GRUPPO_MIS_DT'))) {
            sp.MeterGroup__c = mapRequestFields.get('GRUPPO_MIS_DT');
        }  

        //HRAWRM-471
        if(!String.isBlank(mapRequestFields.get('TEMP_ES_PREV'))) {
            ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
        }
        
        updateServicePoint();      
    }

    public void handlE351Flow(Map<String, String> mapRequestFields, Order ord){
        system.debug('flusso 351');
        if (!String.isBlank(mapRequestFields.get('TRATTAMENTO_DT'))) {
            sp.DistributorTreatment__c = mapRequestFields.get('TRATTAMENTO_DT');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_MIS'))) {
            ord.MeterSN__c = mapRequestFields.get('MATR_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_MIS'))) {
            sp.MeterDigitNumber__c = mapRequestFields.get('N_CIFRE_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_CONV'))) {
            sp.CorrectorSN__c = mapRequestFields.get('MATR_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_CONV'))) {
            sp.CorrectorDigitNumber__c = mapRequestFields.get('N_CIFRE_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('COEFF_CORRETTIVO'))) {
            sp.CorrectiveCoefficient__c = mapRequestFields.get('COEFF_CORRETTIVO');
        }
        if (!String.isBlank(mapRequestFields.get('RACCOLTA'))) {
            sp.Collection__c = mapRequestFields.get('RACCOLTA');
        }
        if (!String.isBlank(mapRequestFields.get('VOL_ANNUO_SOST'))) {
            sp.AnnualVolumeReplacement__c = mapRequestFields.get('VOL_ANNUO_SOST');
        }
        if (!String.isBlank(mapRequestFields.get('CLASSE_GRUPPO_MIS'))) {
            sp.MeterClass__c = mapRequestFields.get('CLASSE_GRUPPO_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('PRE_CONV'))) {
            sp.CorrectorWithdrawal__c = mapRequestFields.get('PRE_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('GRUPPO_MIS_INT'))) {
            sp.MeterGroup__c = mapRequestFields.get('GRUPPO_MIS_INT');
        }

        //HRAWRM-471
        if(!String.isBlank(mapRequestFields.get('TEMP_ES_PREV'))) {
            ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
        }

        updateServicePoint();
    }



    public void handlE300Flow(Map<String, String> mapRequestFields, Order ord){
        system.debug('flusso 300');
        List<String> bonusData = new List<String>();
        if (!String.isBlank(mapRequestFields.get('MATR_MIS'))) {
            ord.MeterSN__c = mapRequestFields.get('MATR_MIS');
        }
        /*if (!String.isBlank(mapRequestFields.get('TIPO_PDR'))) {
            ord.SupplyType__c = mapRequestFields.get('TIPO_PDR');
        }*/
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_MIS'))) {
            sp.MeterDigitNumber__c = mapRequestFields.get('N_CIFRE_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('CLASSE_GRUPPO_MIS'))) {
            sp.MeterClass__c = mapRequestFields.get('CLASSE_GRUPPO_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('ANNO_FABB_MIS'))) {
            sp.MeterYear__c = mapRequestFields.get('ANNO_FABB_MIS');
        }
        if (!String.isBlank(mapRequestFields.get('SEGN_MIS_AVVIO'))) {
            sp.MeterSignal__c = mapRequestFields.get('SEGN_MIS_AVVIO');
        }
        if (!String.isBlank(mapRequestFields.get('MATR_CONV'))) {
            sp.CorrectorSN__c = mapRequestFields.get('MATR_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('N_CIFRE_CONV'))) {
            sp.CorrectorDigitNumber__c = mapRequestFields.get('N_CIFRE_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('SEGN_CONV'))) {
            sp.CorrectorSignal__c = mapRequestFields.get('SEGN_CONV');
        }
        if (!String.isBlank(mapRequestFields.get('COEFF_CORRETTIVO'))) {
            sp.CorrectiveCoefficient__c = mapRequestFields.get('COEFF_CORRETTIVO');
        }
        if (!String.isBlank(mapRequestFields.get('ACC_MIS'))) {
            sp.MeterAccessible__c = mapRequestFields.get('ACC_MIS');
        }
        /*if (!String.isBlank(mapRequestFields.get('COD_PROF_PREL'))) {
            //Gestire caso CLASSE_PRELIEVO
            //sp.WithdrawalClass__c = mapRequestFields.get('COD_PROF_PREL');
        }*/
        if (!String.isBlank(mapRequestFields.get('COD_REMI'))) {
            ord.RemiCode__c = mapRequestFields.get('COD_REMI');
        }
        if (!String.isBlank(mapRequestFields.get('PRESS_MIS'))) {
            sp.Pressure__c =Decimal.valueOf( mapRequestFields.get('PRESS_MIS'));
        }
        if (!String.isBlank(mapRequestFields.get('MAX_PRELIEVO_ORA'))) {
            sp.MaxHourWithdrawal__c = mapRequestFields.get('MAX_PRELIEVO_ORA');
        }
        if (!String.isBlank(mapRequestFields.get('CONS_ANNUO'))) {
            sp.AnnualConsumption__c = Decimal.valueOf( mapRequestFields.get('CONS_ANNUO'));
        }
        if (!String.isBlank(mapRequestFields.get('DATA_SCAD_DS'))) {
            sp.OrderDueDate__c = mapRequestFields.get('DATA_SCAD_DS');
        }
        if (!String.isBlank(mapRequestFields.get('BONUSGAS'))) {
            bonusData.add(mapRequestFields.get('BONUSGAS'));
        }
        if (!String.isBlank(mapRequestFields.get('BONUS_INIZ'))) {
            bonusData.add(mapRequestFields.get('BONUS_INIZ'));
        }
        if (!String.isBlank(mapRequestFields.get('BONUS_FINE'))) {
            bonusData.add(mapRequestFields.get('BONUS_FINE'));
        }
        if (!String.isBlank(mapRequestFields.get('MESE_RIN'))) {
            sp.RenewalMonth__c = mapRequestFields.get('MESE_RIN');
        }
        if (!String.isBlank(mapRequestFields.get('TIPO_BONUS'))) {
            bonusData.add(mapRequestFields.get('TIPO_BONUS'));
        }
        if (bonusData.size()>0) {
            ord.BonusData__c = String.join(bonusData, ';');
        }

        //HRAWRM-471
        if(!String.isBlank(mapRequestFields.get('TEMP_ES_PREV'))) {
            ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
        }

        updateServicePoint();
    }

    public void handleCompletata(Map<String, String> mapRequestFields){
        if (!String.isBlank(mapRequestFields.get('ANLAGE'))) {
            sp.SAPImplantCode__c = mapRequestFields.get('ANLAGE');
        }
        if (!String.isBlank(mapRequestFields.get('VERTRAG'))) {
            sp.SAPContractCode__c = mapRequestFields.get('VERTRAG');
        }
        if (!String.isBlank(mapRequestFields.get('ANLAGE_ST'))) {
            switch on mapRequestFields.get('ANLAGE_ST'){
                when 'Open', 'Riatt. avviata per morosita'{
                    sp.MeterStatus__c = 'Attivo';
                }
                when 'Impianto chiuso per morosita' {
                    sp.MeterStatus__c = 'Inattivo'; 
                }
                when 'Interr. avviata per morosita' {
                    sp.MeterStatus__c = 'Sospeso';
                }
            }
        }
        sp.Status__c='Impianto compl. in funzione';
        updateServicePoint();
    }

    private static Date getExpireDate(String expireDate){
        Integer yr = Integer.valueOf(expireDate.substring(0, 4));
        Integer mth = Integer.valueOf(expireDate.substring(4, 6));
        Integer dy = Integer.valueOf(expireDate.substring(6, 8));
        return Date.newInstance(yr, mth, dy);
    }

    private void updateServicePoint(){
        try{
            ServicePointSrv.updateRecord(sp);
        }catch(Exception e){
            system.debug('Exception Update ServicePoint');
            throw new HDT_WS_MrrRequest.CustomMessageException('Error on Updating ServicePoint - '+e.getMessage());
        }
    }

}
