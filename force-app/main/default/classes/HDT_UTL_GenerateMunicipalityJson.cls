public inherited sharing class HDT_UTL_GenerateMunicipalityJson {

    public static void createJsonObj(Boolean enableDifferentRegions){

        HDT_WRP_MunicipalityObj detailObj = new HDT_WRP_MunicipalityObj();
        detailObj.regionList = new List<HDT_WRP_Region>();

        /*
            = enableDifferentRegions
            - true -> create a list of regions
            - false -> create only one region with all province
        */
    
        try{
            Map<String, String> regionsMap = new Map<String, String>{};
            List<Municipality__c> comuni = new List<Municipality__c>();
            Map<String, Set<String>> provinceMap = new Map<String, Set<String>>();
            Map<String, String> codeProvinceMap = new Map<String, String>();
            Map<String, List<HDT_WRP_Municipality>> comuniMap = new Map<String, List<HDT_WRP_Municipality>>();

            regionsMap = generateRegionsMap(regionsMap);

            List<Municipality__c> muniList;
            muniList = HDT_QR_Municipality.getAllMunicipalities(muniList);
                        
            for(String regionCode : regionsMap.keyset()){
                provinceMap.put(regionCode, new Set<String>());
            }

            Set<String> l;
            for(Municipality__c c : muniList){
                l = provinceMap.get(c.RegionCode__c);
                if(!l.contains(c.ProvinceName__c)){
                    codeProvinceMap.put(c.ProvinceName__c, c.ProvinceCode__c);
                    l.add(c.ProvinceName__c);
                    provinceMap.put(c.RegionCode__c, l);
                }
                if(!comuniMap.containsKey(c.ProvinceName__c)){
                    comuniMap.put(c.ProvinceName__c, new List<HDT_WRP_Municipality>());
                }
            }

            List<HDT_WRP_Municipality> lcom;
            for(Municipality__c c : muniList){
                lcom = comuniMap.get(c.ProvinceName__c);
                HDT_WRP_Municipality sc = new HDT_WRP_Municipality();
                sc.label = c.Name;
                sc.value = c.MunicipalityCode__c;
                lcom.add(sc);
                comuniMap.put(c.ProvinceName__c, lcom);
            }
            
            if(enableDifferentRegions){
                HDT_WRP_Region r;
                for(String s : provinceMap.keySet()){
                    r = new HDT_WRP_Region();
                    r.provinceList = new List<HDT_WRP_Province>();
                    r.label = regionsMap.get(s);
                    r.value = s;

                    Set<String> listaProv = provinceMap.get(s);
                    
                    HDT_WRP_Province p;
                    for(String pp : listaProv){
                        p = new HDT_WRP_Province();
                        p.label = pp;
                        p.value = codeProvinceMap.get(pp);
                        p.isEnabled = true;
                        p.cityAvailable = new List<HDT_WRP_Municipality>();
                        p.cityRemoved = new List<HDT_WRP_Municipality>();
                        p.cityAvailable = comuniMap.get(pp);
                        r.provinceList.add(p);
                    }
                    
                    detailObj.regionList.add(r);
                }
            } else {
                HDT_WRP_Region r = new HDT_WRP_Region();
                r.label = 'allRegions';
                r.value = '0';
                r.eligibleForAllCities = true;
                r.provinceList = new List<HDT_WRP_Province>();

                Map<String, HDT_WRP_Province> mapToSort = new Map<String, HDT_WRP_Province>();

                for(String s : provinceMap.keySet()){
                    Set<String> listaProv = provinceMap.get(s);
                    
                    HDT_WRP_Province p;
                    for(String pp : listaProv){
                        p = new HDT_WRP_Province();
                        p.label = pp;
                        p.value = codeProvinceMap.get(pp);
                        p.isEnabled = true;
                        p.cityAvailable = new List<HDT_WRP_Municipality>();
                        p.cityRemoved = new List<HDT_WRP_Municipality>();
                        p.cityAvailable = comuniMap.get(pp);
                        r.provinceList.add(p);
                    }
                }

                detailObj.regionList.add(r);
            }

        } catch(Exception e){
            System.debug('>>>> SOMETHING GOES WRONG');
            System.debug('> ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
        }	

        List<Folder> folderList;
        folderList = HDT_QR_Municipality.getFolder(folderList, 'MunicipalityJSON');

        Datetime dt = DateTime.now();

        String jsonCode = JSON.serialize(detailObj);
        Document doc = new Document();
        doc.FolderId = folderList[0].Id;
        doc.Name = 'JSON Comuni ' + String.valueOf(dt);
        doc.Body = Blob.valueOf(jsonCode);
        doc.Type = 'txt';
        doc.ContentType = 'text/plain; charset=UTF-8';

        SObjectType objtype = Schema.getGlobalDescribe().get('Document');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        try{
            if(objRes.isCreateable()){
                insert doc;
                System.debug('>>>> WE HAVE CREATED -> ' + doc.Id);
            }
        } catch(Exception e){
            System.debug('>>>> SOMETHING GOES WRONG');
            System.debug('> ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
        }	

    }
    
    public static Map<String, String> generateRegionsMap(Map<String, String> regionsMap){

        //regionCode => number
        //regionsMap.put('0', 'allRegions');

        //regionCode => number
        regionsMap.put('13', 'Abruzzo');
        regionsMap.put('17', 'Basilicata');
        regionsMap.put('18', 'Calabria');
        regionsMap.put('15', 'Campania');
        regionsMap.put('8', 'Emilia-Romagna');
        regionsMap.put('6', 'Friuli-Venezia Giulia');
        regionsMap.put('12', 'Lazio');
        regionsMap.put('7', 'Liguria');
        regionsMap.put('3', 'Lombardia');
        regionsMap.put('11', 'Marche');
        regionsMap.put('14', 'Molise');
        regionsMap.put('1', 'Piemonte');
        regionsMap.put('16', 'Puglia');
        regionsMap.put('20', 'Sardegna');
        regionsMap.put('19', 'Sicilia');
        regionsMap.put('9', 'Toscana');
        regionsMap.put('4', 'Trentino-Alto Adige');
        regionsMap.put('10', 'Umbria');
        regionsMap.put('2', 'Valle d\'Aosta');
        regionsMap.put('5', 'Veneto');

        //regionCode => String
        //regionsMap.put('ABR', 'Abruzzo');
        //regionsMap.put('BA', 'Basilicata');
        //regionsMap.put('CAL', 'Calabria');
        //regionsMap.put('CAM', 'Campania');
        //regionsMap.put('EMR', 'Emilia-Romagna');
        //regionsMap.put('FVG', 'Friuli-Venezia Giulia');
        //regionsMap.put('LAZ', 'Lazio');
        //regionsMap.put('LIG', 'Liguria');
        //regionsMap.put('LO', 'Lombardia');
        //regionsMap.put('MAR', 'Marche');
        //regionsMap.put('MOL', 'Molise');
        //regionsMap.put('PIE', 'Piemonte');
        //regionsMap.put('PUG', 'Puglia');
        //regionsMap.put('SAR', 'Sardegna');
        //regionsMap.put('SIC', 'Sicilia');
        //regionsMap.put('TOS', 'Toscana');
        //regionsMap.put('TAA', 'Trentino-Alto Adige');
        //regionsMap.put('UMB', 'Umbria');
        //regionsMap.put('VDA', 'Valle d\'Aosta');
        //regionsMap.put('VEN', 'Veneto');
        return regionsMap;
    }

    public class HDT_WRP_MunicipalityObj {
        public List<HDT_WRP_Region> regionList;
    }

    public class HDT_WRP_Region {
        public String label;
        public String value;
        public Boolean eligibleForAllCities;
        public List<HDT_WRP_Province> provinceList;
    }

    public class HDT_WRP_Province{
        public String label;
        public String value;
        public Boolean isEnabled;
        public List<HDT_WRP_Municipality> cityAvailable;
        public List<HDT_WRP_Municipality> cityRemoved;
    }

    public class HDT_WRP_Municipality {
        public String label;
        public String value;
    }
    
}