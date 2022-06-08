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
        ];

        if(slaAdminList.size() > 0){
            adminRuleMap = new Map<Id, SlaAdministration__c>(slaAdminList);
        }

        String rangeType;
        Date startDate;
        Date endDate;
        for(SlaTracking__c track : (SlaTracking__c[])Trigger.New){
            if(track.StartDateTime__c != null && track.EndDateTime__c != null){
                rangeType = adminRuleMap.get(track.SlaAdministration__c).RangeType__c;
                startDate = Date.valueOf(track.StartDateTime__c);
                endDate = Date.valueOf(track.EndDateTime__c);
                track.SlaValue__c = startDate.daysBetween(endDate);

                if(rangeType.equalsIgnoreCase('Giorni Lavorativi')){
                    track.SlaValue__c = calculateWorkingDays(Integer.valueOf(track.SlaValue__c), track.StartDateTime__c);
                }

            }
        }

    }

    public static Integer calculateWorkingDays(Integer diff, DateTime startDateTime){

        Set<String> dayToAvoid = new Set<String>{'Saturday', 'Sunday', 'Sabato', 'Domenica'};
        Set<Date> holidays = new Set<Date>();
        List<Holiday> holidayList = [
            SELECT Name, ActivityDate, EndTimeInMinutes, IsAllDay, IsRecurrence, RecurrenceDayOfMonth,
                   RecurrenceDayOfWeekMask, RecurrenceEndDateOnly, RecurrenceInstance, RecurrenceInterval,
                   RecurrenceMonthOfYear, RecurrenceStartDate, RecurrenceType, StartTimeInMinutes
            FROM Holiday
        ];

        for(Holiday hDay : holidayList){
            holidays.add(hDay.ActivityDate);
        }

        String dayOfWeek;
        Integer slaValue = 0;
        DateTime dt;
        for(Integer day=0; day<=diff; day++){
            dt = startDateTime.addDays(day);
            dayOfWeek = dt.format('EEEE');
            if(!dayToAvoid.contains(dayOfWeek) && !holidays.contains(Date.valueOf(dt))){
                slaValue++;
            }

        }
        return slaValue;
    }

}