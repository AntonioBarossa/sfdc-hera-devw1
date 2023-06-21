import { LightningElement, api, track } from 'lwc';

const JSON_COLUMNS = {
    'ASSOCIA_DOTAZIONI': [
                            {label:"Anagrafica TCP Name", fieldName:"Name"},
                            {label:"Codice Dotazione", fieldName:"EquipmentCode__c", type:"Text"},
                            {label:"Tipologia", fieldName:"Type__c", type:"Text"},
                            {label:"Volumetria", fieldName:"Volumetry__c", type:"Text"},
                            {label:"Stato Dotazione", fieldName:"Status__c", type:"Text"}
                        ],
    }

export default class HdtCustomDataTableFlow extends LightningElement {

    @api records;
    @api processType;
    @api objects;
    showTable = false;
    showErrorMessage = false;

    connectedCallback(){
        console.log('@@@@: '+this.records);
        this.columns = JSON_COLUMNS[this.processType];
        this.showTable = true;
        if(this.records == undefined || this.records == null || this.records.length == 0){
            this.showErrorMessage = true;
        }
    }


}