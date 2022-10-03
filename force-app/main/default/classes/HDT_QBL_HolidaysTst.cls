@isTest
public with sharing class HDT_QBL_HolidaysTst {
    @TestSetup
    static void setup()
    {
        TechnicalHolidaysCalendar__c holidaysDate = new TechnicalHolidaysCalendar__c();
        holidaysDate.HolidayDate__c = System.today();
        holidaysDate.Year__c = System.today().year();

        insert holidaysDate;
        
    }

    @isTest
    static void executeSuccessTst()
    {
        Test.setMock(HttpCalloutMock.class, new HDT_WS_HolidayMock(2));
        Test.startTest();
            System.enqueueJob(new HDT_QBL_Holidays());
        Test.stopTest();
        List<TechnicalHolidaysCalendar__c> holidaysTest = [SELECT Id, HolidayDate__c, Year__c FROM TechnicalHolidaysCalendar__c];
        System.assertEquals(true, holidaysTest.size() > 1, 'Creazione Fallita');
    }
    
    @isTest
    static void executeFailedTst()
    {
        Test.setMock(HttpCalloutMock.class, new HDT_WS_HolidayMock(1));
        Test.startTest();
            System.enqueueJob(new HDT_QBL_Holidays());
        Test.stopTest();
        List<TechnicalHolidaysCalendar__c> holidaysTest = [SELECT Id FROM TechnicalHolidaysCalendar__c];
        System.assertEquals(true, holidaysTest.size() == 1, 'Creazione Fallita');
    }

    @isTest
    static void executeNullTst()
    {
        Test.setMock(HttpCalloutMock.class, new HDT_WS_HolidayMock(0));
        Test.startTest();
            System.enqueueJob(new HDT_QBL_Holidays());
        Test.stopTest();
        List<TechnicalHolidaysCalendar__c> holidaysTest = [SELECT Id FROM TechnicalHolidaysCalendar__c];
        System.assertEquals(true, holidaysTest.size() == 1, 'Creazione Fallita');
    }

    class HDT_WS_HolidayMock implements HttpCalloutMock
    {

        public Integer isSuccess;
        public HDT_WS_HolidayMock(Integer isSuccess)
        {
            this.isSuccess = isSuccess;
        }

        public HttpResponse respond(HttpRequest request)
        {

            HDT_QBL_Holidays.HDT_WRP_Response resWrp = new HDT_QBL_Holidays.HDT_WRP_Response();
            resWrp.status = isSuccess == 2 ? 'success' : 'failed';
            resWrp.correlationId = 'asiodjas8jaosidjaoskdmas9d8ajsd';
            resWrp.timestamp = 'asldajsidoajsdjaoskdaosdi';
            if(isSuccess == 1)
            {
                List<HDT_QBL_Holidays.HDT_WRP_ErrorDetail> errorDetailsList = new List<HDT_QBL_Holidays.HDT_WRP_ErrorDetail>();
                HDT_QBL_Holidays.HDT_WRP_ErrorDetail errorDetail = new HDT_QBL_Holidays.HDT_WRP_ErrorDetail();
                errorDetail.code = 'testcode';
                errorDetail.message = 'testcode';
                errorDetail.additionalInfo = 'testcode';
                errorDetailsList.add(errorDetail);
                resWrp.errorDetails = errorDetailsList;
            }
            else if(isSuccess == 2)
            {
                HDT_QBL_Holidays.HDT_WRP_Data data = new HDT_QBL_Holidays.HDT_WRP_Data();
                List<HDT_QBL_Holidays.HDT_WRP_Holidays> holidaysList = new List<HDT_QBL_Holidays.HDT_WRP_Holidays>();
                HDT_QBL_Holidays.HDT_WRP_Holidays holidayOne = new HDT_QBL_Holidays.HDT_WRP_Holidays();
                HDT_QBL_Holidays.HDT_WRP_Holidays holidayTwo = new HDT_QBL_Holidays.HDT_WRP_Holidays();
                holidayOne.calendarDate = String.valueOf(System.today());
                holidayTwo.calendarDate = String.valueOf(System.today().addDays(2));
                holidaysList.add(holidayOne);
                holidaysList.add(holidayTwo);
                data.holidayDate = holidaysList;
                data.responseMsg = 'test';
                resWrp.data = data;
            }


            Integer statusCode = isSuccess == 2 ? 200 : 502;
            String statusString = isSuccess == 2 ? 'OK' : 'KO';

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resWrp));
            response.setStatusCode(statusCode);
            response.setStatus(statusString);

            return response;
        }
    }
}
