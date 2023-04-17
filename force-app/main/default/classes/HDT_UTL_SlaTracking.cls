@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_SlaTracking {

    public static void calculateSlaRealValue(List<SlaTracking__c> slaTrackingFromTrigger){

        List<Id> adminRuleIds = new List<Id>();
        List<SlaTracking__c> slaTrackingToElaborate = new List<SlaTracking__c>();
        Map<Id, SlaAdministration__c> adminRuleMap;

        try{
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
            List<TechnicalHolidaysCalendar__c> holidayList = HDT_QR_SlaTracking.getHolidaysList();

            if(slaAdminList.size() > 0){
                adminRuleMap = new Map<Id, SlaAdministration__c>(slaAdminList);
            }

            String rangeType;
            Date startDate;
            Date endDate;
            for(SlaTracking__c track : slaTrackingToElaborate){

                //startDate = convertDateTime(track.StartDateTime__c);
                //endDate = convertDateTime(track.EndDateTime__c);
                //track.SlaValue__c = startDate.daysBetween(endDate);//+1;
                track.SlaValue__c = calculateSlaValue(track.StartDateTime__c, track.EndDateTime__c);

                if(adminRuleMap.containsKey(track.SlaAdministration__c)){
                    rangeType = adminRuleMap.get(track.SlaAdministration__c).RangeType__c;
                    if(String.isNotEmpty(rangeType) && rangeType.equalsIgnoreCase('Giorni Lavorativi')){
                        track.SlaValue__c = calculateWorkingDaysInteger(startDate, Integer.valueOf(track.SlaValue__c), holidayList);
                    }
                }

            }
        } catch(Exception e){
            System.debug('>>> ERROR calculate SlaValue__c -> ' + e.getMessage());
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
        List<TechnicalHolidaysCalendar__c> holidayList = HDT_QR_SlaTracking.getHolidaysList();

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
            //slaRange = calculateWorkingDays(track.StartDateTime__c, slaRange, holidayList);
            track.EndDateWorkingDays__c = calculateWorkingDays(startDate, slaRange, holidayList);
        }

    }

    public static Date calculateWorkingDays(Date startDate, Integer slaRange, List<TechnicalHolidaysCalendar__c> holidayList){
        Set<Date> holidays = new Set<Date>();
        for(TechnicalHolidaysCalendar__c holiday : holidayList){
            if(holiday.HolidayDate__c >= startDate){
                holidays.add(holiday.HolidayDate__c);
            }
        }    
    
        Date finalDate = startDate;
        Integer direction = slaRange < 0 ? -1 : 1;
        while(slaRange != 0){
            finalDate = finalDate.addDays(direction);
            if(!isWeekend(finalDate) && !holidays.contains(finalDate)){
                slaRange -= direction;
            }
        }
        return finalDate;
    }

    private static Boolean isWeekend(Date myDate){
        String myDateString = Datetime.newInstance(myDate.year(), myDate.month(),myDate.day()).format('EEE');
        return 'Sat'.equals(myDateString) || 'Sun'.equals(myDateString);
    }

    public static Date convertDateTime(DateTime dt){
        return Date.newinstance(dt.year(), dt.month(), dt.day());
    }

    public static Integer calculateWorkingDaysInteger(Date startDate, Integer diff, List<TechnicalHolidaysCalendar__c> holidayList){

        Set<String> dayToAvoid = new Set<String>{'Saturday', 'Sunday', 'Sabato', 'Domenica'};
        Set<Date> holidays = new Set<Date>();
        for(TechnicalHolidaysCalendar__c holiday : holidayList){
            if(holiday.HolidayDate__c >= startDate){
                holidays.add(holiday.HolidayDate__c);
            }
        }  

        String dayOfWeek;
        Integer slaValue = 0;
        DateTime dt;
        Boolean isWeekEnd;
        Boolean isHoliday;
        for(Integer day=0; day<diff; day++){
            dt = startDate.addDays(day);
            dayOfWeek = dt.format('EEEE');

            isWeekEnd = dayToAvoid.contains(dayOfWeek);
            isHoliday = holidays.contains(convertDateTime(dt));
            

            if(!isWeekEnd && !isHoliday){
                //System.debug('>>> count');
                slaValue++;
            }
            //System.debug('>>> date ' + Date.valueOf(dt) + ' - ' + dayOfWeek + ' - slaValue ' + slaValue);
        }
        return slaValue;
    }

    //DateTime startDt = DateTime.newInstance(2023, 04, 06, 12, 00 , 00);
    //DateTime endDt = DateTime.newInstance(2023, 04, 07, 12, 00 , 01);
    //System.debug('>>>>>>>>> SLA ' + calculateSlaValue(startDt, endDt));
    public static Integer calculateSlaValue(DateTime startDatetime, DateTime endDatetime){
        Decimal timeStart = startDatetime.getTime();
        Decimal timeEnd = endDatetime.getTime();
        Decimal hours = (timeEnd - timeStart) / 3600000;
        Decimal days = hours / 24;
        System.debug('>>>>>>>>> days ' + days + ' - hours ' + hours);
        return (days < 1) ? 0 : (Integer)days.round(System.RoundingMode.UP);
    }

}