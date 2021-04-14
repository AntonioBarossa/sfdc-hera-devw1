public with sharing class HDT_SRV_DataEnrichmentPostSales {
    
    private HDT_QR_DataEnrichmentPostSales depsQr = new HDT_QR_DataEnrichmentPostSales();

    public String getPicklistValue(String objectName, String fieldName, String condition){

        String result;

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


}
