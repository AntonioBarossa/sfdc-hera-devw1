@SuppressWarnings('PMD.AvoidDebugStatements')
/**
* @author Luca Molino (luca.molino@engdb.com.br)
* @date 23/03/2021
* @description HDT_UTL_ServicePoint Class
* @history Luca Molino – 23/03/2021 – Created Class
* 18/11/2022 - Fabio Palladino - Class refactoring e gestione dati catastali 
*/
public with sharing class HDT_UTL_ServicePoint {
    
    private static HDT_QR_RecordType qrRecordType = new HDT_QR_RecordType(); //21/08/2021 - gabriele.rota@webresults.it
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint serviceSrv = new HDT_SRV_ServicePoint();
   

    @InvocableMethod(label='Invoke ServicePoint Enrichment')
    public static List<ServicePoint__c> servicePointEnrichment( List<HDT_UTL_FlowInput> inputs){
        //  List<ServicePoint__c> sp, List<String> responseSerialized

        HDT_WS_ArrichmentDataEntityResponse response = (HDT_WS_ArrichmentDataEntityResponse) JSON.deserialize(inputs[0].responseSerialized, HDT_WS_ArrichmentDataEntityResponse.class);
        List<ServicePoint__c> ret = extractDataFromArriccDataServiceWithExistingSp(inputs[0].servicePoint, response); 

        return ret;
    }
    
    @AuraEnabled
    public static List<ServicePoint__c> extractDataFromArriccDataServiceWithExistingSp(ServicePoint__c sp, HDT_WS_ArrichmentDataEntityResponse response){
        HDT_SRV_DataEnrichmentPostSales dataEnrich = new HDT_SRV_DataEnrichmentPostSales();
        HDT_QR_LandRegistry landRegistryQr = new HDT_QR_LandRegistry();
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
        if( String.isNotBlank(mapRes.get('PRESSIONE'))){
            spNew.Pressure__c  = Decimal.valueOf(mapRes.get('PRESSIONE'));
        }        
        if( String.isNotBlank(mapRes.get('CODICEREMI'))){
            spNew.RemiCode__c = mapRes.get('CODICEREMI');
        }
        if( String.isNotBlank(mapRes.get('CALIBRO1'))){
            String calDevName = 'CAL_' + mapRes.get('CALIBRO1');
            HDT_CaliberTranscode__mdt cmdCaliber = HDT_CaliberTranscode__mdt.getInstance(calDevName);
            spNew.MeterClass__c = cmdCaliber != null ? cmdCaliber.SfdcFieldValue__c : '';
        }
        if( String.isNotBlank(mapRes.get('AF_CLASSE'))){
            String devName = 'AF_' + mapRes.get('AF_CLASSE');
            HDT_AfClassTranscode__mdt cmdAfClass = HDT_AfClassTranscode__mdt.getInstance(devName);
            spNew.MeterClass__c = cmdAfClass != null ? cmdAfClass.SfdcFieldValue__c : '';
        }
        if( String.isNotBlank(mapRes.get('STATO_PUNTO'))){
            String metStatus = spNew.MeterStatus__c;
            switch on mapRes.get('STATO_PUNTO') {
                when 'H010', 'H030', 'H045', 'H050', 'H060' {
                    metStatus = 'Sospeso';
                }
                when 'H020' {
                    metStatus = 'Inattivo';
                }
                when 'H100' {
                    metStatus = 'Attivo';
                }
            }
            spNew.MeterStatus__c = metStatus;
        }
        if( String.isNotBlank(mapRes.get('MATRICOLA1'))){
            spNew.MeterSN__c = mapRes.get('MATRICOLA1');
        }
        if( String.isNotBlank(mapRes.get('BRANDSOCIETARIO'))){
            spNew.BrandLogo__c   = mapRes.get('BRANDSOCIETARIO');
        }
        if( String.isNotBlank(mapRes.get('DISTRIBUTORE'))){
            Account a = accountQr.getAccountByDistributorKey(mapRes.get('DISTRIBUTORE'));
            spNew.Distributor__c = a.Id != null ? a.Id : ((sp != null && sp.Distributor__c != null) ? sp.Distributor__c : null);
        }
        if( String.isNotBlank(mapRes.get('VENDITORE'))){
            String codiceVenditore = (String)mapRes.get('VENDITORE');
            List<HDT_MatriceSocietaVendita__mdt> salesCompanies = [SELECT SellerCompany__c FROM HDT_MatriceSocietaVendita__mdt WHERE SalesCompanyCode__c = :codiceVenditore WITH SECURITY_ENFORCED];
            if(!salesCompanies.isEmpty()){
                spNew.Vendor__c = salesCompanies[0].SellerCompany__c;
            }
            spNew.SalesCompanyCode__c = codiceVenditore;
        } else if( String.isNotBlank(mapRes.get('COMPANY'))){
            /* recupero il codice società per i casi di non energy -- cr005 */
            spNew.SalesCompanyCode__c = mapRes.get('COMPANY');
        }
        if( String.isNotBlank(mapRes.get('POD'))){
            spNew.ServicePointCode__c   = mapRes.get('POD');
            spNew.Name   = mapRes.get('POD');            
        }
        if( String.isNotBlank(mapRes.get('IMPIANTO'))){            
            spNew.SAPImplantCode__c = mapRes.get('IMPIANTO');
        }
        if( String.isNotBlank(mapRes.get('DESCRCOMM'))){            
            if(mapRes.get('DESCRCOMM')== 'Energia elettrica'){
                spNew.CommoditySector__c = 'Energia Elettrica';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Ele');
            }
            else if(mapRes.get('DESCRCOMM')== 'Gas'){
                spNew.CommoditySector__c = 'Gas';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Gas');
            }
            else if(mapRes.get('DESCRCOMM')== 'Acqua'){
                spNew.CommoditySector__c = 'Acqua';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Acqua');
                //Per la commodity Acqua l'impianto è sempre presente in SAP
                spNew.PlugPresence__c = 'Si';
            }
            else if(mapRes.get('DESCRCOMM')== 'Ambiente'){
                spNew.CommoditySector__c = 'Ambiente';
                spNew.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Ambiente'); 
                if(response.datiCatastali!=null && response.datiCatastali.size()>0 && spNew.Id != null) {
                    List <LandRegistry__c> landLstToInsert = new List<LandRegistry__c>();
                    try {     
                        List <LandRegistry__c> landLstToDelete = landRegistryQr.getTARILandRegistryByServicePointIds(new list<Id>{spNew.Id});
                        Id idLand = qrRecordType.getRecordTypeIdByName('HDT_RT_DatiCatastali_TARI');
                        
                        for(HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_DatiCatastaliResponseObject l : response.datiCatastali){                       
                            LandRegistry__c landReg = new LandRegistry__c();
                            landReg.DestinationUsage__c = l.destinazione;
                            landReg.CodeMissingRegistryData__c = l.codiceAssenzaDatiCatastali;
                            landReg.SapProgressive__c = l.progressivo;
                            landReg.LegalCity__c = l.comuneAmministrativo;
                            landReg.RegistryCity__c = l.comuneCatastale;
                            landReg.RegistryCityCode__c = l.codiceComuneCatastale;
                            landReg.Province__c = l.codiceProvincia;
                            landReg.UnitType__c = l.tipoUnita;
                            landReg.Sheet__c = l.foglio;
                            landReg.ParticleSheet__c = l.particella;
                            landReg.Subaltern__c = l.subalterno;
                            landReg.Title__c = l.qualificaTitolareUtenza;
                            landReg.RegistrySurface__c = Decimal.valueOf(l.superficeCatastale);
                            landReg.RecordTypeId = idLand;
                            landReg.ServicePoint__c = spNew.Id;
                            landReg.StartDate__c = dataEnrich.getDateFromString(mapRes.get('DATAATTIVAZIONE'));
                            landReg.EndDate__c = dataEnrich.getDateFromString('99991231'.equals(mapRes.get('DATACESSAZIONE'))? null: mapRes.get('DATACESSAZIONE'));
                            landReg.GlobalMigrationKey__c = 'DC_'+ spNew.SAPImplantCode__c + '_' + landReg.DestinationUsage__c + '_' + landReg.SapProgressive__c;
                            landLstToInsert.add(landReg);
                            
                        }
                        HDT_UTL_DatabaseService.deleteSObject(landLstToDelete);
                        HDT_UTL_DatabaseService.insertSObject(landLstToInsert);
                    } catch (Exception e) { 
                        System.debug(LoggingLevel.DEBUG,' Arricchimaneto LandRegistry Fallito: ' + e.getMessage());
                    }
                }
            }
        }
        if(mapRes.get('MOTGARANZIAFORN')==null){            
            spNew.Disconnectable__c = 'Si';
        }
        else if(mapRes.get('MOTGARANZIAFORN') == ''){            
            spNew.Disconnectable__c = 'No';
        }        
        if( String.isNotBlank(mapRes.get('RESELLER'))){
            spNew.isReseller__c = mapRes.get('RESELLER') == 'X';
        }
        else{
            spNew.isReseller__c = false;
        }
        if( String.isNotBlank(mapRes.get('DATACESSAZIONE')))
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
        if( String.isNotBlank(mapRes.get('DATACESSAZIONE'))){
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
        if(!String.isBlank(mapRes.get('TIPOIMPIANTO'))){
            spNew.ImplantType__c = dataEnrich.getPicklistValue('ServicePoint__c', 'ImplantType__c', mapRes.get('TIPOIMPIANTO'));
        }
        if(!String.isBlank(mapRes.get('MODPAGUSCITA'))){
            spNew.MethodsForOutgoingPayments__c = dataEnrich.getPicklistValue('ServicePoint__c', 'MethodsForOutgoingPayments__c', mapRes.get('MODPAGUSCITA'));
        }
        if(!String.isBlank(mapRes.get('AFPAG_FFUG'))){
            spNew.JointBottomAdhesion__c = dataEnrich.getPicklistValue('ServicePoint__c', 'JointBottomAdhesion__c', mapRes.get('AFPAG_FFUG'));
        }
        if(!String.isBlank(mapRes.get('AFPAGA_DEP'))){
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
        if( String.isNotBlank(mapRes.get('AFPAGA_FOG'))){
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFPAGA_FOG')))== 0) {
                spNew.PaySewer__c = 'No - Esente';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFPAGA_FOG')))== 1) {
                spNew.PaySewer__c = 'Si - Paga';                
            }
        }
        if( String.isNotBlank(mapRes.get('AFP_DEP355'))){
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFP_DEP355')))== 0) {
                spNew.PurificationInfoOnTheInvoice__c = 'Utenza non servita';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFP_DEP355')))== 1) {
                spNew.PurificationInfoOnTheInvoice__c = 'Utenza servita';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFP_DEP355')))== 2) {
                spNew.PurificationInfoOnTheInvoice__c = 'Utenza non servita con progettazione in corso';                
            }
            if(integer.valueOf(Decimal.valueOf(mapRes.get('AFP_DEP355')))== 3) {
                spNew.PurificationInfoOnTheInvoice__c = 'Utenza temporaneamente non servita';                
            }
        }        
        if( String.isNotBlank(mapRes.get('CODICE_ATECO'))){
            spNew.IstatCode__c = mapRes.get('CODICE_ATECO');
        }
        if( String.isNotBlank(mapRes.get('TUCATCOM00'))){
            spNew.RonchiCategoryCode__c = mapRes.get('TUCATCOM00');
        }
        if( String.isNotBlank(mapRes.get('TUSCATCOM0'))){
            spNew.RonchiSubCategoryCode__c = mapRes.get('TUSCATCOM0');
        }
        if( String.isNotBlank(mapRes.get('TRATAUNICA'))){
            spNew.SingleInstallmentOperating__c = mapRes.get('TRATAUNICA');
        }
        if( String.isNotBlank(mapRes.get('DI_TRATAUNICA'))){
            spNew.SingleInstallmentValidityDate__c = date.parse(mapRes.get('DI_TRATAUNICA'));
        }
        if( String.isNotBlank(mapRes.get('AFVASCA_AC'))){
            spNew.HasAccumulationTanks__c = Boolean.valueOf(mapRes.get('AFVASCA_AC'));
        }
        if( String.isNotBlank(mapRes.get('CONSUMOCAPDR'))){            
            spNew.AnnualConsumption__c = integer.valueOf(Decimal.valueOf(mapRes.get('CONSUMOCAPDR')));
        }
        if( String.isNotBlank(mapRes.get('CONSUMOANNUOEE'))){         
            spNew.AnnualConsumption__c = integer.valueOf(Decimal.valueOf(mapRes.get('CONSUMOANNUOEE')));
        }
        if( String.isNotBlank(mapRes.get('AQCNS_ANNO'))){         
            spNew.AnnualConsumption__c = integer.valueOf(Decimal.valueOf(mapRes.get('AQCNS_ANNO')));
        }
        if( String.isNotBlank(mapRes.get('TFNCE00000'))){      
            spNew.NumberOfTARIMembers__c = (mapRes.get('TFNCE00000'));
        } 
        if( String.isNotBlank(mapRes.get('TFNCDC0000'))){    
            spNew.NumberOfTARIMembers__c = (mapRes.get('TFNCDC0000'));
        }        
        if( String.isNotBlank(mapRes.get('AFNUM_COMP'))){         
            spNew.NumberOfCommunityMembers__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFNUM_COMP')));
        }        
        if( String.isNotBlank(mapRes.get('AFUADRS'))){         
            spNew.ResidentDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUADRS')));
        }
        if( String.isNotBlank(mapRes.get('AFUADNR'))){         
            spNew.NotResidentDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUADNR')));
        }
        if( String.isNotBlank(mapRes.get('AFUND'))){         
            spNew.NotDomesticHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUND')));
        }
        if( String.isNotBlank(mapRes.get('AFUNDA'))){         
            spNew.AgriculturalHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDA')));
        }
        if( String.isNotBlank(mapRes.get('AFUNDC'))){         
            spNew.CommercialHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDC')));
        }
        if( String.isNotBlank(mapRes.get('AFUNDI'))){         
            spNew.IndustrialHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDI')));
        }
        if( String.isNotBlank(mapRes.get('AFUNDZ'))){
            spNew.ZootechnicalHousingUnit__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFUNDZ')));
        }
        if( String.isNotBlank(mapRes.get('AFBI_DIAM1'))){         
            spNew.HydrantMouthsNumberA__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFBI_DIAM1')));
        }
        if( String.isNotBlank(mapRes.get('AFBI_DIAM2'))){         
            spNew.HydrantMouthsNumberB__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFBI_DIAM2')));
        }
        if( String.isNotBlank(mapRes.get('AF_BOC_IDR'))){         
            spNew.HydrantMouthsNumber__c = integer.valueOf(Decimal.valueOf(mapRes.get('AF_BOC_IDR')));
        }
        if( String.isNotBlank(mapRes.get('SUP_DICH'))){         
            spNew.AreaDeclaredTARI__c = integer.valueOf(Decimal.valueOf(mapRes.get('SUP_DICH')));
        }
        if( String.isNotBlank(mapRes.get('SUP_RILEVANTE'))){         
            spNew.AreaRelevantForCalculation__c  = integer.valueOf(Decimal.valueOf(mapRes.get('SUP_RILEVANTE')));
        }
        if( String.isNotBlank(mapRes.get('MERCATO'))){
            String mercato =  mapRes.get('MERCATO').containsIgnoreCase('STGM') ? 'STGM' : mapRes.get('MERCATO').substring(0,1) + mapRes.get('MERCATO').substring(1,mapRes.get('MERCATO').length()).toLowerCase();
            Boolean isStg = mapRes.get('DEFINIZIONEOFFERTA')!=null && mapRes.get('DEFINIZIONEOFFERTA').containsIgnoreCase('STG_')? true:false;
            mercato = mercato.containsIgnoreCase('Tutela')?'Regolamentato':mercato;
            mercato = isStg ? 'Regolamentato':mercato;
            spNew.MarketOrigin__c = mercato;
        }
        if( String.isNotBlank(mapRes.get('FLAGTELEGESTIBILE'))){            
            spNew.IsRemoteManaged__c = 'X'.equalsIgnoreCase(mapRes.get('FLAGTELEGESTIBILE'));
        }
        if( String.isNotBlank(mapRes.get('POTENZACONTRATTUALE'))){
            Decimal d = decimal.valueOf(mapRes.get('POTENZACONTRATTUALE'));
            spNew.PowerContractual__c = d;
        }
        if( String.isNotBlank(mapRes.get('POTENZATECNICA'))){            
            Decimal d = decimal.valueOf(mapRes.get('POTENZATECNICA'));
            spNew.PowerAvailable__c  =d;            
        }
        if( String.isNotBlank(mapRes.get('TENSIONE'))){            
            spNew.VoltageLevel__c = mapRes.get('TENSIONE');
        }
        if( String.isNotBlank(mapRes.get('RESIDENTEINDFORN'))){            
            spNew.Resident__c = mapRes.get('RESIDENTEINDFORN') == 'SI' ? true : false;
        }        
        if( String.isNotBlank(mapRes.get('CAP'))){            
            spNew.SupplyPostalCode__c = mapRes.get('CAP');
        }
        if( String.isNotBlank(mapRes.get('VIA'))){
            spNew.SupplyStreet__c  = mapRes.get('VIA');
            spNew.SupplyStreetName__c = mapRes.get('VIA');
        }
        if( String.isNotBlank(mapRes.get('CIVICO'))){
            spNew.SupplyStreetNumber__c  = mapRes.get('CIVICO');
        }
        if( String.isNotBlank(mapRes.get('LOCALITA'))){
            spNew.SupplyCity__c  = mapRes.get('LOCALITA');
            if(!String.isBlank(spNew.CommoditySector__c) && 'Acqua'.equalsIgnoreCase(spNew.CommoditySector__c)){
                List<TownATOTable__c> atoList = [Select id, ATO__c from TownATOTable__c where Town__c =: spNew.SupplyCity__c WITH SECURITY_ENFORCED];
                spNew.ATO__c = (!atoList.isEmpty() && String.isNotBlank(atoList[0].ATO__c)) ? atoList[0].ATO__c : '';
            }
        }
        if( String.isNotBlank(mapRes.get('CODICEVIA'))){
            spNew.SupplySAPStreetCode__c = mapRes.get('CODICEVIA');
            spNew.SupplyStreetCode__c = mapRes.get('CODICEVIA');
        }
        if( String.isNotBlank(mapRes.get('REGIONE'))){
            spNew.SupplyProvince__c = mapRes.get('REGIONE');
        }
        if( String.isNotBlank(mapRes.get('CODIFICALOCALITA'))){
            spNew.SupplySAPCityCode__c = mapRes.get('CODIFICALOCALITA');
            spNew.SupplyCityCode__c = mapRes.get('CODIFICALOCALITA');
        }
        if( String.isNotBlank(mapRes.get('CODICEPAESE'))){
            spNew.SupplyCountry__c = mapRes.get('CODICEPAESE') == 'IT' ? 'Italia' : 'Estero';
        }
        if( String.isNotBlank(mapRes.get('LOCALITA'))
           && String.isNotBlank(mapRes.get('CIVICO'))
           && String.isNotBlank(mapRes.get('CODIFICALOCALITA'))
           && String.isNotBlank(mapRes.get('VIA'))
           && String.isNotBlank(mapRes.get('CODICEVIA')))
        {
            spNew.SupplyisAddressVerified__c = true;
        }
        if( String.isNotBlank(mapRes.get('AFNCOMP'))){
            spNew.NumberOfFamilyMembers__c = integer.valueOf(Decimal.valueOf(mapRes.get('AFNCOMP')));
        }
        if( String.isNotBlank(mapRes.get('PADRE-FIGLIO'))){
            spNew.MeterRelation__c = mapRes.get('PADRE-FIGLIO');
        }
        if( String.isNotBlank(mapRes.get('CATEGORIATARIFFA'))){
            List<AllineamentoGAA__c> listAllineamentoGaa = [SELECT Frequenza__c FROM AllineamentoGAA__c WHERE Comune__c =: spNew.SupplyCity__c AND Rate_Category__c =: mapRes.get('CATEGORIATARIFFA') WITH SECURITY_ENFORCED];
    
            if(listAllineamentoGaa.size() > 0){
                spNew.AlignmentFrequencyGAA__c = listAllineamentoGaa.get(0).Frequenza__c;
            }
        }
        if( String.isNotBlank(mapRes.get('FATTURACOLLETTIVA'))){
            spNew.AggregateBilling__c = mapRes.get('FATTURACOLLETTIVA');
        }

        if( String.isNotBlank(mapRes.get('DATAULTIMAGAA'))){
            spNew.DateOfLastAlignmentGAA__c = dataEnrich.alignGaaDate(String.valueOf(spNew.DateOfLastAlignmentGAA__c), mapRes.get('DATAULTIMAGAA'));
        }

        //Reset flag di check creazione activity di "Modifica Indirizzo Fornitura", tale flag verrà impostato a true nel caso in cui si vada a modificare l'indirizzo sul form del service point.
        spNew.IsAddressChanged__c = false;

        if( String.isNotBlank(mapRes.get('CA'))){
            spNew.SAPContractAccountCode__c = mapRes.get('CA');
        }
        Map<String, Account> accBpMap = new Map<String, Account>();
        if(mapRes.get('BP') != null){
            List<Account> accBp = accountQr.getAccountByCustomerCode(mapRes.get('BP'));
            if (!accBp.isEmpty()) {
                spNew.Account__c = accBp[0].Id;
                accBpMap.put(accBp[0].Id, accBp[0]);
                spNew.CustomerCodeSAP__c = null;
            }
            else {
                spNew.CustomerCodeSAP__c = mapRes.get('BP');
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
            tipoFornitura = tipoImpianto != null && tipoImpianto.equalsIgnoreCase('1101-Domestico') ? 'Domestico' : 'Non Domestico';    
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

    public class HDT_UTL_FlowInput{

        @InvocableVariable
        public ServicePoint__c servicePoint;
        @InvocableVariable
        public String responseSerialized;
    }
}