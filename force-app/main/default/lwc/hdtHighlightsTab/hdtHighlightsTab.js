import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ROOT_CLC from '@salesforce/schema/Account.CustomerLifeCycle__c';
import ENERGY_CLC from '@salesforce/schema/Account.CustomerLifeCycleEnergy__c';
import EE_CLC from '@salesforce/schema/Account.CustomerLifeCycleEle__c';
import GAS_CLC from '@salesforce/schema/Account.CustomerLifeCycleGas__c';
import VAS_CLC from '@salesforce/schema/Account.CustomerLifeCycleVAS__c';

import getKpis from '@salesforce/apex/HDT_LC_HighlightsTab.getKpis';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [
    'DataEnrichmentLastUpdate__c',
    'AssistedCustomer__c',
    'ChurnkRisk__c',
    'AccountRating__c'
];

var items = [{
    "label": "Customer Life Cycle: ",
    "name": "clc",
    "expanded": true,
    "items": [{
        "label": "Life Cycle Energy: ",
        "name": "clcEnergy",
        "expanded": true,
        "items": [{
            "label": "Commodity Life Cycle EE: ",
            "name": "clcEE",
            "expanded": true,
            "items" :[]
        }, {
            "label": "Commodity Life Cycle Gas: ",
            "name": "clcGas",
            "expanded": true,
            "items" :[]
        }, {
            "label": "Commodity Life Cycle VAS: ",
            "name": "clcVAS",
            "expanded": true,
            "items" :[]
        }]
    }]
}];

export default class HdtHighlightsTab extends LightningElement {
    
    @api recordId;
    @track record;
    @track wireError;
    @track fields = fields;
    @track openCasesNumber;
    @track openOptyNumber;
    @track koCasesNumber;
    @track clcItems;

    gridClass = '';

    @wire(getRecord, { recordId: '$recordId', fields: [ROOT_CLC, ENERGY_CLC, EE_CLC, GAS_CLC, VAS_CLC] })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            this.wireError = undefined;
            this.updateClc();
        } else if (error) {
            console.log('wire failed to fetch data: ' + error);
            this.wireError = error;
            this.record = undefined;
        }
    }

    connectedCallback() {
        this.gridClass = 'slds-col slds-size_1-of-' + fields.length.toString();
        this.doGetKpis();
    }

    async doGetKpis() {
        const result = await getKpis({accountId: this.recordId});
        if(result.error) {
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: 'Errore',
                message: result.error,
            }));
        } else {
            this.openOptyNumber = result.opportunities;
            this.openCasesNumber = result.dossier_open;
            this.koCasesNumber = result.dossier_ko;
        }
    }

    updateClc() {

        this.updateClcLabel(items[0], this.record.fields.CustomerLifeCycle__c);
        this.updateClcLabel(items[0].items[0], this.record.fields.CustomerLifeCycleEnergy__c);
        this.updateClcLabel(items[0].items[0].items[0], this.record.fields.CustomerLifeCycleEle__c);
        this.updateClcLabel(items[0].items[0].items[1], this.record.fields.CustomerLifeCycleGas__c);
        this.updateClcLabel(items[0].items[0].items[2], this.record.fields.CustomerLifeCycleVAS__c);

        this.clcItems = items;

    } 

    updateClcLabel(clcObject, clcField) {
        var clcValue = clcField.value;
        if (clcValue == null) {
            clcValue = 'N/A';
        } 

        clcObject.label += clcValue;
    }
}