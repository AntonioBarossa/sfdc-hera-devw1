public with sharing class HDT_SRV_DataEnrichmentPostSales {
    
    private HDT_QR_DataEnrichmentPostSales depsQr = new HDT_QR_DataEnrichmentPostSales();

    public String getPicklistValue(String objectName, String fieldName, String condition){

        String result;

        if(fieldName == 'PhaseTypeAvailable__c'){

            Try{   
                Decimal phaseCondition = Decimal.valueOf(condition);
                if(phaseCondition <= 1.0 ){

                    condition = 'Monofase';

                }else{

                    condition = 'Trifase';

                }
            }catch(Exception e){

                System.debug(e.getMessage());
                return null;

            }

        }

        List<PicklistEntry> entryList =
            ((SObject) (Type.forName('Schema.'+objectName).newInstance())).getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();

        for(PicklistEntry entry : entryList){

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

        }else{

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

            currentCase.put(fieldName, transcodeMap.get(fieldName));
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

        String salesCompany;

        switch on salesCompanyCode {

            when '13V0000000'{

                salesCompany = 'Hera Comm S.p.A.';

            }
            when '10V0000160'{

                salesCompany = 'Hera Comm Marche';

            }

        }

        return salesCompany;

    }


    public String getCaliber(String caliber){

        String result;

        switch on caliber{

            when 'GRT005'{

                result = 'G10';

            }
            when 'GRT010'{

                result = 'G100';

            }
            when 'GRT015'{

                result = 'G1000';

            }
            when 'GRT006'{

                result = 'G16';

            }when 'GRT011'{

                result = 'G160';

            }
            when 'GRT016'{

                result = 'G1600';

            }
            when 'GRT002'{

                result = 'G2,5';

            }
            when 'GRT007'{

                result = 'G25';

            }when 'GRT012'{

                result = 'G250';

            }
            when 'GRT003'{

                result = 'G4';

            }
            when 'GRT008'{

                result = 'G40';

            }
            when 'GRT013'{

                result = 'G400';

            }when 'GRT017'{

                result = 'G4000';

            }
            when 'GRT004'{

                result = 'G6';

            }
            when 'GRT009'{

                result = 'G65';

            }
            when 'GRT014'{

                result = 'G650';

            }when 'GRT018'{

                result = 'G6500';

            }


        }

        return result;

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

        if (currentCase.Type.equals('Unificazione/Separazione BP-CA-Bolletta')) {
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

        System.debug('writeBlockCode: ' + sapValue + ' ' + currentCase);
        if (currentCase.Type.equals('Sollecito Emissione Bolletta')) {
            return 'Codice Blocco: ' + sapValue;
        }

        return '';
    }

    public Date getDateFromString(String stringDate){

        //String Date is yyyymmdd
        
        Integer year = Integer.valueOf(stringDate.substring(0,4));
        Integer month = Integer.valueOf(stringDate.substring(4,6));
        Integer day = Integer.valueOf(stringDate.substring(6,8));

        if(year > 4000){

            year = 4000;

        }

        return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        
    }

    public Boolean variationsBlock(String sapValue){

        return sapValue.equalsIgnoreCase('T1');

    }

}