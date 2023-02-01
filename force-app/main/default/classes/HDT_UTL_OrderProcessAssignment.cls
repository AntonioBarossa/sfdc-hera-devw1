/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 08/01/2021
 * @description HDT_UTL_OrderProcessAssignment.cls - Class that holds logic for assigning order processes
 * @history Keltin Mesonjesi – 23/06/2021 – Created class
 */
public inherited sharing class HDT_UTL_OrderProcessAssignment {

    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_SRV_ActivityCustom activityCustomSrv = new HDT_SRV_ActivityCustom();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_QR_SaleServiceItem saleItQr = new HDT_QR_SaleServiceItem();
    private static Order orderRecived = null;


    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description HDT_WRP_Process
     */
    public class HDT_WRP_Process {
        /**
         * @description processType
         */
        @AuraEnabled
        public String processType {get; set;}

        /**
         * @description processType
         */
        @AuraEnabled
        public String recordType {get; set;}

        /**
         * @description processType
         */
        @AuraEnabled
        public String processCode {get; set;}
        Set<String> meterStatus {get; set;}
        Set<String> marketOrigin {get; set;}
        String plugPresence {get; set;} //allacio
        Boolean isOwnAccount {get; set;}
        Boolean isChangeUse {get; set;}
        Boolean isSwitchInRipristinatorio {get; set;}
        Boolean isAttivazioneConModifica {get; set;}

        /**
         * @description processType
         */
        @AuraEnabled
        public String commodity {get; set;}
        Boolean isAmendmentAllowed {get; set;}
        Boolean isSwitchOut {get; set;} //only for winback case is true
        Boolean isReseller {get; set;}

        /**
         * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
         * @description HDT_WRP_Process
         * @param processType
         * @param recordType
         * @param processCode
         * @param meterStatus
         * @param marketOrigin
         * @param plugPresence
         * @param isOwnAccount
         * @param isChangeUse
         * @param isSwitchInRipristinatorio
         * @param isAttivazioneConModifica
         * @param commodity
         * @param isAmendmentAllowed
         * @param isSwitchOut
         * @param isReseller
         */
        public HDT_WRP_Process(
            String processType,
            String recordType,
            String processCode,
            Set<String> meterStatus,
            Set<String> marketOrigin,
            String plugPresence,
            Boolean isOwnAccount,
            Boolean isChangeUse,
            Boolean isSwitchInRipristinatorio,
            Boolean isAttivazioneConModifica,
            String commodity,
            Boolean isAmendmentAllowed,
            Boolean isSwitchOut,
            Boolean isReseller
        ) {
            ///////
            this.processType = processType;
            this.recordType = recordType;
            this.processCode = processCode;
            this.meterStatus = meterStatus;
            this.marketOrigin = marketOrigin;
            this.plugPresence = plugPresence;
            this.isOwnAccount = isOwnAccount;
            this.isChangeUse = isChangeUse;
            this.isSwitchInRipristinatorio = isSwitchInRipristinatorio;
            this.isAttivazioneConModifica = isAttivazioneConModifica;
            this.commodity = commodity;
            this.isAmendmentAllowed = isAmendmentAllowed;
            this.isSwitchOut = isSwitchOut;
            this.isReseller = isReseller;
        }
    }

    /**
     * @description initProcesses
     * @return List<ProcessMatrix__c>
     */
    public static List<ProcessMatrix__c> initProcesses(){

        return [SELECT CasualCode__c,
            ProcessName__c,
            RecordTypeName__c,
            Commodity__c,
            ContractStatus__c,
            ExistActivityDatiDiscordantiNew__c,
            ExistActivitySwitchRipristinatorioNew__c,
            IsAmendment__c,
            IsChangeUseNew__c,
            isOwnAccountNew__c,
            IsResellerNew__c,
            IsSTGNew__c,
            MarketOrigin__c,
            OngoingSwitchOutNew__c,
            PlugPresence__c,
            PowerChange__c
            FROM ProcessMatrix__c 
            WITH SECURITY_ENFORCED];
    }

    private static String getTempNewActivationCode(){
        if(orderRecived.VoltageLevel__c=='MT' || orderRecived.PowerAvailable__c>40){
            return 'PN1';
        }
        return 'E02';
    }

    private static String getProcessCodeReseller(){
        if(orderRecived.ServicePoint__r.RecordType.DeveloperName=='HDT_RT_Ele'){
            return 'SE1';
        }
        return 'SG1';
    }
    /**
     * @Author NTTData
     * @Description: Check if is an Amendment Quote or if is an Order with only Opzioni TARI
     * 
     **/
    private static Boolean checkAmendmentOrder(Order ord){
        if(ord.SBQQ__Quote__r.AmendmentAllowed__c) return true;
        if(String.isNotBlank(ord.ServicePoint__r.CommoditySector__c) && 'Ambiente'.equalsIgnoreCase(ord.ServicePoint__r.CommoditySector__c)){
            List<OrderItem> items = orderItemQr.getMainItem(ord.id);
            if(!items.isEmpty()){
                for(OrderItem oi : items){
                    //product Family è sempre valorizzato
                    if(String.isNotBlank(oi.Product2.Family) && !'Opzioni TARI'.equalsIgnoreCase(oi.Product2.Family	)){
                        return false;
                    }
                }
                return true;
            }
            return false; 
        }
        return false;
    }

    private static Boolean isRemoveSubscriptions(Order ord){
        if(String.isNotBlank(ord.ServicePoint__r.CommoditySector__c) && 'Ambiente'.equalsIgnoreCase(ord.ServicePoint__r.CommoditySector__c)){
            List<OrderItem> items = orderItemQr.getMainItem(ord.id);
            if(!items.isEmpty()){
                for(OrderItem oi : items){
                    //product Family è sempre valorizzato
                    if(oi.Quantity != null && oi.Quantity <= 0){
                        return true;
                    }
                }
                return false;
            }
            return false; 
        }
        return false;
    }


    /**
     * @description getAvailableProcesses
     * @param ord
     * @return List<ProcessMatrix__c>
     */
    public static List<ProcessMatrix__c> getAvailableProcesses(Order ord){
        orderRecived=ord;
        List<ProcessMatrix__c> allProcesses = initProcesses();
        List<ProcessMatrix__c> availableProcesses = new List<ProcessMatrix__c>();
        List<SObject> toUpdateList = new List<SObject>();

        /* Calcolo Parametri Processo */
        String sapContractStatus = ord.ServicePoint__r.SapContractStatus__c != null ? ord.ServicePoint__r.SapContractStatus__c : 'null';
        String isStg = ord.isSTG__c ? 'Si' : 'No';
        String marketOrigin = ord.MarketOrigin__c;
        Boolean plugPresence = ord.ServicePoint__r.PlugPresence__c == null ? true : (ord.ServicePoint__r.PlugPresence__c.containsIgnoreCase('Si'));
        String isOwnAccount = ord.AccountId == ord.ServicePoint__r.Account__c ? 'Si' : 'No';
        String isReseller = ord.ServicePoint__r.isReseller__c ? 'Si' : 'No';
        String isChangeUse = ord.SBQQ__Quote__r.AllowChangeUse__c ? 'Si' : 'No';
        String isSwitchInRipr = isSwitchInRipristinatorio(ord) ? 'Si' : 'No';
        String datiDiscordanti = 'No';
        String isWinback = ord.IsWinback__c ? 'Si' : 'No';
        Boolean isAmendmentAllowed = checkAmendmentOrder(ord);
        Boolean isPowerChange = isAttivazioneConModifica(ord);
		String commodity = ord.ServicePoint__r.CommoditySector__c;
        Boolean isRemoveSubscriptions = isRemoveSubscriptions(ord);
        
        for (ProcessMatrix__c process : allProcesses){
            /* 
            System.debug( process.ProcessName__c + ': ');
            System.debug( 'ContractStatus__c: expected \'' +                        process.ContractStatus__c + '\', effective \'' + sapContractStatus +'\'' );
            System.debug( 'isSTGNew__c: expected \'' +                              process.isSTGNew__c + '\', effective \'' + isStg +'\'' );
            System.debug( 'marketOrigin__c: expected \'' +                          process.MarketOrigin__c + '\', effective \'' + marketOrigin +'\'' );
            System.debug( 'plugPresence__c: expected \'' +                          process.PlugPresence__c + '\', effective \'' + plugPresence +'\'' );
            System.debug( 'IsOwnAccountNew__c: expected \'' +                       process.IsOwnAccountNew__c + '\', effective \'' + isOwnAccount +'\'' );
            System.debug( 'isResellerNew__c: expected \'' +                         process.IsResellerNew__c + '\', effective \'' + isReseller +'\'' );
            System.debug( 'isChangeUseNew__c: expected \'' +                        process.IsChangeUseNew__c + '\', effective \'' + isChangeUse +'\'' );
            System.debug( 'ExistActivitySwitchRipristinatorioNew__c: expected \'' + process.ExistActivitySwitchRipristinatorioNew__c + '\', effective \'' + isSwitchInRipr +'\'' );
            System.debug( 'OngoingSwitchOutNew__c: expected \'' +                   process.OngoingSwitchOutNew__c + '\', effective \'' + isWinback +'\'' );
            System.debug( 'PowerChange__c: expected \'' +                           process.PowerChange__c + '\', effective \'' + isPowerChange +'\'' );
            System.debug( 'commodity__c: expected \'' +                             process.Commodity__c + '\', effective \'' + commodity +'\'' );
            System.debug( 'IsAmendment__c: expected \'' +                           process.IsAmendment__c + '\', effective \'' + isAmendmentAllowed +'\'' ); 
            */
            if(ord.RateCategory__c == 'APSCARPRO0' && process.ProcessName__c == 'Voltura - Subentro Scarico produttivo')
            {
                availableProcesses.add(process);
            }
            else if( process.ProcessName__c == 'Voltura - Subentro Scarico produttivo' && 'Marche Multiservizi S.p.A'.equalsIgnoreCase(ord.SalesCompany__c) ){
                continue;
            }
            else if(
                    /* Controllo Stato Contratto */
                    (process.ContractStatus__c.containsIgnoreCase(sapContractStatus))
                    /* Controllo IsStg */
                &&  (process.IsSTGNew__c.containsIgnoreCase(isStg) || process.isSTGNew__c.equalsIgnoreCase('All'))
                    /* Controllo Market Origin */
                &&  (process.MarketOrigin__c.contains(marketOrigin))
                    /* Controllo Presenza Allaccio */
                &&  (process.PlugPresence__c == plugPresence || process.commodity__c.containsIgnoreCase('Gas'))
                    /* Controllo Stesso Account */
                &&  (process.IsOwnAccountNew__c.equalsIgnoreCase(isOwnAccount) || process.isOwnAccountNew__c.equalsIgnoreCase('All') || (process.processName__c.containsIgnoreCase('Voltura Ele') && ord.ServicePoint__r.Account__c == null))
                    /* Controllo Reseller */
                &&  (process.IsResellerNew__c.containsIgnoreCase(isReseller) || process.isResellerNew__c.equalsIgnoreCase('All'))
                    /* Controllo Cambio Uso */
                &&  (process.IsChangeUseNew__c.containsIgnoreCase(isChangeUse) || process.isChangeUseNew__c.equalsIgnoreCase('All'))
                    /* Controllo Switch Ripristinatorio */
                &&  (process.ExistActivitySwitchRipristinatorioNew__c.containsIgnoreCase(isSwitchInRipr) || process.ExistActivitySwitchRipristinatorioNew__c.equalsIgnoreCase('All'))
                    /* Controllo Dati Discordanti */
                &&  (process.ExistActivityDatiDiscordantiNew__c.containsIgnoreCase(datiDiscordanti) || process.ExistActivityDatiDiscordantiNew__c.equalsIgnoreCase('All'))
                    /* Controllo WinBack */
                &&  (process.OngoingSwitchOutNew__c.containsIgnoreCase(isWinback) || process.OngoingSwitchOutNew__c.equalsIgnoreCase('All'))
                    /* Controllo Variazione Potenza */
                &&  (process.PowerChange__c == isPowerChange)
                    /* Controllo Commodity */
                &&  ((process.Commodity__c.containsIgnoreCase(commodity) || process.Commodity__c == null))
                    /* Controllo Amendment */
                &&  (process.IsAmendment__c == isAmendmentAllowed)
            ) {
                if(process.RecordTypeName__c.equalsIgnoreCase('HDT_RT_TemporaneaNuovaAtt'))
                {
                    process.CasualCode__c = getTempNewActivationCode();
                }
                if(process.RecordTypeName__c.equalsIgnoreCase('HDT_RT_SubentroAmbiente') && ord.ServicePoint__r.RateCategory__c != null && ord.RateCategory__c != null && ord.ServicePoint__r.RateCategory__c.containsIgnoreCase('TATUDRES01') && ord.ServicePoint__r.RateCategory__c != ord.RateCategory__c )
                {
                    process.CasualCode__c = 'RI6';
                }
               //escludo il processo di modifica tariffa se si sta eseguendo una rimozione sconto
                if(!process.RecordTypeName__c.equalsIgnoreCase('HDT_RT_AgevolazioniAmbiente') || (process.RecordTypeName__c.equalsIgnoreCase('HDT_RT_AgevolazioniAmbiente') && !isRemoveSubscriptions)){
                    availableProcesses.add(process);
                }
            }
        }

        /* update toUpdateList; */
        return utilityOrderProcessAssignment(availableProcesses);
    }

    private static boolean isScontiBonus(Order ord){
        system.debug('entra sconti');
        List<OrderItem> items = orderItemQr.getMainItem(ord.id);
        Set<String> familySconto = getFamilySconto();
        if(!items.isEmpty()){
            system.debug('entra sconti2');
            OrderItem itm =  items[0];
            for(String family : familySconto)
            {
                if(family.equalsIgnoreCase(itm.Product2.Family))
                {
                    return true;
                }
            }
        }
        return false;

    }
    
    /**
     * @description getAvailableProcesses
     * @param ord
     * @return Boolean
     */
    public static Boolean isCambioOfferta(Order ord){

        system.debug('HDT_UTL_OrderProcessAssignment.isCambioOfferta START');

        List<OrderItem> offertaCommerciale = orderItemQr.getRecordsByOrderIdFilteredPdrPod(ord.Id);

        system.debug('HDT_UTL_OrderProcessAssignment.isCambioOfferta offertaCommerciale: ' + offertaCommerciale);
        system.debug('HDT_UTL_OrderProcessAssignment.isCambioOfferta ContractReference__c: ' + ord.SBQQ__Quote__r.ContractReference__c);

        Boolean result = !offertaCommerciale.isEmpty() && !ord.SBQQ__Quote__r.AllowChangeUse__c && ord.SBQQ__Quote__r.ContractReference__c != null && !ord.SBQQ__Quote__r.AmendmentAllowed__c;

        system.debug('HDT_UTL_OrderProcessAssignment.isCambioOfferta RESULT: ' + result);
        
        system.debug('HDT_UTL_OrderProcessAssignment.isCambioOfferta END');

        return result;
    }

    public static Set<String> getFamilySconto(){
        List<AggregateResult> lgr = [select ProductFamily__c fam  from Service26Config__c WITH SECURITY_ENFORCED  group by ProductFamily__c  ];
        Set<String> famils = new Set<String>();
        for(AggregateResult ag : lgr){
            if(String.isNotBlank((String) ag.get('fam')))
                famils.add((String) ag.get('fam'));
        }
        famils.add('Promozione');
        //aggiunto per gestire il link degli order in caso di Amend di aggiunta agevolazione
        famils.add('Opzioni TARI');
        return famils;
    }

    public static Boolean isSwitchInRipristinatorio(Order ord){
        
        Boolean result = false;

        List<wrts_prcgvr__Activity__c> activityList = new List<wrts_prcgvr__Activity__c>();
        
        if (ord.ServicePoint__c != null) {
            activityList = HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePointNotStatus('Gestione Switch in Ripristinatorio', 'Completed', ord.AccountId, ord.ServicePoint__r.ServicePointCode__c);
        }

        system.debug('HDT_UTL_OrderProcessAssignment.isSwitchInRipristinatorio activityList: ' + activityList);
        system.debug('HDT_UTL_OrderProcessAssignment.isSwitchInRipristinatorio AmendmentAllowed__c: ' + ord.SBQQ__Quote__r.AmendmentAllowed__c);
        system.debug('HDT_UTL_OrderProcessAssignment.isSwitchInRipristinatorio AllowChangeUse__c: ' + ord.SBQQ__Quote__r.AllowChangeUse__c);

        if (!activityList.isEmpty() 
            && !ord.SBQQ__Quote__r.AmendmentAllowed__c 
            && !ord.SBQQ__Quote__r.AllowChangeUse__c
            /*&& !isCambioOfferta(ord)*/) {
                result = true;
        }

        return result;
    }

    /**
     * @description getAvailableProcesses
     * @param ord
     */
    public static void switchInRipristinatorioAction(Order ord) {

        system.debug('HDT_UTL_OrderProcessAssignment.switchInRipristinatorioAction START');
        List<wrts_prcgvr__Activity__c> activityList = HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePointNotStatus('Gestione Switch in Ripristinatorio', 'Completed', ord.AccountId, ord.ServicePoint__r.ServicePointCode__c);

        //List<wrts_prcgvr__Activity__c> activityList = HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePoint('Gestione Switch in Ripristinatorio', 'Creata', ord.AccountId, ord.ServicePoint__r.ServicePointCode__c);

        activityCustomSrv.updateRecord(new wrts_prcgvr__Activity__c(
            Id = activityList[0].Id,
            Order__c = ord.Id
        ));

        system.debug('HDT_UTL_OrderProcessAssignment.switchInRipristinatorioAction END');
    }

    /**
     * @description isAttivazioneConModifica
     * @param ord
     * @return Boolean
     */
    public static Boolean isAttivazioneConModifica(Order ord){
        Boolean result = false;

        system.debug('isAttivazioneConModifica ord.ServicePoint__r.RecordType.DeveloperName ' + ord.ServicePoint__r.RecordType.DeveloperName);
        system.debug('isAttivazioneConModifica ord.PowerRequested__c ' + ord.PowerRequested__c);
        system.debug('isAttivazioneConModifica ord.PowerCommitted__c ' + ord.PowerCommitted__c);
      //  System.debug('isAttivazioneConModifica ord.RecordType.DeveloperName' + ord.RecordType.DeveloperName);

        if (ord.ServicePoint__c != null 
            && ord.ServicePoint__r.RecordType.DeveloperName == 'HDT_RT_Ele' 
            && ord.PowerRequested__c != null 
            && ord.PowerRequested__c != ord.PowerCommitted__c ) {
                result = true;
        }

        return result;
    }

    /**
     * @description fieldsTransition
     * @param sale
     * @return String
     */
    @AuraEnabled
    public static String fieldsTransition(Sale__c sale){
        // ServicePoint__c serpoint = new ServicePoint__c();
        HDT_QR_ServicePoint srQr = new HDT_QR_ServicePoint();
        Sale__c sal = saleQr.getRecordById(sale.id,'id,isTransition__c,Account__r.customerMarking__c');
        Sale__c s = new Sale__c(Id=sale.Id);
        boolean check = false;
        String res = '';
        List<String> listRes = new List<String>();
        List<SaleServiceItem__c> transitionlist =saleItQr.getRecordsBySaleIdFilter(sale.id);
        Set<String> energySet = new Set<String>{'Energia Elettrica', 'Gas'};
        Set<String> nonEnergySet = new Set<String>{'Acqua', 'Ambiente'};
        Boolean isMms = sal.Account__r.customerMarking__c.containsIgnoreCase('MMS');
        Boolean checkEnergy = false;
        Boolean checkNonEnergy = true;
        if(sal.isTransition__c){
                //Map<String,
            // String sub = 'Subentro';
            boolean r = false;
            for(SaleServiceItem__c ser :transitionlist ){
                if(isMms)
                {
                    if(energySet.contains(ser.ServicePoint__r.CommoditySector__c))
                    {
                        checkEnergy = true;
                    }
                    else if(nonEnergySet.contains(ser.ServicePoint__r.CommoditySector__c))
                    {
                        checkNonEnergy = true;
                    }
                    if(checkEnergy && checkNonEnergy)
                    {
                        return 'MmsMisto';
                    }
                }	
                if((ser.ServicePoint__r.PlugPresence__c== 'NO')||(ser.ServicePoint__r.PowerRequested__c != null && (ser.ServicePoint__r.PowerRequested__c!= ser.ServicePoint__r.PowerContractual__c))){
                //Sale__c s = new Sale__c(Id=sale.Id);
                    s.isTransition__c=true;
                    check = true;
                    listRes.add(ser.ServicePoint__r.ServicePointCode__c);
                }
                if(ser.ServicePoint__r.CommoditySector__c == 'Gas' && ser.ServicePoint__r.MeterStatus__c != 'Attivo'){
                    r = true;
                }
            }
            if(check){
                saleSrv.updateRecord(s);
            }
            res = String.join(listRes,',');
            /**@frpanico 2022-12-14 nel caso di Service Point non innescabile per transitorio e punto gas innescabile a transitorio
             * Verrebbe sovrascritto la stringa res perdendo traccia della non innescabilita' del punto
             */
            if(r && (res == null || String.isBlank(res))){
                res = 'Subentro';
            }
        }
        if(res == null || res == '' || res == 'Subentro'){
            List<String> spListId = new List<String>();
            for(SaleServiceItem__c ser :transitionlist ){
                if(ser.ServicePoint__r.CommoditySector__c == 'Gas'){
                    spListId.add(ser.ServicePoint__c);
                }
                if(isMms)
                {
                    if(energySet.contains(ser.ServicePoint__r.CommoditySector__c))
                    {
                        checkEnergy = true;
                    }
                    else if(nonEnergySet.contains(ser.ServicePoint__r.CommoditySector__c))
                    {
                        checkNonEnergy = true;
                    }
                    if(checkEnergy && checkNonEnergy)
                    {
                        return 'MmsMisto';
                    }
                } 
            }
            List<ServicePoint__c> spList = srQr.getRecordByIdList(spListId,'id,CommoditySector__c,SupplyCity__c,distributor__r.code__c');
            Set<String> comuni = new set<String>(); 
            for(ServicePoint__c sp : spList){
                comuni.add(sp.SupplyCity__c.toUpperCase());
            }

            Map<String,String> serviceSocieta = HDT_UTL_Sales.getAgentNameAndCodeList(spList,sal.Account__r.customerMarking__c);
            Set<String> companies = new Set<String>();
            //String company = serviceSocieta.get(sr.id); //-> passare al nostro metodo
            
            for(ServicePoint__c sr :spList){
                companies.add(serviceSocieta.get(sr.id));
            }

            // chiamare metodo per calcolo remicode/vatNumber
            Map<String, MatriceRemiCode__c> remiCodeMap = HDT_UTL_OrderProcess.calculateRemiCodeVatNumberServicePoint(comuni, companies);

            if(!remiCodeMap.isEmpty()){
                for(ServicePoint__c sr :spList){
                    if(String.isNotBlank(remiCodeMap.get(sr.SupplyCity__c + '-' + serviceSocieta.get(sr.Id)).RemiCode__c)){
                        sr.RemiCode__c = remiCodeMap.get(sr.SupplyCity__c + '-' + serviceSocieta.get(sr.Id)).RemiCode__c;
                    }
                    else{
                        res += '_Remi';            
                    }
                    if(String.isNotBlank(sr.VATNumberUdb__c = remiCodeMap.get(sr.SupplyCity__c + '-' + serviceSocieta.get(sr.Id)).VATNumberUdb__c)){
                        sr.VATNumberUdb__c = remiCodeMap.get(sr.SupplyCity__c + '-' + serviceSocieta.get(sr.Id)).VATNumberUdb__c;                    
                    }
                    else{
                        sr.VATNumberUdb__c = '02060500390';        
                    }
                }
            }

            HDT_UTL_DatabaseService.updateSObject(spList);
        }
        //     Map<String,HDT_WRP_RemiUbd> mapRemiCode = new Map<String,HDT_WRP_RemiUbd>();
        //     Map<String,String> mapRemi = new Map<String,String>();
        //     Set<String> comuniToUdb = new set<String>(); 
        //     List<MatriceRemiCode__c> remiList = HDT_QR_MatriceRemiCode.getAllRemiConfiguration();
        //     for(MatriceRemiCode__c m : remiList){
        //         if(mapRemi.get(m.Comune__c.toUpperCase()) == null){
        //             mapRemi.put(m.Comune__c.toUpperCase(),m.RemiCode__c);
        //         }
        //     }

        //     for(ServicePoint__c sr :spList){
        //        /* String remi = '';
        //         if(mapRemi.get(sr.SupplyCity__c.toUpperCase()) != null){
        //             remi = mapRemi.get(sr.SupplyCity__c.toUpperCase());
        //             sr.RemiCode__c = remi;
        //         }
        //         else{
        //             res += '_Remi';
        //         }*/
        //         comuniToUdb.add(sr.SupplyCity__c);
        //         /*if(mapRemiCode.get(remi + '_' + sr.SupplyCity__c.toUpperCase() + '_' + serviceSocieta.get(sr.id)) != null){
        //             HDT_WRP_RemiUbd wrp = mapRemiCode.get(remi + '_' + sr.SupplyCity__c.toUpperCase() + '_' + serviceSocieta.get(sr.id));
        //            // sr.RemiCode__c = wrp.remiCode;
        //             sr.VATNumberUdb__c = wrp.vatUbd;
        //             system.debug(wrp);
        //             system.debug('SP to Update '+sr.VATNumberUdb__c);
        //         }
        //         else{
        //             sr.VATNumberUdb__c = '02060500390';
        //            // res += '_Remi';
        //         }*/
        //     }
        //     List<MatriceRemiCode__c> partitaUdbList = HDT_QR_MatriceRemiCode.getAllPartitaUdbConfiguration(comuniToUdb);
            
        //     for(MatriceRemiCode__c m : partitaUdbList){
        //         //mapRemiCode.put(m.Comune__c + '_' + m.SalesCompany__c, m.RemiCode__c);
        //         HDT_WRP_RemiUbd wrp = new HDT_WRP_RemiUbd(m.RemiCode__c, m.VATNumberUdb__c);
        //         mapRemiCode.put(m.RemiCode__c.toUpperCase() + '_' + m.Comune__c.toUpperCase() + '_' + m.SalesCompany__c, wrp);
        //     }

        //     Map<String,String> serviceSocieta = HDT_UTL_Sales.getAgentNameAndCodeList(spList,sal.Account__r.customerMarking__c);
        //     for(ServicePoint__c sr :spList){
        //         String remi = '';
        //         if(mapRemi.get(sr.SupplyCity__c.toUpperCase()) != null){
        //             remi = mapRemi.get(sr.SupplyCity__c.toUpperCase());
        //             sr.RemiCode__c = remi;
        //         }
        //         else{
        //             res += '_Remi';
        //         }
        //         if(mapRemiCode.get(remi + '_' + sr.SupplyCity__c.toUpperCase() + '_' + serviceSocieta.get(sr.id)) != null){
        //             HDT_WRP_RemiUbd wrp = mapRemiCode.get(remi + '_' + sr.SupplyCity__c.toUpperCase() + '_' + serviceSocieta.get(sr.id));
        //            // sr.RemiCode__c = wrp.remiCode;
        //             sr.VATNumberUdb__c = wrp.vatUbd;
        //             system.debug(wrp);
        //             system.debug('SP to Update '+sr.VATNumberUdb__c);
        //         }
        //         else{
        //             sr.VATNumberUdb__c = '02060500390';
        //            // res += '_Remi';
        //         }
        //     }
        //    // if(res != '_Remi' && res !='Subentro_Remi'){
        //         servicePointSrv.updateRecordRemiCode(spList);
        //    // }
        //}
        return res;
    }

    /**
     * @description fieldsTransition
     */
    private class HDT_WRP_RemiUbd{
        /**
        * @description remiCode
        */
        public String remiCode {get;set;}

        /**
        * @description vatUbd
        */
        public String vatUbd {get;set;}

        /**
        * @description HDT_WRP_RemiUbd
        * @param remiCode
        * @param vatUbd
        */
        public HDT_WRP_RemiUbd(String remiCode, String vatUbd){
            this.remiCode=remiCode;
            this.vatUbd=vatUbd;
        }
    }

   /**
   * @description filtra la lista lProcess in base al CustomSetting HDT_Process_Sale_Partner_Community__c 
   * per aggiungere un processo alla lista inserire un nuovo campo boolean nel CustomSetting HDT_Process_Sale_Partner_Community__c,
   * la label del campo deve essere uguale al nome del processo e gli spazzi devono essere sostituiti dal carattere "_".
   * @param lProcess 
   * @return List<ProcessMatrix__c> 
   **/

  public static List<ProcessMatrix__c> utilityOrderProcessAssignment(List<ProcessMatrix__c> lProcess){
        System.debug('HDT_UTL_OrderProcessAssignment.utilityOrderProcessAssignment');
        List<ProcessMatrix__c> toReturn = new List<ProcessMatrix__c>();
        String type='HDT_Process_Sale_Partner_Community__c';
        Map<String, String> mapLabelToApi = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        for (String fieldName: fieldMap.keySet()) { 
            String tempKey=(String)fieldMap.get(fieldName).getDescribe().getLabel().toUppercase().replace('_', ''); 
            mapLabelToApi.put(tempKey,String.valueOf(fieldName));
        }
 
        Id pid=userinfo.getProfileId();
        HDT_Process_Sale_Partner_Community__c mhc = HDT_Process_Sale_Partner_Community__c.getInstance(pid);
        System.debug('mhc : '+mhc);
        if (mhc.name!=null) {
            Map<String,Object> objectToMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(mhc));
            map<string,string> newMap= new Map<string,string>();
            for(String strKey: objectToMap.keyset()){
                newMap.put(strKey.removeEnd('__c').toUpperCase(), String.valueof(objectToMap.get(strKey)));
            }

            for (ProcessMatrix__c proc : lProcess) {
                String key=String.valueOf(proc.processName__c).toUppercase().deleteWhitespace();
                System.debug('key : '+key); 
                if (mapLabelToApi.get(key)!=null &&newMap.get(mapLabelToApi.get(key).removeEnd('__c').toUpperCase()) !=null && 'true'.equalsIgnoreCase(newMap.get(mapLabelToApi.get(key).removeEnd('__c').toUpperCase()) ) ) {
                    System.debug('if ok');
                    toReturn.add(proc);
                }
            }
            System.debug('toReturn : '+toReturn.size() );
        }
        else {
                toReturn=lProcess;
        }
        System.debug('toReturn :' + toReturn);

        return toReturn;
    }

    public static String getProcessDriver(Order ord)
    {
        Map<String, List<Map<String,String>>> result = new Map<String,List<Map<String,String>>>(); 
        /* Column Header */
        result.put('columnsObj',new List<Map<String,String>>{new Map<String,String>{'label' => 'Driver', 'fieldName' => 'driverLabel'}, new Map<String,String>{'label' => 'Valore', 'fieldName' => 'driverValue'}});
        /* Stato Contratto SAP */
        List<Map<String,String>> infoList = new List<Map<String,String>>();
        infoList.add(addDriver('Stato Contratto SAP', 'sapContractStatus', ord.ServicePoint__r.SapContractStatus__c != null ? ord.ServicePoint__r.SapContractStatus__c : 'Nullo'));
        /* STG */
        infoList.add(addDriver('STG','isStg',ord.isSTG__c ? 'Si' : 'No'));
        /* Mercato Provenienza */
        infoList.add(addDriver('Mercato Provenienza','marketOrigin',ord.MarketOrigin__c));
        /* Presenza Allaccio */
        infoList.add(addDriver('Presenza Allaccio','plugPresence',ord.ServicePoint__r.PlugPresence__c == null ? 'N/A' : ord.ServicePoint__r.PlugPresence__c));
        /* Stesso Account */
        infoList.add(addDriver('Stesso Account','sameAccount',ord.AccountId == ord.ServicePoint__r.Account__c ? 'Si' : 'No'));
        /* Reseller */
        infoList.add(addDriver('Reseller','isReseller',ord.ServicePoint__r.isReseller__c ? 'Si' : 'No'));
        /* Cambio Uso */
        infoList.add(addDriver('Cambio Uso','isChangeUse', ord.SBQQ__Quote__r.AllowChangeUse__c ? 'Si' : 'No'));
        /* Switch In Ripristinatorio */
        infoList.add(addDriver('Switch Ripristinatorio','switchRipr',isSwitchInRipristinatorio(ord) ? 'Si' : 'No'));
        /* Dati Discordanti */
        infoList.add(addDriver('Dati Discordanti','datiDiscordanti','No'));
        /* Presenza SwitchOut */
        infoList.add(addDriver('Presenza Switchout','isWinback',ord.isWinback__c ? 'Si' : 'No'));
        /* Modifica Potenza */
        infoList.add(addDriver('Modifica Potenza','isPowerChange',isAttivazioneConModifica(ord) ? 'Si' : 'No'));
        /* Servizio */
        infoList.add(addDriver('Servizio','commodity',ord.ServicePoint__r.CommoditySector__c));
        
        result.put('infoObj', infoList);

        return JSON.serialize(result);
    }
    private static Map<String,String> addDriver(String label, String name, String value)
    {
        return new Map<String,String>{'driverLabel' => label, 'driverName' => name, 'driverValue' => value};
    }
}