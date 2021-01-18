/*HDT_UTL_AmountQuote class
  ----Francesco Panico*/

public inherited sharing class HDT_UTL_AmountQuote {

  //List<FlowInputs> looks like a good solution to overcome constraints on InvocableMethod inputs.
  @InvocableMethod
  public static  List<AdminPriceQuote__c> calculateAmountQuote(List<HDT_UTL_FlowInputs> inputs){
    
    //Assigning values to string in order to avoid query inside loops
    String distributor = inputs[0].distributor;

    String city = inputs[0].city;

    String cal = inputs[0].caliber;

    Boolean existCorrector = inputs[0].hasCorrector;

    String mark = inputs[0].market;

    //Call to the relative query class 
    return HDT_QR_AmountQuote.queryAmount(distributor, city, cal, existCorrector, mark);
    

  }


    public class HDT_UTL_FlowInputs{

          //Distributor and City fields are not being used at the moment because they do not appear on Case object
          @InvocableVariable
          public String distributor;

          @InvocableVariable
          public String city;

          @InvocableVariable
          public String caliber;

          @InvocableVariable
          public Boolean hasCorrector;

          @InvocableVariable
          public String market;

    }
}