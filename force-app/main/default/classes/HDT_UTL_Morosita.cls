public inherited sharing class HDT_UTL_Morosita {

    public String transcodeProcess(String process){
        string result;

        switch on process{
            when 'Sospensione Fornitura'{
                result = 'Sospensione Fornitura';
            }
            when 'Riattivazione Fornitura'{
                result = 'Riattivazione Fornitura';
            }
        }

        return result;
    }
}
