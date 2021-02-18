public inherited sharing class HDT_LC_SelfReading {

    @AuraEnabled
    public static String updateSelfReading(String fields, 
    String readingCustomerDate, 
    String relatedObj, 
    String recordId,
    String commodity){

        List<HDT_UTL_SelfReadingObject> resultReading = new List<HDT_UTL_SelfReadingObject>();

        //List<Reading__c> listReading = new List<Reading__c>();

        List<Object> listJson = (List<Object>) JSON.deserializeUntyped(fields);


        for(Object singleObj : listJson){

            Map<String, Object> mapObj = (Map<String, Object>) singleObj;

            resultReading.add(new HDT_UTL_SelfReadingObject(
                String.valueOf(mapObj.get('id')),
                String.valueOf(mapObj.get('readingType')),
                String.valueOf(mapObj.get('readingDate')),
                String.valueOf(mapObj.get('reading')),
                String.valueOf(mapObj.get('readingCustomer')),
                String.valueOf(mapObj.get('band')),
                String.valueOf(mapObj.get('meterCode')),
                String.valueOf(mapObj.get('register')),
                String.valueOf(mapObj.get('unitMeasure'))));

        }

        /*for(HDT_UTL_SelfReadingObject readObj : resultReading){

            if(relatedObj == 'Case'){
                listReading.add(new Reading__c(
                    Name = commodity == 'Gas' ? readObj.id : 'R0 '+readObj.id,
                    ReadingType__c = readObj.readingType,
                    ReadingDate__c = Date.valueOf(readObj.readingDate),
                    ReadingBand__c = readObj.band,
                    ReadingSerialNumber__c = readObj.meterCode,
                    ReadingUnit__c = readObj.unitMeasure,
                    ReadingValue__c = readObj.readingCustomer,
                    Case__c = recordId));

            }else if(relatedObj == 'Order'){

                listReading.add(new Reading__c(
                    Name = commodity == 'Gas' ? readObj.id : 'R0 '+readObj.id,
                    ReadingType__c = readObj.readingType,
                    ReadingDate__c = Date.valueOf(readObj.readingDate),
                    ReadingBand__c = readObj.band,
                    ReadingSerialNumber__c = readObj.meterCode,
                    ReadingUnit__c = readObj.unitMeasure,
                    ReadingValue__c = readObj.readingCustomer,
                    Order__c = recordId));                


            }
        }*/

        //System.debug(listReading);

    

        //insert with DB service



        return null;

    }


    public class HDT_UTL_SelfReadingObject{

        public String id;

        public String readingType;

        public String readingDate; 

        public String reading;

        public String readingCustomer;

        public String band;

        public String meterCode;
        
        public String register;

        public string unitMeasure;

        public HDT_UTL_SelfReadingObject(String id, String readingType, String readingDate, String reading, String readingCustomer,
        String band, String meterCode, String register, String unitMeasure){

            this.id = id;

            this.readingType = readingType;

            this.readingDate = readingDate;

            this.reading = reading;

            this.readingCustomer = readingCustomer;

            this.band = band;

            this.meterCode = meterCode;

            this.register = register;

            this.unitMeasure = unitMeasure;


        }

    }


}