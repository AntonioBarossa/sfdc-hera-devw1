/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 12/05/2021
* @description HDT_UTL_CheckFiscalCodeTaxNumber.cls
* @history Lorenzo – 12/05/2021 – created class
*/
public with sharing class HDT_UTL_CheckFiscalCodeTaxNumber {
    private static Map<String,Object> dataFromFiscalCode=new Map<String,Object>();
    private static Map<String, String> monthsLetters=new Map<String, String>{
        'A'=> '1', 
        'B'=> '2',
        'C'=> '3',
        'D'=> '4',
        'E'=> '5',
        'H'=> '6',
        'L'=> '7',
        'M'=> '8',
        'P'=> '9',
        'R'=>'10',
        'S'=>'11',
        'T'=>'12'
    };
    private static List<String> listAlf = new List<String>{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S' ,'T' ,'U', 'V', 'W', 'X', 'Y' ,'Z'};
    private static  List<String> listNum = new List<String>{'0','1','2','3','4','5','6','7','8','9'};
    
    /**
    * @description  Confronta il codice fiscale inserito con il codice fiscale stimato
    * @param infoData 
    * @param fiscalCode 
    * @return Boolean 
    **/
    public static Boolean matchEstimatedFCode(Map<String,String> infoData,String fiscalCode){
        //HRAWRM-491 27/09/2021 Controllo codice fiscale stimato

        String estimatedFCode=HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoData);
        System.debug('Inserted FiscalCode:'+fiscalCode);
        System.debug('Estimated FiscalCode:'+estimatedFCode);
        if (estimatedFCode.equalsIgnoreCase(fiscalCode)) {
            return true;
            
        }
        return false;
    }



    @AuraEnabled
    public static Map<String,Object> getDataFromFiscalCodeData(String fiscalCodes){
        System.debug('test1234');
        System.debug(fiscalCodes);
        Map<String,Map<String,Object>> res=new Map<String,Map<String,Object>>();
        List<String> codes= new List<String>(); 
        String gender= '';
        String birthDate= '';
        String city='';
        String cityCode= '';
       // for(String s:fiscalCodes.keySet()){
            try {
                cityCode= fiscalCodes.replaceAll( '\\s+', '').substring(11,15);
                codes.add(cityCode);
            } catch (Exception e) {
              //  e.setMessage('Inserire un codice fiscale valido');
                throw new AuraHandledException('Inserire un codice fiscale valido');
               // return null;
            }
       // }
        Map<String,String> cities= HDT_QR_City.getCityFromCode(codes);
       // for(String s:fiscalCodes.keySet()){
            try {
                String fiscalCode = fiscalCodes.replaceAll( '\\s+', '');
                String year = '19' + fiscalCode.substring(6,8);
                String month = fiscalCode.substring(8,9);
                String day = fiscalCode.substring(9,11);
                month =  monthsLetters.get(month.toUpperCase());
                if(month== null || month == ''){
                    throw new AuraHandledException('Inserire un codice fiscale valido');
                }
                if(Integer.valueOf(day) <=31){
                    gender= 'Maschio';
                }else{
                    day=  String.valueOf(Integer.valueOf(day) -40);
                    gender= 'Femmina';
                }
                birthDate = year +'-'+ month +'-'+day;
                System.debug('city Code: '+fiscalCode.substring(11,15));
                city= cities.get(fiscalCode.substring(11,15).toUpperCase());

                if (String.isBlank(gender)||String.isBlank(city) || String.isBlank(day) || String.isBlank(year)) {
                    System.debug('gender: '+gender);
                    System.debug('city: '+city);
                    System.debug('day: '+day);
                    System.debug('year: '+year);
                    throw new AuraHandledException('Inserire un codice fiscale valido');
                }
                if (!listAlf.contains(fiscalCode.substring(15,16).toUpperCase()) 
                ) {
                    throw new AuraHandledException('Inserire un codice fiscale valido');

                }
                //Start HRAWRM-491 08/09/2021
                list <String> stringCharacters = fiscalCode.toUpperCase().split('');
                System.debug('stringCharacters: '+stringCharacters);
                Boolean isValid=true;
                for (Integer i = 0; i < 15; i++) {
                    if (i<6 && !listAlf.contains(stringCharacters.get(i))) {
                        System.debug('prime 6 lettere : '+stringCharacters.get(i));
                        isValid=false;
                    }
                    else if ( i>=6 && i<=7  && !listNum.contains(stringCharacters.get(i))) {
                        System.debug('7° e 8° numeri : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if(i==8 && !listAlf.contains(stringCharacters.get(i))) {
                        System.debug('9° lettere : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if( i>=9 && i<=10  && !listNum.contains(stringCharacters.get(i))) {
                        System.debug('10° e 11°  numeri : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if( i==11  && !stringCharacters.contains(stringCharacters.get(i))) {
                        System.debug('12°  lettere : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if( i==15  && !stringCharacters.contains(stringCharacters.get(i))) {
                        System.debug('12° e 15°  lettere : ' +stringCharacters.get(i));
                        isValid=false;
                    }

                }
               
                if (!isValid) {
                    throw new AuraHandledException('Inserire un codice fiscale valido');

                }
                //End HRAWRM-491 08/09/2021

                dataFromFiscalCode.put('gender', gender);
                dataFromFiscalCode.put('birthDate', birthDate);
                dataFromFiscalCode.put('birthPlace', city);
                res.put(fiscalCode,dataFromFiscalCode);
           
            } catch (Exception e) {
               // e.setMessage('Inserire un codice fiscale valido');
                throw new AuraHandledException('Inserire un codice fiscale valido');
                //return null;            
            }
       // }
        return res;
    }
    @AuraEnabled
    public static Map<String,Map<String,Object>> getDataFromFiscalCode(Map<String,String> fiscalCodes){
        System.debug('test1234');
        System.debug(fiscalCodes);
        Map<String,Map<String,Object>> res=new Map<String,Map<String,Object>>();
        List<String> codes= new List<String>(); 
        String gender= '';
        String birthDate= '';
        String city='';
        String cityCode= '';
        for(String s:fiscalCodes.keySet()){
            try {
                cityCode= fiscalCodes.get(s).replaceAll( '\\s+', '').substring(11,15);
                codes.add(cityCode);
            } catch (Exception e) {
              //  e.setMessage('Inserire un codice fiscale valido');
                throw new AuraHandledException('Inserire un codice fiscale valido');
               // return null;
            }
        }
        Map<String,String> cities= HDT_QR_City.getCityFromCode(codes);
        for(String s:fiscalCodes.keySet()){
            try {
                String fiscalCode = fiscalCodes.get(s).replaceAll( '\\s+', '');
                String year = '19' + fiscalCode.substring(6,8);
                String month = fiscalCode.substring(8,9);
                String day = fiscalCode.substring(9,11);
                month =  monthsLetters.get(month);
                if(month== null || month == ''){
                    throw new AuraHandledException('Inserire un codice fiscale valido');
                }
                if(Integer.valueOf(day) <=31){
                    gender= 'Maschio';
                }else{
                    day=  String.valueOf(Integer.valueOf(day) -40);
                    gender= 'Femmina';
                }
                birthDate = year +'-'+ month +'-'+day;
                city= cities.get(fiscalCode.substring(11,15));
                dataFromFiscalCode.put('gender', gender);
                dataFromFiscalCode.put('birthDate', birthDate);
                dataFromFiscalCode.put('birthPlace', city);
                res.put(s,dataFromFiscalCode);
            } catch (Exception e) {
               // e.setMessage('Inserire un codice fiscale valido');
                throw new AuraHandledException('Inserire un codice fiscale valido');
                //return null;            
            }
        }
        return res;
    }
    // Start 27-08-2021 HRAWRM-351
    public static Map<String,HDT_WRP_FiscalObject> getDataFromFiscalCode(Set<String> fiscalCodes){
        System.debug('HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode');
        System.debug('FiscalCode: '+fiscalCodes);
  
        Map<String,HDT_WRP_FiscalObject> res = new Map<String,HDT_WRP_FiscalObject>();
        List<String> codes      = new List<String>(); 
        String gender= '';
        String birthDate= '';
        String city='';
        String cityCode= '';
        for(String s:fiscalCodes){
            try {
                cityCode= s.replaceAll( '\\s+', '').substring(11,15);
                codes.add(cityCode);
            } catch (Exception e) {
                System.debug('errore :'+e.getStackTraceString());
                HDT_WRP_FiscalObject wrp=new HDT_WRP_FiscalObject();
                wrp.fiscalCode=s;
                wrp.isValid=false;
                res.put(s,wrp);
                continue;
            }
        }
        Map<String,String> cities= HDT_QR_City.getCityFromCode(codes);
        for(String s:fiscalCodes){
            HDT_WRP_FiscalObject wrp=new HDT_WRP_FiscalObject();

            try {
                
           
                String fiscalCode = s.replaceAll( '\\s+', '');
                String year = '19' + s.substring(6,8);
                String month = s.substring(8,9);
                String day = s.substring(9,11);
                Boolean isValid=true;
                month =  monthsLetters.get(month);
 
                if(Integer.valueOf(day) <=31){
                    gender= 'Maschio';
                }
                else{
                    day=  String.valueOf(Integer.valueOf(day) -40);
                    gender= 'Femmina';
                }
                birthDate = year +'-'+ month +'-'+day;
                if (cities.get(s.substring(11,15))!=null) {
                    city= cities.get(s.substring(11,15));
                }
                if (String.isBlank(gender)||String.isBlank(city) || String.isBlank(day) || String.isBlank(year)|| String.isBlank(month)) {
                    isValid=false;
                }
                //Start HRAWRM-491 08/09/2021
               
                list <String> stringCharacters = fiscalCode.toUpperCase().split('');
                System.debug('stringCharacters: '+stringCharacters);
                for (Integer i = 0; i < 15; i++) {
                    if (i<6 && !listAlf.contains(stringCharacters.get(i))) {
                        System.debug('prime 6 lettere : '+stringCharacters.get(i));
                        isValid=false;
                    }
                    else if ( i>=6 && i<=7  && !listNum.contains(stringCharacters.get(i))) {
                        System.debug('7° e 8° numeri : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if(i==8 && !listAlf.contains(stringCharacters.get(i))) {
                        System.debug('9° lettere : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if( i>=9 && i<=10  && !listNum.contains(stringCharacters.get(i))) {
                        System.debug('10° e 11°  lettere : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if( i==11  && !stringCharacters.contains(stringCharacters.get(i))) {
                        System.debug('12°  lettere : ' +stringCharacters.get(i));
                        isValid=false;
                    }
                    else if( i==15  && !stringCharacters.contains(stringCharacters.get(i))) {
                        System.debug('12° e 15°  lettere : ' +stringCharacters.get(i));
                        isValid=false;
                    }

                }
                //End HRAWRM-491 08/09/2021
                if (String.isBlank(gender)||String.isBlank(city) || String.isBlank(day) || String.isBlank(year)|| String.isBlank(month)) {
                    isValid=false;
                }

                if (!listAlf.contains(s.substring(15,16).toUpperCase()) 
                ) {
                    isValid=false;
                }
                wrp.fiscalCode=s;
                wrp.day=day;
                wrp.month=month;
                wrp.year=year;
                wrp.city=city;
                wrp.gender=gender;
                wrp.isValid=isValid;
   
                res.put(s,wrp);

            } catch (Exception e) {
               
                wrp.fiscalCode=s;
                wrp.isValid=false;
                res.put(s,wrp);
            }   
        }
        return res;
    }
    public class HDT_WRP_FiscalObject{
       public String fiscalCode;
       public String year; 
       public String month;
       public String day;
       public String city;
       public String gender;
       public Boolean isValid;
     
    }
    // End 27-08-2021 HRAWRM-351
}