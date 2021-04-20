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

}