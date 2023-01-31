public with sharing class HDT_UTL_CalculateFiscalCode {

    private static String vowels='AEIUO';
    private static String[] vowelsLetters=new List<String>();
    private static String[] consonantsLetters=new List<String>();
    private static Map<String, String> omocodiaMap = new Map<String, String>
    {
        'L' => '0',
        'M' => '1',
        'N' => '2',
        'P' => '3',
        'Q' => '4',
        'R' => '5',
        'S' => '6',
        'T' => '7',
        'U' => '8',
        'V' => '9'
    };
    
    @AuraEnabled
    public static String calculateFiscalCode(Map<String,String> infoData){

        String checkCitta = HDT_QR_City.getCityCode(infoData.get('birthPlace').toUpperCase());
        String fiscalCode='';
        if(''.equals(checkCitta)){
            fiscalCode = null ;
        }else{
            
            fiscalCode += getLastNameCode(infoData.get('lastName').toUpperCase().replaceAll('\'', '').deleteWhitespace());//HRAWRM-763,HRAWRM-800
            fiscalCode += getFirstNameCode(infoData.get('firstName').toUpperCase().replaceAll('\'', '').deleteWhitespace());//HRAWRM-763,HRAWRM-800

            fiscalCode += getYear(infoData.get('birthDate'));
            fiscalCode += getMonthLetter(infoData.get('birthDate'));
            fiscalCode += getDayAndGenderCode(infoData.get('birthDate'), infoData.get('gender'));
            fiscalCode += checkCitta;
            System.debug(checkCitta);
            fiscalCode += getControlLetter(fiscalCode);
        }
        return fiscalCode;
    }
    /* Nel calcolo del lead viene eseguito un controllo prima sulla validita' del codice fiscale
    * Poi lo calcola nuovamente
    * in caso di citta' con piu' codici belfiore e' necessario calcolare il codice fiscale 
    * per ogni possibile citycode
    */
    public static Set<String> calculateSetFiscalCode(Map<String,String> infoData){
        String city = infoData.get('birthPlace').toUpperCase();
        Set<String> cityCodes = new Set<String>();
        Set<String> fiscalCodes = new Set<String>();
        List<City__c> checkCitta = [SELECT BelfioreCode__c FROM City__c WHERE Name = :city AND BelfioreCode__c != null WITH SECURITY_ENFORCED];
        for(City__c singleCity : checkCitta)
        {
            cityCodes.add(singleCity.BelfioreCode__c);
        }
        for(String singleCode : cityCodes)
        {
            String fiscalCode='';
            if(''.equals(singleCode)){
                fiscalCode = null ;
            }else{
                
                fiscalCode += getLastNameCode(infoData.get('lastName').toUpperCase().replaceAll('\'', '').deleteWhitespace());//HRAWRM-763,HRAWRM-800
                fiscalCode += getFirstNameCode(infoData.get('firstName').toUpperCase().replaceAll('\'', '').deleteWhitespace());//HRAWRM-763,HRAWRM-800

                fiscalCode += getYear(infoData.get('birthDate'));
                fiscalCode += getMonthLetter(infoData.get('birthDate'));
                fiscalCode += getDayAndGenderCode(infoData.get('birthDate'), infoData.get('gender'));
                fiscalCode += singleCode;
                System.debug(singleCode);
                fiscalCode += getControlLetter(fiscalCode);
            }
            fiscalCodes.add(fiscalCode);
        }
        return fiscalCodes;
    }

    public static String cleanFiscalCodeFromOmocodia(String fiscalCode)
    {
        String newFiscalCode = '';
        String name = fiscalCode.substring(0,6);
        String year = cleanInfoFromOmocodia(fiscalCode.substring(6,8));
        String month = fiscalCode.substring(8,9);
        String day = cleanInfoFromOmocodia(fiscalCode.substring(9,11));
        String cityCodeFirstChar =  fiscalCode.replaceAll( '\\s+', '').substring(11,12);
        String cityCode =cleanInfoFromOmocodia(fiscalCode.replaceAll( '\\s+', '').substring(12,15));
        newFiscalCode = name + year + month + day + cityCodeFirstChar + cityCode;
        newFiscalCode += getControlLetter(newFiscalCode);
        return newFiscalCode;
    }
    private static String cleanInfoFromOmocodia(String s)
    {
        String lastString = s;
        String newString = '';
        for(Integer i=0; i < s.length(); ++i)
        {
            String sub = s.substring(i, i+1);
            if(!sub.isNumeric())
            {
                newString = lastString.replace(sub, omocodiaMap.get(sub));
                lastString = newString;
            }
        }
        return String.isBlank(newString) ? lastString : newString;
    }
    private static Boolean isVowel(String test, String letter){
        return test.contains(letter)?true:false;
    }

    /**@frpanico 2022-31-03
     * Inserito controllo per 
     * validare nome e cognome del codice fiscale
     */
    public static Boolean checkFirstLastNameFromFiscalCode(String fiscalCode, String firstName, String lastName)
    {
        fiscalCode = fiscalCode.toUpperCase();
        String lastNameCode = fiscalCode.substring(0,3);
        String firstNameCode = fiscalCode.substring(3,6);
        String lastNameCodeToCheck = getLastNameCode(lastName.toUpperCase().replace(' ',''));
        String firstNameCodeToCheck = getFirstNameCode(firstName.toUpperCase());
        Boolean resultFirstName = firstNameCode.equalsIgnoreCase(firstNameCodeToCheck);
        Boolean resultLastName = lastNameCode.equalsIgnoreCase(lastNameCodeToCheck);

        return resultFirstName && resultLastName;
    }
    

    private static String getLastNameCode(String word){
        String lastNameCode='';
        splitLetters(word);
        if(consonantsLetters.size()>=3){
            lastNameCode= consonantsLetters.get(0)+consonantsLetters.get(1)+consonantsLetters.get(2);
        }else{
            if(consonantsLetters.size()==2 && vowelsLetters.size()>0 ){
                lastNameCode= consonantsLetters.get(0)+consonantsLetters.get(1)+vowelsLetters.get(0);
            }
            if(consonantsLetters.size()==1 ){
                if(vowelsLetters.size()>1){
                  lastNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+vowelsLetters.get(1);
                }else if(vowelsLetters.size()==1){
                    lastNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+ 'X';
                }
            }
            //Caso di Cognome con Due lettere bisogna aggiungere una X
            if(String.isBlank(lastNameCode) && consonantsLetters.size() <3 && consonantsLetters.size() >1 && vowelsLetters.size()<1){
                lastNameCode= consonantsLetters.get(0)+consonantsLetters.get(1) + 'X';
            }
            else if(String.isBlank(lastNameCode) && vowelsLetters.size() <3  && vowelsLetters.size() >1 && consonantsLetters.size()<1){
                lastNameCode= vowelsLetters.get(0)+vowelsLetters.get(1) + 'X';
            }
            //Caso di Cognome con una lettera, bisogna aggiungere due X
            if(String.isBlank(lastNameCode) && consonantsLetters.size() ==0 && vowelsLetters.size()==1){
                lastNameCode= vowelsLetters.get(0)+ 'X' + 'X';
            } 
            else if(String.isBlank(lastNameCode) && vowelsLetters.size() ==0 && consonantsLetters.size()==1){
                lastNameCode= consonantsLetters.get(0)+ 'X' + 'X';
            }
        }
        return lastNameCode;   
    }
    private static String getFirstNameCode(String word){
        String firstNameCode='';
        splitLetters(word);
        if(consonantsLetters.size()>3){
            firstNameCode= consonantsLetters.get(0)+consonantsLetters.get(2)+consonantsLetters.get(3);
        }else if(consonantsLetters.size()==3 ){
            firstNameCode= consonantsLetters.get(0)+consonantsLetters.get(1)+consonantsLetters.get(2);
        }else if(consonantsLetters.size()==2 && vowelsLetters.size()>=1){
            firstNameCode=consonantsLetters.get(0)+consonantsLetters.get(1)+vowelsLetters.get(0);
        }else if(consonantsLetters.size()==1 && vowelsLetters.size()>=2){
            firstNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+vowelsLetters.get(1);
        }else if(consonantsLetters.size()==1 && vowelsLetters.size()==1){
            firstNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+'X';
        }else if(consonantsLetters.size()==1 && vowelsLetters.size()==0){
            firstNameCode=consonantsLetters.get(0)+'X'+'X';
        }else if(consonantsLetters.size()==0 && vowelsLetters.size()>2){
            firstNameCode=vowelsLetters.get(0)+vowelsLetters.get(1)+vowelsLetters.get(2);
        }else if(consonantsLetters.size()==0 && vowelsLetters.size()==2){
            firstNameCode=vowelsLetters.get(0)+vowelsLetters.get(1)+'X';
        }else if(consonantsLetters.size()==2 && vowelsLetters.size()==0){
            firstNameCode=consonantsLetters.get(0)+consonantsLetters.get(1)+'X';
        }else if(consonantsLetters.size()==0 && vowelsLetters.size()==1){
            firstNameCode=vowelsLetters.get(0)+'X'+'X';
        }
        
        return firstNameCode;
    }
    
    private static void splitLetters(String word){
        vowelsLetters=new List<String>();
      consonantsLetters=new List<String>();
        for(Integer i=0;i<word.length();i++){
            if(isVowel(vowels,word.substring(i, i+1))){
                vowelsLetters.add(word.substring(i, i+1));
            }else{
                consonantsLetters.add(word.substring(i, i+1));
            }
        }
    }
    
    private static String getYear(String birthday){
        String yearCode='';
        Date birth = Date.valueOf(birthday);
        Integer year= birth.year();
        yearCode= String.valueOf(year).substring(2);
        return yearCode;
    }
    private static String getMonthLetter(String birthDate){
        Date birth = Date.valueOf(birthDate);
        Integer month= birth.month();

        switch on month{
            when 1 {
                return 'A';
            }when 2 {
                return 'B';
            }when 3 {
                return 'C';
            }when 4 {
                return 'D';
            }when 5 {
                return 'E';
            }when 6 {
                return 'H';
            }when 7 {
                return 'L';
            }when 8 {
                return 'M';
            }when 9 {
                return 'P';
            }when 10 {
                return 'R';
            }when 11 {
                return 'S';
            }when 12 {
                return 'T';
            }when else{
                return '';
            }
        }                                                                        
    }
    private static String getDayAndGenderCode(String birthday, String gender){
        String dayAndGenderCode='';
        Date birth = Date.valueOf(birthday);
        Integer day= birth.day();
        if(gender=='Maschio'){
            if(day>9){
                dayAndGenderCode= String.valueOf(day);
            }else{
                dayAndGenderCode= '0'+ String.valueOf(day);
            }
        }else{
            dayAndGenderCode= String.valueOf(40+day);
        }
        return dayAndGenderCode;
    }   
    
    public static String getControlLetter(String s){
		List<String> evenChars=new List<String>();
		List<String> oddChars= new List<String>();
        String letter='';
		Integer counter=0;
		for(Integer i=0;i<s.length();i++){
			if(math.mod(i,2)==0){
                oddChars.add(s.substring(i,i+1));
            }else{
                evenChars.add(s.substring(i,i+1));
            }
		}
        for (String c : oddChars) {
            switch on c{
                when '0' { 
                    counter+=1;
                }when '1' { 
                    counter+=0;
                }when '2' { 
                    counter+=5;
                }when '3' { 
                    counter+=7;
                }when '4' { 
                    counter+=9;
                }when '5' { 
                    counter+=13;
                }when '6' { 
                    counter+=15;
                }when '7' { 
                    counter+=17;
                }when '8' { 
                    counter+=19;
                }when '9' { 
                    counter+=21;
                }when 'A' { 
                    counter+=1;
                }when 'B' { 
                    counter+=0;
                }when 'C' { 
                    counter+=5;
                }when 'D' { 
                    counter+=7;
                }when 'E' { 
                    counter+=9;
                }when 'F' { 
                    counter+=13;
                }when 'G' { 
                    counter+=15;
                }when 'H' { 
                    counter+=17;
                }when 'I' { 
                    counter+=19;
                }when 'J' { 
                    counter+=21;
                }when 'K' { 
                    counter+=2;
                }when 'L' { 
                    counter+=4;
                }when 'M' { 
                    counter+=18;
                }when 'N' { 
                    counter+=20;
                }when 'O' { 
                    counter+=11;
                }when 'P' { 
                    counter+=3;
                }when 'Q' { 
                    counter+=6;
                }when 'R' { 
                    counter+=8;
                }when 'S' { 
                    counter+=12;
                }when 'T' { 
                    counter+=14;
                }when 'U' { 
                    counter+=16;
                }when 'V' { 
                    counter+=10;
                }when 'W' { 
                    counter+=22;
                }when 'X' { 
                    counter+=25;
                }when 'Y' { 
                    counter+=24;
                }when 'Z' { 
                    counter+=23;
                }
            }
        }
        for (String e : evenChars) {
            switch on e{
                when '0' { 
                    counter+=0;
                }when '1' { 
                    counter+=1;
                }when '2' { 
                    counter+=2;
                }when '3' { 
                    counter+=3;
                }when '4' { 
                    counter+=4;
                }when '5' { 
                    counter+=5;
                }when '6' { 
                    counter+=6;
                }when '7' { 
                    counter+=7;
                }when '8' { 
                    counter+=8;
                }when '9' { 
                    counter+=9;
                }when 'A' { 
                    counter+=0;
                }when 'B' { 
                    counter+=1;
                }when 'C' { 
                    counter+=2;
                }when 'D' { 
                    counter+=3;
                }when 'E' { 
                    counter+=4;
                }when 'F' { 
                    counter+=5;
                }when 'G' { 
                    counter+=6;
                }when 'H' { 
                    counter+=7;
                }when 'I' { 
                    counter+=8;
                }when 'J' { 
                    counter+=9;
                }when 'K' { 
                    counter+=10;
                }when 'L' { 
                    counter+=11;
                }when 'M' { 
                    counter+=12;
                }when 'N' { 
                    counter+=13;
                }when 'O' { 
                    counter+=14;
                }when 'P' { 
                    counter+=15;
                }when 'Q' { 
                    counter+=16;
                }when 'R' { 
                    counter+=17;
                }when 'S' { 
                    counter+=18;
                }when 'T' { 
                    counter+=19;
                }when 'U' { 
                    counter+=20;
                }when 'V' { 
                    counter+=21;
                }when 'W' { 
                    counter+=22;
                }when 'X' { 
                    counter+=23;
                }when 'Y' { 
                    counter+=24;
                }when 'Z' { 
                    counter+=25;
                }
            }
        }
        switch on math.mod(counter,26) {
            when 0 {
                letter='A';
            }when 1 {
                letter='B';
            }when 2 {
                letter='C';
            }when 3 {
                letter='D';
            }when 4 {
                letter='E';
            }when 5 {
                letter='F';
            }when 6 {
                letter='G';
            }when 7 {
                letter='H';
            }when 8 {
                letter='I';
            }when 9 {
                letter='J';
            }when 10 {
                letter='K';
            }when 11 {
                letter='L';
            }when 12 {
                letter='M';
            }when 13 {
                letter='N';
            }when 14 {
                letter='O';
            }when 15 {
                letter='P';
            }when 16 {
                letter='Q';
            }when 17 {
                letter='R';
            }when 18 {
                letter='S';
            }when 19 {
                letter='T';
            }when 20 {
                letter='U';
            }when 21 {
                letter='V';
            }when 22 {
                letter='W';
            }when 23 {
                letter='X';
            }when 24 {
                letter='Y';
            }when 25 {
                letter='Z';
            }
        }
        return letter;
    }

    public static String getControlNumberPiva(String s){
		List<Integer> evenNums=new List<Integer>();
		List<Integer> oddNums= new List<Integer>();
        String controllNum='';
		Integer oddCounter=0;
        Integer evenCounter=0;

		for(Integer i=0;i<s.length();i++){
			if(math.mod(i,2)==0){
                oddNums.add(Integer.valueOf(s.substring(i,i+1)));
            }else{
                evenNums.add(Integer.valueOf(s.substring(i,i+1)));
            }
		}
        for (Integer i=0; i<oddNums.size(); i++){
            oddCounter+=oddNums[i];
        }
        for (Integer i=0; i<evenNums.size(); i++){
            integer tempNum=0;
            tempNum=evenNums[i]*2;
            if(tempNum>9){
                tempNum-=9;
            }
            evenCounter+=tempNum;
        }

        integer sumMod=math.mod((oddCounter+evenCounter),10);
        controllNum=string.valueOf(math.mod((10-sumMod),10));
        return controllNum;
    }
}