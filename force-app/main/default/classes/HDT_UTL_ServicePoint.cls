/**
* @author Luca Molino (luca.molino@engdb.com.br)
* @date 23/03/2021
* @description HDT_UTL_ServicePoint Class
* @history Luca Molino – 23/03/2021 – Created Class
*/
public with sharing class HDT_UTL_ServicePoint {
    
    private static HDT_QR_RecordType qrRecordType = new HDT_QR_RecordType(); //21/08/2021 - gabriele.rota@webresults.it
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint serviceSrv = new HDT_SRV_ServicePoint();
    
    @AuraEnabled
    public static List<ServicePoint__c> extractDataFromArriccDataServiceWithExistingSp(ServicePoint__c sp, HDT_WS_ArrichmentDataEntityResponse response){
        
        ServicePoint__c spNew = new ServicePoint__c();
        if(sp != null){
            spNew = sp;
        }
        
        Map<String, String> mapRes = new Map<String, String>();
        
        for(HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_posizioniResponseObject r : response.data.posizioni){
            if(!String.isBlank(r.campo) && mapRes.get(r.campo.toUpperCase()) == null){
                mapRes.put(r.campo.toUpperCase(),r.valore);
            }            
        }

        if(mapRes.get('DEFINIZIONEOFFERTA')!=null && mapRes.get('DEFINIZIONEOFFERTA').containsIgnoreCase('STG_') ){
            spNew.isSTG__c = true;
        }
        /**@frpanico 2022-03-15
         * Aggiunto campo
         * GRUPPONUMERATORE
         * Per processo Sconti e Bonus
         */
        if(mapRes.get('GRUPPONUMERATORE')!=null)
        {
            spNew.NumeratorGroup__c = mapRes.get('GRUPPONUMERATORE');
        }
        if(mapRes.get('IMPOSTE')!=null){
            if(mapRes.get('DESCRCOMM')=='Gas'){
                spNew.ExciseGas__c  = mapRes.get('IMPOSTE') != null ? mapRes.get('IMPOSTE') : 'ALTRO';                
            }
            else if(mapRes.get('DESCRCOMM')=='Energia Elettrica'){
                spNew.ExciseEle__c  = mapRes.get('IMPOSTE') != null ? mapRes.get('IMPOSTE') : 'ALTRO';
            }
        }
        if(mapRes.get('ALIQUOTAIVA')!=null){
            spNew.Vat__c  = mapRes.get('ALIQUOTAIVA');            
        }
        if(spNew.MeterStatus__c  != 'Sospeso'){
            if(mapRes.get('STATODEVICE')== 'A'){
                spNew.MeterStatus__c  = 'Attivo';                
            }
            else if(mapRes.get('STATODEVICE')== 'I'){
                spNew.MeterStatus__c  ='Inattivo' ;
            }
            else if(!String.isBlank(mapRes.get('STATODEVICE'))){
                spNew.MeterStatus__c  = 'Bozza';
            }else{
                spNew.MeterStatus__c  = 'Inattivo';
            }
        }
        if(mapRes.get('PRESSIONE')!=null && !String.isBlank(mapRes.get('PRESSIONE'))){
            spNew.Pressure__c  = Decimal.valueOf(mapRes.get('PRESSIONE'));
        }        
        if(mapRes.get('CODICEREMI')!=null && !String.isBlank(mapRes.get('CODICEREMI'))){
            spNew.RemiCode__c = mapRes.get('CODICEREMI');
        }
        if(mapRes.get('CALIBRO1')!=null && !String.isBlank(mapRes.get('CALIBRO1'))){
            if(mapRes.get('CALIBRO1')=='GRT005'){
                spNew.MeterClass__c = 'G10';                
            }
            if(mapRes.get('CALIBRO1')=='GRT010'){
                spNew.MeterClass__c = 'G100';                
            }
            if(mapRes.get('CALIBRO1')=='GRT015'){
                spNew.MeterClass__c = 'G100';                
            }
            if(mapRes.get('CALIBRO1')=='GRT006'){
                spNew.MeterClass__c = 'G16';                
            }
            if(mapRes.get('CALIBRO1')=='GRT011'){
                spNew.MeterClass__c = 'G160';                
            }
            if(mapRes.get('CALIBRO1')=='GRT016'){
                spNew.MeterClass__c = 'G1600';                
            }
            if(mapRes.get('CALIBRO1')=='GRT002'){
                spNew.MeterClass__c = 'G2,5';                
            }
            if(mapRes.get('CALIBRO1')=='GRT007'){
                spNew.MeterClass__c = 'G25';                
            }
            if(mapRes.get('CALIBRO1')=='GRT012'){
                spNew.MeterClass__c = 'G250';
            }
            if(mapRes.get('CALIBRO1')=='GRT003'){
                spNew.MeterClass__c = 'G4';
            }
            if(mapRes.get('CALIBRO1')=='GRT008'){
                spNew.MeterClass__c = 'G40';
            }
            if(mapRes.get('CALIBRO1')=='GRT013'){
                spNew.MeterClass__c = 'G400';
            }
            if(mapRes.get('CALIBRO1')=='GRT017'){
                spNew.MeterClass__c = 'G4000';
            }
            if(mapRes.get('CALIBRO1')=='GRT004'){
                spNew.MeterClass__c = 'G6';
            }
            if(mapRes.get('CALIBRO1')=='GRT009'){
                spNew.MeterClass__c = 'G65';
            }
            if(mapRes.get('CALIBRO1')=='GRT014'){
                spNew.MeterClass__c = 'G650';
            }
            if(mapRes.get('CALIBRO1')=='GRT018'){
                spNew.MeterClass__c = 'G6500';
            }            
        }
        if(mapRes.get('MATRICOLA1')!=null && !String.isBlank(mapRes.get('MATRICOLA1'))){
            spNew.MeterSN__c = mapRes.get('MATRICOLA1');
        }
        if(mapRes.get('BRANDSOCIETARIO')!=null && !String.isBlank(mapRes.get('BRANDSOCIETARIO'))){
            spNew.BrandLogo__c   = mapRes.get('BRANDSOCIETARIO');
        }
        if(mapRes.get('DISTRIBUTORE')!=null && !String.isBlank(mapRes.get('DISTRIBUTORE'))){
            Account a = accountQr.getAccountByDistributorKey(mapRes.get('DISTRIBUTORE'));
            spNew.Distributor__c = a.Id != null ? a.Id : ((sp != null && sp.Distributor__c != null) ? sp.Distributor__c : null);
        }
        /**@frpanico 2022-05-27
         * Aggiunta gestione campo VENDITORE
         */
        if(mapRes.get('VENDITORE')!=null && !String.isBlank(mapRes.get('VENDITORE')))
        {
            String codiceVenditore = (String)mapRes.get('VENDITORE');
            List<HDT_MatriceSocietaVendita__mdt> salesCompanies = [SELECT SellerCompany__c FROM HDT_MatriceSocietaVendita__mdt WHERE SalesCompanyCode__c = :codiceVenditore WITH SECURITY_ENFORCED];
            if(!salesCompanies.isEmpty())
            {
                spNew.Vendor__c = salesCompanies[0].SellerCompany__c;
            }
            spNew.SalesCompanyCode__c = codiceVenditore;
        }
        if(mapRes.get('POD')!=null && !String.isBlank(mapRes.get('POD'))){
            spNew.ServicePointCode__c   = mapRes.get('POD');
            spNew.Name   = mapRes.get('POD');            
        }
        if(mapRes.get('DESCRCOMM')!=null && !String.isBlank(mapRes.get('DESCRCOMM'))){            
            if(mapRes.get('DESCRCOMM')== 'Energia elettrica'){
                spNew.CommoditySector__c = 'Energia Elettrica';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Ele'); //21/08/2021 - gabriele.rota@webresults.it
            }
            else if(mapRes.get('DESCRCOMM')== 'Gas'){
                spNew.CommoditySector__c = 'Gas';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Gas'); //21/08/2021 - gabriele.rota@webresults.it
            }
            else if(mapRes.get('DESCRCOMM')== 'Acqua'){
                spNew.CommoditySector__c = 'Acqua';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Acqua'); //21/08/2021 - gabriele.rota@webresults.it
            }
            else if(mapRes.get('DESCRCOMM')== 'Ambiente'){
                spNew.CommoditySector__c = 'Ambiente';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Ambiente'); //21/08/2021 - gabriele.rota@webresults.it
            }
        }
        if(mapRes.get('MOTGARANZIAFORN')==null){            
            spNew.Disconnectable__c = 'Si';
        }
        else if(mapRes.get('MOTGARANZIAFORN') == ''){            
            spNew.Disconnectable__c = 'No';
        }        
        if(mapRes.get('IMPIANTO')!=null && !String.isBlank(mapRes.get('IMPIANTO'))){            
            spNew.SAPImplantCode__c = mapRes.get('IMPIANTO');
        }
        if(mapRes.get('RESELLER')!=null && !String.isBlank(mapRes.get('RESELLER'))){
            spNew.isReseller__c = mapRes.get('RESELLER') == 'X';
        }
        else{
            spNew.isReseller__c = false;
        }
        /**@frpanico 2022-04-08
         * Aggiunta gestione Stato Contratto SAP
         * Da DATACESSAZIONE
         */
        if(mapRes.get('DATACESSAZIONE') !=null && !String.isBlank(mapRes.get('DATACESSAZIONE')))
        {
            if(mapRes.get('DATACESSAZIONE') == '99991231' || Date.valueOf(mapRes.get('DATACESSAZIONE').substring(0,4)+'-'+mapRes.get('DATACESSAZIONE').substring(4,6)+'-'+mapRes.get('DATACESSAZIONE').substring(6,8)) > System.today())
            {
                spNew.SapContractStatus__c = 'Attivo';
            }
            else
            {
                spNew.SapContractStatus__c = 'Cessato';
            }
        }
        if(mapRes.get('DATACESSAZIONE')!=null && !String.isBlank(mapRes.get('DATACESSAZIONE'))){
            if(mapRes.get('DATACESSAZIONE') != '99991231' && mapRes.get('DATACESSAZIONE').length()== 8 ){
                Date d = Date.valueOf(mapRes.get('DATACESSAZIONE').substring(0,4)+'-'+mapRes.get('DATACESSAZIONE').substring(4,6)+'-'+mapRes.get('DATACESSAZIONE').substring(6,8));
                if(d > date.today()){
                    spNew.SwitchInWinback__c = true;
                    spNew.SwitchOutDate__c = d;
                }
                else{
                    spNew.SwitchInWinback__c = false;
                    spNew.SwitchOutDate__c = null;
                }
            }
            else{
                spNew.SwitchInWinback__c = false;
                spNew.SwitchOutDate__c = null;
            }
        }
        else{
            spNew.SwitchInWinback__c = false;
            spNew.SwitchOutDate__c = null;
        }
        if(mapRes.get('TIPOIMPIANTO')!=null && !String.isBlank(mapRes.get('TIPOIMPIANTO'))){
            HDT_SRV_DataEnrichmentPostSales dataEnrich = new HDT_SRV_DataEnrichmentPostSales();
            spNew.ImplantType__c = dataEnrich.getPicklistValue('ServicePoint__c', 'ImplantType__c', mapRes.get('TIPOIMPIANTO'));
        }
        if(mapRes.get('MODPAGUSCITA')!=null && !String.isBlank(mapRes.get('MODPAGUSCITA'))){
            HDT_SRV_DataEnrichmentPostSales dataEnrich = new HDT_SRV_DataEnrichmentPostSales();
            spNew.MethodsForOutgoingPayments__c = dataEnrich.getPicklistValue('ServicePoint__c', 'MethodsForOutgoingPayments__c', mapRes.get('MODPAGUSCITA'));
        }
        if(mapRes.get('AFPAG_FFUG')!=null && !String.isBlank(mapRes.get('AFPAG_FFUG'))){
            HDT_SRV_DataEnrichmentPostSales dataEnrich = new HDT_SRV_DataEnrichmentPostSales();
            spNew.JointBottomAdhesion__c = dataEnrich.getPicklistValue('ServicePoint__c', 'JointBottomAdhesion__c', mapRes.get('AFPAG_FFUG'));
        }
        if(mapRes.get('AFPAGA_DEP')!=null && !String.isBlank(mapRes.get('AFPAGA_DEP'))){
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFPAGA_DEP')))== 0) {
                spNew.PayPurification__c = 'No - Esente';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFPAGA_DEP')))== 1) {
                spNew.PayPurification__c = 'Si - Paga';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFPAGA_DEP')))== 2) {
                spNew.PayPurification__c = 'Si - Ridotta';                
            }
        }
        if(mapRes.get('AFPAGA_FOG')!=null && !String.isBlank(mapRes.get('AFPAGA_FOG'))){
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFPAGA_FOG')))== 0) {
                spNew.PaySewer__c = 'No - Esente';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFPAGA_FOG')))== 1) {
                spNew.PaySewer__c = 'Si - Paga';                
            }
        }
        if(mapRes.get('AFP_DEP355')!=null && !String.isBlank(mapRes.get('AFP_DEP355'))){
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFP_DEP355')))== 0) {
                spNew.PurificationInfoOnTheInvoice__c = 'No - Esente';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFP_DEP355')))== 1) {
                spNew.PurificationInfoOnTheInvoice__c = 'Si - Paga';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFP_DEP355')))== 2) {
                spNew.PurificationInfoOnTheInvoice__c = 'Si - Ridotta';                
            }
        }
        if(mapRes.get('TRATAUNICA')!=null && !String.isBlank(mapRes.get('TRATAUNICA'))){
            spNew.SingleInstallmentOperating__c = mapRes.get('TRATAUNICA');
        }
        if(mapRes.get('DI_TRATAUNICA')!=null && !String.isBlank(mapRes.get('DI_TRATAUNICA'))){
            spNew.SingleInstallmentValidityDate__c = date.parse(mapRes.get('DI_TRATAUNICA'));
        }
        if(mapRes.get('AFVASCA_AC')!=null && !String.isBlank(mapRes.get('AFVASCA_AC'))){
            spNew.HasAccumulationTanks__c = Boolean.valueOf(mapRes.get('AFVASCA_AC'));
        }
        if(mapRes.get('CONSUMOCAPDR')!=null && !String.isBlank(mapRes.get('CONSUMOCAPDR'))){            
            spNew.AnnualConsumption__c = integer.valueOf(Decimal.valueOf(mapRes.get('CONSUMOCAPDR')));
        }
        if(mapRes.get('CONSUMOANNUOEE')!=null && !String.isBlank(mapRes.get('CONSUMOANNUOEE'))){         
            spNew.AnnualConsumption__c = integer.valueOf(Decimal.valueOf(mapRes.get('CONSUMOANNUOEE')));
        }
        if(mapRes.get('AQCNS_ANNO')!=null && !String.isBlank(mapRes.get('AQCNS_ANNO'))){         
            spNew.AnnualConsumption__c = integer.valueOf(Decimal.valueOf(mapRes.get('AQCNS_ANNO')));
        }
        if(mapRes.get('TFNCE0000')!=null){         
            spNew.NumberOfTARIMembers__c = (mapRes.get('TFNCE0000'));
        } 
        if(mapRes.get('TFNCDC000')!=null){         
            spNew.NumberOfTARIMembers__c = (mapRes.get('TFNCDC000'));
        }        
        if(mapRes.get('AFNUM_COMP')!=null && !String.isBlank(mapRes.get('AFNUM_COMP'))){         
            spNew.NumberOfCommunityMembers__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFNUM_COMP')));
        }        
        if(mapRes.get('AFUADRS')!=null && !String.isBlank(mapRes.get('AFUADRS'))){         
            spNew.ResidentDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUADRS')));
        }
        if(mapRes.get('AFUADNR')!=null && !String.isBlank(mapRes.get('AFUADNR'))){         
            spNew.NotResidentDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUADNR')));
        }
        if(mapRes.get('AFUND')!=null && !String.isBlank(mapRes.get('AFUND'))){         
            spNew.NotDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUND')));
        }
        if(mapRes.get('AFUNDA')!=null && !String.isBlank(mapRes.get('AFUNDA'))){         
            spNew.NotDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDA')));
        }
        if(mapRes.get('AFUNDC')!=null && !String.isBlank(mapRes.get('AFUNDC'))){         
            spNew.NotDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDC')));
        }
        if(mapRes.get('AFUNDI')!=null && !String.isBlank(mapRes.get('AFUNDI'))){         
            spNew.NotDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDI')));
        }
        if(mapRes.get('AFUNDZ')!=null && !String.isBlank(mapRes.get('AFUNDZ'))){         
            spNew.NotDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDZ')));
        }
        if(mapRes.get('AFBI_DIAM1')!=null && !String.isBlank(mapRes.get('AFBI_DIAM1'))){         
            spNew.HydrantMouthsNumberA__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFBI_DIAM1')));
        }
        if(mapRes.get('AFBI_DIAM2')!=null && !String.isBlank(mapRes.get('AFBI_DAFBI_DIAM2IAM1'))){         
            spNew.HydrantMouthsNumberB__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFBI_DIAM2')));
        }
        if(mapRes.get('AF_BOC_IDR')!=null && !String.isBlank(mapRes.get('AF_BOC_IDR'))){         
            spNew.HydrantMouthsNumber__c = integer.valueOf(Decimal.valueOf(mapRes.get('AF_BOC_IDR')));
        }
        if(mapRes.get('TFRS000000')!=null && !String.isBlank(mapRes.get('TFRS000000'))){         
            spNew.AreaDeclaredTARI__c = integer.valueOf(Decimal.valueOf(mapRes.get('AF_BOC_IDR')));
        }
        if(mapRes.get('MERCATO')!=null && !String.isBlank(mapRes.get('MERCATO'))){
            String mercato = mapRes.get('MERCATO').substring(0,1) + mapRes.get('MERCATO').substring(1,mapRes.get('MERCATO').length()).toLowerCase();
            Boolean isStg = mapRes.get('DEFINIZIONEOFFERTA')!=null && mapRes.get('DEFINIZIONEOFFERTA').containsIgnoreCase('STG_')? true:false;
            mercato = mercato.equalsIgnoreCase('Tutela')?'Regolamentato':mercato;
            mercato = isStg ? 'Regolamentato':mercato;
            spNew.MarketOrigin__c = mercato;
        }
        if(mapRes.get('FLAGTELEGESTIBILE')!=null && !String.isBlank(mapRes.get('FLAGTELEGESTIBILE'))){            
            spNew.IsRemoteManaged__c = 'X'.equalsIgnoreCase(mapRes.get('FLAGTELEGESTIBILE'));
        }
        if(mapRes.get('POTENZACONTRATTUALE')!=null && !String.isBlank(mapRes.get('POTENZACONTRATTUALE'))){
            Decimal d = decimal.valueOf(mapRes.get('POTENZATECNICA'));
            spNew.PowerContractual__c = d.setScale(0);
        }
        if(mapRes.get('POTENZATECNICA')!=null && !String.isBlank(mapRes.get('POTENZATECNICA'))){            
            Decimal d = decimal.valueOf(mapRes.get('POTENZATECNICA'));
            spNew.PowerAvailable__c  =d.setScale(1);            
        }
        if(mapRes.get('TENSIONE')!=null && !String.isBlank(mapRes.get('TENSIONE'))){            
            spNew.VoltageLevel__c = mapRes.get('TENSIONE');
        }
        if(mapRes.get('RESIDENTEINDFORN')!=null && !String.isBlank(mapRes.get('RESIDENTEINDFORN'))){            
            spNew.Resident__c = mapRes.get('RESIDENTEINDFORN') == 'SI' ? true : false;
        }        
        if(mapRes.get('CAP')!=null && !String.isBlank(mapRes.get('CAP'))){            
            spNew.SupplyPostalCode__c = mapRes.get('CAP');
        }
        if(mapRes.get('VIA')!=null && !String.isBlank(mapRes.get('VIA'))){
            spNew.SupplyStreet__c  = mapRes.get('VIA');
        }
        if(mapRes.get('CIVICO')!=null && !String.isBlank(mapRes.get('CIVICO'))){
            spNew.SupplyStreetNumber__c  = mapRes.get('CIVICO');
        }
        if(mapRes.get('LOCALITA')!=null && !String.isBlank(mapRes.get('LOCALITA'))){
            spNew.SupplyCity__c  = mapRes.get('LOCALITA');
        }
        if(mapRes.get('CODICEVIA')!=null && !String.isBlank(mapRes.get('CODICEVIA'))){
            spNew.SupplySAPStreetCode__c = mapRes.get('CODICEVIA');
        }
        if(mapRes.get('REGIONE')!=null && !String.isBlank(mapRes.get('REGIONE'))){
            spNew.SupplyProvince__c = mapRes.get('REGIONE');
        }
        if(mapRes.get('CODIFICALOCALITA')!=null && !String.isBlank(mapRes.get('CODIFICALOCALITA'))){
            spNew.SupplySAPCityCode__c = mapRes.get('CODIFICALOCALITA');
        }
        if(mapRes.get('CODICEPAESE')!=null && !String.isBlank(mapRes.get('CODICEPAESE'))){
            spNew.SupplyCountry__c = mapRes.get('CODICEPAESE') == 'IT' ? 'Italia' : 'Estero';
        }
        if(mapRes.get('LOCALITA')!=null && !String.isBlank(mapRes.get('LOCALITA'))
           && mapRes.get('CIVICO')!=null && !String.isBlank(mapRes.get('CIVICO'))
           && mapRes.get('CODIFICALOCALITA')!=null && !String.isBlank(mapRes.get('CODIFICALOCALITA'))
           && mapRes.get('VIA')!=null && !String.isBlank(mapRes.get('VIA'))
           && mapRes.get('CODICEVIA')!=null && !String.isBlank(mapRes.get('CODICEVIA')))
        {
            spNew.SupplyisAddressVerified__c = true;
        }
        Map<String, Account> accBpMap = new Map<String, Account>();
        if(mapRes.get('BP') != null){
            List<Account> accBp = accountQr.getAccountByCustomerCode(mapRes.get('BP'));
            if (!accBp.isEmpty()) {
                spNew.Account__c = accBp[0].Id;
                accBpMap.put(accBp[0].Id, accBp[0]);
            }
        }
        Map<String, String> inputFields = new Map<String, String>();
        String imposta = spNew.CommoditySector__c.equalsIgnoreCase('Energia Elettrica') ? spNew.ExciseEle__c : spNew.ExciseGas__c;
        String accCategory = accBpMap.get(spNew.Account__c) != null ? accBpMap.get(spNew.Account__c).Category__c : '';

        inputFields.put('servizio', spNew.CommoditySector__c);
        inputFields.put('imposta', imposta);
        inputFields.put('tipoImpianto', spNew.ImplantType__c);
        inputFields.put('accCategory', accCategory);

        spNew.SupplyType__c = calculateSupplyType(inputFields);
        
        List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
        servicePoints.add(spNew);
        return servicePoints;
    }

    public static String calculateSupplyType(Map<String, String> inputFields){

        String tipoFornitura = '';
        String servizio = inputFields.get('servizio');
        String imposta = inputFields.get('imposta');
        String tipoImpianto = inputFields.get('tipoImpianto');
        String accCategory = inputFields.get('accCategory');

        if(servizio.equalsIgnoreCase('Energia Elettrica')){
            tipoFornitura = tipoImpianto != null && tipoImpianto.equalsIgnoreCase('13A0-Usi di Abitazione BT') ? 'Domestico' : 'Non Domestico';
        }
        else if(servizio.equalsIgnoreCase('Acqua')){
            tipoFornitura = tipoImpianto != null && tipoImpianto.equalsIgnoreCase('1101-Domestico') ? 'Uso domestico' : 'Uso diverso da domestico';    
        }
        else {
            String fields = 'Id, SupplyType__c';
            String conditions = '';
            conditions += String.isNotBlank(imposta) ? 'Taxes__c = \'' +imposta +'\' AND ' : '';
            conditions += String.isNotBlank(tipoImpianto) ? 'ImplantType__c = \'' +tipoImpianto +'\' AND ' : '';
            conditions += String.isNotBlank(accCategory) ? 'AccountCategory__c = \'' +accCategory +'\' AND ' : '';
            conditions = conditions.removeEndIgnoreCase(' AND ');
            
            List<FieldCoerenceServicePoint__c> fieldCoerenceList = new List<FieldCoerenceServicePoint__c>();
            fieldCoerenceList = HDT_QR_GenericQuery.getGenericRecords(fields, 'FieldCoerenceServicePoint__c' , conditions);
            tipoFornitura = fieldCoerenceList.size() > 0 ? fieldCoerenceList[0].SupplyType__c : '';
        }
        return tipoFornitura;
    }
    
    @AuraEnabled
    public static List<String> objectToList(HDT_WRP_AddressObject wrap){
        
        List<String> listFields = new List<String>();
        String stringWrap = JSON.serialize(wrap);
        listFields = (List<String>)JSON.deserializeUntyped(stringWrap);
        
        return listFields;        
    }
    @AuraEnabled(cacheable=true)
    public static  HDT_WRP_AddressObject getInstanceWrapAddressObject(String servicePoint)
    {
        ServicePoint__c sp = (ServicePoint__c) JSON.deserialize(servicePoint, ServicePoint__c.class);
        return getInstanceWrapAddressObject(sp);
    }
    
    @AuraEnabled(cacheable=true)
    public static  HDT_WRP_AddressObject getInstanceWrapAddressObject(sObject s){
        
        Map<String,String> mapApiName = new map<String,String>
        {
            'SupplyPostalCode__c' => 'CAP',
            'SupplyStreetNumber__c' => 'Civico',
            'SupplyCountry__c' => 'Stato',
            'SupplySAPCityCode__c' => 'CodiceComuneSAP',
            'SupplyCity__c' => 'Comune',
            'SupplyStreet__c' => 'Via',
            'SupplyStreetNumberExtension__c' => 'EstensCivico',
            'SupplySAPStreetCode__c' => 'CodiceViaStradarioSAP',
            'SupplyIsAddressVerified__c' => 'IndirizzoVerificato',
            'SupplyProvince__c' => 'Provincia',
            'SupplyIsAddressVerified__c' => 'FlagVerificato',
            'SupplyPlace__c' => 'Localita',
            'SupplyPlaceCode__c' => 'CodiceLocalita'
        };
        
        HDT_WRP_AddressObject result = new HDT_WRP_AddressObject();
        
        if(s!= null){
            List<sObject> listObject = new  List<sObject>();
            listObject.add((sObject)s);
            String type = listObject.get(0).getSObjectType().getDescribe().getName();
            Map<String,Boolean> mapBooleanObject = new Map<String,Boolean>();
            Map<String,String> mapObject = new Map<String,String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objectSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            
            for (String fieldName: fieldMap.keySet()){
                
                Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                if(fielddataType.name().toUpperCase() == 'STRING' || fielddataType.name().toUpperCase() == 'TEXTAREA'|| fielddataType.name().toUpperCase() == 'TEXT'){
                    mapObject.put(fieldMap.get(fieldName).getDescribe().getName(),(String)(s.get(fieldName)));
                }
                if(fielddataType.name().toUpperCase() == 'BOOLEAN'||fielddataType.name().toUpperCase() == 'CHECKBOX' ){
                    mapBooleanObject.put(fieldMap.get(fieldName).getDescribe().getName(),(Boolean)(s.get(fieldName)));
                }                
            }
            return result = mapFieldsAddressWithWrapObject(mapObject,mapBooleanObject,mapApiName);            
        }
        else{            
            result = new HDT_WRP_AddressObject('','','','','','','','','',false,false,'','');
        }
        return result;
    }
    
    public static void updateServicePointImplantAndSupplytype(Set<String> servicePointIdListSet){
        List<String> listServiceId = new List<String>();
        listServiceId.addAll(servicePointIdListSet);
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordByIdList(listServiceId,'Id,SupplyTypeTemp__c,ImplantTypeTemp__c');
        for(servicePoint__c sr : servicePointList){
            sr.supplytype__c = sr.supplytypeTemp__c;
            sr.implantType__c = sr.implanttypetemp__c;
        }
        serviceSrv.updateRecordRemiCode(servicePointList);
    }
    
    public static void blockblankonfield(List<ServicePoint__c> oldList , List<ServicePoint__c> newList){
        Map<String,ServicePoint__c> oldMap = new Map<String,Servicepoint__c>();
        for(ServicePoint__c srvOld : oldList){
            oldMap.put(srvOld.id,srvOld);
        }
        for(ServicePoint__c srv : newList){
            if(srv.SupplyType__c == null || srv.ImplantType__c == null){ 
                if(srv.SupplyType__c == null && oldMap.get(srv.id).supplyType__c != null){
                    srv.SupplyType__c = oldMap.get(srv.id).supplyType__c;
                }
                if(srv.ImplantType__c == null && oldMap.get(srv.id).ImplantType__c != null){
                    srv.ImplantType__c = oldMap.get(srv.id).ImplantType__c;
                }
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject mapFieldsAddressWithWrapObject(Map<String,String> mapObject,Map<String,Boolean> mapBooleanObject,Map<String,String> mapApiName){

        HDT_WRP_AddressObject h = new HDT_WRP_AddressObject();
        
        if(!mapObject.isEmpty()){
            for(String s :mapObject.keySet()){
                
                if(mapApiName.containsKey(s) && s == 'SupplyPostalCode__c'){
                    h.CAP = mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyCity__c'){
                    h.Comune= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreet__c'){
                    h.Via= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreetNumber__c'){
                    h.Civico= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreetNumberExtension__c'){
                    h.EstensCivico= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyProvince__c'){
                    h.Provincia= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyCountry__c'){
                    h.Stato= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPCityCode__c'){
                    h.CodiceComuneSAP= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPStreetCode__c'){
                    h.CodiceViaStradarioSAP= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPStreetCode__c'){
                    h.CodiceViaStradarioSAP= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyPlace__c'){
                    h.Localita= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyPlaceCode__c'){
                    h.CodiceLocalita= mapObject.get(s);
                }
            }
        }
        
        if(!mapBooleanObject.isEmpty()){
            for(String b :mapBooleanObject.keySet()){
                if(mapApiName.containsKey(b)&& b == 'SupplyIsAddressVerified__c'){
                    h.flagVerificato= mapBooleanObject.get(b);
                }
            }
        }
        return h;
    }

    public static Boolean checkTaxesCoerence (String tipoFornitura, String accise){

        if((tipoFornitura == 'Domestico' && accise == 'Imposta usi domestici') || (tipoFornitura == 'Non Domestico' && accise != 'Imposta usi domestici')){
            return true;
        }
        else{
            return false;
        }
    }
}