import { LightningElement, track, wire, api } from 'lwc';
import getFields from '@salesforce/apex/HDT_LC_RecordCommodityViewForm.getFields';

export default class HdtRecordCommodityViewForm extends LightningElement {

    // @api processType;
    @api recordId;
    @api objectApiName;

    // @api density;
    // @api showReadOnly;

    // @track errorMessage;
    // @track error;
    // @track fieldsJSON;
    // @track wiredResponse;
    // @track firstColumn = [];
    // @track secondColumn = [];
    // @track showViewSection = false;

    // @track fieldsJSONReadOnly;
    // @track firstColumnReadOnly = [];
    // @track secondColumnReadOnly = [];

    @track fields;
    // columnList = [];
    // fieldList = [];

        connectedCallback()
        {
            console.log('### START connected 2');
            console.log('refresh 4');
            getFields({ recordId: this.recordId })
            .then(result => {
                console.log('result:'+ result);
                if (result) {
                    let parsedResult = JSON.parse(result);
                    // console.log('parsedResult:'+ parsedResult);
                    this.fields = JSON.parse(parsedResult.FieldsJSON__c);
                    console.log('fields:'+ this.fields);
                }
            })//.catch(error => {
            //     console.log(error);
            //     this.error = error;
            // }); 
            // console.log('### ProcessType -> ' + this.processType);
            console.log('### RecordId -> ' + this.recordId);
            console.log('### Object Name -> ' + this.objectApiName);
            console.log('### END Connected ###');
        }
}