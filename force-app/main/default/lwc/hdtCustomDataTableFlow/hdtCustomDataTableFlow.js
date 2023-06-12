import { LightningElement, api, track } from 'lwc';

export default class HdtCustomDataTableFlow extends LightningElement {

    @api records;
    @api objects;
    @api jsonColumns;
    showTable = false;
    showErrorMessage = false;

    /*
    
    jsonColumns example:

    [
        { "label": "Anagrafica TCP Name", "fieldName": "Name" },
        { "label": "Codice Dotazione", "fieldName": "EquipmentCode__c", "type": "Text" },
        { "label": "Tipologia", "fieldName": "Type__c", "type": "Text" },
        { "label": "Codice Impianto", "fieldName": "ImplantCode__c", "type": "Text" }
    ]

    */

    connectedCallback(){
        console.log('@@@@: '+this.records);
        this.columns = JSON.parse(this.jsonColumns);
        this.showTable = true;
        if(this.records == undefined || this.records == null || this.records.length == 0){
            this.showErrorMessage = true;
        }
    }


}