public inherited sharing class HDT_UTL_HandleTechnicalData {

    public ServicePoint__c sp;
    private HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();

    private static final List<String> BONUS_KEYS = new List<String>{'BONUSGAS','BONUS_INIZ','BONUS_FINE','TIPO_BONUS'};

    private static final Map<String, Schema.SObjectField> E150_SERVICEPOINT_MAP = new Map<String, Schema.SObjectField>{
        'PUNTODISPACCIAMENTO' => ServicePoint__c.DispatchingPoint__c,
        'TIPO_MISURATORE' => ServicePoint__c.CorrectorType__c,
        'DATA_REGIME_2G' => ServicePoint__c.RegimeDate2G__c,
        'TRATTAMENTO_DT' => ServicePoint__c.DistributorTreatment__c,
        'K_ATT' => ServicePoint__c.kActive__c,
        'K_REATT' => ServicePoint__c.kReactive__c,
        'K_POT' => ServicePoint__c.kPower__c,
        'MATR_MIS_ATTIVA_NEW' => ServicePoint__c.MeterActiveSN__c,
        'MATR_MIS_REATTIVA_NEW' => ServicePoint__c.MeterReactiveSN__c,
        'MATR_MIS_POTENZA_NEW' => ServicePoint__c.MeterPowerSN__c,
        'DATA_INST_ATT' => ServicePoint__c.InstallationDateActive__c,
        'DATA_INST_REA' => ServicePoint__c.InstallationDateReactive__c,
        'DATA_INST_POT' => ServicePoint__c.InstallationDatePower__c,
        'CIFRE_ATTIVA' => ServicePoint__c.DigitNumberActive__c,
        'CIFRE_REATTIVA' => ServicePoint__c.DigitNumberReactive__c,
        'CIFRE_POT' => ServicePoint__c.DigitNumberPower__c,
        'GRUPPO_MIS' => ServicePoint__c.MeterGroup__c,
        'FORFAIT' => ServicePoint__c.Forfait__c,
        'SERV_TUTELA' => ServicePoint__c.MarketTypeCode__c,
        'GRUPPO_MIS_DT' => ServicePoint__c.MeterGroup__c
    };

    private static final Map<String, Schema.SObjectField> E351_SERVICEPOINT_MAP = new Map<String, Schema.SObjectField>{
        'TRATTAMENTO_DT' => ServicePoint__c.DistributorTreatment__c,
        'N_CIFRE_MIS' => ServicePoint__c.MeterDigitNumber__c,
        'MATR_CONV' => ServicePoint__c.CorrectorSN__c,
        'N_CIFRE_CONV' => ServicePoint__c.CorrectorDigitNumber__c,
        'COEFF_CORRETTIVO' => ServicePoint__c.CorrectiveCoefficient__c,
        'RACCOLTA' => ServicePoint__c.Collection__c,
        'VOL_ANNUO_SOST' => ServicePoint__c.AnnualVolumeReplacement__c,
        'CLASSE_GRUPPO_MIS' => ServicePoint__c.MeterClass__c,
        'PRE_CONV' => ServicePoint__c.CorrectorWithdrawal__c,
        'GRUPPO_MIS_INT' => ServicePoint__c.MeterGroup__c
    };

    Map<String, Schema.SObjectField> E300_SERVICEPOINT_MAP = new Map<String, Schema.SObjectField>{
        'N_CIFRE_MIS' => ServicePoint__c.MeterDigitNumber__c,
        'CLASSE_GRUPPO_MIS' => ServicePoint__c.MeterClass__c,
        'ANNO_FABB_MIS' => ServicePoint__c.MeterYear__c,
        'SEGN_MIS_AVVIO' => ServicePoint__c.MeterSignal__c,
        'MATR_CONV' => ServicePoint__c.CorrectorSN__c,
        'N_CIFRE_CONV' => ServicePoint__c.CorrectorDigitNumber__c,
        'SEGN_CONV' => ServicePoint__c.CorrectorSignal__c,
        'COEFF_CORRETTIVO' => ServicePoint__c.CorrectiveCoefficient__c,
        'ACC_MIS' => ServicePoint__c.MeterAccessible__c,
        'PRESS_MIS' => ServicePoint__c.Pressure__c,
        'MAX_PRELIEVO_ORA' => ServicePoint__c.MaxHourWithdrawal__c,
        'CONS_ANNUO' => ServicePoint__c.AnnualConsumption__c,
        'DATA_SCAD_DS' => ServicePoint__c.OrderDueDate__c,
        'MESE_RIN' => ServicePoint__c.RenewalMonth__c
    };

//NON TOCCARE
    public void handleE154Flow(Map<String, String> mapRequestFields, Order ord){
        System.debug(LoggingLevel.DEBUG, 'flusso E154');
        if (!String.isBlank(mapRequestFields.get('IMP_PREV_DIST'))) {
            HDT_LC_CalculateEstimatedCost calculateAmount = new HDT_LC_CalculateEstimatedCost();
            ord.EstimateAmount__c = Decimal.valueOf(mapRequestFields.get('IMP_PREV_DIST'));
            Map<String,Decimal> amounts = calculateAmount.getAmounts(ord.SupplyType__c, ord.EstimateAmount__c);
            ord.AdministrativeBurden__c = amounts.get('fixedAmount');
            ord.VariableAmount__c = amounts.get('variableAmount');
            ord.QuotationType__c = 'Analitico';
        }
        if(!String.isBlank(mapRequestFields.get('DT_MAX_PREV'))){
            try
            {
                ord.ValidityDateEstimate__c = Date.valueOf(mapRequestFields.get('DT_MAX_PREV'));
            }
            catch(Exception e)
            {
                System.debug(LoggingLevel.DEBUG, 'DT_MAX_PREV Exception -> ' + e.getMessage());
            }
            if(ord.ValidityDateEstimate__c == null && mapRequestFields.get('DT_MAX_PREV').getChars().size()==8){
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
        System.debug(LoggingLevel.DEBUG, 'flusso E150');

        mapServicePointData(mapRequestFields, E150_SERVICEPOINT_MAP);
        
        if (!String.isBlank(mapRequestFields.get('CODICE_TARIFFA'))) {
            ord.FareCode__c = mapRequestFields.get('CODICE_TARIFFA');
        }

        //HRAWRM-471
        if(!String.isBlank(mapRequestFields.get('TEMP_ES_PREV'))) {
            ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
        }
        
        updateServicePoint();      
    }

    public void handlE351Flow(Map<String, String> mapRequestFields, Order ord){
        System.debug(LoggingLevel.DEBUG, 'flusso 351');

        mapServicePointData(mapRequestFields, E351_SERVICEPOINT_MAP);
        
        if (!String.isBlank(mapRequestFields.get('MATR_MIS'))) {
            ord.MeterSN__c = mapRequestFields.get('MATR_MIS');
        }

        //HRAWRM-471
        if(!String.isBlank(mapRequestFields.get('TEMP_ES_PREV'))) {
            ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
        }

        updateServicePoint();
    }

    public void handlE300Flow(Map<String, String> mapRequestFields, Order ord){
        System.debug(LoggingLevel.DEBUG, 'flusso 300');

        mapServicePointData(mapRequestFields, E300_SERVICEPOINT_MAP);

        if (!String.isBlank(mapRequestFields.get('MATR_MIS'))) {
            ord.MeterSN__c = mapRequestFields.get('MATR_MIS');
        }
        /*if (!String.isBlank(mapRequestFields.get('TIPO_PDR'))) {
            ord.SupplyType__c = mapRequestFields.get('TIPO_PDR');
        }*/
        /*if (!String.isBlank(mapRequestFields.get('COD_PROF_PREL'))) {
            //Gestire caso CLASSE_PRELIEVO
            //sp.WithdrawalClass__c = mapRequestFields.get('COD_PROF_PREL');
        }*/
        if (!String.isBlank(mapRequestFields.get('COD_REMI'))) {
            ord.RemiCode__c = mapRequestFields.get('COD_REMI');
        }

        List<String> bonusData = getBonusData(mapRequestFields);
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
        if(String.isNotBlank(mapRequestFields.get('POD'))){
            sp.Name= mapRequestFields.get('POD');
            sp.ServicePointCode__c = mapRequestFields.get('POD');
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

        //Modifica HRADRT_GV 31/01/2022 - Inizio
        if (!String.isBlank(mapRequestFields.get('NuovoAccount'))) {
            sp.Account__c = mapRequestFields.get('NuovoAccount');
        }
        //Modifica HRADRT_GV 31/01/2022 - Fine

        if (String.isNotBlank(mapRequestFields.get('supplyType')))
        {
            sp.SupplyType__c = mapRequestFields.get('supplyType');
        }
        if (String.isNotBlank(mapRequestFields.get('implantType')))
        {
            sp.ImplantType__c = mapRequestFields.get('implantType');
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

    /**
    * @description Reading bonus data from request
    * @author gabriele.rota@webresults.it | 2021-10-22 
    * @param mapRequestFields 
    **/
    private static List<String> getBonusData(Map<String, String> mapRequestFields) {
        List<String> bonusData = new List<String>();
        for (String bonusKey:BONUS_KEYS) {
            if (String.isNotBlank(mapRequestFields.get(bonusKey))) {
                bonusData.add(mapRequestFields.get(bonusKey));
            }
        }
        return bonusData;
    }

    /**
    * @description Mapping request to Service Point
    * @author gabriele.rota@webresults.it | 2021-10-22 
    * @param mapRequestFields 
    * @param spMap 
    **/
    private void mapServicePointData(Map<String, String> mapRequestFields, Map<String, Schema.SObjectField> spMap) {
        for (String key:spMap.keySet()) {
            String keyValue = mapRequestFields.get(key);
            Schema.SObjectField field = spMap.get(key);
            Boolean isNumber = (field.getDescribe().getType()==Schema.DisplayType.Double);

            if (String.isNotBlank(keyValue)) {
                if (isNumber) {
                    sp.put(field, Decimal.valueOf(keyValue));
                }
                else {
                    sp.put(field, keyValue);
                }
            }
        }
    }

    private void updateServicePoint(){
        try{
            ServicePointSrv.updateRecord(sp);
        }catch(Exception e){
            throw new HDT_WS_MrrRequest.CustomMessageException('Error on Updating ServicePoint - '+e.getMessage());
        }
    }

}
