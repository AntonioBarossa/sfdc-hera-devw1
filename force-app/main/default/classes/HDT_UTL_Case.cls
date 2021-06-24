public inherited sharing class HDT_UTL_Case {


    @InvocableMethod(label='Predefault')
    public static List<HDT_UTL_FlowOutputs> caseFlowPredefaults(List<HDT_UTL_FlowInputs> inputs){

        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();

        Date effectiveDate = inputs[0].effectiveDate;

        if(effectiveDate != null){
            effectiveDate = addBusinessDay(effectiveDate, 3);
        }else{
            effectiveDate = addBusinessDay(System.today(), 3);
        }

        output.effectiveDate = effectiveDate;

        outputs.add(output);

        return outputs;


    }

    public static Date addBusinessDay(Date startDate, Integer businessDayToAdd){

        Date finalDate = startDate;

        Integer direction = businessDayToAdd < 0 ? -1 : 1;

        while(businessDayToAdd != 0){

            finalDate = finalDate.addDays(direction);
            
            if(!isWeekend(finalDate)){

                businessDayToAdd -= direction;
            
            }

        }

        return finalDate;

    }

    public static Boolean isWeekend(Date myDate){

        String myDateString = Datetime.newInstance(myDate.year(), myDate.month(),myDate.day()).format('EEE');

        return 'Sat'.equals(myDateString) || 'Sun'.equals(myDateString);

    }


    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public Date effectiveDate;

    }

    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public Date effectiveDate;

    }



}
