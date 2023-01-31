@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_SlaTracking {

    public static void calculateSlaRealValue(List<SlaTracking__c> slaTrackingFromTrigger){

        List<Id> adminRuleIds = new List<Id>();
        List<SlaTracking__c> slaTrackingToElaborate = new List<SlaTracking__c>();
        Map<Id, SlaAdministration__c> adminRuleMap;

        for(SlaTracking__c track : slaTrackingFromTrigger){

            //if(track.Status__c.equalsIgnoreCase('Chiuso')){
            //    continue;
            //}

            if(track.StartDateTime__c != null && track.EndDateTime__c != null){
                adminRuleIds.add(track.SlaAdministration__c);
                slaTrackingToElaborate.add(track);
            }
        }

        if(slaTrackingToElaborate.size()==0){
            return;
        }

        List<SlaAdministration__c> slaAdminList = HDT_QR_SlaTracking.getSlaAdminList(adminRuleIds);
        List<Holiday> holidayList = HDT_QR_SlaTracking.getHolidayList();

        if(slaAdminList.size() > 0){
            adminRuleMap = new Map<Id, SlaAdministration__c>(slaAdminList);
        }

        String rangeType;
        Date startDate;
        Date endDate;
        for(SlaTracking__c track : slaTrackingToElaborate){

            startDate = convertDateTime(track.StartDateTime__c);
            endDate = convertDateTime(track.EndDateTime__c);
            track.SlaValue__c = startDate.daysBetween(endDate);//+1;

            if(adminRuleMap.containsKey(track.SlaAdministration__c)){
                rangeType = adminRuleMap.get(track.SlaAdministration__c).RangeType__c;
                if(String.isNotEmpty(rangeType) && rangeType.equalsIgnoreCase('Giorni Lavorativi')){
                    track.SlaValue__c = calculateWorkingDays(track.StartDateTime__c, Integer.valueOf(track.SlaValue__c), holidayList);
                }
            }

        }

    }
    
    public static void calculateSlaForecastValue(List<SlaTracking__c> slaTrackingFromTrigger){

        List<Id> adminRuleIds = new List<Id>();
        List<SlaTracking__c> slaTrackingToElaborate = new List<SlaTracking__c>();
        Map<Id, SlaAdministration__c> adminRuleMap;

        for(SlaTracking__c track : slaTrackingFromTrigger){
            if(track.StartDateTime__c != null){
                adminRuleIds.add(track.SlaAdministration__c);
                slaTrackingToElaborate.add(track);
            }
        }

        List<SlaAdministration__c> slaAdminList = HDT_QR_SlaTracking.getSlaAdminList(adminRuleIds);
        List<Holiday> holidayList = HDT_QR_SlaTracking.getHolidayList();

        if(slaAdminList.size() > 0){
            adminRuleMap = new Map<Id, SlaAdministration__c>(slaAdminList);
        }

        Integer slaRange;
        Date startDate;
        Date endDate;
        for(SlaTracking__c track : slaTrackingToElaborate){
            startDate = convertDateTime(track.StartDateTime__c);
            slaRange = Integer.valueOf(adminRuleMap.get(track.SlaAdministration__c).Range__c);
            track.EndDateSolarDays__c = startDate.addDays(slaRange);
            slaRange = calculateWorkingDays(track.StartDateTime__c, slaRange, holidayList);
            track.EndDateWorkingDays__c = startDate.addDays(slaRange);
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
                //System.debug('>>> count');
                slaValue++;
            }
            //System.debug('>>> date ' + Date.valueOf(dt) + ' - ' + dayOfWeek + ' - slaValue ' + slaValue);
        }
        return slaValue;
    }

    public static Date convertDateTime(DateTime dt){
        //return Date.valueOf(dt);
        return Date.newinstance(dt.year(), dt.month(), dt.day());
    }

}