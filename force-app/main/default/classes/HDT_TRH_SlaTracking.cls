@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing  class HDT_TRH_SlaTracking extends HDT_TRH_TriggerHandler {

    public override void beforeUpdate(){

        List<Id> adminRuleIds = new List<Id>();
        Map<Id, SlaAdministration__c> adminRuleMap;

        for(SlaTracking__c track : (SlaTracking__c[])Trigger.New){
            if(track.StartDateTime__c != null && track.EndDateTime__c != null){
                adminRuleIds.add(track.SlaAdministration__c);
            }
        }

        List<SlaAdministration__c> slaAdminList = [ 
            SELECT Id, CaseField__c, OrderField__c, Cluster__c, CompanyOwner__c, EndDate__c, StartDate__c,
                   Description__c, EndCasePhase__c, StartCasePhase__c, Range__c, Name, Process__c,
                   RecordType.DeveloperName, Commodity__c, SalesCompany__c, CustomerType__c, RangeType__c, Type__c, ActivityType__c,
                   StartOrderPhase__c, EndOrderPhase__c
            FROM SlaAdministration__c
            WHERE Id IN :adminRuleIds
            WITH SECURITY_ENFORCED
        ];

        List<Holiday> holidayList = [
            SELECT Name, ActivityDate
                   //,EndTimeInMinutes, IsAllDay, IsRecurrence, RecurrenceDayOfMonth,
                   //RecurrenceDayOfWeekMask, RecurrenceEndDateOnly, RecurrenceInstance, RecurrenceInterval,
                   //RecurrenceMonthOfYear, RecurrenceStartDate, RecurrenceType, StartTimeInMinutes
            FROM Holiday
            WITH SECURITY_ENFORCED
        ];

        if(slaAdminList.size() > 0){
            adminRuleMap = new Map<Id, SlaAdministration__c>(slaAdminList);
        }

        String rangeType;
        Date startDate;
        Date endDate;
        for(SlaTracking__c track : (SlaTracking__c[])Trigger.New){

            if(track.StartDateTime__c == null || track.EndDateTime__c == null){
                continue;
            }

            startDate = convertDateTime(track.StartDateTime__c);
            endDate = convertDateTime(track.EndDateTime__c);
            track.SlaValue__c = startDate.daysBetween(endDate)+1;

            if(adminRuleMap.containsKey(track.SlaAdministration__c)){
                rangeType = adminRuleMap.get(track.SlaAdministration__c).RangeType__c;
                if(String.isNotEmpty(rangeType) && rangeType.equalsIgnoreCase('Giorni Lavorativi')){
                    track.SlaValue__c = calculateWorkingDays(track.StartDateTime__c, Integer.valueOf(track.SlaValue__c), holidayList);
                }
            }

        }

    }

    public static Integer calculateWorkingDays(DateTime startDateTime, Integer diff, List<Holiday> holidayList){

        Set<String> dayToAvoid = new Set<String>{'Saturday', 'Sunday', 'Sabato', 'Domenica'};
        Set<String> holidays = new Set<String>();

        for(Holiday hDay : holidayList){
            holidays.add(String.valueOf(hDay.ActivityDate.day()) + '-' + String.valueOf(hDay.ActivityDate.month()));//01-01
        }

        String dayOfWeek;
        Integer slaValue = 0;
        DateTime dt;
        Boolean isWeekEnd;
        Boolean isHoliday;
        for(Integer day=0; day<diff; day++){
            dt = startDateTime.addDays(day);
            dayOfWeek = dt.format('EEEE');

            isWeekEnd = dayToAvoid.contains(dayOfWeek);
            isHoliday = holidays.contains(String.valueOf(dt.day()) + '-' + String.valueOf(dt.month()));
            

            if(!isWeekEnd && !isHoliday){
                System.debug('>>> count');
                slaValue++;
            }
            System.debug('>>> date ' + Date.valueOf(dt) + ' - ' + dayOfWeek + ' - slaValue ' + slaValue);
        }
        return slaValue;
    }

    public static Date convertDateTime(DateTime dt){
        //return Date.valueOf(dt);
        return Date.newinstance(dt.year(), dt.month(), dt.day());
    }

}