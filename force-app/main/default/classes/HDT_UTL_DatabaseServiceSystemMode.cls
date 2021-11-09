/**
 * @author            : Andrei Necsulescu - (andrei.necsulescu@webresults.it)
 * @description       : HDT_UTL_DatabaseServiceSystemMode - class for dml operations without checks
 * @last modified on  : 11-09-2021
**/

public inherited sharing class HDT_UTL_DatabaseServiceSystemMode {
    
    public List<Sobject> insertSobject(List<Sobject> objects) {
        
        insert objects;        

        return objects;

    }

    public List<Sobject> updateSobjectate(List<Sobject> objects) {

        update objects;

        return objects;

    }

    public List<Sobject> deleteSobject(List<Sobject> objects) {

        delete objects;

        return objects;

    }

    public List<Sobject> upsertSobject(List<Sobject> objects) {

        upsert objects;

        return objects;

    }
    
}
