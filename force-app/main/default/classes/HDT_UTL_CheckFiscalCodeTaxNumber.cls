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

    @AuraEnabled
    public static Map<String,Map<String,Object>> getDataFromFiscalCode(Map<String,String> fiscalCodes){
        System.debug('test');
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
                e.setMessage('Enter a valid fiscal code');
                return null;
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
                e.setMessage('Enter a valid fiscal code');
                return null;            
            }
        }
        return res;
    }
}