public with sharing class HDT_UTL_Reclami
{
    public Map<String,String> setExpirationDate(Case inputCase, String supplyCity)
    {
        return calculateExpirationDate(inputCase, supplyCity);
    }   

    private Map<String,String> calculateExpirationDate(Case inputCase, String supplyCity)
    {
        String commodity = inputCase.CommodityFormula__c;
        Map<String,String> result = new Map<String,String>();

        if ( 'Acqua'.equalsIgnoreCase(commodity) )
        {
            result = calculateDatesWater(inputCase, calculateAto(supplyCity));
        }
        else
        {
            result = calculateDates(inputCase,commodity);
        }
        return result;
    }

    private Map<String,String> calculateDatesWater(Case inputCase, String ato)
    {
        Map<String,String> result = new Map<String,String>();
        String process = 'Reclamo Scritto/Rich. Info'.equalsIgnoreCase(inputCase.Type) ? inputCase.FirstLevelComplaintClassification__c : inputCase.Type ;
        Integer suspensionDays;

        List<HDT_IndemnitiesDays__mdt> configurations = getExpirationDateConfigurations(process,'Acqua');

        for(HDT_IndemnitiesDays__mdt config : configurations)
        {
            SuspensionDays = Integer.valueOf(config.SuspensionDays__c);
            if( ( process.equalsIgnoreCase('Richiesta Parere') && String.isNotBlank(ato) && config.ObjectName__c.containsIgnoreCase(ato) && config.ObjectName__c.containsIgnoreCase(inputCase.SecondLevelOpinion__c) ) ||
                ( String.isNotBlank(ato) && config.ObjectName__c.equalsIgnoreCase(ato) ) ||
                 config.ObjectName__c.equalsIgnoreCase('Default') )
            {
                result = setDates(inputCase, config);
            }
        }
        return result;
    }

    private Map<String,String> calculateDates( Case inputCase, String commodity )
    {
        Map<String,String> result = new Map<String,String>();
        String process = 'Reclamo Scritto/Rich. Info'.equalsIgnoreCase(inputCase.Type) ? inputCase.FirstLevelComplaintClassification__c : inputCase.Type ;
        List<HDT_IndemnitiesDays__mdt> configurations = getExpirationDateConfigurations(process,commodity);

        for(HDT_IndemnitiesDays__mdt config : configurations)
        {
            if( ( process.equalsIgnoreCase('Richiesta Parere') && config.ObjectName__c.containsIgnoreCase(inputCase.SecondLevelOpinion__c) ) ||
                config.ObjectName__c.equalsIgnoreCase('Default'))
            {
                result = setDates(inputCase, config);
            }
        }
        return result;
    }
  
    private List<HDT_IndemnitiesDays__mdt> getExpirationDateConfigurations( String process, String commodity )
    {
        return [SELECT Id, SuspensionDays__c, SuspensionDaysRectification__c, BasicAmount__c, ComputeType__c, ObjectName__c FROM HDT_IndemnitiesDays__mdt WHERE Process__c = :process AND Commodity__c = :commodity WITH SECURITY_ENFORCED];
    }

    private Map<String,String> setDates(Case inputCase, HDT_IndemnitiesDays__mdt config)
    { 
        Date startDate = inputCase.SendDate__c;
        Date firstDate;
        Date secondDate;
        Date thirdDate;
        Map<String,String> result = new Map<String,String>();
        if( 'W'.equalsIgnoreCase(config.ComputeType__c ) )
        {
            result.put('EndDate__c', String.valueof(addBusinsessDaysWithHolidays( Integer.valueOf(config.SuspensionDays__c), startDate) ));
            result.put('CompletedDocumentationDate__c', String.valueof(addBusinsessDaysWithHolidays( 2*Integer.valueOf(config.SuspensionDays__c), startDate) ));
            result.put('DepositExpirationDate__c', String.valueof(addBusinsessDaysWithHolidays( 3*Integer.valueOf(config.SuspensionDays__c), startDate) ));
            firstDate = addBusinsessDaysWithHolidays( Integer.valueOf(config.SuspensionDaysRectification__c), startDate);
            secondDate = addBusinsessDaysWithHolidays( Integer.valueOf(config.SuspensionDaysRectification__c), firstDate);
            thirdDate = addBusinsessDaysWithHolidays( Integer.valueOf(config.SuspensionDaysRectification__c), secondDate);

            if( inputCase.CorrectionDocumentEmissionDay__c != null )
            {
                if( firstDate < inputCase.CorrectionDocumentEmissionDay__c && inputCase.CorrectionDocumentEmissionDay__c <= secondDate )
                {
                    result.put('DepositAmount__c', String.valueof(config.BasicAmount__c) );
                } 
                else if( secondDate < inputCase.CorrectionDocumentEmissionDay__c && inputCase.CorrectionDocumentEmissionDay__c <= thirdDate )
                {
                    result.put('DepositAmount__c', String.valueof(2*config.BasicAmount__c) );
                } 
                else if( thirdDate < inputCase.CorrectionDocumentEmissionDay__c )
                {
                    result.put('DepositAmount__c', String.valueof(3*config.BasicAmount__c) );
                } 
                else
                {
                    result.put('DepositAmount__c', '0' );
                }
            }
        }
        else // ComputeType__c  == 'S'
        {
            result.put('EndDate__c', String.valueof(startDate.addDays(Integer.valueOf(config.SuspensionDays__c))) );
            result.put('CompletedDocumentationDate__c', String.valueof(startDate.addDays(2*Integer.valueOf(config.SuspensionDays__c))) );
            result.put('DepositExpirationDate__c', String.valueof(startDate.addDays(3*Integer.valueOf(config.SuspensionDays__c))) );
            firstDate = startDate.addDays(Integer.valueOf(config.SuspensionDaysRectification__c));
            secondDate = firstDate.addDays(Integer.valueOf(config.SuspensionDaysRectification__c));
            thirdDate = secondDate.addDays(Integer.valueOf(config.SuspensionDaysRectification__c));

            if( inputCase.CorrectionDocumentEmissionDay__c != null )
            {
                if( firstDate < inputCase.CorrectionDocumentEmissionDay__c && inputCase.CorrectionDocumentEmissionDay__c <= secondDate )
                {
                    result.put('DepositAmount__c', String.valueof(config.BasicAmount__c) );
                } 
                else if( secondDate < inputCase.CorrectionDocumentEmissionDay__c && inputCase.CorrectionDocumentEmissionDay__c <= thirdDate )
                {
                    result.put('DepositAmount__c', String.valueof(2*config.BasicAmount__c) );
                } 
                else if( thirdDate < inputCase.CorrectionDocumentEmissionDay__c )
                {
                    result.put('DepositAmount__c', String.valueof(3*config.BasicAmount__c) );
                } 
                else
                {
                    result.put('DepositAmount__c', '0' );
                }
            }
        }
        result.put('AmountToPayInInstallments__c', String.valueof(config.BasicAmount__c) );

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

    private Date addBusinsessDaysWithHolidays(Integer businessDayToAdd, Date startDate)
    {
        Set<Date> holidays = getHolidaysDate();
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

}
