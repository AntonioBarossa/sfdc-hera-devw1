@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_DataEnrichmentPostSales {
    
    private final Map<String,String> SALESCOMPANY_MAP = new Map<String,String>{
        '13V0000000'=>'Hera Comm S.p.A.',
        '10V0000000'=>'Hera Comm S.p.A.',
        '10V0000160'=>'Hera Comm Marche',
        '11-HERASPA'=>'Marche Multiservizi S.p.A',
        '1200000000'=>'Marche Multiservizi TARI'};
    
    private HDT_QR_DataEnrichmentPostSales depsQr = new HDT_QR_DataEnrichmentPostSales();

    public String getPicklistValue(String objectName, String fieldName, String condition){

        String result;
        if ('Case'.equalsIgnoreCase(objectName) && 'Market__c'.equalsIgnoreCase(fieldName) && 'Tutela'.equalsIgnoreCase(condition)){
            condition = 'Regolamentato';
        }

        if(fieldName == 'PhaseTypeAvailable__c'){
            try{
                Decimal phaseCondition = Decimal.valueOf(condition);
                if(phaseCondition <= 1.0 ){
                    condition = 'Monofase';
                }
                else {
                    condition = 'Trifase';
                }
            }
            catch (Exception e) {
                return null;                
            }
        }

        if(fieldName == 'Taxes__c'){
            if(condition == 'E_IMPOST'){
                condition = 'Imposta usi domestici';
            }
        }

        List<PicklistEntry> entryList = ((SObject) (Type.forName('Schema.'+objectName).newInstance())).getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();

        for(PicklistEntry entry : entryList){
            // Per non matchare il testo 10% se condition = 10
            if(entry.getValue().containsIgnoreCase(condition + '%')){
                continue;
            }
            if(entry.getValue().containsIgnoreCase(condition)){
                result = entry.getValue();
            }
        }

        return result;
    }

    public Boolean getBoolFromString(String value){

        Boolean result;
        if(value == 'SI' || value == 'X'){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    public Date getDateByYear(String year){
        Date result;
        result = Date.newInstance(Integer.valueOf(year), 1, 1);
        return result;
    }

    public String getBillingProfileIdBySapCode(String sapCode){
        String result;
        result = depsQr.getBillingProfileIdBySapCode(sapCode).Id;
        return result;
    }

    public Case populateCase(Map<String, Object> transcodeMap, Case currentCase){
        for(String fieldName : transcodeMap.keySet()){
            if(fieldName != null && String.isNotBlank(fieldName))
            {
                currentCase.put(fieldName, transcodeMap.get(fieldName));
            }
        }
        return currentCase;
    }

    public String getDeliveryAddress(String recordId){

        BillingProfile__c billingProfile = new BillingProfile__c();
        String streetName;
        String streetNumber;
        String streetNumberExt;
        String city;
        String province;
        String postalCode;
        String country;

        String deliveryAddres;

        billingProfile = depsQr.getBillingProfileInvoiceData(recordId);

        streetName = billingProfile.InvoicingStreetName__c != null 
            ? billingProfile.InvoicingStreetName__c + ' '
            : '';
        streetNumber = billingProfile.InvoicingStreetNumber__c != null 
            ? billingProfile.InvoicingStreetNumber__c + ' '
            : '';
        streetNumberExt = billingProfile.InvoicingStreetNumberExtension__c != null 
            ? billingProfile.InvoicingStreetNumberExtension__c + ', '
            : '';
        city = billingProfile.InvoicingCity__c != null
            ? billingProfile.InvoicingCity__c + ' '
            : '';
        province = billingProfile.InvoicingProvince__c != null
            ? billingProfile.InvoicingProvince__c + ', '
            : '';
        postalCode = billingProfile.InvoicingPostalCode__c != null 
            ? billingProfile.InvoicingPostalCode__c + ', '
            : '' ;
        country = billingProfile.InvoicingCountry__c != null 
            ? billingProfile.InvoicingCountry__c
            : '';

        deliveryAddres = streetName 
        + streetNumber 
        + streetNumberExt 
        + city 
        + province 
        + postalCode 
        + country;

        return deliveryAddres;

    }


    public String calculateSalesCompany(String salesCompanyCode){
        
        return SALESCOMPANY_MAP.get(salesCompanyCode);
    }


    public String getCaliber(String caliber){ 
        String calDevName = 'CAL_' + caliber;
        HDT_CaliberTranscode__mdt cmdtCaliber = HDT_CaliberTranscode__mdt.getInstance(calDevName);
        return cmdtCaliber != null ? cmdtCaliber.SfdcFieldValue__c : '';
    }

    public String getOpzione(String option){

        String result;

        switch on option{

            when 'E_UD_TDR','E_UD_TDNR'{
                result = 'Domestici-TD';
            }
            when 'E_MTIP'{
                result = 'AEEG Opzione MTIP-E_MTIP';
            }
            when 'E_BTIP'{
                result = 'AEEG Opzione BTIP-E_BTIP';
            }
            when 'E_MTA1'{
                result = 'AEEG Opz MTA1 fin 100kW-E_MTA1';
            }
            when 'E_BTA1'{
                result = 'AEEG Opz BTA1 <= 1,5 kW-E_BTA1';
            }
            when 'E_MTA3'{
                result = 'AEEG Op MTA3 olt 500kW-E_MTA3';
            }
            when 'E_MTA2'{
                result = 'AEEG Op MTA2 >100 <=500-E_MTA2';
            }
            when 'E_BTA6'{
                result = 'AEEG Op BTA6 olt 16,5kW-E_BTA6';
            }
            when 'E_BTA5'{
                result = 'AEEG Op BTA5 > 10 kW-E_BTA5';
            }
            when 'E_BTA4'{
                result = 'AEEG Op BTA4 >6 <=10 kW-E_BTA4';
            }
            when 'E_BTA3'{
                result = 'AEEG Op BTA3 >3 <=6 kW-E_BTA3';
            }
            when 'E_BTA2'{
                result = 'AEEG Op BTA2 >1,5<=3 kW-E_BTA2';
            }
            when 'E_ALTA'{
                result = 'AEEG Op ALTA fin 220 kV-E_ALTA';
            }
        }

        return result;

    }

    /**
      Possibili valori mandati nei campi FATTURACOLLETTIVA/DESCRFATTURACOLL
       1 - Il contratto deve essere fatturato con altri contratti
       2 - Il contratto può essere fatturato con altri contratti
       3 - Il contratto non può mai essere fatt. con altri contratti
       Poichè questi valori servono solo sul processo 'Unificazione/Separazione BP-CA-Bolletta',
       scriviamo la DESCRFATTURACOLL sul campo Note__c del Case. Siccome questo campo
       è usato anche da altri processo per altri scopi, limitiamo la scrittura del campo solo al processo dedicato.
     */
    public String writeCollectiveBillType(String sapValue, Case currentCase) {

        if (currentCase.Type != null && currentCase.Type.equals('Unificazione/Separazione BP-CA-Bolletta')) {
            return 'Tipo fattura collettiva: ' + sapValue;
        }

        return '';
    }

    /**
       Poichè il codice blocco serve solo sul processo 'Sollecito Emissione Bolletta',
       scriviamo il codice sul campo Note__c del Case. Siccome questo campo
       è usato anche da altri processo per altri scopi, limitiamo la scrittura del campo solo al processo dedicato.
     */
    public String writeBlockCode(String sapValue, Case currentCase) {

        System.debug(LoggingLevel.DEBUG, 'writeBlockCode: ' + sapValue + ' ' + currentCase);
        if (currentCase.Type != null && currentCase.Type.equals('Sollecito Emissione Bolletta')) {
            return 'Codice Blocco: ' + sapValue;
        }

        return '';
    }

    public Date getDateFromString(String stringDate){
        //String Date format must be yyyymmdd
        Date toReturn = null;
        if(String.isNotBlank(stringDate)){
            Integer year = Integer.valueOf(stringDate.substring(0,4));
            Integer month = Integer.valueOf(stringDate.substring(4,6));
            Integer day = Integer.valueOf(stringDate.substring(6,8));
            year = year > 4000 ? 4000 : year;
            toReturn = Date.newInstance(year,month,day);
        }
        return toReturn;       
    }

    public Boolean variationsBlock(String sapValue){
        return 'T1'.equalsIgnoreCase(sapValue);
    }

    public static AmministrazioneSottotipologiaUso__c handleSubType (String salesComp, String prodCode) {

        List <HDT_HeraCompany__mdt> compCodeList = [SELECT CompanyCode__c FROM HDT_HeraCompany__mdt  WHERE MasterLabel =: salesComp WITH SECURITY_ENFORCED];
            
        String campCode = null;
        
        if(compCodeList.size() > 0) {
            campCode = compCodeList[0].CompanyCode__c;
        }
        
        System.debug(LoggingLevel.DEBUG, campCode);
    
        List <AmministrazioneSottotipologiaUso__c> subTypList = [SELECT SottotipologiaUso__c, IntendedUse__c FROM AmministrazioneSottotipologiaUso__c WHERE Societa__c=: campCode AND
        CodiceCategoriaTariffa__c=: prodCode AND Attivo__c=TRUE WITH SECURITY_ENFORCED];

        if(!subTypList.isEmpty()){
            return subTypList[0];
        }

        return (new AmministrazioneSottotipologiaUso__c(SottotipologiaUso__c = null, IntendedUse__c = null));
    
    }

    public String transCodeSiNo (String  valueIn) {
        String valueOut = null;
        valueOut = (valueIn == '0' || valueIn == '0.0000000') ? 'No' : valueOut;
        valueOut = (valueIn == '1' || valueIn == '1.0000000') ? 'Si' : valueOut;
        valueOut = (valueIn == '2' || valueIn == '2.0000000') ? 'Si - Ridotta' : valueOut;      
        return valueOut;   
    }

    public String transcodificaInfoDepurazione (String  valueIn) {
        String valueOut = null;
        valueOut = (valueIn == '0' || valueIn == '0.0000000') ? 'Utenza non servita' : valueOut;
        valueOut = (valueIn == '1' || valueIn == '1.0000000') ? 'Utenza servita' : valueOut;
        valueOut = (valueIn == '2' || valueIn == '2.0000000') ? 'Utenza non servita con progettazione in corso' : valueOut;      
        valueOut = (valueIn == '3' || valueIn == '3.0000000') ? 'Utenza temporaneamente non servita' : valueOut;      
        return valueOut;   
    }

   /* public  String transCodeDoubleOppositeToDecimal(String doubleInput){

        String doubleOutput = doubleInput == '0.0000000' ? '1' : '0';
        doubleOutput = transCodeSiNo(doubleOutput);

        System.debug(LoggingLevel.DEBUG, 'La transcodifica di AFPAG_FFUG risulta: ' + doubleOutput);
        return doubleOutput;
       }*/

    public  String transCodeDoubleToString(String doubleInputStr){
        String doubleOutStr = null;

        doubleOutStr = (doubleInputStr =='0.0000000') ? 'Esente' : doubleOutStr;
        doubleOutStr = (doubleInputStr =='1.0000000') ? 'Intera' : doubleOutStr;
        doubleOutStr = (doubleInputStr =='2.0000000') ? 'Ridotta' : doubleOutStr;

        return doubleOutStr;
    }

    public  String transCodeSiNoConDescr(String doubleInputStr){
        String doubleOutStr = null;

        doubleOutStr = (doubleInputStr =='0.0000000') ? 'No - Esente' : doubleOutStr;
        doubleOutStr = (doubleInputStr =='1.0000000') ? 'Si - Paga' : doubleOutStr;
        doubleOutStr = (doubleInputStr =='2.0000000') ? 'Si - Ridotta' : doubleOutStr;

        return doubleOutStr;
    }

    public Date alignGaaDate(String oldDateString, String newDateString){
        Date newDate = getDateFromString(newDateString);
        Date oldDate = String.isNotBlank(oldDateString) ? Date.valueOf(oldDateString) : null;
        oldDate = (oldDate == null) ? newDate : oldDate;
        newDate = (newDate == null) ? oldDate : newDate;
        return newDate > oldDate ? newDate : oldDate;
    }
}