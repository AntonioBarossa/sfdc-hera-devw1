public with sharing class HDT_UTL_Sales {
    
     private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
     private static HDT_QR_Order orderQr = new HDT_QR_Order();
     private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
     private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
     private static HDT_QR_Case caseQr = new HDT_QR_Case();
     private static HDT_QR_RecordType rtQr = new HDT_QR_RecordType();

    public static map<String,String> mapMarcatura = new Map<String,String>{
        'G6 - MMS Associazione' => 'MMS','G5 - MMS Condominio'=> 'MMS','G4 - MMS Parti comuni'=> 'MMS','G3 - MMS Azienda'=> 'MMS','G2 - MMS Ditta individuale'=> 'MMS','G1 - MMS Persona fisica'=> 'MMS'
    };//
    public static String getCityAgency(String comune,boolean isEle, boolean isGas){
        String getSDVComune = '';
        
        if(isEle){
            getSDVComune = HDT_QR_City.getCitySDVEle(comune);
        }
        else if(isGas){
            getSDVComune = HDT_QR_City.getCitySDVGas(comune);
        }

        return getSDVComune;
    }
    public static Map<String,String> getCityAgencyList(Map<String,String> svIdComune,Map<String,String> svIdcommodity){
        Map<String,String> comuneCode = new Map<String,String>();
        map<String,City__c> comObj = new map<String,City__c> ();
        List<city__c> lCity = HDT_QR_City.getCitySDVList(svIdComune.values());
        for(City__c c : lCity){
            comObj.put(c.Name,c);
        }
        for(String s : svIdComune.keySet()){
            if(comObj.get(svIdComune.get(s)) != null){
                City__c ci = comObj.get(svIdComune.get(s));
                if((svIdcommodity.get(s) == 'Energia Elettrica' && ci.ServiceEle__c == true) || (svIdcommodity.get(s) == 'Gas' && ci.ServiceGas__c == true)){
                    comuneCode.put(s,ci.SDV__c);
                }
            }
        }

        return comuneCode;
    }

    public class wrapReturnCity{
        @AuraEnabled public String commodity;
        @AuraEnabled public String comune;
    }
    


    public static Map<String,String> getAgentNameAndCode(ServicePoint__c Service,String Marcatura){
        //system.debug('ivaste getAgentNameAndCode');
        String marcaturaValue = '';
        Map<String,String> mapRes = new Map<String,String>();
        String comune = getCityAgency(service.SupplyCity__c,Service.CommoditySector__c == 'Energia Elettrica' ? true:false,Service.CommoditySector__c == 'Gas' ? true:false);
        if(mapMarcatura.get(Marcatura) != null && mapMarcatura.get(Marcatura) != ''){
            marcaturaValue = mapMarcatura.get(Marcatura);
        }
        else{
            marcaturaValue = 'ALTRO';
        }
        if(comune == null || comune == ''){
            comune = 'ALTRO';
        }
        System.debug('***Comune:' + comune);
        System.debug('***Service:' + Service.CommoditySector__c);
        System.debug('***Marcatura:' + marcaturaValue);
        List<HDT_MatriceSocietaVendita__mdt> listConf = new List<HDT_MatriceSocietaVendita__mdt>();
        if(service.distributor__c != null){
            //system.debug('primo if '+service.distributor__c);
            listConf = HDT_QR_MatriceAgenti.getAgenteException(Service.CommoditySector__c,comune,marcaturaValue,'ALTRO',service.distributor__r.code__c);
        }
        if(listConf != null && listConf.isEmpty()){
            //system.debug('sec if '+service.distributor__c);
            listConf = HDT_QR_MatriceAgenti.getAgente(Service.CommoditySector__c,comune,marcaturaValue,'ALTRO');
        }

        if(listConf != null && !listConf.isEmpty()){
            mapRes.put('nomeAgente',listConf[0].SellerCompany__c);
            mapRes.put('codiceAgente',listConf[0].SalesCompanyCode__c);
        }else{
            mapRes.put('nomeAgente','');
            mapRes.put('codiceAgente','');
        }
        return mapRes;
    }

    public static Map<String,String> getAgentNameAndCodeList(List<ServicePoint__c> ServiceList,String Marcatura){
        String marcaturaValue = '';
        Map<String,String> mapRes = new Map<String,String>();
        Map<String,String> serviceCom = new Map<String,String>();
        Map<String,String> ServiceCmm = new Map<String,String>();
        Map<String,String> mapConf1 = new Map<String,String>();
        Map<String,String> mapConf2 = new Map<String,String>();

        for(ServicePoint__c ser : ServiceList){
            serviceCom.put(ser.id,ser.SupplyCity__c );
            ServiceCmm.put(ser.id,ser.CommoditySector__c );
        }
        Map<String,String> comuneCode = getCityAgencyList(serviceCom,ServiceCmm);
        ///String comune = getCityAgency(service.SupplyCity__c,Service.CommoditySector__c == 'Energia Elettrica' ? true:false,Service.CommoditySector__c == 'Gas' ? true:false);
        if(mapMarcatura.get(Marcatura) != null && mapMarcatura.get(Marcatura) != ''){
            marcaturaValue = mapMarcatura.get(Marcatura);
        }
        else{
            marcaturaValue = 'ALTRO';
        }
        for(String r : serviceCom.keyset()){
            if(comuneCode.get(r) == null){
                comuneCode.put(r,'ALTRO');
            }
        }

       /* if(comune == null || comune == ''){
            comune = 'ALTRO';
        }*/
      //  System.debug('***Comune:' + comune);
      //  System.debug('***Service:' + Service.CommoditySector__c);
       // System.debug('***Marcatura:' + marcaturaValue);
        List<HDT_MatriceSocietaVendita__mdt> listConf = new List<HDT_MatriceSocietaVendita__mdt>();
        List<HDT_MatriceSocietaVendita__mdt> listConf2 = new List<HDT_MatriceSocietaVendita__mdt>();

        listConf = HDT_QR_MatriceAgenti.getAgenteExceptionList();
        
        listConf2 = HDT_QR_MatriceAgenti.getAgenteList();
        for(HDT_MatriceSocietaVendita__mdt md1 : listConf){
            if(md1.distributor__c != null ){
                for(String s :md1.distributor__c.split(',')){
                    mapConf1.put(md1.Service__c+'_'+md1.Comune__c + '_' + md1.Marcatura__c +'_' + md1.offerta__c + '_' + s,md1.SellerCompany__c);
                }
            }
        }
        for(HDT_MatriceSocietaVendita__mdt md2 : listConf2){
            mapConf2.put(md2.Service__c+'_'+md2.Comune__c + '_' + md2.Marcatura__c +'_' + md2.offerta__c,md2.SellerCompany__c);
        }

        for(ServicePoint__c service : ServiceList){
            String res = '';
            if(mapConf1.get(Service.CommoditySector__c + '_' + comuneCode.get(Service.id) +'_' + marcaturaValue + '_' + 'ALTRO' + '_' + service.distributor__r.code__c) != null){
                res = mapConf1.get(Service.CommoditySector__c + '_' + comuneCode.get(Service.id) +'_' + marcaturaValue + '_' + 'ALTRO' + '_' + service.distributor__r.code__c);
            }
            else if(mapConf2.get(Service.CommoditySector__c + '_' + comuneCode.get(Service.id) +'_' + marcaturaValue + '_' + 'ALTRO') != null){
                res = mapConf2.get(Service.CommoditySector__c + '_' + comuneCode.get(Service.id) +'_' + marcaturaValue + '_' + 'ALTRO');
            }
            mapRes.put(service.id,res);
        }


       /* if(listConf != null && !listConf.isEmpty()){
            mapRes.put('nomeAgente',listConf[0].SellerCompany__c);
            mapRes.put('codiceAgente',listConf[0].SalesCompanyCode__c);
        }else{
            mapRes.put('nomeAgente','');
            mapRes.put('codiceAgente','');
        }*/
        return mapRes;
    }

    /**@frpanico 13/01/2022
     * Introdotto metodo per il controllo transitorio
     * per Vas da selezione Contratto/Order
     */
    public static Boolean isTransitionVas(String city, Sale__c sale)
    {
        //Nuova Versione - HRADTR_GV 01/04/2022

        HDT_UTL_CalculateTransition calcTransition = new HDT_UTL_CalculateTransition(city, sale);
        Boolean result = calcTransition.calculateTransition();
        if(result){
            Sale__c s = new Sale__c(Id=sale.Id);
            s.isTransition__c=true;
            saleSrv.updateRecord(s);
        }

        return result;

        //Vecchia Versione
        // Set<String> stabbedData = new Set<String>{'AQ', 'CH', 'PE', 'TE', 'AN', 'AP', 'FM', 'MC', 'PU'};//province abbruzzo e marche
        // List<City__c> listCity = HDT_QR_City.getRecordByComune(city);
        // if(listCity != null && !listCity.isEmpty() && listCity[0].Province__c != null)
        // {
        //     String province = listCity[0].Province__c;
        //     if(((sale.Account__c != null && (sale.Account__r.CompanyOwner__c == 'Reseller' 
        //     || (sale.Account__r.Category__c != null && sale.Account__r.Category__c != 'Famiglie' && sale.Account__r.Category__c != 'Aziende Soho' && sale.Account__r.Category__c != 'Piccoli Condomini'))) 
        //     ||(!stabbedData.contains(province)))){
        //         Sale__c s = new Sale__c(Id=sale.Id);
        //         s.isTransition__c=true;
        //         saleSrv.updateRecord(s);
        //         return true;
        //     }else{
        //         return false;
        //     }
        // }
        // else
        // {
        //     return false;
        // }
    }

    public static Boolean isTransition(ServicePoint__c sp, Sale__c sale){
        
        // Nuova Versione - HRADTR_GV 01/04/2022

         HDT_UTL_CalculateTransition calcTransition = new HDT_UTL_CalculateTransition(sp, sale);
         Boolean result = calcTransition.calculateTransition();
         if(result){
             Sale__c s = new Sale__c(Id=sale.Id);
             s.isTransition__c=true;
             saleSrv.updateRecord(s);
         }
 
         return result;

        // Vecchia Versione
        // List<ServicePoint__c> reseller = [SELECT isReseller__c, SupplyProvince__c FROM ServicePoint__c WHERE Id=:sp.Id WITH SECURITY_ENFORCED ];
        // Set<String> stabbedData = new Set<String>{'AQ', 'CH', 'PE', 'TE', 'AN', 'AP', 'FM', 'MC', 'PU'};//province abbruzzo e marche
        // if(reseller[0].isReseller__c || ((sale.Account__c != null && (sale.Account__r.CompanyOwner__c == 'Reseller' || (sale.Account__r.Category__c != null && sale.Account__r.Category__c != 'Famiglie' && sale.Account__r.Category__c != 'Aziende Soho' && sale.Account__r.Category__c != 'Piccoli Condomini'))) ||(!stabbedData.contains(reseller[0].SupplyProvince__c)))){
        //     Sale__c s = new Sale__c(Id=sale.Id);
        //     s.isTransition__c=true;
        //     saleSrv.updateRecord(s);
        //     return true;
        // }else{
        //     return false;
        // }
    }
    public static Boolean isTransitionNoUp(ServicePoint__c sp, Sale__c sale){

        // Nuova Versione - HRADTR_GV 01/04/2022

        HDT_UTL_CalculateTransition calcTransition = new HDT_UTL_CalculateTransition(sp, sale);
        Boolean result = calcTransition.calculateTransition();
        if(result){
            Sale__c s = new Sale__c(Id=sale.Id);
            s.isTransition__c=true;
        }

        return result;

        // //List<ServicePoint__c> reseller = [SELECT isReseller__c, SupplyProvince__c FROM ServicePoint__c WHERE Id=:sp.Id WITH SECURITY_ENFORCED ];
        // Set<String> stabbedData = new Set<String>{'AQ', 'CH', 'PE', 'TE', 'AN', 'AP', 'FM', 'MC', 'PU'};//province abbruzzo e marche
        // if(sp.isReseller__c || ((sale.Account__c != null && (sale.Account__r.CompanyOwner__c == 'Reseller' || (sale.Account__r.Category__c != null && sale.Account__r.Category__c != 'Famiglie' && sale.Account__r.Category__c != 'Aziende Soho' && sale.Account__r.Category__c != 'Piccoli Condomini'))) ||(!stabbedData.contains(sp.SupplyProvince__c)))){
        //     Sale__c s = new Sale__c(Id=sale.Id);
        //     s.isTransition__c=true;
        //    // saleSrv.updateRecord(s);
        //     return true;
        // }else{
        //     return false;
        // }
    }
    public static Boolean isTransitionNoUp(Sale__c sale){

       // Set<String> stabbedData = new Set<String>{'AQ', 'CH', 'PE', 'TE', 'AN', 'AP', 'FM', 'MC', 'PU'};//province abbruzzo e marche
       if(sale.Account__c != null && (sale.Account__r.CompanyOwner__c == 'Reseller' || (sale.Account__r.Category__c != null && sale.Account__r.Category__c != 'Famiglie' && sale.Account__r.Category__c != 'Aziende Soho' && sale.Account__r.Category__c != 'Piccoli Condomini')) ){
            Sale__c s = new Sale__c(Id=sale.Id);
            s.isTransition__c=true;
           // saleSrv.updateRecord(s);
            return true;
        }else{
            return false;
        }
    }


    public static Boolean isWinback(String servicePointId){
        List<Case> caseList = caseQr.getServicePointCaseWinBack(servicePointId);
        return !caseList.isEmpty();
    }

    public static Boolean isWinback(String servicePointId, String servicePointCode){
        List<Case> caseList = caseQr.getServicePointCaseWinBack(servicePointId, servicePointCode);
        return !caseList.isEmpty();
    }

    public static List<Order> validationActivityPhaseTransition(List<Order> orderNew){
        List<wrts_prcgvr__Activity__c> listActivityToCreate = new List<wrts_prcgvr__Activity__c>();
        List<Order> childToUpdate = new List<Order>();
        Id rt = rtQr.getRecordTypeIdByName('HDT_RT_Default','wrts_prcgvr__Activity__c');
        for(Order ord : orderNew){
            if(ord.RecordType.DeveloperName == 'HDT_RT_OrderDossier'){ //&& ord.TecnicalPhase__c != null){
                if(ord.phase__c == 'Documentazione da inviare'){
                    if((ord.Sale__r.Channel__c == 'Teleselling Outbound'  /*|| ord.Sale__r.Channel__c == 'Teleselling Inbound' || ord.Sale__r.Channel__c == 'Telefono'*/) && ord.SignatureMethod__c == 'Vocal Order'){
                        ord.Phase__c = 'Registrazione da validare';
                        listActivityToCreate.add(instanceActVocalOrd(ord.accountid,ord.id,rt));
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'Telefono' || ord.Sale__r.Channel__c == 'Teleselling Inbound') && ord.SignatureMethod__c == 'Vocal Order')
                    {
                        ord.Phase__c = 'Registrazione Validata';
                        /*
                        ord.SignedDate__c = Date.today();
                        ord.DocumentalPhase__c = 'Plico firmato';
                        */
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'Teleselling Outbound' || ord.Sale__r.Channel__c == 'Teleselling Inbound') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'Agenzie' || ord.Sale__r.Channel__c == 'Business Agent') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' )){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'Agenzie' || ord.Sale__r.Channel__c == 'Business Agent') && ord.SignatureMethod__c == 'Cartacea'){
                        ord.Phase__c = 'Documentazione da Validare';
                        childToUpdate.add(ord);
                    }
                    else if(ord.Sale__r.Channel__c == 'Telefono' && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'HC Point' || ord.Sale__r.Channel__c == 'Sportello') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'HC Point') && ord.SignatureMethod__c == 'Cartacea' ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                        //listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                    }
                    else if((ord.Sale__r.Channel__c == 'Sportello') && ord.SignatureMethod__c == 'Cartacea' ){
                        ord.Phase__c = 'Documentazione da Firmare';
                       // ord.status = 'Activated';
                        childToUpdate.add(ord);
                        //listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                    }
                    else if(ord.Sale__r.Channel__c == 'Vendita Condomini' && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if(ord.Sale__r.Channel__c == 'Back office' && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                }
                else if(ord.phase__c == 'Documentazione da firmare'){
                    if(ord.DocumentalPhase__c != null && ord.DocumentalPhase__c.containsIgnoreCase('Plico firmato')){
                        if((ord.Sale__r.Channel__c == 'Agenzie' || ord.Sale__r.Channel__c == 'Business Agent') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' )){
                            //ord.TecnicalPhase__c = 'Documentazione da Validare';
                            listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                            //childToUpdate.add(ord);
                        }
                    } 
                }
            }
        }
        if(childToUpdate != null && !childToUpdate.isEmpty()){
            SObjectAccessDecision securityDecision =  Security.stripInaccessible(AccessType.UPDATABLE, childToUpdate);
            orderSrv.updateRecords(securityDecision.getRecords());
            //update childToUpdate;
        }
        if(listActivityToCreate != null && !listActivityToCreate.isEmpty()){
            activitySrv.createRecordWithFieldCheck(listActivityToCreate);
           // insert listActivityToCreate;
        }
        return childToUpdate;
    }


    public static Order validationActivityPhaseTransition(Order ord){
        List<wrts_prcgvr__Activity__c> listActivityToCreate = new List<wrts_prcgvr__Activity__c>();
        List<Order> childToUpdate = new List<Order>();
        Id rt = rtQr.getRecordTypeIdByName('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
      //  List<String> orderParentToActivityDocument = new List<String>();
            if(ord.RecordType.DeveloperName == 'HDT_RT_OrderDossier'){ //&& ord.TecnicalPhase__c != null){
                if(ord.phase__c == 'Documentazione da inviare'){
                    if((ord.Sale__r.Channel__c == 'Teleselling Outbound'  /*|| ord.Sale__r.Channel__c == 'Teleselling Inbound' || ord.Sale__r.Channel__c == 'Telefono'*/) && ord.SignatureMethod__c == 'Vocal Order'){
                        ord.Phase__c = 'Registrazione  da validare';
                        listActivityToCreate.add(instanceActVocalOrd(ord.accountid,ord.id,rt));
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'Telefono' || ord.Sale__r.Channel__c == 'Teleselling Inbound') && ord.SignatureMethod__c == 'Vocal Order')
                    {
                        ord.Phase__c = 'Registrazione Validata';
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'Teleselling Outbound' || ord.Sale__r.Channel__c == 'Teleselling Inbound') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'Agenzie' || ord.Sale__r.Channel__c == 'Business Agent') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' )){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                        //tutti i figli per cui crearla
                        //orderParentToActivityDocument.add(ord.id);
                       //listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                    }
                    else if((ord.Sale__r.Channel__c == 'Agenzie' || ord.Sale__r.Channel__c == 'Business Agent') && ord.SignatureMethod__c == 'Cartacea' && ord.DocSendingMethod__c == 'Stampa Cartacea'){
                        ord.Phase__c = 'Documentazione da Validare';
                        childToUpdate.add(ord);
                        //tutti i figli per cui crearla
                        //orderParentToActivityDocument.add(ord.id);
                        listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                    }
                    /*else if((ord.Sale__r.Channel__c == 'Teleselling Inbound' || ord.Sale__r.Channel__c == 'Telefono') && ord.SignatureMethod__c == 'Vocal Order'){
                        ord.Phase__c = 'Documentazione Gestita';
                        //ord.status = 'Activated';
                        childToUpdate.add(ord);
                    }*/
                /* else if(ord.Sale__r.Channel__c = 'Web' && ord.SignatureMethod__c == 'Vocal Order'){
                        
                    }*/
                    else if(ord.Sale__r.Channel__c == 'Telefono' && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                     //   childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'HC Point' || ord.Sale__r.Channel__c == 'Sportello') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if((ord.Sale__r.Channel__c == 'HC Point') && ord.SignatureMethod__c == 'Cartacea' && ord.DocSendingMethod__c == 'Stampa Cartacea'){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                        listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                    }
                    else if((ord.Sale__r.Channel__c == 'Sportello') && ord.SignatureMethod__c == 'Cartacea' && ord.DocSendingMethod__c == 'Stampa Cartacea'){
                        ord.Phase__c = 'Documentazione Gestita';
                       // ord.status = 'Activated';
                        childToUpdate.add(ord);
                        listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                    }
                    else if(ord.Sale__r.Channel__c == 'Vendita Condomini' && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    else if(ord.Sale__r.Channel__c == 'Back office' && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' ) ){
                        ord.Phase__c = 'Documentazione da Firmare';
                        childToUpdate.add(ord);
                    }
                    /*else if(ord.Sale__r.Channel__c = 'HC Point' && ord.SignatureMethod__c == 'Cartacea'){
                        ord.phase__c = 'Plico Firmato da validare';
                    // orderParentToActivityDocument.add(ord.id);
                        listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                    }*/
                }
                else if(ord.phase__c == 'Documentazione da Firmare'){
                    if(ord.DocumentalPhase__c == 'Plico firmato'){
                        if((ord.Sale__r.Channel__c == 'Agenzie' || ord.Sale__r.Channel__c == 'Business Agent') && (ord.SignatureMethod__c == 'OTP Remoto' || ord.SignatureMethod__c == 'OTP Coopresenza' )){
                            //ord.Phase__c = 'Documentazione da Validare';
                            listActivityToCreate.add(instanceActValidazioneDocumentale(ord.accountid,ord.id,rt));
                            //childToUpdate.add(ord);
                        }
                        else{
                            System.debug('*********DentroValidazione');
                            //ord.phase__c = 'Documentazione Gestita';
                            //ord.status = 'Activated';
                            //ord.SignedDate__c = date.today();
                        }
                    } 
                }
            }
        if(childToUpdate != null && !childToUpdate.isEmpty()){
            SObjectAccessDecision securityDecision =  Security.stripInaccessible(AccessType.UPDATABLE, childToUpdate);
            orderSrv.updateRecords(securityDecision.getRecords());
        }
        if(listActivityToCreate != null && !listActivityToCreate.isEmpty()){
            activitySrv.createRecordWithFieldCheck(listActivityToCreate);
            //insert listActivityToCreate;
        }
        return ord;
    }

    public static wrts_prcgvr__Activity__c instanceActVocalOrd(String accountId, String orderId, Id recordtypeId) {
        String link;
        try {
            link = [SELECT Id, RecordingLink__c FROM wrts_prcgvr__Activity__c WHERE CreatedById =: UserInfo.getUserId() AND Type__c = 'Chiamata outbound' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC  LIMIT 1].RecordingLink__c;
        } catch (Exception e) {
            link = 'ERRORE - ATTIVITA CHIAMATA OUTBOUND NON TROVATA';
        }
        if(String.isBlank(link)) {
            link = 'ERRORE - NESSUN LINK REGISTRAZIONE NELL\'ATTIVITA DI CHIAMATA OUTBOUND';
        }
        return new wrts_prcgvr__Activity__c(
            account__c = accountId,
            wrts_prcgvr__Status__c = 'Aperta',
            order__c = orderId,
            type__c = 'Validazione Vocal Order',
            recordtypeid = recordtypeId, 
            RecordingLink__c = link
        );
    }

    public static wrts_prcgvr__Activity__c instanceActValidazioneDocumentale(String accountid,String orderid,id recordtypeid){
        return new wrts_prcgvr__Activity__c(account__c = accountid,wrts_prcgvr__Status__c= 'Aperta',wrts_prcgvr__IsRequired__c=true,order__c = orderid,type__c='Validazione Documentale',recordtypeid=recordtypeid);
    }

    public static void handleContractVariation(Order order){
        String processType = '';
        String contractId = '';
        String servicePointId = '';
        String parentOrderId = '';
        String orderId = '';
        HDT_QR_Contract qrContract = new HDT_QR_Contract();
        HDT_QR_OrderItem qrOrderItems = new HDT_QR_OrderItem();
        HDT_QR_Quote quoteQuery = new HDT_QR_Quote();
        try{
                    

            if(order != null){
                processType = order.ProcessType__c;
                if(String.isNotBlank(processType) && processType.contains('Aggiunta Sconti o Bonus VAS')){
                    contractId = order.ContractReference__c;
                    servicePointId = order.ServicePoint__c;
                    parentOrderId = order.ParentOrder__c;
                    orderId = order.Id;
                
                    if(String.isNotBlank(contractId) && quoteQuery.getQuoteType(orderId).equalsIgnoreCase('Amendment')){
                        SBQQ__Subscription__c subscription = qrContract.getSubscriptionFromContract(contractId);
                        if(subscription != null){
                            order.CommercialProduct__c = subscription.SBQQ__ProductName__c;
                            order.CommercialProductCode__c = subscription.ProductCode__c;
                            order.CommercialProductVersion__c = subscription.VersionFormula__c;
                        }
                    }else if(String.isNotBlank(servicePointId) && String.isNotBlank(parentOrderId)) {
                        //Get offer from OrderItem Activation
                        OrderItem orderItem = qrOrderItems.getOfferActivationItem(parentOrderId,servicePointId);
                        if(orderItem != null){
                            order.CommercialProduct__c = orderItem.Product2.Name;
                            order.CommercialProductCode__c = orderItem.Product2.ProductCode;
                            order.CommercialProductVersion__c = orderItem.Product2.Version__c;            
                        }
                    }
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.DEBUG, ex.getMessage());
        }
    }

    public static void handleContractVariation(Order order,Order orderOriginal){
        String processType = '';
        String contractId = '';
        String servicePointId = '';
        String parentOrderId = '';
        String orderId = '';
        HDT_QR_Contract qrContract = new HDT_QR_Contract();
        HDT_QR_OrderItem qrOrderItems = new HDT_QR_OrderItem();
        HDT_QR_Quote quoteQuery = new HDT_QR_Quote();
        try{
                    

            if(orderOriginal != null){
                processType = orderOriginal.ProcessType__c;
                //if(String.isNotBlank(processType) && processType.contains('Aggiunta Sconti o Bonus VAS')){
                    contractId = orderOriginal.ContractReference__c;
                    servicePointId = orderOriginal.ServicePoint__c;
                    parentOrderId = orderOriginal.ParentOrder__c;
                    orderId = order.Id;
                
                    if(String.isNotBlank(contractId) && quoteQuery.getQuoteType(orderId).equalsIgnoreCase('Amendment')){
                        SBQQ__Subscription__c subscription = qrContract.getSubscriptionFromContract(contractId);
                        if(subscription != null){
                            order.CommercialProduct__c = subscription.SBQQ__ProductName__c;
                            order.CommercialProductCode__c = subscription.ProductCode__c;
                            order.CommercialProductVersion__c = subscription.VersionFormula__c;
                        }
                    }else if(String.isNotBlank(servicePointId) && String.isNotBlank(parentOrderId)) {
                        //Get offer from OrderItem Activation
                        OrderItem orderItem = qrOrderItems.getOfferActivationItem(parentOrderId,servicePointId);
                        if(orderItem != null){
                            order.CommercialProduct__c = orderItem.Product2.Name;
                            order.CommercialProductCode__c = orderItem.Product2.ProductCode;
                            order.CommercialProductVersion__c = orderItem.Product2.Version__c;            
                        }
                    }
                //}
            }
            
        }catch(Exception ex){
            sendEmail(ex,order,orderOriginal);
            System.debug(LoggingLevel.DEBUG, ex.getMessage());
        }
    }

    private static void sendEmail(Exception ex, Order ord, Order originalOrder){
        try{
            list <OrgWideEmailAddress> orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address'  LIMIT 1];
			
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);
            mail.setToAddresses(new String[]{'EVERIS_HERA_DT@nttdata.com'});
			mail.setSubject('Error: Class HDT_UTL_Sales method handleContractVariation');
            String body='Exception messagge: ERROR: ' + ex.getMessage() + ' Error Line: ' +ex.getLineNumber() + ' order: ' +JSON.serialize(ord) + ' orderOriginal: '+JSON.serialize(originalOrder);
			mail.setPlainTextBody (body);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Send Email Error: ' + ex.getMessage());
        }
    }
}