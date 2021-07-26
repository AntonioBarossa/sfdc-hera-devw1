public inherited sharing class HDT_SRV_ComunicationsSearchList {

    public static Object getWsData(String wrapperObj) {

        System.debug('>>> wrapperObj ' + wrapperObj);

        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj wsObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj();
        
        try{
            wsObj.success = true;
            wsObj.message = '';
            wsObj.body = '';

            String s = '[';

            Integer max = 50;
            Date dd = Date.today();
            Date currentDate;
            String stringDate;
            for(Integer n=1; n <= max; n++){
                currentDate = dd.addDays(n);
                String d = (currentDate.day()<10) ? '0' + String.valueOf(currentDate.day()) : String.valueOf(currentDate.day());
                String m = (currentDate.month()<10) ? '0' + String.valueOf(currentDate.month()) : String.valueOf(currentDate.month());
                stringDate = d + '/' + m + '/' + String.valueOf(currentDate.year());
                s += '{"id": "' + String.valueOf(n) + '", "billNumber": "' + String.valueOf(n) + '", "billDate": "' + stringDate + '"}';
                if(n != max){
                    s += ',';
                }
            }

            s += ']';

            wsObj.body = s;

            //Account a = new Account();
            //a.Id = '';
            //insert a;

        } catch (Exception ex){
            wsObj.success = false;
            wsObj.message = ex.getMessage();
            wsObj.body = null;
        }

        return JSON.serialize(wsObj);
    }

}