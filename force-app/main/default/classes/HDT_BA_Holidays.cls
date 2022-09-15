public with sharing class HDT_BA_Holidays implements Database.Batchable<HDT_WRP_Scope>, Database.AllowsCallouts
{

    public List<HDT_WRP_Scope> batchScope;

    HDT_BA_Holidays()
    {
        this.batchScope = new List<HDT_WRP_Scope>();
    }

    public Iterable<HDT_WRP_Scope> start(Database.BatchableContext bc)
    {
        return this.batchScope;
    }

    public void execute(Database.BatchableContext bc, List<HDT_WRP_Scope> scope)
    {
        /* Get current year */
        Integer year = System.today().year();
        /* Query all TechnicalHolidaysCalendar__c*/
        List<TechnicalHolidaysCalendar__c> existingHolidays = [SELECT HolidayDate__c, Year__c FROM TechnicalHolidaysCalendar__c WHERE Year__c = :year];
        /* Exeute Callout */
        String response = makeRequest(year);
        /* Handle Response */
        List<TechnicalHolidaysCalendar__c> newHolidays = handleResponse(response, year, existingHolidays);
        if(!newHolidays.isEmpty())
        {
            HDT_UTL_DatabaseService.insertSObject(newHolidays);
        }
    }

    public void finish(Database.BatchableContext bc)
    {
        return;
    }


    private String makeRequest(Integer year)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        HDT_WRP_RequestBody requestBody = new HDT_WRP_RequestBody();

        requestBody.callId = '01';
        requestBody.dateFrom = Date.newInstance(year, 01, 01);
        requestBody.dateTo = Date.newInstance(year, 12, 31);
        requestBody.year = year;

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
            if(singleDate.dateString == null || String.isBlank(singleDate.dateString))
            {
                continue;
            }
            Date singleDt = tryParseDate(singleDate.dateString);
            if(singleDt != null && existDate(singleDt, year, existingHolidays))
            {
                TechnicalHolidaysCalendar__c newHoliday = new TechnicalHolidaysCalendar__c(HolidayDate__c = singleDt, Year__c = year);
                result.add(newHoliday);
            }
        }
        return result;
    }

    private Date tryParseDate(String dateString)
    {
        Date result;
        try
        {
            result = Date.valueOf(dateString);
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
        Integer year;
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
        public String dateString;
    }
}   
