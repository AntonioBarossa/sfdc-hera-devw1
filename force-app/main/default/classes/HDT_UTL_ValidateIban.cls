public inherited sharing class HDT_UTL_ValidateIban {

    //ValidateIban Cluster

    //Step #1 : rearranging the IBAN string by moving the first four digits to the end
    //The algorithm is available here:
    //https://en.wikipedia.org/wiki/International_Bank_Account_Number#Example
    private static String rearrange(String iban) {
        iban = iban.trim().toUpperCase();
        iban = iban.replaceAll('(\\s+)', '');
        String start = iban.substring(0,4);
        String ending = iban.substring(4);
        String rearranged = ending + start;
        
        System.debug('####rearranged : ' + rearranged);
        return rearranged;
    }
    
    //Step #2 : converting the letters to their corresponding numbers
    //The algorithm is available here:
    //https://en.wikipedia.org/wiki/International_Bank_Account_Number#Example
    private static String convertToInteger(String iban) {
        iban = iban.replaceAll('A', '10');
        iban = iban.replaceAll('B', '11');
        iban = iban.replaceAll('C', '12');
        iban = iban.replaceAll('D', '13');
        iban = iban.replaceAll('E', '14');
        iban = iban.replaceAll('F', '15');
        iban = iban.replaceAll('G', '16');
        iban = iban.replaceAll('H', '17');
        iban = iban.replaceAll('I', '18');
        iban = iban.replaceAll('J', '19');
        iban = iban.replaceAll('K', '20');
        iban = iban.replaceAll('L', '21');
        iban = iban.replaceAll('M', '22');
        iban = iban.replaceAll('N', '23');
        iban = iban.replaceAll('O', '24');
        iban = iban.replaceAll('P', '25');
        iban = iban.replaceAll('Q', '26');
        iban = iban.replaceAll('R', '27');
        iban = iban.replaceAll('S', '28');
        iban = iban.replaceAll('T', '29');
        iban = iban.replaceAll('U', '30');
        iban = iban.replaceAll('V', '31');
        iban = iban.replaceAll('W', '32');
        iban = iban.replaceAll('X', '33');
        iban = iban.replaceAll('Y', '34');
        iban = iban.replaceAll('Z', '35');

        return iban;
    }
    
   //Step #3 : Performs modulos by doing a sequence of modulos 97 on the formatted IBAN string
   //The algorithm is available here:
   //https://en.wikipedia.org/wiki/International_Bank_Account_Number#Example 
   private static Long performModulos(String iban) {
        
        //Doing a mod 97 on the first 9-digits chunk
		String partOne = iban.substring(0,9);
        System.debug('####part1 : ' + partOne);
        Long resultOne = Math.mod(Long.valueOf(partOne) , Long.valueOf('97') );
       
        Integer currentPosition = 9;
        Boolean digitsRemaining = true;
        Long result = resultOne;
        String partn;
        
        //Doing a mod 97 on the next 7-digits chunk
        //Or the last chunk if there is less than 7 digits remaining
        while (digitsRemaining) {
            
            if (iban.length() < (currentPosition+7) ) {
                digitsRemaining = false;
            }
            
            if (digitsRemaining) {
                partN = String.valueOf(result) + iban.substring(currentPosition,currentPosition+7);
        		System.debug('####part ' + currentPosition + ' to ' + currentPosition+7);
        		result = Math.mod(Long.valueOf(partn) , Long.valueOf('97') );
            } else {
                partN = String.valueOf(result) + iban.substring(currentPosition);
        		System.debug('####part ' + currentPosition + ' to end');
        		result = Math.mod(Long.valueOf(partn) , Long.valueOf('97') );
            }
            
            currentPosition+=7;
        }
       
        return result;
    }
    
    @InvocableMethod(label = 'ValidateIban')
    public static List<String> validateIban(List<HDT_UTL_FlowInputs> inputs) {
        List<String> results = new List<String>();
        //iban  = 'GB82 WEST 1234 5698 7654 32';
        //iban  = 'DE89 3704 0044 0532 0130 00';
        //iban  = 'FR14 2004 1010 0505 0001 3M02 606';
        //iban  = 'FR7610807004090232158413487';
        //iban  = 'FR7616707000190112158931852';
        
        String iban = inputs[0].iban;

        //Step #1 : rearranging the IBAN string by moving the first four digits to the end
        iban = rearrange(iban);
        //Step #2 : converting the letters to their corresponding numbers
        iban = convertToInteger(iban);
		//Step #3 : Performs modulos by doing a sequence of modulos 97 on the formatted IBAN string
        Long result = performModulos(iban);
        
       if(result == 1){

        results.add('OK');

       } else {

        results.add('KO');

       }

       return results; 
    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String iban;

  }

}