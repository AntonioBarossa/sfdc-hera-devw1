public with sharing class HDT_UTL_Reclami
{
    public Date setExpirationDate(Case inputCase, String supplyCity)
    {
        return calculateExpirationDate(inputCase, supplyCity);
    }   

    private Date calculateExpirationDate(Case inputCase, String supplyCity)
    {
        Set<Date> holidays = new Set<Date>();
        Date currentDate = inputCase.SendDate__c;
        Integer suspensionDays = inputCase.Commodity__c.equalsIgnoreCase('Acqua') ? calculateSuspensionDaysWater(inputCase, calculateAto(supplyCity)) : calculateSuspensionDaysAmbiente(inputCase);
        holidays = getHolidaysDate();
        return addBusinsessDaysWithHolidays(suspensionDays, currentDate, holidays);
    }
    private String calculateAto(String supplyCity)
    {
        String result = '';
        List<TownAtoTable__c> atoTable = [SELECT Id, Ato__c FROM TownAtoTable__c WHERE Town__c = :supplyCity WITH SECURITY_ENFORCED];
        if(!atoTable.isEmpty())
        {
            result = atoTable[0].Ato__c != null ? atoTable[0].Ato__c : '';
        }

        return result;
    }
    private List<HDT_SuspensionDays__mdt> getExpirationDateConfigurations(String process)
    {
        return [SELECT Id,SuspensionDays__c,ObjectName__c FROM HDT_SuspensionDays__mdt WHERE (Process__c = :process OR Process__c = 'Default') WITH SECURITY_ENFORCED];
    }
    private List<HDT_SuspensionDays__mdt> getExpirationDateConfigurationsAmbiente()
    {
        return [SELECT Id,SuspensionDays__c,ObjectName__c FROM HDT_SuspensionDays__mdt WHERE Process__c = 'Ambiente' WITH SECURITY_ENFORCED];
    }
    private Integer calculateSuspensionDaysWater(Case inputCase, String ato)
    {
        Integer result;
        String process = inputCase.Type.equalsIgnoreCase('Reclamo da Cittadino') ? inputCase.Type : inputCase.FirstLevelComplaintClassification__c;

        List<HDT_SuspensionDays__mdt> configurations = getExpirationDateConfigurations(process);
        for(HDT_SuspensionDays__mdt config : configurations)
        {
            if(String.isNotBlank(ato) && config.ObjectName__c.equalsIgnoreCase(ato))
            {
                result = Integer.valueOf(config.SuspensionDays__c);
                break;
            }
            else if(String.isBlank(ato) && config.ObjectName__c.equalsIgnoreCase('Default'))
            {
                result = Integer.valueOf(config.SuspensionDays__c);
                break;
            }
        }
        
        return result;
    }
    private Integer calculateSuspensionDaysAmbiente(Case inputCase)
    {
        Integer result;

        List<HDT_SuspensionDays__mdt> configurations = getExpirationDateConfigurationsAmbiente();
        for(HDT_SuspensionDays__mdt config : configurations)
        {
            if(config.ObjectName__c.equalsIgnoreCase('Default'))
            {
                result = Integer.valueOf(config.SuspensionDays__c);
                break;
            }
        }

        return result;
    }
    private Set<Date> getHolidaysDate()
    {
        Set<Date> result = new Set<Date>();
        Integer year = System.today().year();
        List<TechnicalHolidaysCalendar__c> holidaysDate = [SELECT Id, HolidayDate__c FROM TechnicalHolidaysCalendar__c WHERE Year__c = :year WITH SECURITY_ENFORCED];
        for(TechnicalHolidaysCalendar__c holiday : holidaysDate)
        {
            result.add(holiday.HolidayDate__c);
        }
        return result;
    }
    private Date addBusinsessDaysWithHolidays(Integer businessDayToAdd, Date startDate, Set<Date> holidays)
    {
        Date finalDate = startDate;
        Integer direction = businessDayToAdd < 0 ? -1 : 1;
        while(businessDayToAdd != 0){
            finalDate = finalDate.addDays(direction);
            if(!isWeekend(finalDate) && !holidays.contains(finalDate)){
                businessDayToAdd -= direction;
            }
        }
        return finalDate;
    }
    private Boolean isWeekend(Date myDate){
        String myDateString = Datetime.newInstance(myDate.year(), myDate.month(),myDate.day()).format('EEE');
        return 'Sat'.equals(myDateString) || 'Sun'.equals(myDateString);
    }
}
