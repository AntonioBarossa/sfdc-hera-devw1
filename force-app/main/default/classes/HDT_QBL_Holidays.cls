public with sharing class HDT_QBL_Holidays implements Queueable, Database.AllowsCallouts
{
    public void execute(QueueableContext context)
    {

        List<TechnicalHolidaysCalendar__c> newHolidays = new List<TechnicalHolidaysCalendar__c>();
        /* Query all TechnicalHolidaysCalendar__c*/
        List<TechnicalHolidaysCalendar__c> existingHolidays = [SELECT HolidayDate__c, Year__c FROM TechnicalHolidaysCalendar__c];
        /* Get current year */
        Integer year = System.today().year();

        for( integer i = 0; i < 2; i++ )
        {
            year = year + i;
            /* Exeute Callout */
            String response = makeRequest(year);
            /* Handle Response */
            newHolidays.addAll(handleResponse(response, year, existingHolidays));
        }

        if(!newHolidays.isEmpty())
        {
            HDT_UTL_DatabaseService.insertSObject(newHolidays);
        }
    }



    private String makeRequest(Integer year)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        HDT_WRP_RequestBody requestBody = new HDT_WRP_RequestBody();
        /* callId indica la nazionone per cui si vuole verificare il calendario, se lasciato vuoto viene considerato IT */
        requestBody.callId = '';
        requestBody.dateFrom = Date.newInstance(year, 01, 01);
        requestBody.dateTo = Date.newInstance(year, 12, 31);
        requestBody.year = String.valueOf(year);

        request.setEndpoint('Callout:MulesoftBasePath'+'/holidays-calendar/search');
        request.setMethod('POST');
        request.setBody(JSON.serialize(requestBody));
        request.setTimeout(120000);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');

        response = http.send(request);

        return response.getBody() != null ? response.getBody() : '';

    }

    private List<TechnicalHolidaysCalendar__c> handleResponse(String responseBody, Integer year, List<TechnicalHolidaysCalendar__c> existingHolidays)
    {
        List<TechnicalHolidaysCalendar__c> result = new List<TechnicalHolidaysCalendar__c>();

        if(String.isBlank(responseBody))
        {
            return result;
        }

        HDT_WRP_Response response = (HDT_WRP_Response) JSON.deserialize(responseBody, HDT_WRP_response.class);
        if(response.data == null)
        {
            return result;
        }
        if(response.data.holidayDate == null || response.data.holidayDate.isEmpty())
        {
            return result;
        }
        for(HDT_WRP_Holidays singleDate : response.data.holidayDate)
        {
            if(singleDate.calendarDate == null || String.isBlank(singleDate.calendarDate))
            {
                continue;
            }
            Date singleDt = tryParseDate(singleDate.calendarDate);
            if(singleDt != null && !existDate(singleDt, year, existingHolidays))
            {
                TechnicalHolidaysCalendar__c newHoliday = new TechnicalHolidaysCalendar__c(HolidayDate__c = singleDt, Year__c = year);
                result.add(newHoliday);
            }
        }
        return result;
    }

    private Date tryParseDate(String calendarDate)
    {
        Date result;
        try
        {
            result = Date.valueOf(calendarDate);
        } 
        catch (Exception e)
        {
            result = null;
        }
        return result;
    }

    private Boolean existDate(Date inputDate, Integer year,List<TechnicalHolidaysCalendar__c> existingHolidays)
    {
        for(TechnicalHolidaysCalendar__c singleHoliday : existingHolidays)
        {
            if(singleHoliday.HolidayDate__c != null && singleHoliday.Year__c != null && singleHoliday.HolidayDate__c == inputDate && singleHoliday.Year__c == year)
            {
                return true;
            }
        }
        return false;
    }

    class HDT_WRP_RequestBody
    {
        String callId;
        Date dateFrom;
        Date dateTo;
        String year;
    }
    public class HDT_WRP_Response
    {
        public String status;
        public String correlationId;
        public String timestamp;
        public List<HDT_WRP_ErrorDetail> errorDetails;
        public HDT_WRP_Data data;
    }
    public class HDT_WRP_ErrorDetail
    {
        public String code;
        public String message;
        public String additionalInfo;
    }
    public class HDT_WRP_Data
    {
        public List<HDT_WRP_Holidays> holidayDate;
        public String responseMsg;
    }
    public class HDT_WRP_Holidays
    {
        public String calendarDate;
    }
}
